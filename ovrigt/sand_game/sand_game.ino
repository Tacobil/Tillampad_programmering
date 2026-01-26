/*
Name: Sand Game
Author: Tacobilen
Date: 2025-09-25
Description: A simple sand and fluid simulation game
*/
#include "U8glib.h"

U8GLIB_SSD1306_128X64 u8g(U8G_I2C_OPT_NO_ACK);

#define FONT_SMALL u8g_font_6x10
#define FONT_MEDIUM u8g_font_9x15
#define FONT_LARGE u8g_font_fub20
#define UNIFONT u8g_font_unifont

int potPin = A1;
int buttonPin = 2;

int rows = 8; // y
int cols = 16; // x

int _ = 0;

int particles[] = {
  _,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,
  _,_,_,_,_,_,_,1,_,1,_,_,_,_,_,_,
  _,_,_,_,_,_,_,1,_,1,_,_,_,_,_,_,
  _,_,_,_,_,1,_,_,_,_,_,1,_,_,_,_,
  _,_,_,_,_,_,1,1,1,1,1,_,_,_,_,_,
  _,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,
  _,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,
  _,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,
};

int pSize = 8;

// RES 128 x 64
// 64 x 32 
// 32 x 16
// 16 x 8
// 2 x 1


void setup() {
  Serial.begin(9600);
  u8g.setFont(UNIFONT);
  pinMode(potPin, INPUT);
  pinMode(buttonPin, INPUT);

  for (int i = 0; i < rows*cols; i++) {
    int x = i % cols;
    int y = i / rows;
    /*Serial.print(x);
    Serial.print(" ");
    Serial.println(y);*/
  }
}

void update() {
  for (int i = rows*cols-1; i >= 0; i++) {
      int x = i % cols;
      int y = i / cols;
      int particle = particles[i];
      int particle_below = particles[i + cols];

      if (particle_below == 0) {
        particles[i] = 0;
        particles[i+cols] = particle;
      }


  }
}

void loop() {
  // put your main code here, to run repeatedly:
  update();
  draw();
}

void draw() {
  u8g.firstPage();

  do {
    for (int i = 0; i < rows*cols; i++) {
      int x = i % cols;
      int y = i / cols;
      int particle = particles[i];

      if (particle == 1) {
        // u8g.drawPixel(x, y);
        u8g.drawBox(x*pSize, y*pSize, pSize, pSize);
      }


    }

  } while (u8g.nextPage());
  
}
