/* 
  Name: Clock project
  Author: Simon Bukvic
  Date: 2025-11-07
  Description: Displays the time, date and temperature on a screen. 
 */

// Include libraries
#include "U8glib.h"
#include "RTClib.h"
#include "Servo.h"
#include "LedControl.h"

// Construct object
U8GLIB_SSD1306_128X64 u8g(U8G_I2C_OPT_NO_ACK);
RTC_DS3231 rtc;
Servo myservo;
LedControl lc = LedControl(11, 12, 10, 1);

// Constants
const int servoPin = 9;

const int servoTempMin = 24;
const int servoTempMax = 30;

const int clockX = 64;
const int clockY = 40;
const int clockRadius = 20;

const int clockMainHourLength = clockRadius * 0.3; // the lines indicating hour 0, 3, 6, 9
const int secondRadius = clockRadius * 0.9;
const int minuteRadius = clockRadius * 0.7;
const int hourRadius = clockRadius * 0.5;

const float pi = 3.141528;

const char daysOfTheWeek[7][12] = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"};

// Initiates ther Real-Time Clock module
void setupRTC() {
  if (! rtc.begin()) {
    Serial.println("Couldn't find RTC");
    Serial.flush();
    while (1) delay(10);
  }

  if (rtc.lostPower()) {
    Serial.println("RTC lost power, let's set the time!");
    // When time needs to be set on a new device, or after a power loss, the
    // following line sets the RTC to the date & time this sketch was compiled
    rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));
    // This line sets the RTC with an explicit date & time, for example to set
    // January 21, 2014 at 3am you would call:
    //rtc.adjust(DateTime(2014, 1, 21, 3, 0, 0));
  }

  // When time needs to be re-set on a previously configured device, the
  // following line sets the RTC to the date & time this sketch was compiled
  rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));
  // This line sets the RTC with an explicit date & time, for example to set
  // January 21, 2014 at 3am you would call:
  //rtc.adjust(DateTime(2014, 1, 21, 3, 0, 0));
}

// Initiates the 8 digit 7 segment display
void setupLCD() {
  lc.shutdown(0, false);   // Wake up the MAX7219
  lc.setIntensity(0, 15);   // Brightness 0–15
  lc.clearDisplay(0);      // Clear the display
}

// Main setup
void setup () {
  Serial.begin(9600);
  myservo.attach(servoPin);
  u8g.setFont(u8g_font_4x6);
  setupRTC();
  setupLCD();

  // LCD pins
  pinMode(10, OUTPUT);
  pinMode(11, OUTPUT);
  pinMode(12, OUTPUT);
}

// Main loop
void loop () {
  String time = getTime();
  float temp = rtc.getTemperature();

  updateServo(temp);
  updateLCD();

  draw(time, String(temp));
  delay(100);
}


// Function that returns the current date and time as a string
String getTime() {
  // Get the current time from the RTC
  DateTime now = rtc.now();
  
  // Getting each time field in individual variables
  // And adding a leading zero when needed;

  String yearStr = String(now.year(), DEC);
  String monthStr = (now.month() < 10 ? "0" : "") + String(now.month(), DEC);
  String dayStr = (now.day() < 10 ? "0" : "") + String(now.day(), DEC);
  String hourStr = (now.hour() < 10 ? "0" : "") + String(now.hour(), DEC); 
  String minuteStr = (now.minute() < 10 ? "0" : "") + String(now.minute(), DEC);
  String secondStr = (now.second() < 10 ? "0" : "") + String(now.second(), DEC);
  String dayOfWeek = daysOfTheWeek[now.dayOfTheWeek()];

  // Complete time string
  String formattedTime = dayOfWeek + ", " + yearStr + "-" + monthStr + "-" + dayStr + " " + hourStr + ":" + minuteStr + ":" + secondStr;
  return formattedTime;
}

// Update the servo according to the current temperature
void updateServo(float temp) {
  const int multiplier = 100; 
  int integerTemp = temp * multiplier; // ex. 20 degrees to 200
  int servoAngle = map(integerTemp, servoTempMin*multiplier, servoTempMax*multiplier, 0, 179);
  myservo.write(servoAngle);
}

void updateLCD() {
  // get time like the following: "hh mm ss"
  DateTime now = rtc.now();
  
  String hourStr = (now.hour() < 10 ? "0" : "") + String(now.hour(), DEC);
  String minuteStr = (now.minute() < 10 ? "0" : "") + String(now.minute(), DEC);
  String secondStr = (now.second() < 10 ? "0" : "") + String(now.second(), DEC);

  String time = hourStr + " " + minuteStr + " " + secondStr;

  for (int i = 0; i < 8; i++) {
    lc.setChar(0, 7 - i, time[i], false);
  }
}

// Draws the analog clock to the screen, however, doesn't actually refresh the screen
void drawAnalogClock() {
  DateTime now = rtc.now();
  uint8_t second = now.second();
  float minute = now.minute() + second / 60;
  float hour = now.hour() + minute / 60;
  
  // Math behind the clock lines, visualized here: https://www.geogebra.org/classic/unfashgk
  float sx = sin(second * pi / 30) * secondRadius + clockX;
  float sy = -cos(second * pi / 30) * secondRadius + clockY;

  int mx = sin(minute * pi / 30) * minuteRadius + clockX;
  int my = -cos(minute * pi / 30) * minuteRadius + clockY;

  int hx = sin(hour * pi / 6) * hourRadius + clockX;
  int hy = -cos(hour * pi / 6) * hourRadius + clockY;

  // Draw second, minute and hour
  u8g.drawLine(clockX, clockY, sx, sy);
  u8g.drawLine(clockX, clockY, mx, my);
  u8g.drawLine(clockX, clockY, hx, hy);

  // Draw main hour lines
  u8g.drawVLine(clockX, clockY - clockRadius, clockMainHourLength);
  u8g.drawVLine(clockX, clockY + clockRadius - clockMainHourLength, clockMainHourLength);
  u8g.drawHLine(clockX - clockRadius, clockY, clockMainHourLength);
  u8g.drawHLine(clockX + clockRadius - clockMainHourLength, clockY, clockMainHourLength);

  u8g.drawCircle(clockX, clockY, clockRadius);  
}

// Update the screen
void draw(String time, String temp) {
  u8g.firstPage();
  do {
    drawAnalogClock();
    u8g.drawStr(5, 12, time.c_str());
    u8g.drawStr(5, 24, (temp+" "+char(176)+"C").c_str());

  } while (u8g.nextPage());
}