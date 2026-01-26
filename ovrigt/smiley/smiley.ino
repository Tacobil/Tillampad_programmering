
/* 
Name: Smiley
Author: Tacobilen
Date: 2025-10-02
Description: Give your screen a tired yet cute look o:
*/

#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>

#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, -1);

// 'Smiley_sleep_1', 15x15px
const unsigned char smiley_sleep_1 [] PROGMEM = {
	0x07, 0xc0, 0x18, 0x30, 0x20, 0x08, 0x40, 0x04, 0x40, 0x04, 0x92, 0x92, 0x8c, 0x62, 0x80, 0x02, 
	0x80, 0x02, 0x80, 0x02, 0x41, 0x84, 0x41, 0x84, 0x20, 0x08, 0x18, 0x30, 0x07, 0xc0
};
// 'Smiley_sleep_2', 15x15px
const unsigned char smiley_sleep_2 [] PROGMEM = {
	0x07, 0xc0, 0x18, 0x30, 0x20, 0x08, 0x40, 0x04, 0x40, 0x04, 0x92, 0x92, 0x8c, 0x62, 0x80, 0x02, 
	0x80, 0x02, 0x80, 0x02, 0x40, 0x04, 0x41, 0x04, 0x20, 0x08, 0x18, 0x30, 0x07, 0xc0
};

void drawBitmapScaled(int16_t x, int16_t y, const uint8_t *bitmap, int16_t w, int16_t h, uint8_t scale, uint16_t color) {
  for (int16_t j = 0; j < h; j++) {
    for (int16_t i = 0; i < w; i++) {
      // Read the bit at position (i, j)
      uint8_t byte = pgm_read_byte(bitmap + (j * ((w + 7) / 8)) + (i / 8));
      bool pixelOn = byte & (0x80 >> (i % 8));

      if (pixelOn) {
        display.fillRect(x + i * scale, y + j * scale, scale, scale, color);
      }
    }
  }
}

void drawSmiley(const uint8_t *bitmap) {
  uint8_t x = 34, y = 2; // aligned to center
  display.fillRect(x,y,62,62,BLACK);
  drawBitmapScaled(x,y,bitmap, 15, 15, 4, WHITE);
  display.display();
}


void setup() {
  digitalWrite(13, HIGH);
  display.begin(SSD1306_SWITCHCAPVCC, 0x3C);
  display.clearDisplay();
}

void loop() {
  drawSmiley(smiley_sleep_1);
  delay(1500);
  drawSmiley(smiley_sleep_2);
  delay(1500);
}
