INC_DIRS = inc
INC_DIRS += Drivers/STM32F3xx_HAL_Driver/Inc
INC_DIRS += Drivers/CMSIS/Device/ST/STM32F3xx/Include
INC_DIRS += Drivers/CMSIS/Core/Include
INC_DIRS += Drivers/BSP/STM32F3xx-Nucleo
INC_DIRS += Middlewares/Third_Party/FreeRTOS/Source/CMSIS_RTOS
INC_DIRS += Middlewares/Third_Party/FreeRTOS/Source/include
INC_DIRS += Middlewares/Third_Party/FreeRTOS/Source/portable/GCC/ARM_CM4F
INC_DIRS += Drivers/BSP/STM32303E_EVAL

#LD_FLAGS := -mthumb -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -std=gnu11 -DUSE_HAL_DRIVER -DSTM32F303xE -DUSE_STM32F3XX_NUCLEO -O0 -ffunction-sections -g -fstack-usage -Wall -fmessage-length=0 -specs=nano.specs
#LD_FLAGS := -lm -mthumb -mcpu=cortex-m3 -mfloat-abi=softfp -mfpu=fpv4-sp-d16 -TSW4STM32/STM32F303RE-Nucleo/STM32F303RETx_FLASH.ld -specs=nosys.specs -static -Wl,-cref,-u,Reset_Handler -Wl,-Map=STM32303C-EVAL_FreeRTOS_Simple_Demo.map -Wl,--gc-sections -Wl,--defsym=malloc_getpagesize_P=0x80 -Wl,--start-group -lc -lm -Wl,--end-group -specs=nano.specs

LD_FLAGS := -mthumb -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -std=gnu11 -DUSE_HAL_DRIVER -DSTM32F303xE -DUSE_STM32F3XX_NUCLEO -O0 -ffunction-sections -g -fstack-usage -Wall -fmessage-length=0 -Wno-unused-variable -Wno-pointer-sign -Wno-main -Wno-format -Wno-address -Wno-unused-but-set-variable -Wno-strict-aliasing -Wno-parentheses -Wno-missing-braces -specs=nano.specs -o Drivers/STM32F3xx_HAL_Driver/stm32f3xx_hal_cortex.o
LDS_FLAG := -mthumb -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -TSW4STM32/STM32F303RE-Nucleo/STM32F303RETx_FLASH.ld -O0 -specs=nosys.specs -static -Wl,-Map=STM32F303RE-Nucleo.map -Wl,--gc-sections -Wl,--defsym=malloc_getpagesize_P=0x80 -Wl,--start-group -lc -lm -Wl,--end-group -specs=nano.specs

STARTUP_FILE_IN := startup_stm32f303xe.s

VPATH = src
SRC_DIR := src

SRC_DIRS := $(SRC_DIR) Middlewares/Third_Party/FreeRTOS/Source/portable/GCC/ARM_CM4F
SRC_DIRS := $(SRC_DIRS) Middlewares/Third_Party/FreeRTOS/Source/portable/Common
SRC_DIRS := $(SRC_DIRS) Middlewares/Third_Party/FreeRTOS/Source/portable/MemMang
SRC_DIRS := $(SRC_DIRS) Middlewares/Third_Party/FreeRTOS/Source/CMSIS_RTOS
SRC_DIRS := $(SRC_DIRS) Middlewares/Third_Party/FreeRTOS/CMSIS_RTOS
SRC_DIRS := $(SRC_DIRS) Middlewares/Third_Party/FreeRTOS/Source
SRC_DIRS := $(SRC_DIRS) Drivers/STM32F3xx_HAL_Driver/Src
SRC_DIRS := $(SRC_DIRS) Drivers/BSP/STM32303E_EVAL
SRC_DIRS := $(SRC_DIRS) Drivers/STM32F3xx_HAL_Driver/Src

OBJ_DIR := obj

SRC_FILES := $(foreach dir,$(SRC_DIRS),$(wildcard $(dir)/*.c))
OBJ_FILES := $(patsubst %.c,$(OBJ_DIR)/%.o,$(SRC_FILES))
STARTUP_FILE_OUT := $(STARTUP_FILE_IN:.s=.o)

CFLAGS = -DSTM32F303xE
CFLAGS += -DUSE_STM32FXX_NUCLEO
#CFLAGS += -DconfigSUPPORT_DYNAMIC_ALLOCATION=1
CFLAGS += -DUSE_HAL_DRIVER

INCLUDE = $(addprefix -I,$(INC_DIRS))

testapp.elf: $(OBJ_FILES) $(STARTUP_FILE_OUT)
	@echo
	@echo "making src: " $(SRC_DIRS)
	@echo "making obj: " $(OBJ_FILES)
	@echo "making elf: " $<
	@echo

	arm-atollic-eabi-gcc $(LDS_FLAG) -o $@ $^
$(OBJ_DIR)/%.o: %.c|$(OBJ_DIR)/%.f
	@echo
	@echo "building obj: " $@
	@echo

	arm-atollic-eabi-gcc -c $< $(LD_FLAGS) $(CFLAGS) $(INCLUDE) -o $@

$(OBJ_DIR)/%.o: %.s
	@echo
	@echo "building obj: " $@
	@echo

	arm-atollic-eabi-gcc -c $<  $(LD_FLAGS) $(CFLAGS) $(INCLUDE) -o $@

%.f:
	@mkdir -p $(dir $@)

clean:
	rm -rf obj/*
	rm -f testapp.elf

.PHONY: clean all
