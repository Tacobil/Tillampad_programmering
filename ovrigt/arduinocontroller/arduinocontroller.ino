// 2024-11-05

// Pin definitions
const int xPin = A0;    // X-axis (horizontal)
const int yPin = A1;    // Y-axis (vertical)
const int joystickButtonPin = 2; // Joystick button

const int buttonPin1 = 3; // Excess push button
const int buttonPin2 = 4;

float mapFloat(int x, int in_min, int in_max, float out_min, float out_max) {
  return (float)(x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}

void setup() {
  // Initialize serial communication
  Serial.begin(9600);
  
  // Configure the button pin as input with internal pull-up resistor
  pinMode(xPin, INPUT);
  pinMode(xPin, INPUT);
  pinMode(joystickButtonPin, INPUT_PULLUP);
  
  pinMode(buttonPin1, INPUT_PULLUP);
  pinMode(buttonPin2, INPUT_PULLUP);
}

void loop() {
  // Read the analog values from joystick and convert analog value:  0 to 1023  ->  -1 to 1
  float xValue = mapFloat(analogRead(xPin), 0, 1023, -1.0, 1.0);
  float yValue = mapFloat(analogRead(yPin), 0, 1023, -1.0, 1.0); 
  
  int joystickButtonState = digitalRead(joystickButtonPin);
  int buttonState1 = digitalRead(buttonPin1);
  int buttonState2 = digitalRead(buttonPin2);
  

  Serial.print(-yValue);
  Serial.print(",");
  Serial.print(xValue);
  Serial.print(",");
  Serial.print(joystickButtonState == LOW);
  Serial.print(",");
  Serial.print(buttonState1 == LOW);
  Serial.print(",");
  Serial.println(buttonState2 == LOW);

  delay(2);
}
