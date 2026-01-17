/* 
  Name: 2D-Drawer
  Author: Simon Bukvic
  Date: 2026-01-14
  Description: 
*/


// https://www.youtube.com/watch?v=nW5FUVzYCKM


#include <Servo.h>

Servo servoLeft;
Servo servoRight;
Servo servoLift;

// Units in cm
// 0.8 cm between each stud for lego
#define R1 4.8  // bottom right arm
#define R2 4.8  // top right arm

#define L1 4.8  // bottom left arm
#define L2 6.4  // top left arm

#define OFFSET 2.8     // distance between left servo and right servo
#define PENOFFSET 1.6  // distance between top joint and pen

// pins
#define LEFTPIN 9
#define RIGHTPIN 10
#define LIFTPIN 11
#define CALIBRATEPIN 2  // when pin is high, servos are set to 90 degrees, making it easy to calibrate

#define PI 3.141528


String inputString = "";  // stores incoming chars
float lastX = 0;
float lastY = 0;

void setPos(double x, double y, bool debug = false) {
  y = -y;
  // left arm inverse kinematics
  double q2Left = -acos((x * x + y * y - L1 * L1 - L2 * L2) / (2 * L1 * L2));
  double q1Left = atan2(y, x) + atan2((L2 * sin(q2Left)), (L1 + L2 * cos(q2Left)));
  q2Left = -q2Left;


  // compensate servo offset
  x -= OFFSET;

  // compensate pen offset
  x -= cos(q1Left + q2Left) * PENOFFSET;
  y -= sin(q1Left + q2Left) * PENOFFSET;

  // right arm inverse kinematics
  double q2Right = acos((x * x + y * y - R1 * R1 - R2 * R2) / (2 * R1 * R2));
  double q1Right = atan2(y, x) + atan2((R2 * sin(q2Right)), (R1 + R2 * cos(q2Right)));

  q1Left = -q1Left;
  q1Right = -q1Right;

  int angleLeftMillis = map(q1Left * 1000, 0, PI * 1000, 544, 2400);
  int angleRightMillis = map(q1Right * 1000, 0, PI * 1000, 544, 2400);
  servoLeft.writeMicroseconds(angleLeftMillis);
  servoRight.writeMicroseconds(angleRightMillis);

  if (debug) {
    Serial.println("angle left: " + String(angleLeftMillis) + ", " + String(q1Left) + ", " + String(q2Left));
    Serial.println("angle right: " + String(angleRightMillis) + ", " + String(q1Right) + ", " + String(q2Right));
  }
}

void setup() {
  servoLeft.attach(LEFTPIN);
  servoRight.attach(RIGHTPIN);
  servoLift.attach(LIFTPIN);

  Serial.begin(9600);
  servoLeft.write(90);
  servoRight.write(90);

  pinMode(CALIBRATEPIN, INPUT);
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
    c 3 5 4 - draw circle at position (3, 5) with radius 4

*/
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
          servoLeft.write(90);
          servoRight.write(90);
          break;

        case 'a': // angle
          Serial.println("angle");
          Serial.println("Set servo angles to " + String(rest.toInt()) + " degrees");
          servoLeft.write(rest.toInt());
          servoRight.write(rest.toInt());
          break;

        case 'c': // circle
          Serial.println("Circle");
          drawCircle(OFFSET / 2, 8, 2);
          break;

        case 'r': // rect
          Serial.println("Rectangle");
          drawRect(OFFSET/2, 7, 2, 2);
          break;
        
        case 'p': // set position
          Serial.println("Set position to " + String(rest[0]) + "," + String(rest[2]));
          setPos(String(rest[0]).toInt(), String(rest[2]).toInt());
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
          setPos(0,5);
          lastX = 0;
          lastY = 5;
          drawTo(5,5);
          break;
      }        

      inputString = "";  // clear for next command
      
    } else {
      // build the string
      inputString += c;
    }
  }
}

void loop() {
  handeInput();
  delay(100);
}

void drawTo(float x, float y) {
  int steps = 200;
  double stepX = (x - lastX) / steps;
  double stepY = (y - lastY) / steps;
  
  Serial.println("Drawing line from (" + String(lastX) + "," + String(lastY) + ") to (" + String(x) + "," + String(y) + ")");

  for (int i = 0; i <= steps; i++) {
    Serial.println(String(stepX * i + lastX) + " - " + String(stepY * i + lastY)); 
    setPos(stepX * i + lastX, stepY * i + lastY);
    delay(5);
  }

  setPos(x, y);

  lastX = x;
  lastY = y;
}

void lift(int p) {
  switch (p) {
    case 0: // pen down
      servoLift.write(90);
      break;
    case 1: // pen up
      servoLift.write(100);
      break;
    case 2: // pen idle
      servoLift.write(110);
      break;
  }
}

void drawRect(float x, float y, float w, float h) {
  drawTo(x - w / 2, y + h / 2);
  drawTo(x + w / 2, y + h / 2);
  drawTo(x - w / 2, y - h / 2);
  drawTo(x + w / 2, y - h / 2);
}

void drawCircle(float x, float y, float r) {
  for (float t = 0; t <= 2 * PI; t += 0.05) {
    float px = x + r * cos(t);
    float py = y + r * sin(t);
    setPos(px, py);
    delay(10);
  }

  // close circle
  setPos(x + r, y);
}

bool outOfReach(double x, double y) {
  if (x * x + y * y >= L1 * L1 + L2 * L2) {
    //Serial.println("left out of reach");
    return true;
  }

  if ((x - OFFSET) * (x - OFFSET) + y * y >= R1 * R1 + R2 * R2) {
    //Serial.println("right out of reach");
    return true;
  }
  return false;
}
