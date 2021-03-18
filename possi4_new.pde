import processing.video.*;
import gab.opencv.*;
import java.awt.Rectangle; //inport libraries
OpenCV opencv;
Rectangle[] faces;
Capture cam;
int faceAreaX; 
int faceAreaY; //the top-left corner of the mosaic area
int randomFaceNum=5;
int objectNum=5;
int countFace;
int countObject;
int mosaicState=0;
int displayNum;
int displayObjectNum;
int mosaicWidth=7;// width of the mosaic area
int mosaicHeight=5;// height of the mosaic area
float speedRow;
float speedCol;
int faceAreaWidth=1;
int faceAreaHeight=1;
int opacity=255;
int caseNum;

void setup() {
  size(640, 480);
  frameRate(10);
  caseNum=int(random(4)); //four conditions happen at random
  println(caseNum);

  cam = new Capture(this, 640, 480);
  cam.start();
  opencv = new OpenCV(this, cam.width, cam.height);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
}

void draw() {

  opencv.loadImage(cam);
  faces = opencv.detect();
  int side=faceAreaWidth/mosaicWidth; //side length of each square
  cam.read(); 
  image(cam, 0, 0); //capture face and show it on the screen
  rectMode(CORNER);


  //standard to adjust mosaic color
  color standard=get(faceAreaX+side, faceAreaY+(mosaicHeight+1)*side); 
 // color standard=get(mouseX,mouseY); //for color-adjust test use

  if (faces != null) { 
    for (int i = 0; i < faces.length; i++) {

      faceAreaWidth=faces[i].width*5/6;
      faceAreaHeight=faces[i].height*2/3;
      faceAreaX=faces[i].x+((faces[i].width-faceAreaWidth)/2);
      faceAreaY=faces[i].y+((faces[i].height-faceAreaHeight)/2);
    }
  }//detect face and determine the mosaic area

  //Condition 1: generate mosaic from the captured face
  if (caseNum==0) {     

    for (int i=0; i<mosaicWidth; i++) {
      for (int j=0; j<mosaicHeight; j++) {

        color c=get(faceAreaX+(i*side+side/2), faceAreaY+(j*side+side/2));
        fill(c, opacity);
        rect(faceAreaX+(i*side), faceAreaY+(j*side), side, side);
        noStroke();  //draw mosaic on face area
        if (mosaicState==0) {
          opacity=255;
        } else if (mosaicState==1) {
          opacity-=1;
        }
      }
    }
  }


  // Condition 2: generate mosaic from other people's face
  if (caseNum==1) {      

    PImage randomFace[] = new PImage[randomFaceNum];

    for (int n=0; n<randomFaceNum; n++) {
      randomFace[n]=loadImage("randomFace"+n+".jpg");
    }//load pictures of other people's faces

    if (mosaicState==0) {
      countFace=countFace+1;
      if (countFace>randomFaceNum-1) {
        countFace=0;
      }//change faces

      noStroke();
      fill(standard);
      rect(faceAreaX, faceAreaY, mosaicWidth*side, mosaicHeight*side);
      blend(randomFace[countFace], 0, 0, width, height, faceAreaX, faceAreaY, mosaicWidth*side, mosaicHeight*side, SOFT_LIGHT);
      //adjust mosaic color

      for (int i=0; i<mosaicWidth; i++) {
        for (int j=0; j<mosaicHeight; j++) {

          color c=get(faceAreaX+(i*side+side/2), faceAreaY+(j*side+side/2));
          fill(c);
          rect(faceAreaX+(i*side), faceAreaY+(j*side), side, side);
          noStroke();
        }//draw mosaic
      }
    } else if (mosaicState==2) {
      cam.read();
      image(cam, 0, 0);

      noStroke();
      fill(standard);
      rect(faceAreaX, faceAreaY, mosaicWidth*side, mosaicHeight*side);
      blend(randomFace[displayNum], 0, 0, width, height, faceAreaX, faceAreaY, mosaicWidth*side, mosaicHeight*side, SOFT_LIGHT);
    }// display the origin of mosaic
  } 

  //Condition3: Rearranged color blocks
  if (caseNum==2) {       

    color[] colors = new color[mosaicWidth*mosaicHeight];

    for (int i=0; i<mosaicWidth; i++) {
      for (int j=0; j<mosaicHeight; j++) {
        int n=mosaicWidth*j+i;        

        colors[n]=get(faceAreaX+(i*side+side/2), faceAreaY+(j*side+side/2));
      }//select colors for color blocks
    }  


    for (int i=0; i<mosaicWidth; i++) {
      for (int j=0; j<mosaicHeight; j++) {

        float posX=0;
        float posY=0;
        int m=mosaicWidth*mosaicHeight;               

        int colorNum=int(random(m));
        if (brightness(colors[colorNum])>20) {
          fill(colors[colorNum], opacity);
        }        

        noStroke();   
        posX=posX+speedRow;
        posY=posY+speedCol;

        if (mosaicState==0) {
          speedRow=0;
          speedCol=0;
        } else if (mosaicState==3) {
          speedRow=random(-120, 120);
          speedCol=random(-120, 120);// color blocks are blown away

          opacity-=0.06;
        }         

        rect(faceAreaX+(i*side)+posX, faceAreaY+(j*side)+posY, side, side); 
        //draw color blocks
      }
    }
  }

  //Condition 4: generate mosaic from non-face objects
  if (caseNum==3) {    

    PImage objects[] = new PImage[objectNum];

    for (int n=0; n<objectNum; n++) {
      objects[n]=loadImage("object"+n+".jpg");
    }

    if (mosaicState==0) {

      countObject=countObject+1;
      if (countObject>objectNum-1) {
        countObject=0;
      }

      image(objects[countObject], faceAreaX, faceAreaY, mosaicWidth*side, mosaicHeight*side);

      noStroke();
      fill(standard);
      rect(faceAreaX, faceAreaY, mosaicWidth*side, mosaicHeight*side);
      blend(objects[countObject], 0, 0, width, height, faceAreaX, faceAreaY, mosaicWidth*side, mosaicHeight*side, SOFT_LIGHT);
      //adjust mosaic color 

      for (int i=0; i<mosaicWidth; i++) {
        for (int j=0; j<mosaicHeight; j++) {

          color c=get(faceAreaX+(i*side+side/2), faceAreaY+(j*side+side/2));
          fill(c);
          rect(faceAreaX+(i*side), faceAreaY+(j*side), side, side);
          noStroke();
        }
      }
    } else if (mosaicState==4) {
      cam.read();
      image(cam, 0, 0);

      noStroke();
      fill(standard);
      rect(faceAreaX, faceAreaY, mosaicWidth*side, mosaicHeight*side);
      blend(objects[displayObjectNum], 0, 0, width, height, faceAreaX, faceAreaY, mosaicWidth*side, mosaicHeight*side, SOFT_LIGHT);
    }
  }
}

void mouseClicked() {

  if (caseNum==0) {   
    mosaicState=1;
  } else if (caseNum==1) {
    mosaicState=2;
    displayNum=int(random(randomFaceNum));
  } else if (caseNum==2) {    
    mosaicState=3;
  } else if (caseNum==3) {
    mosaicState=4;
    displayObjectNum=int(random(objectNum));
  }
}
