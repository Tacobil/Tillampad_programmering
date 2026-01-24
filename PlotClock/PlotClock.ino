/* 
  Name: 2D-Drawer
  Author: Simon Bukvic
  Date: 2026-01-14
  Description: A 2D writing robot. Goal is for it to write numbers and letters.
*/

/* Useful resources
https://www.youtube.com/watch?v=nW5FUVzYCKM
https://scratch.mit.edu/projects/1267648991
*/

// All units in mm
// 8 mm between each stud for lego

#include <Servo.h>

Servo servoLeft;
Servo servoRight;
Servo servoLift;


// Measurements
const uint8_t R1 = 48;  // bottom right arm
const uint8_t R2 = 64;  // top right arm
const uint8_t L1 = 48;  // bottom left arm
const uint8_t L2 = 80;  // top left arm
const uint8_t OFFSET = 28;     // distance between left servo and right servo
const uint8_t PENOFFSET = 16;  // distance between top joint and pen

// Pins
const uint8_t SERVOLEFTPIN = 9;
const uint8_t SERVORIGHTPIN = 10;
const uint8_t SERVOLIFTPIN = 11;

// Other
const uint8_t ANGLEOFFSET = 60;

String inputString = "";  // stores incoming chars

float lastX, lastY;

void setup() {
  Serial.begin(9600);

  // initiate servos
  servoLeft.attach(SERVOLEFTPIN);
  servoRight.attach(SERVORIGHTPIN);
  servoLift.attach(SERVOLIFTPIN);
  float s = 0.5;
  // drawArcCCW(4 + 7*s, 4+ 10*s, 10*s, 90, 450, 2/3);
  setXY(0,100);
  lastX = 0;
  lastY = 100;

}

void loop() {
  handeInput();
  delay(100);
}


/* 
  Function that handles serial monitor messages.
  COMMANDS:
    a (n) - set servo to angle n. if no angle is specified, sets servo angles to 90 degrees
    c (x, y, r) - draw circle at position (x, y) with radius r
    r (x y w h) - draw rect at position (x, y) with width w and height h
    p (x y) - set position to (x, y)

    m (x, y, text) - text at position (x, y)
    n (x, y, text) - number at position (x, y)

    example:
      c 3 5 4 - draw circle at position (3, 5) with radius 4*/
void handeInput() {
  while (Serial.available() > 0) {
    char c = Serial.read();

    if (c == '\n' || c == '\r') {
            
      char keyword = inputString[0];
      String rest = inputString.substring(2);

      Serial.println("keyword: " + String(keyword));

      switch (keyword) {
        case 'q': // reset
          Serial.println("reset");
          servoLeft.write(90-ANGLEOFFSET);
          servoRight.write(90+ANGLEOFFSET);
          break;

        case 'a': // angle
          Serial.println("angle");
          Serial.println("Set servo angles to " + String(rest.toInt()) + " degrees");
          servoLeft.write(rest.toInt()-ANGLEOFFSET);
          servoRight.write(rest.toInt()+ANGLEOFFSET);
          break;

        case 'c': // circle
          drawCircle(OFFSET / 2, 80, 30);
          break;
        case 'r': // rect
          {
          int x = 0;
          int y = 60;
          int w = OFFSET+50;
          int h = 40;

          drawTo(x+w, y);
          drawTo(x+w, y+h);
          drawTo(x, y+h);
          drawTo(x, y);
          }
          break;
        
        case 'p': // set position
          Serial.println("position");
          break;

        case 'm': // message
          Serial.println("message");
          //
          break;
        
        case 'n': // number
          Serial.println("number");
          break;
        
        case 'l': // line
          Serial.println("line");
          setXY(-40, 70);
          lastX = -40;
          lastY = 70;
          drawTo(80,100);
          break;
      }        

      inputString = "";  // clear for next command
      
    } else {
      // build the string
      inputString += c;
    }
  }
}


