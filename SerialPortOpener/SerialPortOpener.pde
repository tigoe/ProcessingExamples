/*
  Serial Port Opener
 
 Lists the available serial ports, and waits for the user to type the number of the 
 one she wants to open, followed by the return key. Then opens that port and displays the
 incoming bytes on the screen.
 
 created 18 Aug 2013
 by Tom Igoe
 */

import processing.serial.*;

Serial myPort;                // serial port to listen on

int portNumber = -1;          // port number to open from Serial.list()
String portNumString = "";    // the port number as a string

int xPos = 10;
int yPos = 50;

void setup() {
  size(400, 300);             // set the window size:
  background(0);              // make the background black:
  listPorts();                // list the serial ports on the screen
}

void draw() {
  // nothing happens here
}


void keyReleased() {
  if (portNumber < 0 && key != ENTER) {    // if there's no port number and the user hits enter
    if (key >= '0' && key <= '9') {        // if the user types 0 through 9,
      portNumString += key;                // add the keystroke to the port number string
    }
  }
  if (key == ENTER || key == RETURN) {
    portNumber = int(portNumString);     // convert the number string to an int
    if (portNumber >= 0 && portNumber <= Serial.list().length) {    // if the port number's valid
      openPort();        // open the port
    } 
    else {
      println("invalid port number: " + portNumber);
    }
  }
}

/* 
 List the available serial ports on the screen
 */

void listPorts() {
  String portList = "Type the number of your port from the list below, then hit enter:\n\n";
  for (int thisPort=0; thisPort < Serial.list().length; thisPort++) {
    portList += thisPort + ") ";
    portList += Serial.list()[thisPort];
    portList += "\n";
  }
  text(portList, 10, 30);
}

/* 
 open the serial port
 */
void openPort() {
  String portName = Serial.list()[portNumber];    // get the port name string
  myPort = new Serial(this, portName, 9600);      // open the port
  background(0);
  text("Serial port " + portName + " opened", 10, 30);   // report that it's open
}

/*
  listen for serial data
 */
void serialEvent( Serial myPort) {    
  int inByte = myPort.read();    // read incoming byte
  text(inByte, xPos, yPos);

  if (xPos <= width-30) {      // if aren't at the right edge of the screen
    xPos += 30;             // move the cursor horizontally
  } 
  else {                  // if you reach the right edge of the screen
    xPos = 10;              // move x to the left edge
    yPos += 20;            // move y down one row
  }

  if (yPos >= height) {
    background(0);
    yPos = 30;
    xPos = 10;
  }
}

