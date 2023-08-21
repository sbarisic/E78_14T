#include <core2.h>

void main_logic(void *params)
{
    dprintf("main_logic()\n");

    const char *JSON_txt = "{ \"APIKey\": \"OoDUEAxaDLE3L+tdG2ZWmvSNJ8A5jnzh9a4r4d4XzEw=\", \"Action\": 1, \"Napon1\": 16.789 }";
    size_t JSON_txt_len = strlen(JSON_txt);

    while (true)
    {
        // core2_web_json_post("https://demo.sbarisic.com/deviceaccess", JSON_txt, JSON_txt_len);
        vTaskDelay(pdMS_TO_TICKS(1000 * 5));
    }

    vTaskDelete(NULL);
}

void setup()
{
    core2_init();
    core2_print_status();

    core2_wifi_init();
    core2_clock_init();
    core2_json_init();
    core2_shell_init();

    // Start access point
    core2_wifi_ap_start();

    core2_wifi_yield_until_connected();
    dprintf("init() done\n");

    char cur_time[21];
    core2_clock_time_now(cur_time);
    dprintf("Current date time: %s\n", cur_time);

    xTaskCreate(main_logic, "main_logic", 1024 * 16, NULL, 1, NULL);

    vTaskDelay(pdMS_TO_TICKS(1000 * 20));
    core2_wifi_ap_stop();

    // Stop arduino task, job done
    vTaskDelete(NULL);
}

void loop()
{
}