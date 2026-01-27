#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>

#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, -1);

int8_t dvd_x, dvd_y;
int8_t dvd_w = 26, dvd_h = 10;
int8_t dvd_dx, dvd_dy;

// 'dvd logo', 24x10px
const unsigned char dvd_bitmap [] PROGMEM = {
	0x3f, 0xe1, 0xfe, 0x03, 0xe3, 0x87, 0x31, 0xf6, 0xe7, 0x31, 0xbe, 0xc7, 0x7f, 0x18, 0xfe, 0x7e, 
	0x19, 0xf8, 0x00, 0x10, 0x00, 0x07, 0xff, 0x80, 0xff, 0x07, 0xfc, 0x3f, 0xff, 0xf8
};

void initDvd() {
  dvd_x = 64 - dvd_w/2;
  dvd_y = 32 - dvd_h/2;

  dvd_dx = 1;
  dvd_dy = 1;
}

void updateDvd() {
  // Horizontal bounds
  bool hit_x = false, hit_y = false;
  if (dvd_x + dvd_dx < 1 || dvd_x + dvd_dx > SCREEN_WIDTH - dvd_w - 1) {
    dvd_dx = -dvd_dx;
    hit_x = true;
  }

  // Vertical bounds
  if (dvd_y + dvd_dy < 1 || dvd_y + dvd_dy > SCREEN_HEIGHT - dvd_h - 1) {
    dvd_dy = -dvd_dy;
    hit_y = true;
  }

  if (hit_x && hit_y) {
    Serial.println("Vicoty");
  }

  display.fillRect(dvd_x, dvd_y, dvd_w, dvd_h, BLACK);
  dvd_x += dvd_dx;
  dvd_y += dvd_dy;
  // display.drawRect(dvd_x, dvd_y, dvd_w, dvd_h, WHITE); hitbox
  display.drawBitmap(dvd_x+1, dvd_y, dvd_bitmap, 24, 10, WHITE);
  display.display();
}

void setup() {
  display.begin(SSD1306_SWITCHCAPVCC, 0x3C);
  display.clearDisplay();
  initDvd();
  display.drawRect(0,0, 128, 64, WHITE);
}

void loop() {
  updateDvd();
  delay(1);
}
