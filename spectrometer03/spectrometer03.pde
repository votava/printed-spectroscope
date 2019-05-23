/**
This program captures frames from a USB webcam and displays selected part of the image on the Processing graphical window.

Primary purpose of this program is to use it for webcam based spectrometer. 
This version is for a cheap 640x480 pixel webcam, using camera number 1, i.e. 640x480 30fps. 
It is important to remember, that Processing always changes the piexel values when you draw on the screen.
Therefore it is important to first read pixel values from the image before drawing the curves and the cross on the screen.
The program lists all available 'devices', i.e. the possible setings for all available webcams attached
to the computer. It is necessary to run the program once to display the listing and then choose a correct entry and use it in
the cam initializing statement.
To DO:
x port the code to Processing 3
- Use the graph object to display the spectra extracted from the image
x have a button to save the spectrum to a file in text format.  
- include x and y calibration curves to have wavelength calibrated x-axis and linear y axis (use a blackbody source to get normalization curves)

last updated 3/2019 by Ondrej Votava
**/

import g4p_controls.*; 
import processing.video.*; //Processing standard video library
import grafica.*; 
 
//Define auxilary global variables for plotting purposes:
float xPos = 1;
float xOld =1;
float yPos =1;
float yOld =1;

//size of the webcam image:
int imwidth = 640; //size of the entire webcam image in the x-direction, i.e. horizontal on the image. 
int imheight = 480; //size of the entire webcam image in teh y-direction, i. e. vertical on the image.  

//specify the range of the image that will be used for display and further analysis: 
int xmin = 1;
int xmax = 640;
int ymin = 195;
int ymax = 210
;

//string variable for saving the spectrum to a ascii file:
String[] lines = new String[xmax-xmin];

// For testing:
//String TestDat = "1;2;3;27;13;15;40;50;60;70;60;50;40;35;30;25;20;10;5;2";
//float[] list = float(split(TestDat, ";")); //split the inString string and convert to numbers:

Capture cam; //define object cam of type Capture. It is used to read frames from the webcam.
//-----------------------------------------------------------------------------------------------------

void setup() {
  size(1500, 1000); //graphics window size in points 
  createGUI();   //call the g4p to create the GUI objects

  
//we need to choose the correct input device. Following command lists all available capture devices. 
//Chosen device must be entered in the initialize statement below
  String[] cameras = Capture.list();
  for (int i = 0; i < cameras.length; i++) {
    println(i, cameras[i]);
  }
  
 cam = new Capture(this, cameras[1]); //initialize the cam object of type Capture. Choose appropriate entry from the cameras list
//cam = new Capture(this, 640,480, 30); //alternatively, specify resolution 640x480 points at 30 frames per s

 cam.start();  //initialize the webcam.
  
}  //end of the setup unit

//**************************************************************************
void draw () {

  // when a new frame is available, capture the frame
  if(cam.available()) {
    cam.read(); 
  }
  
//**********************************************************************
// display the image on the graphical window:

  fill(255, 255, 255);  //white background
  rect(0,0,width,height); // draw the white background accross the full width of the graphical window to erase previous spectrum. 
  //image(cam, 100, 100); //display the full current frame of the cam object. Good for testing.  
  image(cam, 0.0, 0.0, float(xmax-xmin), float(ymax-ymin), xmin, ymin, xmax, ymax); //display only the relevant part of current webcam frame 

  //filter(GRAY);  // this would be used to display the image in grayscale.

/**
this section has been used in previous version of the program 
//***********************************************************************
//read horizontal cross section at the center of the image: 
       float[] HorCut = new float[imwidth+1];  
       for (int i = 0; i < imwidth; i++)          //loop through the data horizontally
       {  
         HorCut[i] = 0;
         for(int j=-10; j<=10; j++){
          color c = get(i,imheight/2 + j);
          HorCut[i] = HorCut[i] + (red(c) + blue(c) +green(c))/3 ; //average intensity over +/- 10 points around center line
         }
         HorCut[i] = HorCut[i]/21;
       }
 **/
       
//  read vertical cross section of the displayed section of image: 
       float[] VerCut =new float[xmax-xmin+1];  
       for (int i = 1; i < xmax-xmin ; i++) {//loop through the data horozontally
       //now we will stepp over the vertical line:
         VerCut[i] = 0;
         for(int j = 1; j<= ymax-ymin; j++){
          color c = get(i, j);  //read color value from given pixel
          VerCut[i] = VerCut[i]+ (red(c) + blue(c) +green(c))/3 ; //add the intensity from the 3 basic color pixels. 
         }  //end of the horizontal avarating loope
         
         VerCut[i] = VerCut[i]/(ymax-ymin); //calculate the average intenxity accross the line
         lines[i] = str(i) + "\t" +  str(VerCut[i]); //write a line into output file array (TAB delimited)
       }

//*************************************************************************   

//new  new  new  new  new  new  new  new  new  new  new  new  new  new  new  new
         int nPoints = 1000;
         GPointsArray points = new GPointsArray(nPoints);
//new  new  new  new  new  new  new  new  new  new  new  new  new  new  new  new

//display the spectrum as a simple line graph accross the width of the window:          
      for (int i = 1; i < (xmax-xmin); i++) {//loop through the data horizontally
          //scale the data to the screen size:
//          yOld = map(VerCut[i-1], 0, 256, height, 0); 
//          yPos = map(VerCut[i], 0, 256,  height, 0);
//          xOld = map(i-1, 0, (xmax-xmin), 0, width);
//          xPos = map(i, 0, (xmax-xmin), 0, width);
//         points.add((536.4 + i*0.3032), VerCut[i]);
        points.add((400 + i*0.6), VerCut[i] - 33);
         // plot the data on screen: 
//          stroke(255,34,0);
//          fill(255,34,0);
//          line(xOld, yOld, xPos, yPos);
        }  
//new  new  new  new  new  new  new  new  new  new  new  new  new  new  new  new      
// using the Graphica library object to generate the plot:
      GPlot plot = new GPlot(this);
      plot.setPos(25, 100); // Graph uper left corner position
      plot.setDim(1200, 800); // size of the graph window
      
      plot.setTitleText("Optical Spectrum");
      plot.getXAxis().setAxisLabelText("lambda (nm)");
      plot.getYAxis().setAxisLabelText("Intensity");
      plot.setYLim(0, 250 ); // set y limits
      plot.setXLim(395, 810 ); // set x limits (wave length, nm)   
      
      plot.setPoints(points);
      plot.defaultDraw();
        

//new  new  new  new  new  new  new  new  new  new  new  new  new  new  new  new
/**
used in previous version of the program
//display horizontal cross section at the center of the image:     
       for (int i = 1; i < imwidth; i++) { //loop through the data horizontally   
             //scale the data to the screen size:     
          yOld = map(HorCut[i-1], 0, 256, 0, imheight*4/5);
          yPos = map(HorCut[i], 0, 256, 0, imheight*4/5);
          xOld = map(i-1, 0, imwidth, 0, imwidth);
          xPos = map(i, 0, imwidth, 0, imwidth);       
         //plot the data on screen: 
           stroke(127,34,255);
           fill(127,34,255);
          line(xOld, imheight-yOld, xPos, imheight-yPos);
        }  
//**************************************************************************

//display a hair-cross on the screen
   stroke(0,255,0);
   line(0,-imheight/2,imwidth, -imheight/2);
   line(imwidth/2,-imheight,imwidth/2,0);
**/
} // end of the draw unit
