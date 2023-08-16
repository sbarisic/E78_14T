#include <core2.h>

#include <string.h>
#include <sys/unistd.h>
#include <sys/stat.h>

#define DATA_STORE_PARTITION_TYPE ((esp_partition_type_t)0x42)
#define DATA_STORE_PARTITION_SUBTYPE (ESP_PARTITION_SUBTYPE_ANY)

const esp_partition_t *part;

bool core2_flash_init()
{
    dprintf("core2_flash_init()\n");


    part = esp_partition_find_first(DATA_STORE_PARTITION_TYPE, DATA_STORE_PARTITION_SUBTYPE, NULL);

    if (part == NULL)
    {
        dprintf("esp_partition_find_first() = NULL\n");
        return false;
    }
    else
    {
        dprintf("esp_partition_find_first() = Found Data Store!\n");
    }

    return true;
}
