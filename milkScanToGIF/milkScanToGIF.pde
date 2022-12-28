/**
MilkScanner app V0.1 3D scanner
Date: 3-2-2014
Author: Adam Harris
email: adam.projectbloc@gmail.com
Website: www.sheekgeek.org and http://fabacademy.org/archives/2014/students/harris.adam/index.html

License: 
Do what you want, give me some credit as well (unless it 
breaks something, in which case that's all on you and I've
never seen this code before in my life.)

Dependencies:
This code uses a few libraries:
OpenCV for Processing   <-- Could have gotten away with built-in processing video, maybe I'll make a version of that too.
ControlP5
gifAnimation

All of these are available from the processing 2.1.1 
"Sketch-->AddLibrary" menu


Usage:
1. Hang a camera over top a vessel containing an object you want to scan.
2. if the object is light in color, choose a dark liquid, otherwise choose a white liquid
3. Put the object in the vessel (secure it to the bottom with clay or something so it won't float
4. pour a small amount of the liquid in the vessel slowly to cover the bottom of the vessel
5. start this app and adjust the settings in the control window.
    -- Brightness is processed first
    -- Blur can help kill some of the noise in the image. use sparingly though
    -- Threshold is similar to Brightness. Take your pick between them really.
   -- INVERT button may be needed if you use a dark liquid (You want the outline of your object to be WHITE and the background BLACK)
6. YOU MUST HAVE THE MAIN WINDOW IN FOCUS, Press the spacebar to add a frame to the GIF
7. Pour a bit more liquid in and GOTO #7 until liquid completely covers the object (let the camera decide when the object is covered, not your eyeballs)
8. When finished, press 's' on the keyboard to export your final GIF.
9. *Copy and rename this GIF* from the processing script folder. If you don't rename it, IT WILL BE OVERWRITTEN IF THE PROGRAM RUNS AGAIN
10. Edit and clean up GIF in GIMP, 
11. use fab modules to export GIF to PNG heightmap or STL
12. 3D print the STL file
13. rinse, repeat
14. be happy that you just built a 3D scanner for the cost of a webcam and bottle of milk or soda (or india ink or coffee, etc.) 
  (I couldn't end it on #13)


Future TODO:
--reducing the number of libraries by using processing's built-in video filters
--make it possible to only use a region of interest
--export directly as STL or PNG
--3D print directly
*/

import gab.opencv.*;
import processing.video.*;
import java.awt.*;
import java.awt.Frame;
import java.awt.BorderLayout;
import controlP5.*;
import gifAnimation.*;

GifMaker gifExport;



private ControlP5 cp5;

ControlFrame cf;

int threshVal, brightVal, blurVal;
boolean invertToggle = false;

Capture video;
OpenCV opencv;
PImage  img, thresh, blur, bright;

void setup() {
  size(640, 480);
  cp5 = new ControlP5(this);
   gifExport = new GifMaker(this, "export.gif");
  gifExport.setRepeat(0); // make it an "endless" animation
//  gifExport.setTransparent(0,0,0); // make black the transparent color. every black pixel in the animation will be transparent
 
  // by calling function addControlFrame() a
  // new frame is created and an instance of class
  // ControlFrame is instanziated.
  cf = addControlFrame("extra", 300,200);
  
  
  video = new Capture(this, 640/2, 480/2);
  opencv = new OpenCV(this, 640/2, 480/2);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);  

  video.start();
}

void draw() {
  scale(2);
  opencv.loadImage(video);
  PImage img = opencv.getSnapshot();
 
  opencv.loadImage(img);
  opencv.brightness(brightVal);
  bright = opencv.getSnapshot();

    opencv.loadImage(opencv.getOutput());

  opencv.blur(blurVal);  
  blur = opencv.getSnapshot();

    opencv.loadImage(opencv.getOutput());
  opencv.threshold(threshVal);
  thresh = opencv.getSnapshot();
 
  
  image(thresh, 0, 0 );
  //In case the user is using a black background and white object, this gives the option to invert the frame before afdding it to the GIF
if(invertToggle){
  filter(INVERT);
  }

}

void captureEvent(Capture c) {
  c.read();
}




void keyPressed() {
  if(key ==' '){  //add frame to GIF when user hits spacebar
      gifExport.addFrame();
        println("frame added to GIF");

  }
  if(key == 's'){   //save image when user presses 's' key
  gifExport.finish();
  println("gif saved to sketch folder");
  }

}





ControlFrame addControlFrame(String theName, int theWidth, int theHeight) {
  Frame f = new Frame(theName);
  ControlFrame p = new ControlFrame(this, theWidth, theHeight);
  f.add(p);
  p.init();
  f.setTitle(theName);
  f.setSize(p.w, p.h);
  f.setLocation(100, 100);
  f.setResizable(false);
  f.setVisible(true);
  return p;
}


// the ControlFrame class extends PApplet, so we 
// are creating a new processing applet inside a
// new frame with a controlP5 object loaded
public class ControlFrame extends PApplet {

  int w, h;
int col = color(255);

  
  public void setup() {
    size(w, h);
    frameRate(25);
    cp5 = new ControlP5(this);
    cp5.addSlider("Brightness").plugTo(parent,"brightVal").setRange(-255, 255).setValue(0).setSize(200,20).setPosition(10,30);
    cp5.addSlider("Blur").plugTo(parent,"blurVal").setRange(1, 20).setValue(1).setPosition(10,60).setSize(200,20);
    cp5.addSlider("Threshold").plugTo(parent,"threshVal").setRange(0, 255).setValue(75).setSize(200,20).setPosition(10,90);
// create a toggle and change the default look to a (on/off) switch look
  cp5.addToggle("invert")
     .setPosition(40,120)
     .setSize(50,20)
     .setValue(true)
     .setMode(ControlP5.SWITCH)
     ;
  
}
  

  public void draw() {
      background(threshVal);
  }
  
  void invert(boolean theFlag) {
  if(theFlag==true) {
    col = color(255);
    invertToggle = true;
  } else {
    col = color(100);
        invertToggle = false;

  }
  println("a toggle event.");
}
  
  
  private ControlFrame() {
  }

  public ControlFrame(Object theParent, int theWidth, int theHeight) {
    parent = theParent;
    w = theWidth;
    h = theHeight;
  }


  public ControlP5 control() {
    return cp5;
  }
  
  
  ControlP5 cp5;

  Object parent;

  
}

