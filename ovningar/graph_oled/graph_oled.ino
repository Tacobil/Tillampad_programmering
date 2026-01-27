// Include libraries
#include "U8glib.h"

// Construct object
U8GLIB_SSD1306_128X64 u8g(U8G_I2C_OPT_NO_ACK);

// Declare pins
const int ldrPin = A0;  // Pin for LDR sensor; no pinMode needed in setup

// Declare Global Constants and Variables for circular register
const int length = 10;             // Number of values to store for averaging
int lastReadings[length] = {};  // Array to store recent sensor values
int currentIndex = 0;              // Tracks the index for the next reading

// Declare Global Constants and Variables for shifting register
const int oledLength = 128;
int allReadings[oledLength] = {};  // Array to store data for the OLED display
int readingIndex = 0;

void setup() {
  Serial.begin(9600);  // Initialize Serial Monitor
  u8g.setFont(u8g_font_unifont);
  pinMode(2, OUTPUT);
}


void loop() {
  digitalWrite(2, HIGH);
  int raw = analogRead(ldrPin);  // Read the sensor value
  int mean = updateMean(raw);  // Calculate the mean of the last readings

  updateOled(mean);  // Update OLED with the mean value

  /* Serial.print(mean); // Print the mean and raw reading
  Serial.print("   ");
  Serial.println(raw); */  
}

int updateMean(int r) {

  lastReadings[currentIndex] = r;

  currentIndex = (currentIndex + 1) % length;

  int sum = 0;

  for (int i = 0; i < length; i++) {
    sum = sum + lastReadings[i];
  }

  return sum / length;
}

void updateOled(int m) {
  
  // Shift all readings one step to the left to make space for the new reading
  int smallestValue = 64;
  int largestValue = 0;

  for (int i = 0; i < oledLength-1; i++) {
    int value = allReadings[i+1];
    allReadings[i] = value;

    if (value < smallestValue) {
      smallestValue = value;
    }

    if (value > largestValue) {
      largestValue = value;
    }
  }

  // Store the latest mean value in the last position (and mapp value to # pixels)
  allReadings[oledLength-1] = m/16;

  // Picture loop
  u8g.firstPage();
  do {

    int nextY = map(allReadings[0], smallestValue, largestValue, 0, 63);

    // Plot the values on the OLED display
    for (int x = 0; x < oledLength-1; x++) {
      int y = y = nextY;

      nextY = map(allReadings[x+1], smallestValue, largestValue, 0, 63);
      u8g.drawLine(x, y, x+1, nextY);
    }

  } while (u8g.nextPage());
}