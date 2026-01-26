// max7219 8 digit 7 segment display

#include <LedControl.h>

LedControl lc = LedControl(11, 12, 10, 1);

void setup() {
  lc.shutdown(0, false);   // Wake up the MAX7219
  lc.setIntensity(0, 8);   // Brightness 0–15
  lc.clearDisplay(0);      // Clear the display

  // "HELLO"
  lc.setChar(0, 7, '1', false);
  lc.setChar(0, 6, '3', true); 
  lc.setChar(0, 5, '3', false);
  lc.setChar(0, 4, '7', false);

  lc.setChar(0, 3, '1', false);
  lc.setChar(0, 2, '3', true); 
  lc.setChar(0, 1, '3', false);
  lc.setChar(0, 0, '7', false);
}

void loop() {

}
