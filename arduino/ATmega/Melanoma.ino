void setup() {
Serial.begin(9600);
  // put your setup code here, to run once:
  pinMode(13, OUTPUT); 
  pinMode(12, OUTPUT);
  pinMode(11, OUTPUT);
}
 
void loop() {
  // put your main code here, to run repeatedly:
 if(Serial.available()>0)
   {     
      char data= Serial.read(); // reading the data received from the bluetooth module
      switch(data)
      {
        case '1':
          digitalWrite(11, HIGH);
          digitalWrite(12, LOW);
          digitalWrite(13, LOW);
          break; // iPhone requests LED 1
        
        case '2': // iPhone requests LED 2
          digitalWrite(11, LOW);
          digitalWrite(12, HIGH);
          digitalWrite(13, LOW);
          break;
          
        case '3': // iPhone requests LED 3
          digitalWrite(11, LOW);
          digitalWrite(12, LOW);
          digitalWrite(13, HIGH);
          break; 

         case 'X' : // iPhone requests OFF
          digitalWrite(11, LOW);
          digitalWrite(12, LOW);
          digitalWrite(13, LOW);
         break;
         
        default : // iPhone requests OFF
          digitalWrite(11, LOW);
          digitalWrite(12, LOW);
          digitalWrite(13, LOW);
         break;
      }
      Serial.println(data);
   }
   delay(50);
}
