/*---------------------------------------------------------------
 Imports
 ----------------------------------------------------------------*/
// import kinect library
import SimpleOpenNI.*;
// import sound library
import ddf.minim.*;

/*---------------------------------------------------------------
 Variables
 ----------------------------------------------------------------*/
// create kinect object
SimpleOpenNI  kinect;
// image storage from kinect
PImage kinectDepth;
// int of each user being  tracked
int[] userID;
// user colors
color[] userColor = new color[] { 
  color(255, 0, 0), color(0, 255, 0), color(0, 0, 255), 
  color(255, 255, 0), color(255, 0, 255), color(0, 255, 255)
};

// position of head to draw circle
PVector headPosition = new PVector();
// turn headPosition into scalar form
float distanceScalar;
// diameter of head drawn in pixels
float headSize = 200;

// threshold of level of confidence
float confidenceLevel = 0.5;
// the current confidence level that the kinect is tracking
float confidence;
// vector of tracked head for confidence checking
PVector confidenceVector = new PVector();

/*---------------------------------------------------------------
 my_Variables
 ----------------------------------------------------------------*/
//position of left and right hand
PVector leftHand = new PVector();
PVector rightHand = new PVector();
PVector preLeftHand = new PVector();

//background particle system
ArrayList particles;
int restrictParticle;

//define shapes to be displayed in the middle
int currentShape = int(random(4));
int currentZ = 0;
PVector velocity = new PVector();
PVector standerd = new PVector(1.0, 0.0);
final int k = 10;

//game variables
boolean gameStart = false;
boolean gameOver = false;
PFont myFont;
int textCount = 0;
boolean textFlash = true;
int handCount = 0;
boolean matchFinish = false;
int currentLevel = 1;
int shapeCount = 0;
int randomColor = 0;
AudioPlayer player;
Minim minim;

/*---------------------------------------------------------------
 Starts new kinect object and enables skeleton tracking. 
 Draws window
 ----------------------------------------------------------------*/
void setup()
{
  // start a new kinect object
  kinect = new SimpleOpenNI(this);

  // enable depth sensor 
  kinect.enableDepth();

  // enable skeleton generation for all joints
  kinect.enableUser();

  //skeleton weight
  strokeWeight(3);

  // create a window the size of the depth information
  //size(kinect.depthWidth(), kinect.depthHeight()); 
  size(displayWidth, displayHeight, P3D);

  //particle system init
  particles = new ArrayList();
  smooth();

  //font init
  myFont = loadFont("BankGothic-Medium-72.vlw");

  //sount init
  minim = new Minim(this);
  player = minim.loadFile("glass_break.mp3", 2048);
  //player.play();
} // void setup()

/*---------------------------------------------------------------
 Updates Kinect. Gets users tracking and draws skeleton and
 head if confidence of tracking is above threshold
 ----------------------------------------------------------------*/
void draw() { 
  // update the camera
  kinect.update();

  background(0);

  //draw background particle system
  if (particles.size() < 100 || restrictParticle%10 == 0) {
    particles.add(new Particle());
    //println("added");
  }
  restrictParticle++;
  //println(particles.size());
  for (int i = 0; i < particles.size(); i++ ) { 
    Particle p = (Particle) particles.get(i);
    p.run();
    p.display();
  }
  if (particles.size() > 120) {
    particles.remove(0);
  }

  // get all user IDs of tracked users
  userID = kinect.getUsers();

  // loop through each user to see if tracking
  for (int i=0;i<userID.length;i++)
  {
    // if Kinect is tracking certain user then get joint vectors
    if (kinect.isTrackingSkeleton(userID[i]))
    {
      // get confidence level that Kinect is tracking head
      confidence = kinect.getJointPositionSkeleton(userID[i], 
      SimpleOpenNI.SKEL_HEAD, confidenceVector);

      // if confidence of tracking is beyond threshold, then track user
      if (confidence > confidenceLevel)
      {
        // change draw color based on hand id#
        stroke(userColor[(i)]);
        // fill the ellipse with the same color
        fill(userColor[(i)]);
        // draw the rest of the body
        //drawSkeleton(userID[i]);

        //get position of left and right hand
        //get 3D position of left and right hand
        kinect.getJointPositionSkeleton(userID[i], SimpleOpenNI.SKEL_LEFT_HAND, leftHand);
        kinect.getJointPositionSkeleton(userID[i], SimpleOpenNI.SKEL_RIGHT_HAND, rightHand);
        //convert real world point to projective space
        kinect.convertRealWorldToProjective(leftHand, leftHand);
        kinect.convertRealWorldToProjective(rightHand, rightHand);
        //        print("preLeftHand: ");
        //        println(preLeftHand);
        //        print("rightHand");
        //        println(rightHand);
        if (preLeftHand.x != 0 && preLeftHand.y != 0 && !gameOver && gameStart) {
          PVector direction = PVector.sub(leftHand, preLeftHand);
          //println(direction);
          //direction.normalize();
          if (abs(direction.x) > 2 || abs(direction.y) > 2) velocity.add(direction);
          //          print("velocity.x = ");
          //          println(velocity.x);
          //          print("velocity.y = ");
          //          println(velocity.y);
        }
        fill(255, 50, 0, 150);     
        if (!gameStart) ellipse(displayWidth - map(leftHand.x, 0, kinect.depthWidth(), 0, displayWidth), map(leftHand.y, 0, kinect.depthHeight(), 0, displayHeight), 50, 50);
        //ellipse(rightHand.x, rightHand.y, 50, 50);
        //this is important!!! 
        //if pass the object, then they will point to the same address, which will lead to sync these two PVectors
        //"preLeftHand = rightHand;" this is wrong!!!
        preLeftHand.x = leftHand.x;
        preLeftHand.y = leftHand.y;
        //test the position of left and right hand
        //        leftHand.x = map(leftHand.x, 0, kinect.depthWidth(), 0, displayWidth);
        //        leftHand.y = map(leftHand.y, 0, kinect.depthHeight(), 0, displayHeight);
        //        rightHand.x = map(rightHand.x, 0, kinect.depthWidth(), 0, displayWidth);
        //        rightHand.y = map(rightHand.y, 0, kinect.depthHeight(), 0, displayHeight);
        //        fill(0, 255, 0);

        //        print("leftHand.x = ");
        //        print(leftHand.x);
        //        print("; leftHand.y = ");
        //        println(leftHand.y);
        //        print("rightHand.x = ");
        //        print(rightHand.x);
        //        print("; rightHand.y = ");
        //        println(rightHand.y);
      } //if(confidence > confidenceLevel)
    } //if(kinect.isTrackingSkeleton(userID[i]))
  } //for(int i=0;i<userID.length;i++)

  //game start scene
  if (!gameStart && !gameOver) {
    textFont(myFont, 72);
    textAlign(CENTER, BOTTOM);
    fill(255);
    if (currentLevel == 1) text("2D CRASH", width/2, height/2);
    if (currentLevel == 2) text("Level 2", width/2, height/2);
    textFont(myFont, 48);
    if (textCount < 30 && textFlash) {
      text("center your right hand to start", width/2, 11 * height/16);
    }
    if (textCount == 30) {
      textCount = 0;
      textFlash = !textFlash;
    }
    textCount++;
    if (leftHand.y >= kinect.depthHeight()/2 - kinect.depthWidth()/8 && leftHand.y <= kinect.depthHeight()/2 + kinect.depthWidth()/8 &&
      leftHand.x >= 3 * kinect.depthWidth()/8 && leftHand.x <= 5 * kinect.depthWidth()/8) {
      handCount++;
      if (handCount == 60) {
        gameStart = true;
        gameOver = false;
        textCount = 0;
        handCount = 0;
        currentShape = int(random(4));
      }
    }
    else handCount = 0;
  }

  //game over scene
  else if (gameOver) {
    textFont(myFont, 72);
    textAlign(CENTER, BOTTOM);
    fill(255);
    text("game over", width/2, height/2);
    textFont(myFont, 48);
    if (textCount < 30 && textFlash) {
      text("center your right hand here to replay", width/2, 11 * height/16);
    }
    if (textCount == 60) {
      textCount = 0;
      textFlash = !textFlash;
    }
    textCount++;
    if (leftHand.y >= kinect.depthHeight()/2 - kinect.depthWidth()/8 && leftHand.y <= kinect.depthHeight()/2 + kinect.depthWidth()/8 &&
      leftHand.x >= 3 * kinect.depthWidth()/8 && leftHand.x <= 5 * kinect.depthWidth()/8) {
      handCount++;
      if (handCount == 30) {
        gameStart = true;
        gameOver = false;
        textCount = 0;
        handCount = 0;
        currentShape = int(random(4));
      }
    }
    else handCount = 0;
  }

  //game playing scene
  else if (!gameOver && gameStart) {
    //fixed shapes on screen
    stroke(200);
    strokeWeight(5);
    line(width/2 - 60, height/2 - width/4 + 40, width/2 + 60, height/2 - width/4 + 40);
    fill(255, 50, 0, 150);
    noStroke();
    beginShape(TRIANGLES);
    vertex(width/4, height/2 - 40);
    vertex(3 * width/16, height/2 + 40);
    vertex(5 * width/16, height/2 + 40);
    endShape();
    fill(0, 255, 50, 150);
    noStroke();
    ellipse(width/2, 13 * height/16, 80, 80);
    fill(50, 0, 255, 150);
    noStroke();
    rectMode(CENTER);
    rect(3 * width/4, height/2, 80, 80);

    //shapes to be displayed in the middle
    currentZ += 10;
    //println(currentZ);
    //println(currentShape);
    if (currentZ == 500) {
      if (velocity.x < width/4 && velocity.y < width/4 && !matchFinish) {
        gameOver = true;
        gameStart = false;
        shapeCount = 0;
      }
      currentZ = 0;
      currentShape = int(random(4));
      velocity.x = 0;
      velocity.y = 0;
      velocity.z = 0;
      matchFinish = false;
      randomColor = int(random(0, 2));
    }

    if (!matchFinish) {
      pushMatrix();
      translate(-velocity.x * k, velocity.y * k);
      switch(currentShape) {
      case 0://line
        stroke(200);
        strokeWeight(5);
        line(width/2 - 30, height/2, currentZ, width/2 + 30, height/2, currentZ);
        if ((abs(velocity.x * k) >= width/4 ||abs(velocity.y * k) >= width/4)) {
          PVector temp = new PVector();
          temp.x = -velocity.x;
          temp.y = velocity.y;
          if (velocity.y < 0 && 
            PVector.angleBetween(temp, standerd) >= 3 * PI/8 && PVector.angleBetween(temp, standerd) <= 5 * PI/8) {//match
            matchFinish = true;
            shapeCount++;
            player.rewind(); 
            player.play();
          }
          else {//not match
            gameOver = true;
            gameStart = false;
            //matchFinish = false;
            currentZ = 0;
            shapeCount = 0;
          }
          //println(PVector.angleBetween(temp, standerd));
          velocity.x = 0;
          velocity.y = 0;
          velocity.z = 0;
          randomColor = int(random(0, 2));
        }
        //print("0 ");
        //        print(velocity.x);
        //        print(" ");
        //        println(velocity.y);
        break;
      case 1://triangle
        noStroke();
        //original red
        if (randomColor == 0)fill(0, 255, 50, 150);
        else fill(50, 0, 255, 150);
        beginShape(TRIANGLES);
        vertex(width/2, height/2 - 20, currentZ);
        vertex(15 * width/32, height/2 + 20, currentZ);
        vertex(17 * width/32, height/2 + 20, currentZ);
        endShape();
        if ((abs(velocity.x * k) >= width/4 ||abs(velocity.y * k) >= width/4)) {
          PVector temp = new PVector();
          temp.x = -velocity.x;
          temp.y = velocity.y;
          if (PVector.angleBetween(temp, standerd) >= 7 * PI/8 && PVector.angleBetween(temp, standerd) <= PI) {//match
            matchFinish = true;
            shapeCount++;
            player.rewind(); 
            player.play();
          }
          else {//not match
            gameOver = true;
            gameStart = false;
            //matchFinish = false;
            currentZ = 0;
            shapeCount = 0;
          }
          //println(PVector.angleBetween(temp, standerd));
          velocity.x = 0;
          velocity.y = 0;
          velocity.z = 0;
          randomColor = int(random(0, 2));
        }
        //print("1 ");
        //        print(velocity.x);
        //        print(" ");
        //        println(velocity.y);
        break;
      case 2://ellipse
        noStroke();
        if (randomColor == 0)fill(50, 0, 255, 150);
        else fill(255, 50, 0, 150);
        ellipse(width/2, height/2, 40 + currentZ/10, 40 + currentZ/10);
        if ((abs(velocity.x * k) >= width/4 ||abs(velocity.y * k) >= width/4)) {
          PVector temp = new PVector();
          temp.x = -velocity.x;
          temp.y = velocity.y;
          if (velocity.y > 0 && 
            PVector.angleBetween(temp, standerd) >= 3 * PI/8 && PVector.angleBetween(temp, standerd) <= 5 * PI/8) {//match
            matchFinish = true;
            shapeCount++;
            player.rewind(); 
            player.play();
          }
          else {//not match
            gameOver = true;
            gameStart = false;
            //matchFinish = false;
            currentZ = 0;
            shapeCount = 0;
          }
          //println(PVector.angleBetween(velocity, standerd));
          velocity.x = 0;
          velocity.y = 0;
          velocity.z = 0;
          randomColor = int(random(0, 2));
        }  
        //print("2 ");
        //        print(velocity.x);
        //        print(" ");
        //        println(velocity.y);
        break;
      case 3://rect
        noStroke();
        if (randomColor == 0)fill(255, 50, 0, 150);
        else fill(0, 255, 50, 150);
        rectMode(CENTER);
        rect(width/2, height/2, 40 + currentZ/10, 40 + currentZ/10);
        if ((abs(velocity.x * k) >= width/4 ||abs(velocity.y * k) >= width/4)) {
          PVector temp = new PVector();
          temp.x = -velocity.x;
          temp.y = velocity.y;
          if (PVector.angleBetween(temp, standerd) >= 0 && PVector.angleBetween(temp, standerd) <= PI/8) {//match
            matchFinish = true;
            shapeCount++;
            player.rewind(); 
            player.play();
          }
          else {//not match
            gameOver = true;
            gameStart = false;
            //matchFinish = false;
            currentZ = 0;
            shapeCount = 0;
          }
          //println(PVector.angleBetween(temp, standerd));
          velocity.x = 0;
          velocity.y = 0;
          velocity.z = 0;
          randomColor = int(random(0, 2));
        }
        //print("3 ");
        //        print(velocity.x);
        //        print(" ");
        //        println(velocity.y);
        break;
      }
      popMatrix();
    }

    if (shapeCount == 6) {
      currentLevel = 2;
      shapeCount = 0;
      currentZ = 0;
      currentShape = int(random(4));
      velocity.x = 0;
      velocity.y = 0;
      velocity.z = 0;
      matchFinish = false;
      randomColor = int(random(0, 2));
      gameStart = false;
    }
  }//else (gameStart == true)
} // void draw()

/*---------------------------------------------------------------
 Draw the skeleton of a tracked user.  Input is userID
 ----------------------------------------------------------------*/
void drawSkeleton(int userId) { 
  // get 3D position of head
  kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_HEAD, headPosition);
  // convert real world point to projective space
  kinect.convertRealWorldToProjective(headPosition, headPosition);
  // create a distance scalar related to the depth in z dimension
  distanceScalar = (525/headPosition.z);
  // draw the circle at the position of the head with the head size scaled by the distance scalar
  ellipse(headPosition.x, headPosition.y, distanceScalar*headSize, distanceScalar*headSize);

  //draw limb from head to neck 
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);
  //draw limb from neck to left shoulder
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  //draw limb from left shoulde to left elbow
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  //draw limb from left elbow to left hand
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);
  //draw limb from neck to right shoulder
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  //draw limb from right shoulder to right elbow
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  //draw limb from right elbow to right hand
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
  //draw limb from left shoulder to torso
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  //draw limb from right shoulder to torso
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  //draw limb from torso to left hip
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  //draw limb from left hip to left knee
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  //draw limb from left knee to left foot
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);
  //draw limb from torse to right hip
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  //draw limb from right hip to right knee
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  //draw limb from right kneee to right foot
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);
} // void drawSkeleton(int userId)

/*---------------------------------------------------------------
 When a new user is found, print new user detected along with
 userID and start pose detection.  Input is userID
 ----------------------------------------------------------------*/
void onNewUser(SimpleOpenNI curContext, int userId) {
  println("New User Detected - userId: " + userId);
  // start tracking of user id
  curContext.startTrackingSkeleton(userId);
} //void onNewUser(SimpleOpenNI curContext, int userId)

/*---------------------------------------------------------------
 Print when user is lost. Input is int userId of user lost
 ----------------------------------------------------------------*/
void onLostUser(SimpleOpenNI curContext, int userId) {
  // print user lost and user id
  println("User Lost - userId: " + userId);
} //void onLostUser(SimpleOpenNI curContext, int userId)

/*---------------------------------------------------------------
 Called when a user is tracked.
 ----------------------------------------------------------------*/
void onVisibleUser(SimpleOpenNI curContext, int userId) {
} //void onVisibleUser(SimpleOpenNI curContext, int userId)

