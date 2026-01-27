/* 
  Name: 2D-Drawer
  Author: Simon Bukvic
  Date: 2026-01-26
  Description: A 2D writing robot consisting of three servos, one for lifting the pen and two for controlling the pen's position.
*/

/* Useful resources
the math of inverse kinematics: https://www.youtube.com/watch?v=nW5FUVzYCKM
number drawing simulation: https://scratch.mit.edu/projects/1267648991
*/

// All units in mm
// 8 mm between each stud for lego

#include <Servo.h>
#include <RTClib.h>

Servo servoLeft;
Servo servoRight;
Servo servoLift;

RTC_DS3231 rtc;

// Measurements
const uint8_t R1 = 48;         // bottom right arm
const uint8_t R2 = 64;         // top right arm
const uint8_t L1 = 48;         // bottom left arm
const uint8_t L2 = 80;         // top left arm
const uint8_t OFFSET = 28;     // distance between left servo and right servo
const uint8_t PENOFFSET = 16;  // distance between top joint and pen

// Pins
const uint8_t SERVOLEFTPIN = 9;
const uint8_t SERVORIGHTPIN = 10;
const uint8_t SERVOLIFTPIN = 11;
const uint8_t BUTTONPIN = 2;

// Other
const uint8_t ANGLEOFFSET = 60;

String inputString = "";  // stores incoming chars

float lastX, lastY;

/*
  Main setup.
  Parameters: none
  Returns: void
*/
void setup() {
  Serial.begin(9600);

  pinMode(BUTTONPIN, INPUT);

  // initiate servos
  servoLeft.attach(SERVOLEFTPIN);
  servoRight.attach(SERVORIGHTPIN);
  servoLift.attach(SERVOLIFTPIN);
  // set starting position
  lastX = 37 + OFFSET;
  lastY = 65;
  setXY(lastX, lastY);


  // rtc clock
  rtc.begin();
  // rtc.adjust(DateTime(F(__DATE__), F(__TIME__))); // to adjust time: uncomment, upload, comment, upload
}

/*
  Main loop.
  Parameters: none
  Returns: void
*/
void loop() {
  handeInput();
  if (digitalRead(BUTTONPIN) == HIGH) command('t', ""); // when button is pressed, activate command 't' (draw time)
  delay(100);
}


/*
  Function that gets the time.
  Parameters: none
  Returns: Time as a String. hh:mm
*/
String getTime() {
  DateTime now = rtc.now();
  String hourStr = (now.hour() < 10 ? "0" : "") + String(now.hour(), DEC);
  String minuteStr = (now.minute() < 10 ? "0" : "") + String(now.minute(), DEC);

  return hourStr + ":" + minuteStr;
}


/* 
  Function that handles commands.
  Commands:
    q     - set servo angles to 0
    p     - set position for easy pen insert
    a (n) - set servo to angle n
    c (r) - draw circle with radius r
    r (s) - draw square with size s
    m (s) - draw string s to the screen (  only works for the following characters: '0123456789(=:'  )
    t     - draw the current time hh:mm

  Example:
    Message 'c 30' to draw a circle with radius 30 mm.
    Message 'l (' to draw a (

  Parameters: none
  Returns: void
*/
void command(char keyword, String rest) {
  switch (keyword) {
    case 'q':  // reset
      Serial.println("reset");
      servoLeft.write(90 - ANGLEOFFSET);
      servoRight.write(90 + ANGLEOFFSET);
      break;

    case 'a':  // angle
      Serial.println("Set servo angles to " + String(rest.toInt()) + " degrees");
      servoLeft.write(rest.toInt() - ANGLEOFFSET);
      servoRight.write(rest.toInt() + ANGLEOFFSET);
      break;

    case 'c':  // circle
      drawArcCW(OFFSET / 2, 80, rest.toInt(), 360, 0, 1, true);
      break;
      
    case 'r':  // rect
      {
        int x = 0;
        int y = 60;
        int w = rest.toInt();
        int h = rest.toInt();
        setXY(x, y);
        lastX = x;
        lastY = y;
        delay(1000);

        drawTo(x + w, y);
        drawTo(x + w, y + h);
        drawTo(x, y + h);
        drawTo(x, y);
      }
      break;

    case 'p':  // set position
      lastX = 37 + OFFSET;
      lastY = 65;
      setXY(lastX, lastY);
      break;
    case 'm': // draw message
      drawString(rest, OFFSET / 2 - 40, 50, 1);
      break;
    case 't':  // draw time
      drawString(getTime(), OFFSET/2 - 40, 50, 1);
      break;
  }
}

/* 
  Function that handles serial monitor messages.
  Parameters: none
  Returns: void
*/
void handeInput() {
  while (Serial.available() > 0) {
    char c = Serial.read();

    if (c == '\n' || c == '\r') {
      char keyword = inputString[0];
      String rest = inputString.substring(2);
      command(keyword, rest);

      inputString = "";  // clear for next command

    } else {
      // build the string
      inputString += c;
    }
  }
}
