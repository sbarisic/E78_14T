#include <core2.h>
#include <driver/gpio.h>

xQueueHandle q_gpio0 = NULL;

bool core2_gpio_get_interrupt0()
{
    if (q_gpio0 == NULL)
        return false;

    int num;

    if (core2_queue_receive(q_gpio0, &num))
    {
        return true;
    }

    return false;
}

bool core2_gpio_set_interrupt0()
{
    if (q_gpio0 == NULL)
        return false;

    int num = 1;
    core2_queue_send(q_gpio0, &num);
    return true;
}

void core2_gpio_clear_interrupt0()
{
    if (q_gpio0 == NULL)
        return;

    core2_queue_reset(q_gpio0);
}

static void IRAM_ATTR gpio_interrupt_handler(void *args)
{
    gpio_num_t INT_PIN = (gpio_num_t)(int)args;

    if (INT_PIN == GPIO_NUM_0)
    {
        core2_gpio_set_interrupt0();
    }
}

QueueHandle_t CreateInterruptQueue()
{
    QueueHandle_t q = core2_queue_create(10, sizeof(int));
    return q;
}

void CreateInterrupt(gpio_num_t INPUT_PIN)
{
    gpio_pad_select_gpio(INPUT_PIN);
    gpio_set_direction(INPUT_PIN, GPIO_MODE_INPUT);
    gpio_pulldown_en(INPUT_PIN);
    gpio_pullup_dis(INPUT_PIN);
    gpio_set_intr_type(INPUT_PIN, GPIO_INTR_POSEDGE);

    gpio_isr_handler_add(INPUT_PIN, gpio_interrupt_handler, (void *)INPUT_PIN);
}

bool core2_gpio_init()
{
    dprintf("core2_gpio_init()\n");

    // Install global interrupt handler routine
    esp_err_t err = gpio_install_isr_service(0);

    char buf[30];
    core2_err_tostr(err, buf);
    dprintf("gpio_install_isr_service(0) = %s\n", buf);

    q_gpio0 = CreateInterruptQueue();
    CreateInterrupt(GPIO_NUM_0);
    return true;
}