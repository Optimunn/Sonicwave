#Simple Makefile for compile and upload your AVR assembly project
MCU       = attiny10
FILE      = attinybz
PGMR      = usbasp
BITCLOCK  = 125kHz
COMPILER_PATH = /opt/homebrew/Cellar/avra
all: compile clean upload

upload:
	avrdude -p $(MCU) -c $(PGMR) -B $(BITCLOCK) -U flash:w:$(FILE).hex
compile:
	avra --includepath $(COMPILER_PATH)/1.4.2/include/avr \
	-o $(FILE).hex $(FILE).asm
clean:
	rm $(FILE).eep.hex $(FILE).obj