#include <core2.h>

void main_logic(void *params)
{
    dprintf("main_logic()\n");

    while (true)
    {
        vTaskDelay(pdMS_TO_TICKS(1000));
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

    core2_wifi_yield_until_connected();
    dprintf("init() done\n");

    char cur_time[21];
    core2_clock_time_now(cur_time);
    dprintf("Current date time: %s\n", cur_time);

    xTaskCreate(main_logic, "main_logic", 1024 * 16, NULL, 1, NULL);

    // Stop arduino task, job done
    vTaskDelete(NULL);
}

void loop()
{
}