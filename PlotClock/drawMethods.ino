
struct Point {
  int x;
  int y;
};

Point points[] = {
{-21, 86},
{0, -100},
{-19, 86},
{-11, 88},
{-1, 90},
{3, 91},
{1, -100},
{-24, 80},
{0, -100},
{-23, 80},
{-17, 80},
{-7, 81},
{1, 83},
{6, 83},
{11, 84},
{1, -100},
{-12, 82},
{0, -100},
{-12, 82},
{-12, 77},
{-13, 72},
{-15, 67},
{-16, 64},
{-16, 63},
{1, -100},
{-1, 84},
{0, -100},
{-1, 84},
{-1, 81},
{0, 76},
{0, 71},
{0, 67},
{0, 65},
{1, 65},
{3, 65},
{4, 67},
{5, 69},
{5, 71},
{5, 71},
{1, -100},
{32, 97},
{0, -100},
{32, 97},
{31, 94},
{30, 90},
{29, 88},
{29, 87},
{1, -100},
{31, 92},
{0, -100},
{31, 92},
{31, 92},
{37, 93},
{43, 94},
{47, 94},
{50, 94},
{50, 94},
{50, 94},
{50, 94},
{51, 94},
{51, 94},
{52, 94},
{52, 94},
{52, 94},
{52, 94},
{52, 94},
{52, 94},
{52, 94},
{1, -100},
{37, 89},
{0, -100},
{37, 89},
{41, 90},
{47, 91},
{50, 92},
{51, 92},
{51, 92},
{51, 92},
{1, -100},
{31, 85},
{0, -100},
{31, 85},
{34, 85},
{38, 85},
{41, 86},
{44, 87},
{47, 87},
{47, 87},
{48, 86},
{49, 81},
{50, 79},
{50, 76},
{50, 74},
{50, 73},
{51, 72},
{51, 73},
{52, 74},
{52, 74},
{52, 75},
{1, -100},
{44, 81},
{0, -100},
{44, 81},
{43, 80},
{41, 78},
{40, 76},
{39, 74},
{38, 73},
{38, 73},
{1, -100},
{33, 80},
{0, -100},
{33, 80},
{35, 79},
{38, 77},
{40, 75},
{44, 72},
{46, 70},
{46, 70},
{46, 70},
{1, -100},




};

int numPoints = sizeof(points) / sizeof(points[0]);



/*
  Sets position to (x, y). 

  Parameters:
    float x    x-coordinate
    float y    y-coordinate

  Returns: void
*/
void setXY(float x, float y) {
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

  // to degrees
  int angleLeft = q1Left * 180 / PI - ANGLEOFFSET;
  int angleRight = q1Right * 180 / PI + ANGLEOFFSET;

  servoLeft.write(angleLeft);
  servoRight.write(angleRight);
}

/*
  A function that controls the lift motor.

  Parameters:
    int state   0 = down, 1 = pen up, 2 = pen idle
  Returns: void
*/
void lift(int state) {
  Serial.println("lift: " + String(state));
  switch (state) {
    case 0:  // pen down
      servoLift.write(40);
      break;
    case 1:  // pen up
      servoLift.write(60);
      break;
    case 2:  // pen idle
      servoLift.write(70);
      break;
  }
  delay(400);
}

/*
  Function that draws a line to position (x, y). Unlike setXY, this takes small steps to the destination.

  Parameters:
    float x    x-coordinate to draw to
    float y    y-coordinate to draw to

  Returns: void
*/
void drawTo(float x, float y) {
  float distance = sqrt(sq(x - lastX) + sq(y - lastY));
  int steps = distance * 8;  // Number of steps to take. Times 4 means 4 steps per mm
  if (steps == 0) {
    setXY(x, y);
    return;
  }

  // Calculate step size X and step size Y
  float stepX = (x - lastX) / steps;
  float stepY = (y - lastY) / steps;

  for (int i = 0; i <= steps; i++) setXY(lastX + stepX * i, lastY + stepY * i);

  lastX = x;
  lastY = y;
}

/*
  Function that draws an arc counter-clockwise, by drawing a portion of a circle.

  Parameters:
    float x         x-coordinate of the circle
    float y         y-coordinate of the circle
    float r         radius of the circle
    int start       angle to start at (degrees)
    int stop        angle to stop at (degrees)
    float stretch   stretch factor x-axis
    bool delayAtStart  determines if the function should go to starting pos and then delay

  Returns: void
*/
void drawArcCCW(float x, float y, float r, float start, float stop, float stretch, bool penDown) {
  for (int i = start; i <= stop; i += 1) {
    float angleRad = i * PI / 180.0;

    float px = x + stretch * r * cos(angleRad);
    float py = y + r * sin(angleRad);
    if (i == start) {
      setXY(px, py);
      lastX = px;
      lastY = py;

      if (penDown) {
        lift(0);
      }

    } else {
      drawTo(px, py);
    }
  }
}

/*
  Function that draws an arc clockwise, by drawing a portion of a circle.

  Parameters:
    float x         x-coordinate of the circle
    float y         y-coordinate of the circle
    float r         radius of the circle
    int start       angle to start at (degrees)
    int stop        angle to stop at (degrees)
    float stretch   stretch factor x-axis
    bool delayAtStart  determines if the function should go to starting pos and then delay

  Returns: void
*/
void drawArcCW(float x, float y, float r, int start, int stop, float stretch, bool penDown) {
  for (int i = start; i >= stop; i -= 1) {
    float angleRad = i * PI / 180.0;

    float px = x + stretch * r * cos(angleRad);
    float py = y + r * sin(angleRad);

    if (i == start) {

      setXY(px, py);
      lastX = px;
      lastY = py;

      if (penDown) {
        lift(0);
      }

    } else {
      drawTo(px, py);
    }
  }
}

/*
  Function that draws a character.

  Parameters:
    char c   the character to draw
    float x     x-coordinate
    float y     y-coordinate
    float s     scale

  Returns: void
*/
void drawChar(char c, float x, float y, float s) {
  switch (c) {
    case '(':
      drawArcCCW(x + 7.5 * s, y + 10 * s, 13 * s, 130, 230, 0.7, true);
      break;
    case '=':
      lastX = x + 0 * s;
      lastY = y + 14 * s;
      setXY(lastX, lastY);

      lift(0);
      drawTo(x + 13 * s, y + 14 * s);
      lift(1);

      lastX = x + 0 * s;
      lastY = y + 6 * s;
      setXY(lastX, lastY);

      lift(0);
      drawTo(x + 13 * s, y + 6 * s);
      break;
    case ':':
      drawArcCW(x + 5 * s, y + 14 * s, 1 * s, 360, 0, 1, true);
      lift(1);
      drawArcCW(x + 5 * s, y + 7 * s, 1 * s, 360, 0, 1, true);
      break;

    // Digits
    case '0':
      drawArcCCW(x + 7 * s, y + 10 * s, 10 * s, 90, 460, 2.0 / 3.0, true);
      break;

    case '1':
      lastX = x + 3 * s;
      lastY = y + 15 * s;
      setXY(lastX, lastY);

      lift(0);
      drawTo(x + 10 * s, y + 20 * s);
      drawTo(x + 10 * s, y + 0 * s);
      break;

    case '2':
      drawArcCW(x + 7 * s, y + 14.5 * s, 5.5 * s, 160, -50, 1, true);
      drawTo(x + 1 * s, y + 0 * s);
      drawTo(x + 13 * s, y + 0 * s);
      break;

    case '3':
      drawArcCW(x + 7 * s, y + 15 * s, 5 * s, 135, -90, 1.2, true);
      drawArcCW(x + 7 * s, y + 5 * s, 5 * s, 90, -140, 1.2, false);
      break;

    case '4':
      lastX = x + 13 * s;
      lastY = y + 6 * s;
      setXY(lastX, lastY);

      lift(0);
      drawTo(x + 0 * s, y + 6 * s);
      drawTo(x + 10 * s, y + 20 * s);
      drawTo(x + 10 * s, y + 0 * s);
      break;

    case '5':
      lastX = x + 14 * s;
      lastY = y + 20 * s;
      setXY(lastX, lastY);

      lift(0);
      drawTo(x + 2 * s, y + 20 * s);
      drawTo(x + 2 * s, y + 10 * s);
      drawArcCW(x + 7 * s, y + 6 * s, 6 * s, 133, -150, 1.2, false);
      break;

    case '6':
      drawArcCCW(x + 7.2 * s, y + 12 * s, 8 * s, 40, 180, 0.9, true);
      drawTo(x + 0 * s, y + 6.5 * s);
      drawArcCCW(x + 7.2 * s, y + 6 * s, 6 * s, 180, 540, 1.2, false);
      break;

    case '7':
      lastX = x + 1 * s;
      lastY = y + 20 * s;
      setXY(lastX, lastY);
      lift(0);

      drawTo(x + 15 * s, y + 20 * s);
      drawTo(x + 4 * s, y + 0 * s);
      break;

    case '8':
      drawArcCCW(x + 7.5 * s, y + 15 * s, 5 * s, 90, 270, 1.2, true);
      drawArcCW(x + 7.5 * s, y + 5 * s, 5 * s, 90, -270, 1.3, false);
      drawArcCCW(x + 7.5 * s, y + 15 * s, 5 * s, 270, 450, 1.2, false);
      break;

    case '9':
      drawArcCW(x + 5 * s, y + 14 * s, 6 * s, 360, 0, 1.2, true);
      drawTo(x + 12 * s, y + 6.5 * s);
      drawArcCW(x + 5.5 * s, y + 6 * s, 6 * s, 0, -160, 1.1, false);
      break;
  }
}

/*
  Function that draws a string.

  Parameters:
    String str   the string to draw
    float x     x-coordinate
    float y     y-coordinate
    float s     scale

  Returns: void
*/
void drawString(String str, float x, float y, float s) {
  int N = str.length();
  for (int i = 0; i < N; i++) {
    lift(1);
    drawChar(str[i], x + i * 15 * s, y, s);
  }
  lift(1);
}

void drawPoints() {
  for (int i = 0; i < numPoints; i++) {
    Point p = points[i];


    if (p.y == -100) {
      lift(p.x);
    } else {
      drawTo(p.x, p.y);
    }
  }
  lift(2);
}
