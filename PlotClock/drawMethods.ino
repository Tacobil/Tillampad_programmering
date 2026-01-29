
struct Point {
  int x;
  int y;
};

Point points[] = {
{16, 100},
{0, -100},
{16, 100},
{13, 100},
{8, 100},
{2, 97},
{-1, 92},
{-3, 84},
{-3, 77},
{-2, 70},
{2, 63},
{11, 60},
{21, 61},
{28, 67},
{34, 75},
{37, 81},
{39, 87},
{38, 92},
{36, 97},
{32, 100},
{27, 103},
{22, 104},
{18, 104},
{14, 104},
{11, 103},
{8, 101},
{5, 100},
{3, 99},
{2, 97},
{1, 97},
{1, -100},
{5, 91},
{0, -100},
{5, 91},
{5, 90},
{5, 87},
{6, 85},
{6, 85},
{7, 85},
{8, 87},
{9, 89},
{9, 90},
{9, 92},
{7, 93},
{6, 93},
{5, 93},
{5, 93},
{4, 92},
{1, -100},
{18, 92},
{0, -100},
{18, 92},
{18, 92},
{18, 94},
{19, 95},
{19, 96},
{20, 97},
{22, 96},
{22, 95},
{22, 93},
{22, 91},
{22, 90},
{22, 88},
{22, 88},
{21, 88},
{21, 88},
{20, 89},
{20, 90},
{20, 91},
{19, 92},
{19, 92},
{19, 93},
{19, 93},
{1, -100},
{10, 82},
{0, -100},
{10, 82},
{10, 82},
{13, 82},
{14, 82},
{15, 82},
{15, 82},
{16, 81},
{16, 80},
{16, 80},
{16, 79},
{15, 79},
{14, 79},
{13, 80},
{13, 80},
{12, 80},
{12, 80},
{11, 80},
{10, 80},
{10, 80},
{10, 81},
{10, 81},
{10, 82},
{11, 82},
{11, 82},
{11, 82},
{11, 82},
{1, -100},
{-1, 68},
{0, -100},
{-1, 68},
{-1, 67},
{-4, 66},
{-6, 63},
{-8, 61},
{-9, 58},
{-9, 56},
{-9, 54},
{-6, 53},
{-3, 52},
{0, 53},
{1, 55},
{4, 57},
{5, 59},
{6, 60},
{6, 60},
{6, 60},
{1, -100},
{30, 70},
{0, -100},
{30, 70},
{32, 70},
{35, 70},
{37, 68},
{39, 66},
{40, 65},
{41, 63},
{41, 61},
{40, 59},
{35, 57},
{30, 57},
{27, 57},
{24, 57},
{23, 57},
{21, 58},
{20, 59},
{18, 60},
{18, 60},
{18, 60},
{18, 60},
{1, -100},
{36, 99},
{0, -100},
{36, 99},
{36, 99},
{38, 101},
{41, 101},
{44, 100},
{47, 97},
{48, 94},
{49, 92},
{49, 89},
{47, 87},
{44, 86},
{43, 85},
{42, 85},
{41, 85},
{41, 85},
{40, 85},
{40, 85},
{39, 85},
{39, 85},
{1, -100},
{-4, 83},
{0, -100},
{-4, 83},
{-4, 83},
{-6, 83},
{-8, 83},
{-10, 82},
{-11, 81},
{-13, 80},
{-13, 79},
{-14, 77},
{-13, 75},
{-12, 73},
{-11, 72},
{-9, 71},
{-8, 71},
{-6, 72},
{-5, 73},
{-4, 73},
{-3, 74},
{-3, 74},
{-3, 74},
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
      servoLift.write(30);
      break;
    case 1:  // pen up
      servoLift.write(50);
      break;
    case 2:  // pen idle
      servoLift.write(60);
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
    drawChar(str[i],x + i * 15 * s, y, s);
  }
  lift(1);
}

void drawPoints() {
  lift(1);
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
