  /*
 https://www.youtube.com/watch?v=nW5FUVzYCKM
*/

#include <Servo.h>

Servo servoLeft;
Servo servoRight;
Servo servoLift;

// Units in cm
#define L1 35 // bottom right arm
#define L2 45 // top right arm

#define L3 4.8 // bottom left arm
#define L4 4.8 // top left arm
#define OFFSET 2.8 // distance between servos


#define PI 3.141528


void setup() {
  servoLeft.attach(9);
  servoRight.attach(10);
  servoLift.attach(11);
  Serial.begin(9600);

  setPos(0, 4.8*2);
}



void loop() {

}

void setPos(float x, float y) {
  // right arm
  float q2 = acos((L1*L1 + L2*L2 - x*x - y*y) / (2 * L1 * L2));

  float a2_sin_q2 = sqrt(1 - cos(q2*q2));
  float a2_cos_q2 = L2 * sin(q2);

  float q1 = atan2(y,x) - atan2(a2_sin_q2, (L1 + a2_cos_q2));

  Serial.println("angle: " + String(q1 * 180 / PI));
}

  