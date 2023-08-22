#include <freertos/FreeRTOS.h>
#include <freertos/semphr.h>
#include <freertos/queue.h>
#include <WiFi.h>
#include "driver/sdmmc_host.h"

// Entry Point
void core2_main();

// Default defines
// =================================================================================================

#define CORE2_DEBUG
#define CORE2_DEBUG_WIFI

// Uncomment to disable compilation of modules
#define CORE2_DISABLE_MCP320X
#define CORE2_DISABLE_OLED

// Uncomment to disable complilation and calling of test functions
#define CORE2_OMIT_TESTS

#ifdef CORE2_DEBUG
#define dprintf printf
#else
#define dprintf(...)
#endif

#define eprintf(...)         \
    do                       \
    {                        \
        printf("[ERROR] ");  \
        printf(__VA_ARGS__); \
        printf("\n");        \
    } while (0)

// #define CORE2_FILESYSTEM_VERBOSE_OUTPUT // Prints very long debug outputs to the output stream
#define CORE2_FILESYSTEM_SIMPLE_OUTPUT // Prints simple debug outputs to the output stream

// SD SPI pin config
// =================================================================================================

#define SDCARD_PIN_MOSI GPIO_NUM_13 // GPIO_NUM_23 // GPIO_NUM_15
#define SDCARD_PIN_MISO GPIO_NUM_12 // GPIO_NUM_35 // GPIO_NUM_2
#define SDCARD_PIN_CLK GPIO_NUM_14  // GPIO_NUM_32 // GPIO_NUM_14
#define SDCARD_PIN_CS GPIO_NUM_15   // GPIO_NUM_25 // GPIO_NUM_13

// MCP320X SPI pin config
// =================================================================================================

#define MCP320X_PIN_MOSI -1
#define MCP320X_PIN_MISO -1
#define MCP320X_PIN_CLK -1
#define MCP320X_PIN_CS -1

#define MCP320X_CS_CHANNEL1 GPIO_NUM_4
#define MCP320X_CS_CHANNEL2 GPIO_NUM_5

#define MCP320X_ADC_VREF 3311   // 3.3V Vref
#define MCP320X_ADC_CLK 1600000 // 1600000  // SPI clock 1.6MHz

// Core
// =================================================================================================

void core2_init();
void core2_print_status();

SemaphoreHandle_t core2_lock_create();
bool core2_lock_begin(SemaphoreHandle_t lock);
bool core2_lock_end(SemaphoreHandle_t lock);

xQueueHandle core2_queue_create(int count, int elementSize);
BaseType_t core2_queue_send(xQueueHandle q, const void *item);
BaseType_t core2_queue_receive(xQueueHandle q, void *buffer);
void core2_queue_reset(xQueueHandle q);

void core2_err_tostr(esp_err_t err, char *buffer);

void *core2_malloc(size_t sz);
void *core2_realloc(void *ptr, size_t sz);
void core2_free(void *ptr);
char *core2_string_concat(const char *a, const char *b); // Should call core2_free() on result
bool core2_string_ends_with(const char *str, const char *end);

// OLED
// =================================================================================================

bool core2_oled_init();
void core2_oled_print(const char *txt);

// Wifi
// =================================================================================================

bool core2_wifi_init();
bool core2_wifi_isconnected();
IPAddress core2_wifi_getip();
void core2_wifi_yield_until_connected();
bool core2_wifi_ap_start();
bool core2_wifi_ap_stop();

// Clock
// =================================================================================================

bool core2_clock_init();
int32_t core2_clock_bootseconds();
int32_t core2_clock_seconds_since(int32_t lastTime);
void core2_clock_time_now(char *strftime_buf);
void core2_clock_time_fmt(char *strftime_buf, size_t max_size, const char *fmt);
void core2_clock_update_from_ntp();

// GPIO
// =================================================================================================

bool core2_gpio_init();
bool core2_gpio_get_interrupt0();
bool core2_gpio_set_interrupt0();
void core2_gpio_clear_interrupt0();

// Flash
// =================================================================================================

bool core2_flash_init();

// Filesystem
// =================================================================================================

typedef void (*onFileFoundFn)(const char *full_name, const char *file_name);

bool core2_filesystem_init(sdmmc_host_t *host, int CS);
FILE *core2_file_open(const char *filename, const char *type = NULL);
bool core2_file_close(FILE *f);
bool core2_file_move(const char *full_file_path, const char *new_directory);
bool core2_file_write(const char *filename, const char *data, size_t len);
bool core2_file_append(const char *filename, const char *data, size_t len);
bool core2_file_mkdir(const char *dirname, mode_t mode = 0);
void core2_file_list(const char *dirname, onFileFoundFn onFileFound);

// MCP320X ADC
// =================================================================================================

bool core2_mcp320x_init();
void core2_adc_read(float *Volt1, float *Volt2);

// SPI
// =================================================================================================

bool core2_spi_init();
bool core2_spi_create(sdmmc_host_t *host, int MOSI, int MISO, int CLK);

// JSON
// =================================================================================================

typedef enum
{
    CORE2_JSON_INVALID = 0,
    CORE2_JSON_FLOAT = 1,
    CORE2_JSON_STRING = 2,
    CORE2_JSON_FLOAT_ARRAY = 3
} core2_json_fieldtype_t;

bool core2_json_init();
void core2_json_begin();
void core2_json_end();

// Web
bool core2_web_json_post(const char *server_name, const char *json_txt, size_t json_txt_len);

// Shell
// =================================================================================================

void core2_shell_init();