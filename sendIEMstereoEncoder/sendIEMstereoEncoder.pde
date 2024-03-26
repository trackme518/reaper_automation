import oscP5.*;
import netP5.*;

OscP5 osc;

NetAddress myRemoteLocation;
void setup() {
  size(400, 400);
  frameRate(25);

  //osc = new OscP5( this, 9999 );

  myRemoteLocation = new NetAddress("127.0.0.1", 9999);
}


void draw() {
  background(0);
  //sendQuat();
}

void sendQuat() {
  OscMessage myOscMessage = new OscMessage("/StereoEncoder/qw");
  myOscMessage.add(random(-1, 1));
  OscP5.flush(myOscMessage, myRemoteLocation);

  myOscMessage = new OscMessage("/StereoEncoder/qx");
  myOscMessage.add(random(-1, 1));
  OscP5.flush(myOscMessage, myRemoteLocation);

  myOscMessage = new OscMessage("/StereoEncoder/qy");
  myOscMessage.add(random(-1, 1));
  OscP5.flush(myOscMessage, myRemoteLocation);

  myOscMessage = new OscMessage("/StereoEncoder/qz");
  myOscMessage.add(random(-1, 1));
  OscP5.flush(myOscMessage, myRemoteLocation);
}

void mousePressed() {

}
