#include "U8glib.h"
#include "Wire.h"

U8GLIB_SSD1306_128X64 u8g(U8G_I2C_OPT_NO_ACK);

#define FONT_SMALL u8g_font_6x10
#define FONT_MEDIUM u8g_font_9x15
#define FONT_LARGE u8g_font_fub20
#define UNIFONT u8g_font_unifont

int potPin = A1;
int sensorPin = A0;

float R1 = 10000;                                                // value of R1 on board
float c1 = 0.001129148, c2 = 0.000234125, c3 = 0.0000000876741;  //steinhart-hart coeficients for thermistor

bool aboveThresh;

int ledPins[4] = { 10, 11, 12, 13 };
int ledPinTimes[4] = {200, 500, 1000, 400};
int ledIndex = 0;

void setup() {
  Serial.begin(9600);
  u8g.setFont(UNIFONT);

  pinMode(potPin, INPUT);
  pinMode(sensorPin, INPUT);

  for (int i = 0; i < 4; i++) {
    pinMode(ledPins[i], OUTPUT);
  }
}

void loop() {
  int thresh = getThresh();
  float temp = getTemp();

  aboveThresh = (temp > thresh);
  if (aboveThresh) {
    alarm();
  }

  oledDraw(thresh, temp);
}

void oledDraw(int thresh, float temp) {
  u8g.firstPage();

  do {
    u8g.drawStr(5, 11, ("thresh: " + String(thresh)).c_str());
    u8g.drawStr(5, 22, ("temp: " + String(temp) + " " + char(176) + "C").c_str());

    if (aboveThresh) {
      u8g.drawStr(10, 40, "HEAT DEATH");
    }

  } while (u8g.nextPage());
}

void alarm() {
  digitalWrite(ledPins[ledIndex], HIGH);
  delay(ledPinTimes[ledIndex] / analogRead(potPin));
  digitalWrite(ledPins[ledIndex], LOW);

  ledIndex = (ledIndex + 1) % 4;
}

int getThresh() {
  int resistance = analogRead(potPin);
  return map(resistance, 0, 1023, 10, 50);
}

float getTemp() {
  int Vo = analogRead(sensorPin);
  float R2 = R1 * (1023.0 / (float)Vo - 1.0);  // calculate resistance on thermistor
  float logR2 = log(R2);
  float T = (1.0 / (c1 + c2 * logR2 + c3 * logR2 * logR2 * logR2));  // temperature in Kelvin
  T = T - 273.15;                                                    //convert Kelvin to Celcius

  return T;
}
