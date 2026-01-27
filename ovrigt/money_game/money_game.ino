/* 
Name: Money Game
Author: Tacobilen
Date: 2025-09-12
Description: A game where you can unleash your greed and watch your income grow exponentially.
*/
#include "U8glib.h"
#include "Wire.h"

U8GLIB_SSD1306_128X64 u8g(U8G_I2C_OPT_NO_ACK);

int BUTTON_PIN = 2;
int POT_PIN = A0;

long money = 0;

int owned = 0;

long cost_base = 5;
float rate_growth = 1.174;

float production_base = 1;
float multipliers = 1;

int selector_x = 0;
int selector_y = 0;

void setup() {
  Wire.begin();
  pinMode(BUTTON_PIN, INPUT);
  pinMode(POT_PIN, INPUT);

  Serial.begin(9600);

  u8g.setFont(u8g_font_5x7);
}

void loop() {
  if (analogRead(POT_PIN) <= 1023/2) { // ui nav 1
  selector_y = 22 - 4;
  selector_x = 2;
    if (digitalRead(BUTTON_PIN) == HIGH) {
      produce();
    }
  } else if (analogRead(POT_PIN) > 1023/2) { // ui nav 2
    selector_y = 44 - 4;
    selector_x = 2;
    if (digitalRead(BUTTON_PIN) == HIGH) {
      buy();
    }
  }
  draw();
}

void produce() {
  money += production_base * multipliers * owned + 1;
}

int get_price() {
  return floor(cost_base*pow(rate_growth, owned)+0.5);
}

void buy() {
  int price = get_price();
  if (money >= price) {
    owned++;
    money = money - price;
  }
}

void draw() {
  u8g.firstPage();
  do {
    u8g.drawPixel(0,0);
    u8g.drawStr(5, 11, ("money: "+String(money)).c_str());
    u8g.drawStr(5, 22, ("lvl up: "+String(get_price())).c_str());
    u8g.drawCircle(selector_x, selector_y, 3);
  } while (u8g.nextPage());
}

