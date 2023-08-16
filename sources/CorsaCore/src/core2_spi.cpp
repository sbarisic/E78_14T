#include <core2.h>

#include "esp_vfs_fat.h"

#include <driver/spi_common_internal.h>
#include <SPI.h>

bool core2_spi_create(sdmmc_host_t *host, int MOSI, int MISO, int CLK)
{
    dprintf("core2_spi_create(MOSI = %d, MISO = %d, CLK = %d)\n", MOSI, MISO, CLK);

    sdmmc_host_t temp_host = SDSPI_HOST_DEFAULT();
    *host = temp_host;

    spi_bus_config_t bus_cfg = {
        .mosi_io_num = MOSI,
        .miso_io_num = MISO,
        .sclk_io_num = CLK,
        .quadwp_io_num = -1,
        .quadhd_io_num = -1,
        .max_transfer_sz = 4000,
    };

    /*if (spi_bus_get_attr((spi_host_device_t)host->slot) != NULL)
    {
        dprintf("spi_bus_get_attr() - SPI bus already initialized\n");
        return true;
    }*/

    esp_err_t ret = spi_bus_initialize((spi_host_device_t)host->slot, &bus_cfg, SDSPI_DEFAULT_DMA);

    if (ret != ESP_OK)
    {
        dprintf("core2_spi_create() - Failed to initialize bus\n");
        return false;
    }

    return true;
}

bool core2_spi_init()
{
    dprintf("core2_spi_init()\n");

    SPI.begin(MCP320X_PIN_CLK, MCP320X_PIN_MISO, MCP320X_PIN_MOSI, MCP320X_PIN_CS);

    return true;
}