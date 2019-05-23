// Rudimentary webcam program: 
// Creates cam object that reads frames from the webcam and sends them to the screen. 

import processing.video.*; //the library must first be installed via Sketch>import library>add library 


Capture cam;

void setup() {
  size(1280, 720); // set window size (does not need to be same as image
  cam = new Capture(this, 1280, 720, 30); //specify resolution 1280x720 points at 30 frames per s
  cam.start();
}

void draw() {
  if(cam.available()) {
    cam.read();
  }
  //display the image on the processing window, start at origin, scale to the full window width and height
  // one can actually use this to zoom to a specific section of the frame.  
  image(cam, 0, 0, width, height);
}