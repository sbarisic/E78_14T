#include <core2.h>

#ifndef CORE2_DEBUG_WIFI
#undef dprintf
#define dprintf(...)
#endif

#define PRF "c2_wifi_task() "
#define PRF_STAT "WiFi.Status ="

IPAddress IP;
bool ConnectionValid;
int32_t LastBeginConnect;
int32_t NextConnectWaitTime;

bool IsInAccessPointMode;

const char *SSIDs[] = {"Barisic", "TEST69", "Serengeti", "TEST"};
const char *PASSs[] = {"123456789", "123456789", "srgt#2018", "123456789"};

bool ConnectionContains(const char *SSID, const char **PASS)
{
    *PASS = NULL;

    for (size_t i = 0; i < (sizeof(SSIDs) / sizeof(*SSIDs)); i++)
    {
        if (strcmp(SSID, SSIDs[i]) == 0)
        {
            *PASS = PASSs[i];
            return true;
        }
    }

    return false;
}

bool c2_wifi_begin_connect(int32_t NextConnectWaitTime)
{
    if (core2_clock_seconds_since(LastBeginConnect) < NextConnectWaitTime)
        return false;

    LastBeginConnect = core2_clock_bootseconds();

    int found = WiFi.scanNetworks();
    for (int i = 0; i < found; i++)
    {
        String ssid = WiFi.SSID(i);
        const char *SSID = ssid.c_str();
        const char *PASS;

        dprintf("c2_wifi_begin_connect - found '%s'\n", SSID);

        if (ConnectionContains(SSID, &PASS))
        {
            dprintf("c2_wifi_begin_connect(%d) SSID: %s\n", NextConnectWaitTime, SSID);
            WiFi.mode(WIFI_STA);
            WiFi.begin(SSID, PASS);
            return true;
        }
    }

    return false;
}

bool core2_wifi_ap_start()
{
    dprintf("core2_wifi_ap_start()\n");
    IsInAccessPointMode = true;

    // TODO: Move to separate config
    IPAddress local_ip(192, 168, 1, 42);
    IPAddress gateway(192, 168, 1, 1);
    IPAddress subnet(255, 255, 255, 0);

    if (!WiFi.softAPConfig(local_ip, gateway, subnet))
    {
        dprintf("core2_wifi_ap_start() - WiFi Access Point Config FAIL\n");
        return false;
    }

    // TODO: Move to separate config
    if (!WiFi.softAP("core2_wifi_devtest", "core21234"))
    {
        dprintf("core2_wifi_ap_start() - WiFi Access Point FAIL\n");
        return false;
    }

    String ip = WiFi.softAPIP().toString();
    dprintf("core2_wifi_ap_start() - %s\n", ip.c_str());

    dprintf("core2_wifi_ap_start() OK\n");
    return true;
    // WiFi.softAPConfig()
}

bool core2_wifi_ap_stop()
{
    dprintf("core2_wifi_ap_stop()\n");
    IsInAccessPointMode = false;

    WiFi.softAPdisconnect(true);
    return true;
}

void c2_wifi_task(void *params)
{
    dprintf("c2_wifi_task() STARTED\n");
    wl_status_t LastWiFiStatus = (wl_status_t)-1;

    for (;;)
    {
        wl_status_t WiFiStatus = WiFi.status();

        switch (WiFiStatus)
        {
            // Idle status, do nothing
        case WL_IDLE_STATUS:
            if (LastWiFiStatus != WL_IDLE_STATUS)
                dprintf(PRF_STAT " WL_IDLE_STATUS \n");

            NextConnectWaitTime = 10;
            break;

            // SSID not found
        case WL_NO_SSID_AVAIL:
            if (LastWiFiStatus != WL_NO_SSID_AVAIL)
                dprintf(PRF_STAT " WL_NO_SSID_AVAIL \n");

            ConnectionValid = false;
            NextConnectWaitTime = 10;
            break;

        case WL_SCAN_COMPLETED:
            if (LastWiFiStatus != WL_SCAN_COMPLETED)
                dprintf(PRF_STAT " WL_SCAN_COMPLETED \n");

            break;

        case WL_CONNECTED:
            if (LastWiFiStatus != WL_CONNECTED)
                dprintf(PRF_STAT " WL_CONNECTED \n");

            if (!ConnectionValid)
            {
                ConnectionValid = true;
                IP = WiFi.localIP();
                dprintf(PRF "IP = %s\n", IP.toString().c_str());
            }

            break;

        case WL_CONNECT_FAILED:
            if (LastWiFiStatus != WL_CONNECT_FAILED)
                dprintf(PRF_STAT " WL_CONNECT_FAILED \n");

            ConnectionValid = false;
            NextConnectWaitTime = 20;
            break;

        // TODO: Handle losing connection
        case WL_CONNECTION_LOST:
            if (LastWiFiStatus != WL_CONNECTION_LOST)
                dprintf(PRF_STAT " WL_CONNECTION_LOST \n");

            ConnectionValid = false;
            NextConnectWaitTime = 20;
            break;

        // TODO: Handle disconnect
        case WL_DISCONNECTED:
            if (LastWiFiStatus != WL_DISCONNECTED)
                dprintf(PRF_STAT " WL_DISCONNECTED \n");

            ConnectionValid = false;
            NextConnectWaitTime = 20;
            break;

        case WL_NO_SHIELD:
            if (LastWiFiStatus != WL_NO_SHIELD)
                dprintf(PRF_STAT " WL_NO_SHIELD \n");

            ConnectionValid = false;
            NextConnectWaitTime = 2;
            break;

        default:
            if (WiFiStatus != LastWiFiStatus)
                dprintf(PRF_STAT " DEFAULT(%d) \n", WiFiStatus);

            ConnectionValid = false;
            NextConnectWaitTime = 30;
            break;
        }

        if (!ConnectionValid)
        {
            c2_wifi_begin_connect(NextConnectWaitTime);
        }

        LastWiFiStatus = WiFiStatus;
        vTaskDelay(pdMS_TO_TICKS(2000));
    }
}

bool core2_wifi_isconnected()
{
    return ConnectionValid;
}

IPAddress core2_wifi_getip()
{
    return IP;
}

// @brief Yields task, continues execution as soon as wifi is available
void core2_wifi_yield_until_connected()
{
    while (!core2_wifi_isconnected())
    {
        vTaskDelay(pdMS_TO_TICKS(100));
    }
}

bool core2_wifi_init()
{
    dprintf("core2_wifi_init()\n");

    ConnectionValid = false;
    IsInAccessPointMode = false;
    LastBeginConnect = core2_clock_bootseconds();
    NextConnectWaitTime = 0;

    xTaskCreate(c2_wifi_task, "c2_wifi_task", 4096, NULL, 1, NULL);
    return true;
}
