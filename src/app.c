#include "main.h"
#include "cmsis_os.h"

#define THREAD_STACK_SIZE   configMINIMAL_STACK_SIZE
#define QUEUE_SIZE        (uint32_t) 1

osMessageQId osQueue;
uint32_t producer_value = 0, consumer_value = 0;
__IO uint32_t producer_errors = 0, consumer_errors = 0;

static void msg_queue_producer(const void *argument);
static void msg_queue_consumer(const void *argument);

void system_clk_config(void);

int main(void)
{
    HAL_Init();

    system_clk_config();

    BSP_LED_Init(LED2);

    osMessageQDef(osqueue, QUEUE_SIZE, uint16_t);
    osQueue = osMessageCreate(osMessageQ(osqueue), NULL);

    osThreadDef(QCons, msg_queue_consumer, osPriorityBelowNormal, 0, THREAD_STACK_SIZE);
    osThreadCreate(osThread(QCons), NULL);

    osThreadDef(QProd, msg_queue_producer, osPriorityBelowNormal, 0, THREAD_STACK_SIZE);
    osThreadCreate(osThread(QProd), NULL);

    osKernelStart();

    while (1);
}

static void msg_queue_producer(const void *argument)
{
    while (1) {
        if (osMessagePut(osQueue, producer_value, 100) != osOK) {
            ++producer_errors;
            BSP_LED_On(LED2);
        } else {
            ++producer_value;

            if ((producer_errors == 0) && (consumer_errors == 0)) {
                BSP_LED_Toggle(LED2);
            }
            osDelay(1000);
        }
    }
}

static void msg_queue_consumer(const void *argument)
{
    osEvent event;

    while (1) {
        event = osMessageGet(osQueue, 100);

        if (event.status == osEventMessage) {
            if (event.value.v != consumer_value) {
                consumer_value = event.value.v;
                ++consumer_errors;

                BSP_LED_On(LED2);
            }
            else {
                ++consumer_value;
            }
        }
    }
}

void system_clk_config(void)
{
    RCC_ClkInitTypeDef rcc_clk_init;
    RCC_OscInitTypeDef rcc_osc_init;

    rcc_osc_init.OscillatorType = RCC_OSCILLATORTYPE_NONE;
    rcc_osc_init.PLL.PLLState = RCC_PLL_ON;
    rcc_osc_init.PLL.PLLSource = RCC_PLLSOURCE_HSI;
    rcc_osc_init.PLL.PREDIV = RCC_PREDIV_DIV2;
    rcc_osc_init.PLL.PLLMUL = RCC_PLL_MUL16;
    rcc_osc_init.HSICalibrationValue = RCC_HSICALIBRATION_DEFAULT;

    if (HAL_RCC_OscConfig(&rcc_osc_init)!= HAL_OK) {
        while(1);
    }

    rcc_clk_init.ClockType = (RCC_CLOCKTYPE_SYSCLK
                              | RCC_CLOCKTYPE_HCLK
                              | RCC_CLOCKTYPE_PCLK1
                              | RCC_CLOCKTYPE_PCLK2);

    rcc_clk_init.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
    rcc_clk_init.AHBCLKDivider = RCC_SYSCLK_DIV1;
    rcc_clk_init.APB1CLKDivider = RCC_HCLK_DIV2;
    rcc_clk_init.APB2CLKDivider = RCC_HCLK_DIV1;

    if (HAL_RCC_ClockConfig(&rcc_clk_init, FLASH_LATENCY_2)!= HAL_OK) {
        while(1);
    }
}

