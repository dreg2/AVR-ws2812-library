# Sources
TARGET     = ws2812
INCLUDES   = $(TARGET).h
C_SOURCES  = $(TARGET).c
A_SOURCES  = $(TARGET)_xmit.S
LIBS       = -luart -lpin
DEFINES    =

# target specifics
DEVICE     = atmega328p
CLOCK      = 16000000
AVRD_PGMR  = arduino
AVRD_PORT  = /dev/ttyACM0
AVRD_PORT2 = /dev/ttyUSB0
#AVRD_BAUD  = 115200
AVRD_BAUD  = 57600
AVRD_FLAGS = -v
#FUSES      = -U lfuse:w:0xFF:m -U hfuse:w:0xDE:m -U efuse:w:0x05:m
UART_BAUD  = 115200
#UART_BAUD  = 57600

# stdio printf options: float, minimal, normal
#LIB_PRINTF = -Wl,-u,vfprintf -lprintf_flt -lm
#LIB_PRINTF = -Wl,-u,vfprintf -lprintf_min
LIB_PRINTF =

# files
ELF        = $(TARGET).elf
HEX        = $(TARGET).hex
LIB        = lib${TARGET}.a
C_OBJS     = $(C_SOURCES:.c=.o)
A_OBJS     = $(A_SOURCES:.S=.o)
OBJS       = $(C_OBJS) $(A_OBJS)
ASMS       = $(C_SOURCES:.c=.s)

# library test files
TEST_TGT   = $(TARGET)_test
TEST_SRC   = $(TEST_TGT).c
TEST_OBJ   = $(TEST_TGT).o

# compiler options
STANDARD   = -std=gnu11
#TEMPS      = -save-temps
#DEBUG      = -D DEBUG
#OPTIMIZE   = -O2
INC_DIRS   = -I../../include
LIB_DIRS   = -L../../lib
C_FLAGS    = $(STANDARD) $(INC_DIRS) $(DEBUG) $(OPTIMIZE) $(TEMPS) $(DEFINES)\
		-Os -D F_CPU=$(CLOCK) -mmcu=$(DEVICE) \
		-W -Wall -pedantic \
		-Wformat-nonliteral -Wcast-align  \
		-Wpointer-arith -Wbad-function-cast \
		-Wstrict-prototypes -Winline -Wundef \
		-Wnested-externs -Wcast-qual -Wshadow \
		-Wconversion -Wwrite-strings \
		-ffloat-store
L_FLAGS    = $(LIB_DIRS) $(LIB_PRINTF) $(LIBS)
#A_FLAGS    = -Wa,-a

# compiler commands
COMPILE    = avr-gcc $(C_FLAGS)
ASSEMBLE   = avr-gcc $(C_FLAGS) $(A_FLAGS)
AVRDUDE    = avrdude $(AVRD_FLAGS) -c $(AVRD_PGMR) -P $(AVRD_PORT)  -b $(AVRD_BAUD) -p $(DEVICE)
AVRDUDE2   = avrdude $(AVRD_FLAGS) -c $(AVRD_PGMR) -P $(AVRD_PORT2) -b $(AVRD_BAUD) -p $(DEVICE)
AVROBJCOPY = avr-objcopy -j .text -j .data -O ihex $(ELF) $(HEX)


# symbolic targets
all:	$(LIB)

lib:	$(LIB)

test: $(OBJS)
	$(COMPILE) -D TEST -c $(TEST_SRC) -o $(TEST_OBJ)
	$(COMPILE) -o $(ELF) $(OBJS) $(TEST_OBJ) $(L_FLAGS)
	$(AVROBJCOPY)

asm: $(ASMS)

%.o: %.c $(INCLUDES)
	$(COMPILE)  -c $< -o $@

%.o: %.S
	$(ASSEMBLE) -c $< -o $@

%.s: %.c
	$(COMPILE) -S $< -o $@

# command targets
flash:	$(HEX)
	$(AVRDUDE) -U flash:w:$(HEX):i

flash2:	$(HEX)
	$(AVRDUDE2) -U flash:w:$(HEX):i

#fuse:
#	$(AVRDUDE) $(FUSES)

install: $(LIB)
	cp $(TARGET).h ../../include
	cp $(LIB)      ../../lib

clean:
	rm -f $(LIB) $(HEX) $(ELF) $(OBJS) $(TEST_OBJ)

disasm:	$(ELF)
	avr-objdump -d $(ELF)

monitor:
	 minicom -D $(AVRD_PORT) -b $(UART_BAUD)

monitor2:
	 minicom -D $(AVRD_PORT2) -b $(UART_BAUD)


# file targets
$(ELF): $(OBJS)
	$(COMPILE) -o $(ELF) $(OBJS) $(L_FLAGS)

$(HEX): $(ELF)
	$(AVROBJCOPY)

$(LIB): $(OBJS)
	avr-ar rcs $(LIB) $(OBJS)

.PHONY: flash flash2 fuse install lib clean disasm asm monitor monitor2 test

