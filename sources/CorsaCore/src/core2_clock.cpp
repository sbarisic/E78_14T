#include <core2.h>
#include <rtc.h>

#define _tzset tzset

// @brief Get seconds since boot
int32_t core2_clock_bootseconds()
{
    return (int32_t)(esp_timer_get_time() / 1000000);
}

// @brief Seconds since lastTime
int32_t core2_clock_seconds_since(int32_t lastTime)
{
    return core2_clock_bootseconds() - lastTime;
}

// @brief Formats time to DD.MM.YYYY. HH:MM:SS, buffer requires 20 chars
void core2_clock_time_now(char *strftime_buf)
{
    // dprintf("core2_clock_time_now()\n");
    time_t now = time(NULL);
    struct tm *timeinfo = localtime(&now);
    strftime(strftime_buf, 21, "%d.%m.%Y. %H:%M:%S", timeinfo);
    // dprintf("%s\n", strftime_buf);
}

void core2_clock_time_fmt(char *strftime_buf, size_t max_size, const char* fmt)
{
    time_t now = time(NULL);
    struct tm *timeinfo = localtime(&now);
    strftime(strftime_buf, max_size, fmt, timeinfo);
}

void core2_clock_update_from_ntp()
{
    const char *ntpServer = "pool.ntp.org";
    const long gmtOffset_sec = 3600;
    const int daylightOffset_sec = 3600;
    configTime(gmtOffset_sec, daylightOffset_sec, ntpServer);

    vTaskDelay(pdMS_TO_TICKS(10));

    struct tm timeinfo;
    while (!getLocalTime(&timeinfo))
    {
        vTaskDelay(pdMS_TO_TICKS(50));
    }

    setenv("TZ", "UTC-2", 1);
    _tzset();
}

bool core2_clock_init()
{
    dprintf("core2_clock_init()\n");

    core2_wifi_yield_until_connected();
    core2_clock_update_from_ntp();
    return true;
}