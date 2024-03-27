/**
 OSC binding for Reaper default OSC profile (see data folder) for IEM plugin Suite
 
 Data needed as input:
 source position as a Vector(x,y,z) -15m to 15m, -15m to 15m, -10m to 10m
 listener position as a Vector(x,y,z) -15m to 15m, -15m to 15m, -10m to 10m
 room dimensions as a Vector(x,y,z) depth 1m to 30m, width 1m to 30m, height 1m to 20m
 
 reaper API lua script
 https://www.reaper.fm/sdk/reascript/reascripthelp.html
 
 */

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

int ambisonicTrackIndex = 3;
int sourceTrackIndex = 4;

void setup() {
  size(400, 400);
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this, 12000);
  myRemoteLocation = new NetAddress("127.0.0.1", 8000);
}


void draw() {
  background(0);
}

void mouseDragged() {
  //void mousePressed() {
  //setListenerPosition(map(mouseX,0,width,0,1.0) , map(mouseY,0,width,0,1.0), map(mouseX,0,width,0,1.0));
  masterVolume(map(mouseY, 0, height, 0, 1));
}

//use this to adjust volume of each audio source or ambisonics bus (all audio sources are send to ambisonics track)
void volume(int in, float val) {
  //f/track/volume/db
  OscMessage myMessage = new OscMessage("/track/"+in+"/volume/db");
  //OscMessage myMessage = new OscMessage("/track/"+in+"/volume");
  myMessage.add(val); /* add an int to the osc message */
  oscP5.send(myMessage, myRemoteLocation);
  println("volume set for track "+in+" value: "+val);
}

//adjust master volume (currently not used)
void masterVolume(float val) {
  OscMessage myMessage = new OscMessage("/master/volume"); //n/master/volume s/master/volume/str
  myMessage.add(val); /* add an int to the osc message */
  oscP5.send(myMessage, myRemoteLocation);
  println("master volume: "+val);
}

//control spatial audio VST plugin----------------------------
//set room size - should be set once at the start of the program for all tracks
void setRoomSize(float x, float y, float z, int track ) {
  OscMessage myMessage = new OscMessage("/track/"+track+"/fx/2/fxparam/5,6,7/value"); //
  myMessage.add(x);
  myMessage.add(y);
  myMessage.add(z);
  oscP5.send(myMessage, myRemoteLocation);
}
//dynamically change audio source position for each audio source/track
void setSourcePosition(float x, float y, float z, int track ) {
  OscMessage myMessage = new OscMessage("/track/"+track+"/fx/2/fxparam/8,9,10/value"); //
  myMessage.add(x);
  myMessage.add(y);
  myMessage.add(z);
  oscP5.send(myMessage, myRemoteLocation);
}
//set listener position - should be set once at the start of the program for all tracks and then kept in sync for all tracks
void setListenerPosition(float x, float y, float z, int track ) {
  OscMessage myMessage = new OscMessage("/track/"+track+"/fx/2/fxparam/11,12,13/value"); //
  myMessage.add(x);
  myMessage.add(y);
  myMessage.add(z);
  oscP5.send(myMessage, myRemoteLocation);
}
//control reaper play button
void playAudio() {
  OscMessage myMessage = new OscMessage("/play");
  oscP5.send(myMessage, myRemoteLocation);
  println("play");
}
//control reaper stop button
void stopAudio() {
  OscMessage myMessage = new OscMessage("/stop");
  oscP5.send(myMessage, myRemoteLocation);
  println("stop");
}
//control reaper pause button
void pauseAudio() {
  OscMessage myMessage = new OscMessage("/pause");
  oscP5.send(myMessage, myRemoteLocation);
  println("stop");
}

//-----------------
//trigger custom action - actually lua script
void triggerAction(String actionID) {
  OscMessage myMessage = new OscMessage("/action");
  myMessage.add(actionID);//ID of the action (see in Reaper in Actions->Show Action List)
  oscP5.send(myMessage, myRemoteLocation);
  println("custom action trigerred");
}

//set name to track
void renameTrack(String newname, int trackID) {
  OscMessage myMessage = new OscMessage("/track/"+trackID+"/name"); //rename first track
  myMessage.add(newname);
  oscP5.send(myMessage, myRemoteLocation);
  println("track renamed");
}

//custom Actions can be set in Reaper - it also supports .lua script which we utilize here
//scripts are located in:
//C:\Users\3D-Audio\AppData\Roaming\REAPER\Scripts
void loadMediaFile(String filePath, int sourceIndex) {
  //first set path as a name of the track - later that will be red by lua script in reaper and used as a variable
  renameTrack(filePath, 1); //ie "C:/path/to/file.mp3"
  //volume acts as variable here - it will be used as a index of the track where we should place new media file
  volume(1, (float)sourceIndex );
  //trigger lua script inside reaper to load file based on first track name
  //script will read first track name and volume and use it as path and index variables
  triggerAction("_RS90361aec4e2b820549ce9f17feb68ac0b293fc22");
}
//--------------------


void sendIEMRoomEncoderReaper(int index, PVector loc) {
  //send RoomEncoder OSC for universal VST command in Reaper (not IEM integrated)
  //output range is the knob range inside Reaper VST - this depands on the selected room size
  
  //axis are rearranged based on the processing axis order using peasy 3D camera - you might need to test this
  
  OscMessage myMessage = new OscMessage("/track/"+(index+2)+"/fx/1/fxparam/8/value");
  myMessage.add( map(-loc.z, -1, 1, 0.35, 0.65) ); // 2nd and 3rd parameter is min and max range of the input vector
  oscP5.send(myMessage, myRemoteLocation);


  myMessage = new OscMessage("/track/"+(index+2)+"/fx/1/fxparam/9/value");
  myMessage.add( map(loc.x, -1, 1, 0.35, 0.65) );
  oscP5.send(myMessage, myRemoteLocation);


  myMessage = new OscMessage("/track/"+(index+2)+"/fx/1/fxparam/10/value");
  myMessage.add( map(loc.y, -1, 1, 0.0, 1.0 ) );
  oscP5.send(myMessage, myRemoteLocation);
}


void keyPressed() {
  if (key == 'p') {
    playAudio();
  }

  if (key == 's') {
    stopAudio();
  }

  if (key == 't') {
    pauseAudio();
  }

  if (key == 'a') {
    loadMediaFile("C:/Users/3D-Audio/Music/sample.mp3", 5);
  }
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());
}
