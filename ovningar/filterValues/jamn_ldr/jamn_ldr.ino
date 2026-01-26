int ldrPin = A0;

const int length = 1;
unsigned int ldrValues[length] = {0};

int index = 0;

void setup() {
  Serial.begin(9600);  // Starta Serial Monitor
  pinMode(ldrPin, INPUT);
}

int calculateAverage() {
  long sum = 0;

  // (7) Summera alla värden i arrayen
  for (int i = 0; i < length; i++) {
    sum = sum + ldrValues[i];
  }

  // (8) Beräkna medelvärdet
  float average = sum / length;
  return average;
}

void loop() {
  int raw = analogRead(ldrPin);

  // (4) Läs ett nytt sensorvärde och skriv över det äldsta värdet i arrayen
  ldrValues[index] = raw;

  // (5) Öka index-variabeln med 1 och återställ den om den går utanför arrayens storlek
  index = (index+1) % length;

  // (6) Skapa temporära variabler för att beräkna summan och medelvärdet
  int average = calculateAverage();

  // (9) Visa resultatet på Serial Monitor
  Serial.print(raw);
  Serial.print("  ");
  Serial.println(average);

  delay(50);  // Kort paus för stabilare mätningar
}