// Circular list instead of shifting

#include "U8glib.h"

U8GLIB_SSD1306_128X64 u8g(U8G_I2C_OPT_NO_ACK);

const int ldrPin = A0;  // Pin for LDR sensor; no pinMode needed in setup

const int length = 10;             // Number of values to store for averaging
int recentReadings[length] = { 0 };  // Array to store recent sensor values
int currentIndex = 0;              // Tracks the index for the next reading

// Declare Global Constants and Variables for circular register
const int oledLength = 128;
int allReadings[oledLength] = {};  // Array to store data for the OLED display
int firstIndex = 0;

void setup() {
  Serial.begin(9600);  // Initialize Serial Monitor
  u8g.setFont(u8g_font_unifont);
  pinMode(2, OUTPUT); // initiate testing led pin
}

void loop() {
  digitalWrite(2, HIGH); // turn on testing led
  int raw = analogRead(ldrPin);  // Read the sensor value
  int mean = updateMean(raw);  // Calculate the mean of the last readings

  updateOled(mean);  // Update OLED with the mean value

  /* Serial.print(mean); // Print the mean and raw reading
  Serial.print("   ");
  Serial.println(raw); */  
}

int updateMean(int r) {

  recentReadings[currentIndex] = r;

  currentIndex = (currentIndex + 1) % length;


  int sum = 0;

  for (int i = 0; i < length; i++) {
    sum = sum + recentReadings[i];
  }

  return sum / length;
}

void updateOled(int m) {
  allReadings[firstIndex] = m/16;

  firstIndex = (firstIndex + 1) % oledLength;

  // Picture loop
  u8g.firstPage();
  do {
    // Plot the values on the OLED display
    for (int x = 0; x < oledLength-1; x++) {
      int y = allReadings[(x + firstIndex) % (oledLength)];
      int nextY = allReadings[(x + firstIndex + 1) % (oledLength)];

      u8g.drawLine(x, y, x+1, nextY);
    }

  } while (u8g.nextPage());
}