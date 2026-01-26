
#include <Servo.h>


#define ANGLEOFFSET 60


Servo servo1;
Servo servo2;
Servo servo3;

int potpin = A0;  // analog pin used to connect the potentiometer
int val;    // variable to read the value from the analog pin
int pos = 0;    // variable to store the servo position
int deltaPos = 10;
int mid = 1500;
int diff = 500;

String inputString = "";   // stores incoming chars


void setup() {
  // initiate servos
  servo1.attach(9);
  servo2.attach(10);
  servo3.attach(11);
  servosWrite(90);

  Serial.begin(9600);
}

void servosWrite(int angle) {
  int a = angle - ANGLEOFFSET;
  int b = angle + ANGLEOFFSET;
  servo1.write(a);
  servo2.write(b);
  servo3.write(angle);
}

void servosWriteMS(int value) {
  servo1.writeMicroseconds(value);
  servo2.writeMicroseconds(value);
  servo3.writeMicroseconds(value);
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
        servosWrite(angle);

        inputString = ""; // clear for next command
      }
    } else {
      // build the string
      inputString += c;
    }
  }
}

void sweepServoUpdate() {
  pos += deltaPos;
  if (pos > mid + diff) {
    pos = mid + diff;
    deltaPos = -deltaPos;
  }
  if (pos < mid - diff) {
    pos = mid - diff;
    deltaPos = -deltaPos;
  }

  servosWriteMS(pos);
  delay(10);

}


void loop() {
  inputServoUpdate();
  // sweepServoUpdate();
}
