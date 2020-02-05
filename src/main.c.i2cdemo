#include "main.h"
#include "cmsis_os.h"

#define THREAD_STACK_SIZE   configMINIMAL_STACK_SIZE
#define QUEUE_SIZE        (uint32_t) 1

#define I2C_ADDRESS        0x30F
#define I2C_TIMING      0x00400B27
#define RXBUFFERSIZE 1024
#define TXBUFFERSIZE 1024

osMessageQId osQueue;
uint32_t producer_value = 0, consumer_value = 0;
__IO uint32_t producer_errors = 0, consumer_errors = 0;

static void msg_queue_producer(const void *argument);
static void msg_queue_consumer(const void *argument);

static void error_handler(void);
void system_clk_config(void);

uint8_t aRxBuffer[RXBUFFERSIZE] = {"testing"};
uint8_t aTxBuffer[TXBUFFERSIZE];
I2C_HandleTypeDef I2cHandle;

static void i2c_master_handler(void);
#if MASTER_BOARD
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
#else
int main(void)
{
    HAL_Init();

    system_clk_config();

    BSP_LED_Init(LED2);

    while (1) {
        i2c_slave_handler();
        HAL_Delay(50);
    }
}
#endif

static void msg_queue_producer(const void *argument)
{
    while (1) {
        i2c_master_handler();
        HAL_Delay(50);
    }
}

char reg[] = {1,2,3,4,5};
static void msg_queue_consumer(const void *argument)
{
    osEvent event;

    while (1) {
        event = osMessageGet(osQueue, 100);

        if (event.status == osEventMessage) {
            if (event.value.v == reg[0]) {
                BSP_LED_On(LED2);
            } else if (event.value.v == reg[4]){
                BSP_LED_Off(LED2);
            }
        }
    }
}

static void init_i2c(void)
{
    I2cHandle.Instance             = I2C1;
    I2cHandle.Init.Timing          = I2C_TIMING;
    I2cHandle.Init.OwnAddress1     = I2C_ADDRESS;
    I2cHandle.Init.AddressingMode  = I2C_ADDRESSINGMODE_10BIT;
    I2cHandle.Init.DualAddressMode = I2C_DUALADDRESS_DISABLE;
    I2cHandle.Init.OwnAddress2     = 0xFF;
    I2cHandle.Init.GeneralCallMode = I2C_GENERALCALL_DISABLE;
    I2cHandle.Init.NoStretchMode   = I2C_NOSTRETCH_DISABLE;

    if (HAL_I2C_Init(&I2cHandle) != HAL_OK) {
        error_handler();
    }

    HAL_I2CEx_ConfigAnalogFilter(&I2cHandle,I2C_ANALOGFILTER_ENABLE);
}

const uint8_t I2C_REG1 = 0x05;

//
// Request a register content from slave device
// And add it to the queue
//
static void i2c_master_handler(void)
{
    uint8_t rxbuf;
    static char i2c_reg = 0;
    if (i2c_reg > (sizeof(reg) - 1)) {
        i2c_reg = 0;
    }
    // Pingpong communition we send a message out and expect to get the same
    // message returned

#if 0
    do {
        if(HAL_I2C_Master_Transmit_IT(&I2cHandle,
            (uint16_t)I2C_ADDRESS, (uint8_t*)&I2C_REG1,
            sizeof(I2C_REG1))!= HAL_OK) {
            error_handler();
        }

        while (HAL_I2C_GetState(&I2cHandle) != HAL_I2C_STATE_READY) {
        }
    } while (HAL_I2C_GetError(&I2cHandle) == HAL_I2C_ERROR_AF);

    do {
        if (HAL_I2C_Master_Receive_IT(&I2cHandle,
            (uint16_t)I2C_ADDRESS, rxbuf,
            sizeof(rxbuf)) != HAL_OK) {
            error_handler();
        }

        while (HAL_I2C_GetState(&I2cHandle) != HAL_I2C_STATE_READY) {
        }
    } while (HAL_I2C_GetError(&I2cHandle) == HAL_I2C_ERROR_AF);
#endif
    if (osMessagePut(osQueue, reg[i2c_reg], sizeof(char)) != osOK) {
        error_handler();
    }

    i2c_reg++;
}

//
// The board receives the message and sends it back
//
void i2c_slave_handler()
{
    char req_register = -1;
    if(HAL_I2C_Slave_Receive_IT(&I2cHandle, &req_register,
        sizeof(req_register)) != HAL_OK) {
        error_handler();
    }

    while (HAL_I2C_GetState(&I2cHandle) != HAL_I2C_STATE_READY) {
    }

    if (req_register >= 0) {
        if(HAL_I2C_Slave_Transmit_IT(&I2cHandle, &reg[req_register],
            sizeof(char))!= HAL_OK) {
            error_handler();
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

static void error_handler(void)
{
    while(1) {
        BSP_LED_Toggle(LED2);
        HAL_Delay(1000);
    }
}
