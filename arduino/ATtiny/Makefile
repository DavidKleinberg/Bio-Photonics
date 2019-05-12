MCU=attiny85
AVRDUDEMCU=t85
CC=avr-gcc
CFLAGS=-j .text -O ihex
OBJ2HEX=avr-objcopy
AVRDUDE=/usr/local/bin/avrdude
TARGET=Melanoma_Tiny
#INCLUDES=Arduino.h SoftwareSerial.cpp
INCLUDES=

program : $(TARGET).hex
	#avrdude -c usbtiny -p t85 -q -U lfuse:w:0x62:m
	#avrdude -c usbtiny -p t85 -q -U hfuse:w:0xd7:m
	#avrdude -c usbtiny -p t85 -q -U efuse:w:0xff:m
	avrdude -c usbtiny -p $(AVRDUDEMCU) -U flash:w:$(TARGET).hex

noreset :
	sudo $(AVRDUDE) -p $(AVRDUDEMCU) -P /dev/spidev0.0 -c linuxspi -b 10000 -U flash:w:$(TARGET).hex

compile :
	$(CC) -mmcu=$(MCU) -Os $(TARGET).cpp $(INCLUDES) -o $(TARGET).elf
	$(OBJ2HEX) $(CFLAGS) $(TARGET).elf $(TARGET).hex

%.hex : %.obj
	$(OBJ2HEX) -R .eeprom -O ihex $< $@

clean :
	rm -f *.hex *.obj *.o *.elf
