
#include <core2.h>

#include <esp_wifi.h>
#include <esp_netif.h>
#include <esp_sntp.h>
#include <esp_tls.h>

#include <lwip/sockets.h>
#include <lwip/netdb.h>
#include <lwip/dns.h>

#include <WiFi.h>
#include <HTTPClient.h>

#define CORE2_WEB_USER_AGENT "Core2_ESP32"

bool core2_web_internet_available()
{
    dprintf("core2_web_internet_available - ");
    return false;
}

void core2_web_json_post_begin() {

}

void core2_web_json_post_end() {

}

bool core2_web_json_post(const char *server_name, const char *json_txt, size_t json_txt_len)
{
    dprintf("core2_http_json_post @ \"%s\" - ", server_name);

    HTTPClient http;
    http.begin(server_name);
    http.addHeader("Content-Type", "application/json");
    http.addHeader("User-Agent", CORE2_WEB_USER_AGENT);

    int postResult = http.POST((uint8_t *)json_txt, json_txt_len);
    dprintf("%d\n", postResult);

    if (postResult == HTTP_CODE_OK)
    {
        return true;
    }

    return false;
}
