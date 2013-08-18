/*
  XBee Packet Reader and Graphing Program
 Context: Processing 
 Reads a packet from an XBee radio via serial and parses it. 
 Graphs the results over time. The packet should be 22 bytes long, 
 made up of the following:
 byte 1:     0x7E, the start byte value
 byte 2-3:   packet size, a 2-byte value  (not used here)
 byte 4:     API identifier value, a code that says what this response is (not used here)
 byte 5-6:   Sender's address
 byte 7:     signalStrength, Received Signal Strength Indicator (not used here)
 byte 8:     Broadcast options (not used here)
 byte 9:     Number of samples to follow
 byte 10-11: Active channels indicator (not used here)
 byte 12-21: 5 10-bit values, each ADC samples from the sender 
 
 XBee settings for the remote radio:
 ATDLFFFF,D02,IR64,ATIT5, WR
 
 created 2007
 modified 18 Aug 2013
 by Tom Igoe
 */

import processing.serial.*;

Serial myPort;                // serial port to listen on
int hPos = 0;                 // horizontal position on the graph
int lineHeight = 14;          // a variable to set the line height

int portNumber = -1;          // port number to open from Serial.list()
String portNumString = "";    // the port number as a string

int[] data = new int[22];     // the array for the packet data
int dataIndex = 0;            // index of the data for the next byte

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
  listen for serial packets
 */
void serialEvent( Serial myPort) {    
  int inByte = myPort.read();    // read incoming byte
  if (inByte == 0x7E) {          // packets start with 0x7E, so
    dataIndex = 0;               // reset the data index
    parseData(data);             // parse the current packet
  } 
  else {                         // this byte isn't the start of a packet, so
    data[dataIndex] = inByte;    // add it to the data arrray and
    dataIndex++;                 // update the array index
  }
}
/* 
 Once you've got a packet, you need to extract the useful data. 
 This method gets the address of the sender and the 5 ADC readings.
 It then averages the ADC readings and gives you the result.
 */
void parseData(int[] thisPacket) {
  // make sure the packet is 22 bytes long first:
  if (thisPacket.length >= 22) {
    int adcStart = 11;                     // ADC reading starts at byte 12
    int numSamples = thisPacket[8];        // number of samples in packet
    int[] adcValues = new int[numSamples]; // array to hold the 5 readings
    int total = 0;                         // sum of all the ADC readings

    // read the address. It's a two-byte value, so you
    // add the two bytes as follows:
    int address = thisPacket[5] + thisPacket[4] * 256;

    // read the received signal strength:
    int signalStrength = thisPacket[6];
    
    // make sure you have at least one sample:
    if (numSamples > 0) {          
      // read <numSamples> 10-bit analog values, two at a time
      // because each reading is two bytes long:
      for (int i = 0; i < numSamples * 2;  i=i+2) {
        // 10-bit value = high byte * 256 + low byte:
        int thisSample = (thisPacket[i + adcStart] * 256) + 
          thisPacket[(i + 1) + adcStart];
        // put the result in one of 5 bytes:
        adcValues[i/2] = thisSample;
        // add the result to the total for averaging later:
        total = total + thisSample;
      }
      // average the result:
      int average = total / numSamples;
      // draw a line on the graph, and the readings:
      drawGraph(average);
      drawReadings(average, signalStrength);
    }
  }
}
/*
  update the graph 
 */
void drawGraph(int thisValue) {
  // draw the line:
  stroke(#4F9FE1);
  // map the given value to the height of the window:
  float graphValue = map(thisValue, 0, 1023, 0, height);
  // detemine the line height for the graph:
  float graphLineHeight = height - (graphValue);
  // draw the line:
  line(hPos, height, hPos, graphLineHeight);
  // at the edge of the screen, go back to the beginning:
  if (hPos >= width) {
    hPos = 0;
    //wipe the screen:
    background(0);
  } 
  else {
    // increment the horizontal position to draw the next line:
    hPos++;
  }
}

/*
  draw the date and the time
 */
void drawReadings(int thisReading, int thisSignalStrength) {
  // set up an array to get the names of the months 
  // from their numeric values:
  String[] months = {
    "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", 
    "Sep", "Oct", "Nov", "Dec"
  };

  // format the date string:
  String date = day() + " " + months[month() -1] + " " + year() ;

  // format the time string
  // all digits are number-formatted as two digits:
  String time = nf(hour(), 2) + ":" + nf(minute(), 2)  + ":" + nf(second(), 2);

  // calculate the voltage from the reading:
  float voltage = thisReading * 3.3 / 1024;

  // choose a position for the text:
  int xPos = 20;
  int yPos = 20;

  // erase the previous readings:
  noStroke();
  fill(0);
  rect(xPos, yPos, 180, 80); 
  // change the fill color for the text:
  fill(#4F9FE1);
  // print the readings :
  text(date, xPos, yPos + lineHeight);
  text(time, xPos, yPos + (2 * lineHeight));
  text("Voltage: " + voltage + "V", xPos, yPos + (3 * lineHeight));
  text("Signal Strength: -" + thisSignalStrength + " dBm", xPos, yPos + (4 * lineHeight));
}

