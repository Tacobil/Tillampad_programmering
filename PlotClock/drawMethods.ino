// Moves pen quickly to (x, y)
void set_XY(float x, float y) {
  // check if left arm is out of reach
  if (sq(x) + sq(y) >= sq(L1 + L2)) {
    Serial.println("left arm out of reach");
    return;
  }


  y = -y;
  // left arm inverse kinematics
  float q2Left = -acos((sq(x) + sq(y) - sq(L1) - sq(L2)) / (2 * L1 * L2));
  float q1Left = atan2(y, x) + atan2((L2 * sin(q2Left)), (L1 + L2 * cos(q2Left)));
  q2Left = -q2Left;


  // compensate servo offset
  x -= OFFSET;

  // compensate pen offset
  x -= cos(q1Left + q2Left) * PENOFFSET;
  y -= sin(q1Left + q2Left) * PENOFFSET;

  // check if right arm is out of reach
  if (sq(x) + sq(y) >= sq(R1 + R2)) {
    Serial.println("right arm out of reach");
    return;
  }

  // right arm inverse kinematics
  float q2Right = acos((sq(x) + sq(y) - sq(R1) - sq(R2)) / (2 * R1 * R2));
  float q1Right = atan2(y, x) + atan2((R2 * sin(q2Right)), (R1 + R2 * cos(q2Right)));

  q1Left = -q1Left;
  q1Right = -q1Right;

  // with degrees
  int angleLeft = q1Left * 180 / PI - ANGLEOFFSET;
  int angleRight = q1Right * 180 / PI + ANGLEOFFSET;

  servoLeft.write(angleLeft);
  servoRight.write(angleRight);

  /* // with millis
  int angleLeftMillis = map(q1Left * 1000, 0, PI * 1000, 544, 2400);
  int angleRightMillis = map(q1Right * 1000, 0, PI * 1000, 544, 2400);
  servoLeft.writeMicroseconds(angleLeftMillis);
  servoRight.writeMicroseconds(angleRightMillis);
  */
}

void lift(int p) {
  switch (p) {
    case 0:  // pen down
      servoLift.write(90);
      break;
    case 1:  // pen up
      servoLift.write(100);
      break;
    case 2:  // pen idle
      servoLift.write(110);
      break;
  }
}

// Draws a line from current position to (x, y)
void drawTo(float x, float y) {
  float distance = sqrt(sq(x) + sq(y));
  int steps = distance * 2; // Number of steps to take. Times 4 means 4 steps per mm

  // Calculate step size X and step size Y
  float stepX = (x - lastX) / steps;
  float stepY = (y - lastY) / steps;

  for (int i = 0; i <= steps; i++) {
    set_XY(lastX + stepX * i, lastY + stepY * i);
  }

  lastX = x;
  lastY = y;
}

// Draw circle at position (x, y) with radius r
void drawCircle(float x, float y, float r) {
  for (float t = 0; t <= 2; t += 0.1) {
    float px = x + r * cos(t*PI);
    float py = y + r * sin(t*PI);
    drawTo(px, py);
  }
}

void drawArc(float x, float y, float r, float start, float stop) {

  lastX = x;
  lastY = y;
}


void drawDigit(float x, float y, uint8_t digit) {
  switch (digit) {
    case 0:
      lift(1);


      break;
  }
}