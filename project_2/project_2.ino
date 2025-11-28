  /*
 Controlling a servo position using a potentiometer (variable resistor)
 by Michal Rinott <http://people.interaction-ivrea.it/m.rinott>

 modified on 8 Nov 2013
 by Scott Fitzgerald
 http://www.arduino.cc/en/Tutorial/Knob
*/

#include <Servo.h>

Servo servoLeft;
Servo servoRight;
Servo servoLift;

#define L1 10 // bottom right arm
#define L2 10 // top right arm

#define L3 10 // bottom left arm
#define L4 10 // top left arm

#define PI 3.141528


void setup() {
  servoLeft.attach(9);
  servoRight.attach(10);
  servoLift.attach(11);
  Serial.begin(9600);
}



void loop() {

}

void setPos(float x, float y) {
  // right arm
  float alpha = atan((pow(L1, 2) + pow(L2, 2) - x*x - y*y) / (2 * L1 * L2));
  float q2 = PI - alpha;
  
}

  