#include <core2.h>

#define CHUNK_SIZE 512

char *buffer = NULL;
size_t buffer_len = 0;
size_t buffer_content_len = 0;
bool need_comma;

void core2_json_concat(const char *str)
{
    size_t str_len = strlen(str);

    if (str_len + buffer_content_len >= buffer_len)
    {
        // Make some space or somethin'
        buffer_len = str_len + buffer_content_len + CHUNK_SIZE;
        buffer = (char *)core2_realloc(buffer, buffer_len);
    }

    strcat(buffer, str);
    buffer_content_len = strlen(buffer);
}

void core2_json_begin()
{
    buffer = (char *)core2_malloc(CHUNK_SIZE);
    buffer_len = CHUNK_SIZE;
    buffer_content_len = 0;
    need_comma = false;

    core2_json_concat("{ ");
}

char *core2_json_escape_string(char *str)
{
    // TODO
    return str;
}

void core2_json_add_field(const char *field_name, void *data, size_t len, core2_json_fieldtype_t data_type)
{
    char temp_buffer[64];

    if (need_comma)
    {
        core2_json_concat(", \"");
    }
    else
    {
        core2_json_concat("\"");
    }

    core2_json_concat(field_name);
    core2_json_concat("\": ");

    switch (data_type)
    {
    case CORE2_JSON_STRING:
        core2_json_concat("\"");
        core2_json_concat(core2_json_escape_string(*(char **)data));
        core2_json_concat("\"");
        need_comma = true;
        break;

    case CORE2_JSON_FLOAT:
        // dtostrf(*(float *)data, 0, 2, temp_buffer);
        sprintf(temp_buffer, "%f", *(float *)data);

        core2_json_concat(temp_buffer);
        need_comma = true;
        break;

    case CORE2_JSON_FLOAT_ARRAY:
        core2_json_concat("[ ");

        for (size_t i = 0; i < len; i++)
        {
            // dtostrf(((float *)data)[i], 0, 2, temp_buffer);
            sprintf(temp_buffer, "%f", ((float *)data)[i]);

            core2_json_concat(temp_buffer);

            if (i < len - 1)
                core2_json_concat(", ");
        }

        core2_json_concat(" ]");
        need_comma = true;
        break;

    default:
        eprintf("core2_json_add_field unknown data_type %d\n", (int)data_type);
        break;
    }
}

void core2_json_serialize(char **dest_buffer, size_t *json_length)
{
    core2_json_concat(" }");

    if (dest_buffer != NULL && json_length != NULL)
    {
        *dest_buffer = (char *)core2_malloc(buffer_content_len + 1);
        *json_length = buffer_content_len;
        memcpy(*dest_buffer, buffer, buffer_content_len);

        core2_free(buffer);
        buffer = NULL;
        buffer_len = 0;
        buffer_content_len = 0;
    }
}

void core2_json_end(char **dest_buffer, size_t *json_length)
{
    core2_free(*dest_buffer);
    *dest_buffer = NULL;
    *json_length = 0;
}

#ifndef CORE2_OMIT_TESTS
void core2_json_test()
{
    char *json_buffer;
    size_t json_len;

    core2_json_begin();

    const char *field1 = "Ayy lmao";
    core2_json_add_field("field1", &field1, 0, CORE2_JSON_STRING);

    float field2 = 42.69f;
    core2_json_add_field("field2", &field2, 0, CORE2_JSON_FLOAT);

    float field3[] = {1.23f, 2.34f, 3, 4, 5};
    core2_json_add_field("field3", &field3, sizeof(field3) / sizeof(*field3), CORE2_JSON_FLOAT_ARRAY);

    core2_json_serialize(&json_buffer, &json_len);

    printf("======= core2_json_test =======\n");
    printf("%s\n", json_buffer);
    printf("===============================\n");

    core2_json_end(&json_buffer, &json_len);
}
#endif

bool core2_json_init()
{
    dprintf("core2_json_init()\n");

#ifndef CORE2_OMIT_TESTS
    core2_json_test();
#endif

    return true;
}