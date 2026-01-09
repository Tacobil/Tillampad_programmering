  /*
 https://www.youtube.com/watch?v=nW5FUVzYCKM
*/

#include <Servo.h>

Servo servoLeft;
Servo servoRight;
Servo servoLift;

// Units in cm
// 0.8 cm between each stud for lego
#define R1 4.8 // bottom right arm
#define R2 4.8 // top right arm

#define L1 4.8 // bottom left arm
#define L2 6.4 // top left arm

#define OFFSET 2.8 // distance between left servo and right servo
#define PENOFFSET 1.6 // distance between top joint and pen

// pins
#define LEFTPIN 9
#define RIGHTPIN 10
#define LIFTPIN 11
#define CALIBRATEPIN 2 // when pin is high, servos are set to 90 degrees, making it easy to calibrate

#define PI 3.141528


String inputString = "";   // stores incoming chars
int servoAngle = 90;
float lastX = 0;
float lastY = 0;

void setPos(double x, double y, bool debug = false) {
  outOfReach(x, y);

  y = -y;
  // left arm inverse kinematics
  double q2Left = -acos((x*x + y*y - L1*L1 - L2*L2) / (2 * L1 * L2));
  double q1Left = atan2(y, x) + atan2((L2 * sin(q2Left)), (L1 + L2 * cos(q2Left)));
  q2Left = -q2Left;
  
  
  // compensate servo offset
  x -= OFFSET;

  // compensate pen offset
  x -= cos(q1Left + q2Left) * PENOFFSET;
  y -= sin(q1Left + q2Left) * PENOFFSET;

  // right arm inverse kinematics
  double q2Right = acos((x*x + y*y - R1*R1 - R2*R2) / (2 * R1 * R2));
  double q1Right = atan2(y, x) + atan2((R2 * sin(q2Right)), (R1 + R2 * cos(q2Right)));

  q1Left = -q1Left;
  q1Right = -q1Right;

  int angleLeftMillis = map(q1Left*1000, 0, PI*1000, 544, 2400);
  int angleRightMillis = map(q1Right*1000, 0, PI*1000, 544, 2400);
  servoLeft.writeMicroseconds(angleLeftMillis);
  servoRight.writeMicroseconds(angleRightMillis);
  // int angleLeft = q1Left * 180 / PI;
  // int angleRight = q1Right * 180 / PI;
  // servoLeft.write(angleLeft);
  // servoRight.write(angleRight);
 
  if (debug) {
  Serial.println("angle left: "+String(angleLeftMillis)+", "+String(q1Left)+", "+String(q2Left));
  Serial.println("angle right: "+String(angleRightMillis)+", "+String(q1Right)+", "+String(q2Right));
  }

}

void setup() {
  servoLeft.attach(LEFTPIN);
  servoRight.attach(RIGHTPIN);
  servoLift.attach(LIFTPIN);
  
  Serial.begin(9600);
  servosWrite(90);

  pinMode(CALIBRATEPIN, INPUT);
}

void servosWrite(int angle) {
  servoLeft.write(angle);
  servoRight.write(angle);
  servoLift.write(angle);
}

// function that allows you to message an angle to set all servos to. 
void inputServoUpdate() {
  while (Serial.available() > 0) {
    char c = Serial.read();

    if (c == '\n' || c == '\r') {
      // We reached the end of the input line → convert to number
      if (inputString.length() > 0) {
        Serial.println("input: "+inputString);
        int angle = inputString.toInt();
        servoAngle = angle;
        // servosWrite(angle);
        
        Serial.print("Set servo to: ");
        Serial.println(angle);

        inputString = ""; // clear for next command
      }
    } else {
      // build the string
      inputString += c;
    }
  }
}

void loop() {
  if (digitalRead(CALIBRATEPIN) == HIGH) {
    inputServoUpdate();
    servosWrite(servoAngle);
    // setPos(OFFSET/2, 7);
  } else {
    drawCircle(OFFSET/2, 8, 2);
    // followXAxis(4, 7);
    // drawSquare(OFFSET/2, 7, 3, 3);
    // setPos(OFFSET/2, 7);
  }
}

void followXAxis(float distance, float y) {
  float x = OFFSET / 2;
  float inc = 0.05;
  float start = (OFFSET - distance) / 2;
  float stop = (OFFSET + distance) / 2;
  
  setPos(start, y);
  delay(1000);

  for (float x = start; x <= stop; x+=inc) {
    setPos(x, y);
    delay(10);
  }

  delay(1000);
}

void drawTo(float x, float y) {
  for (int i = 0; i <= 100; i++) {

    delay(2);
  }
  lastX = x;
  lastY = y;
}

void drawSquare(float x, float y, float w, float h) {
  // top side  
  float step = 0.05;
  int d = 6;

  for (float i = x - w/2; i <= x + w/2; i += step) {
    setPos(i, y + h/2);
    delay(d);
  }
  setPos(x+w/2, y+h/2);

  // right side
  for (float i = y + h/2; i >= y - h/2; i -= step) {
    setPos(x + w/2, i);
    delay(d);
  }
  setPos(x+w/2, y-h/2);

  // bottom side
  for (float i = x + w/2; i >= x - w/2; i -= step) {
    setPos(i, y - h/2);
    delay(d);
  }
  setPos(x-w/2, y-h/2);

  // left side
  for (float i = y - h/2; i <= y + h/2; i += step) {
    setPos(x - w/2, i);
    delay(d);
  }
  setPos(x-w/2, y+h/2);

}

void drawCircle(float x, float y, float r) {
  for (float t = 0; t <= 2*PI; t += 0.005) {
    float px = x + r * cos(t);
    float py = y + r * sin(t);
    setPos(px, py);
    delay(2);
  }

  // close circle
  setPos(x + r, y);
}

bool outOfReach(double x, double y) {
  if (x*x + y*y >= L1*L1 + L2*L2) {
    //Serial.println("left out of reach");
    return true;
  }

  if ((x-OFFSET)*(x-OFFSET) + y*y >= R1*R1 + R2*R2) {
    //Serial.println("right out of reach");
    return true;
  }
  return false;
}


  