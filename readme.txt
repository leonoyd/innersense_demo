Demo1 - I2C Demo

1. cp src/main.c.i2cdemo src/main.c
2. make or make CFLAGS=-DMASTER_BOARD
3. pyocd-gdbdebugger
4. arm-atollic-eabi-gdb --tui -ex 'target remote localhost:3333' -ex 'load' ' -ex 'b main' testapp.elf

Demo2 - WDT Demo

1. cp src/main.c.wdtdemo src/main.c
2. make
3. pyocd-gdbdebugger
4. arm-atollic-eabi-gdb --tui -ex 'target remote localhost:3333' -ex 'load' ' -ex 'b main' testapp.elf



