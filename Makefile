CROSS 		:= toolchain/bin/arm-none-eabi-
CC   		:=  $(CROSS)gcc
CXX   		:=  $(CROSS)g++
DEBUG   	:=  
# SOURCES   	+=  $(wildcard ./*.c)
CSRCPATH	:= Projects/Src
CXXSRCPATH	?= 
CSOURCES   	+= $(foreach dir, $(CSRCPATH), $(wildcard $(dir)/*.c))
CXXSOURCES	+= $(foreach dir, $(CXXSRCPATH), $(wildcard $(dir)/*.cpp))
CSOURCES   	+= Drivers/STM32MP13xx_HAL_Driver/Src/stm32mp13xx_hal.c \
			   Drivers/STM32MP13xx_HAL_Driver/Src/stm32mp13xx_hal_dma.c \
			   Drivers/STM32MP13xx_HAL_Driver/Src/stm32mp13xx_hal_dma_ex.c \
			   Drivers/STM32MP13xx_HAL_Driver/Src/stm32mp13xx_hal_exti.c \
			   Drivers/STM32MP13xx_HAL_Driver/Src/stm32mp13xx_hal_gpio.c \
			   Drivers/STM32MP13xx_HAL_Driver/Src/stm32mp13xx_hal_i2c.c \
			   Drivers/STM32MP13xx_HAL_Driver/Src/stm32mp13xx_hal_pwr.c \
			   Drivers/STM32MP13xx_HAL_Driver/Src/stm32mp13xx_hal_pwr_ex.c \
			   Drivers/STM32MP13xx_HAL_Driver/Src/stm32mp13xx_hal_rcc.c \
			   Drivers/STM32MP13xx_HAL_Driver/Src/stm32mp13xx_hal_rcc_ex.c \
			   Drivers/STM32MP13xx_HAL_Driver/Src/stm32mp13xx_hal_uart.c \
			   Drivers/STM32MP13xx_HAL_Driver/Src/stm32mp13xx_hal_uart_ex.c \
			   Drivers/CMSIS/Core_A/Source/irq_ctrl_gic.c \
			   Drivers/CMSIS/Device/ST/STM32MP13xx/Source/Templates/mmu_stm32mp13xx.c \
			   Drivers/CMSIS/Device/ST/STM32MP13xx/Source/Templates/system_stm32mp13xx_A7.c \
			   Drivers/BSP/STM32MP13xx_DISCO/stm32mp13xx_disco.c \
			   Drivers/BSP/STM32MP13xx_DISCO/stm32mp13xx_disco_bus.c \
			   Drivers/BSP/STM32MP13xx_DISCO/stm32mp13xx_disco_io.c \
			   Drivers/BSP/STM32MP13xx_DISCO/stm32mp13xx_disco_stpmic1.c \
			   Drivers/BSP/Components/mcp23x17/mcp23x17.c \
			   Drivers/BSP/Components/mcp23x17/mcp23x17_reg.c\
			   Drivers/CMSIS/Device/ST/STM32MP13xx/Source/Templates/gcc/startup_stm32mp135c_ca7.c



INCLUDES   	+=   -IProjects/Src -IProjects/Inc  -IDrivers/CMSIS/Core_A/Include -IDrivers/CMSIS/Device/ST/STM32MP13xx/Include 
INCLUDES   	+=   -IDrivers/STM32MP13xx_HAL_Driver/Inc -IDrivers/BSP/STM32MP13xx_DISCO -IDrivers/BSP/Components/Common



LIB_NAMES  	+=
LIB_PATH  	+=  -L./lib
OBJ   		+=  $(patsubst %.c, %.cc.o, $(CSOURCES))
OBJ   		+=  $(patsubst %.cpp, %.cxx.o, $(CXXSOURCES))
CFLAGS  	+=  -mcpu=cortex-a7 -std=gnu11 -g3  
CFLAGS  	+=  -DSTM32MP135Fxx -D__LOG_TRACE_IO_ -DMCP_IOEXPANDER -DUSE_STM32MP13XX_DK -DCORE_CA7 -DCACHE_USE -DMMU_USE -DUSE_HAL_DRIVER -DUSE_FULL_ASSERT 
CFLAGS  	+=  -ffunction-sections -Wall -Wno-strict-aliasing -fstack-usage -fcyclomatic-complexity -MMD -MP 
# CFLAGS  	+=  -MF"/home/nihao/work/github/STM32CubeMP13/Projects/STM32MP135C-DK/Examples/UART/UART_Receive_Transmit_Console/STM32CubeIDE/Debug/Drivers/STM32MP13xx_HAL_Driver/stm32mp13xx_hal.d" -MT"Drivers/STM32MP13xx_HAL_Driver/stm32mp13xx_hal.o" 
CFLAGS  	+=  --specs=nano.specs -mfpu=vfpv4-d16 -mfloat-abi=hard -mthumb


CXXFLAGS  	+=  -Wall
LDFLAGS	    +=  -mcpu=cortex-a7 -T"Drivers/CMSIS/Device/ST/STM32MP13xx/Source/Templates/gcc/linker/stm32mp13xx_a7_ddr.ld" 
LDFLAGS	    +=  --specs=nosys.specs -Wl,-Map="blink.map" 
LDFLAGS	    +=  -Wl,--gc-sections -static --specs=nano.specs -mfpu=vfpv4-d16 -mfloat-abi=hard -mthumb -Wl,--start-group -lc -lm -Wl,--end-group


mini_sdraw.bin: blink.stm32
	dd if=/dev/zero of=mini_sdraw.bin bs=1M count=1
	dd if=blink.stm32 of=mini_sdraw.bin bs=1K seek=64


blink.stm32:blink.elf
	$(CROSS)size  blink.elf 
	Utilities/ImageHeader/postbuild_STM32MP13.sh toolchain/bin blink


#links
blink.elf:$(OBJ)
	@mkdir -p output
	$(CC) $(OBJ) $(LIB_PATH) $(LIB_NAMES) -o blink.elf $(LDFLAGS)
 
#compile
%.cc.o: %.c
	$(CC) $(INCLUDES) $(DEBUG) -c $(CFLAGS) $< -o $@
%.cxx.o: %.cpp
	$(CXX) $(INCLUDES) $(DEBUG) -c $(CXXFLAGS) $< -o $@

run:
	@ echo run output/$(TARGET)$(VERSION)
	@ ./output/$(TARGET)$(VERSION)


CLEANOBJ   		+=  $(patsubst %.c, %.cc.cyclo, $(CSOURCES))
CLEANOBJ   		+=  $(patsubst %.c, %.cc.d, $(CSOURCES))
CLEANOBJ   		+=  $(patsubst %.c, %.cc.su, $(CSOURCES))
.PHONY:clean
clean:
	@echo "Remove linked and compiled files......"
	rm -rf $(OBJ) $(TARGET) output 
	rm -rf $(CLEANOBJ)
	rm -rf blink*
	rm -rf mini_sdraw.bin

