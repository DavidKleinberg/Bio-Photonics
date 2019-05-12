#include <Arduino.h>
#include <SoftwareSerial.h>
// ***
// *** Define the RX and TX pins. Choose any two
// *** pins that are unused.
// ***

#define RX    0   // *** D3, Pin 5
#define TX    1   // *** D4, Pin 6

// ***
// *** Define the software based serial port. Using the
// *** name Serial so that code can be used on other
// *** platforms that support hardware based serial. On
// *** chips that support the hardware serial, just
// *** comment this line.
// ***
SoftwareSerial mySerial(RX, TX);

void setup() {
  mySerial.begin(9600);
  // put your setup code here, to run once:
  DDRB = B111010;
}
 
void loop() {
  // put your main code here, to run repeatedly:
 if(mySerial.available()>0)
   {     
      char data= mySerial.read(); // reading the data received from the bluetooth module
      switch(data)
      {
        case '1':
          PORTB = PORTB | 100000;
          PORTB = PORTB & 100111;
          break; // iPhone requests LED 1
        
        case '2': // iPhone requests LED 2
          PORTB = PORTB | 010000;
          PORTB = PORTB & 010111;
          break;
          
        case '3': // iPhone requests LED 3
          PORTB = PORTB | 001000;
          PORTB = PORTB & 001111;
          break; 

         case 'X' : // iPhone requests OFF
          PORTB = PORTB & 000111;
         break;
         
        default : // iPhone requests OFF
          PORTB = PORTB & 000111;
         break;
      }
      //Serial.println(data);
   }
   delay(50);
}
