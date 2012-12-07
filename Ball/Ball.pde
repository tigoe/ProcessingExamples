/*
  Bouncy Ball
  context: Processing 
  
  A ball bounces around the screen forever.
  
  created back in the mists of time
  this version 7 Dec 2012
  by Tom Igoe
  
  This example is in the public domain
  
*/

float hPos = 0;                    // initial horizontal position of the ball
float vPos = 0;                    // initial vertical position of the ball
float hDirection = 3;              // horizontal direction of the ball
float vDirection = 3;              // vertical direction of the ball

void setup() {
  size(800, 600);                   // set the window size to 800x600
  noStroke();                       // no stroke around the things you draw
  frameRate(60);                    // frame rate 60 frames per second
  ellipseMode(CENTER);              // draw circles with center registration point
}

void draw() {
  background (#3456DE);             // background is something bluish
  fill(#FFFFFF);                    // fill color is white

  // in the if statement below, || means "or":
  if (hPos >= width || hPos < 0) {  // if the hPos goes off either side
    hDirection = -hDirection;       // reverse the hDirection
  }
  
  // in the if statement below, || means "or":
  if (vPos >= height || vPos < 0) { // if the vPos goes off either side
    vDirection = -vDirection;       // reverse the vDirection
  }

  hPos = hPos + hDirection;         // move in the hDirection
  vPos = vPos + vDirection;         // move in the vDirection

  ellipse(hPos, vPos, 30, 30);      // draw the actual ball
}

