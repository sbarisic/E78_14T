#include <core2.h>

#include <freertos/FreeRTOS.h>
#include <freertos/task.h>
#include <esp_chip_info.h>
#include <esp_flash.h>
#include <nvs_flash.h>
#include <rtc.h>

#include <esp_netif.h>
#include <esp_sntp.h>
#include <string.h>

void core2_init()
{
    dprintf("core2_init()\n");

    // Initialize NVS
    esp_err_t ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND)
    {
        dprintf("Doing nvs_flash_erase()\n");
        ESP_ERROR_CHECK(nvs_flash_erase());
        ret = nvs_flash_init();
    }
}

void core2_print_status()
{
    /* Print chip information */
    esp_chip_info_t chip_info;
    uint32_t flash_size;

    esp_chip_info(&chip_info);

    dprintf("This is %s chip with %d CPU core(s), WiFi%s%s, ",
            CONFIG_IDF_TARGET,
            chip_info.cores,
            (chip_info.features & CHIP_FEATURE_BT) ? "/BT" : "",
            (chip_info.features & CHIP_FEATURE_BLE) ? "/BLE" : "");

    unsigned major_rev = chip_info.revision / 100;
    unsigned minor_rev = chip_info.revision % 100;

    dprintf("silicon revision v%d.%d, ", major_rev, minor_rev);
    if (esp_flash_get_size(NULL, &flash_size) != ESP_OK)
    {
        dprintf("Get flash size failed");
        return;
    }

    dprintf("%luMB %s flash\n", flash_size / (1024 * 1024), (chip_info.features & CHIP_FEATURE_EMB_FLASH) ? "embedded" : "external");
    dprintf("Minimum free heap size: %ld bytes\n", esp_get_minimum_free_heap_size());
}

SemaphoreHandle_t core2_lock_create()
{
    SemaphoreHandle_t lock = xSemaphoreCreateBinary();
    xSemaphoreGive(lock);
    return lock;
}

bool core2_lock_begin(SemaphoreHandle_t lock)
{
    return xSemaphoreTake(lock, portMAX_DELAY);
}

bool core2_lock_end(SemaphoreHandle_t lock)
{
    return xSemaphoreGive(lock);
}

xQueueHandle core2_queue_create(int count, int elementSize)
{
    return xQueueCreate(count, elementSize);
}

BaseType_t core2_queue_send(xQueueHandle q, const void *item)
{
    if (xPortInIsrContext())
    {
        return xQueueSendFromISR(q, item, NULL);
    }
    else
    {
        return xQueueSend(q, item, portMAX_DELAY);
    }
}

BaseType_t core2_queue_receive(xQueueHandle q, void *buffer)
{
    if (xPortInIsrContext())
    {
        return xQueueReceiveFromISR(q, buffer, NULL);
    }
    else
    {
        return xQueueReceive(q, buffer, portMAX_DELAY);
    }
}

void core2_queue_reset(xQueueHandle q)
{
    xQueueReset(q);
}

// @brief Expects 30 byte buffer
void core2_err_tostr(esp_err_t err, char *buffer)
{
#define MAKE_CASE(err)        \
    case err:                 \
        strcpy(buffer, #err); \
        break

    switch (err)
    {
        MAKE_CASE(ESP_OK);
        MAKE_CASE(ESP_FAIL);
        MAKE_CASE(ESP_ERR_NO_MEM);
        MAKE_CASE(ESP_ERR_INVALID_ARG);
        MAKE_CASE(ESP_ERR_INVALID_STATE);
        MAKE_CASE(ESP_ERR_INVALID_SIZE);
        MAKE_CASE(ESP_ERR_NOT_FOUND);
        MAKE_CASE(ESP_ERR_NOT_SUPPORTED);
        MAKE_CASE(ESP_ERR_TIMEOUT);

        MAKE_CASE(ESP_ERR_INVALID_RESPONSE);
        MAKE_CASE(ESP_ERR_INVALID_CRC);
        MAKE_CASE(ESP_ERR_INVALID_VERSION);
        MAKE_CASE(ESP_ERR_INVALID_MAC);
        MAKE_CASE(ESP_ERR_NOT_FINISHED);

        MAKE_CASE(ESP_ERR_WIFI_BASE);
        MAKE_CASE(ESP_ERR_MESH_BASE);
        MAKE_CASE(ESP_ERR_FLASH_BASE);
        MAKE_CASE(ESP_ERR_HW_CRYPTO_BASE);
        MAKE_CASE(ESP_ERR_MEMPROT_BASE);

    default:
        strcpy(buffer, "UNKNOWN");
        break;
    }
}

void *core2_malloc(size_t sz)
{
    void *ptr = malloc(sz);

    if (ptr == NULL)
    {
        eprintf("malloc(%zu) failed", sz);
    }

    return ptr;
}

void core2_free(void *ptr)
{
    free(ptr);
}

char *core2_string_concat(const char *a, const char *b)
{
    size_t len = strlen(a) + strlen(b) + 1;
    char *res = (char *)core2_malloc(len);

    if (res == NULL)
        return NULL;

    memset(res, 0, len);
    strcpy(res, a);
    strcat(res, b);

    return res;
}

bool core2_string_ends_with(const char *str, const char *end)
{
    if (str == NULL || end == NULL)
        return false;

    size_t lenstr = strlen(str);
    size_t lensuffix = strlen(end);

    if (lensuffix > lenstr)
        return false;

    return strncmp(str + lenstr - lensuffix, end, lensuffix) == 0;
}