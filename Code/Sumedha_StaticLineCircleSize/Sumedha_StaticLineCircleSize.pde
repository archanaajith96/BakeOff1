
//Hover Demo
//Changes:

//Function draw rectangle (new parameter added, boolean to signify whether an outline should be drawn)
//new function added --> overRectangle() (void) found at the end of code
//draw function modified
//Cmd F "CHANGE" to find all changes

import java.awt.AWTException;
import java.awt.Rectangle;
import java.awt.Robot;
import java.util.ArrayList;
import java.util.Collections;
import processing.core.PApplet;

//when in doubt, consult the Processsing reference: https://processing.org/reference/

int margin = 200; //set the margina around the squares
final int padding = 50; // padding between buttons and also their width/height
final int buttonSize = 40; // padding between buttons and also their width/height
ArrayList<Integer> trials = new ArrayList<Integer>(); //contains the order of buttons that activate in the test
int trialNum = 0; //the current trial number (indexes into trials array above)
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
int hits = 0; //number of successful clicks
int misses = 0; //number of missed clicks
int borderOn = -1;
Robot robot; //initalized in setup 

int numRepeats = 1; //sets the number of times each button repeats in the test

void setup()
{
  size(700, 700); // set the size of the window
  //noCursor(); //hides the system cursor if you want
  noStroke(); //turn off all strokes, we're just using fills here (can change this if you want)
  textFont(createFont("Arial", 16)); //sets the font to Arial size 16
  textAlign(CENTER);
  frameRate(60);
  ellipseMode(CENTER); //ellipses are drawn from the center (BUT RECTANGLES ARE NOT!)
  //rectMode(CENTER); //enabling will break the scaffold code, but you might find it easier to work with centered rects

  try {
    robot = new Robot(); //create a "Java Robot" class that can move the system cursor
  } 
  catch (AWTException e) {
    e.printStackTrace();
  }

  //===DON'T MODIFY MY RANDOM ORDERING CODE==
  for (int i = 0; i < 16; i++) //generate list of targets and randomize the order
      // number of buttons in 4x4 grid
    for (int k = 0; k < numRepeats; k++)
      // number of times each button repeats
      trials.add(i);

  Collections.shuffle(trials); // randomize the order of the buttons
  System.out.println("trial order: " + trials);
  
  frame.setLocation(0,0); // put window in top left corner of screen (doesn't always work)
}


void draw()
{
  background(0); //set background to black

  if (trialNum >= trials.size()) //check to see if test is over
  {
    float timeTaken = (finishTime-startTime) / 1000f;
    float penalty = constrain(((95f-((float)hits*100f/(float)(hits+misses)))*.2f),0,100);
    fill(255); //set fill color to white
    //write to screen (not console)
    text("Finished!", width / 2, height / 2); 
    text("Hits: " + hits, width / 2, height / 2 + 20);
    text("Misses: " + misses, width / 2, height / 2 + 40);
    text("Accuracy: " + (float)hits*100f/(float)(hits+misses) +"%", width / 2, height / 2 + 60);
    text("Total time taken: " + timeTaken + " sec", width / 2, height / 2 + 80);
    text("Average time for each button: " + (timeTaken)/(float)(hits+misses) + " sec", width / 2, height / 2 + 100);
    text("Average time for each button + penalty: " + ((timeTaken)/(float)(hits+misses) + penalty) + " sec", width / 2, height / 2 + 120);
    return; //return, nothing else to do now test is over
  }

  fill(255); //set fill color to white
  text((trialNum + 1) + " of " + trials.size(), 40, 20); //display what trial the user is on
  for (int i = 0; i < 16; i++) {// for all button
    drawButton(i, false); // CHANGED! --> added false parameter
  
  }
  
  //CHANGED//
  int y = overRectangle();
  if (y != -1) 
      drawButton(y, true);//draw button
      
  //END CHANGE//
  
  Rectangle bounds = getButtonLocation(trials.get(trialNum));
  if (trialNum >  0){
      
      Rectangle bounds1 = getButtonLocation(trials.get(trialNum-1));
      stroke(255);
      int x2 = bounds.x + (bounds.width/2);
      int y2 = bounds.y + (bounds.height/2);
      int x1 = bounds1.x + (bounds1.width/2);
      int y1 = bounds1.y + (bounds1.height/2);
      line(x1, y1, x2, y2);
      // draw a triangle at (x2, y2)
      pushMatrix();
      translate(x2, y2);
      float a = atan2(x1-x2, y2-y1);
      rotate(a);
      line(0, 0, -10, -10);
      line(0, 0, 10, -10);
      popMatrix();
      
  }
  
    // Change the color to RED with high translucency.
  fill(255, 0, 0, 130);
  
  // Get bounds for the target square.
  
  // Get the center x,y coords for the target square.
  int centerX = bounds.x + (buttonSize / 2);
  int centerY = bounds.y + (buttonSize / 2);
  
  // Calculate the x and y distance between the mouse and the target.
  int distX = abs(centerX - mouseX);
  int distY = abs(centerY - mouseY);
  
  // The size of the red dot will be proportional to the distance, but less than maxBallSize.
  int maxBallSize  = 150;
  int distBallSize = (int) sqrt(sq(distX) + sq(distY));
  int ballSize     = min(maxBallSize, distBallSize);
  
  // Draw the red dot.
  fill(255, 0, 0, 200); // set fill color to translucent red
  noStroke();
  ellipse(mouseX, mouseY, ballSize, ballSize);
  
  //ellipse(mouseX, mouseY, 20, 20); //draw user cursor as a circle with a diameter of 20
}

void mousePressed() // test to see if hit was in target!
{
  if (trialNum >= trials.size()) //if task is over, just return
    return;

  if (trialNum == 0) //check if first click, if so, start timer
    startTime = millis();

  if (trialNum == trials.size() - 1) //check if final click
  {
    finishTime = millis();
    //write to terminal some output. Useful for debugging too.
    println("we're done!");
  }

  Rectangle bounds = getButtonLocation(trials.get(trialNum));

 //check to see if mouse cursor is inside button 
  if ((mouseX > bounds.x && mouseX < bounds.x + bounds.width) && (mouseY > bounds.y && mouseY < bounds.y + bounds.height)) // test to see if hit was within bounds
  {
    System.out.println("HIT! " + trialNum + " " + (millis() - startTime)); // success
    hits++; 
  } 
  else
  {
    System.out.println("MISSED! " + trialNum + " " + (millis() - startTime)); // fail
    misses++;
  }

  trialNum++; //Increment trial number

  //in this example code, we move the mouse back to the middle
  //robot.mouseMove(width/2, (height)/2); //on click, move cursor to roughly center of window!
}  

//probably shouldn't have to edit this method
Rectangle getButtonLocation(int i) //for a given button ID, what is its location and size
{
   int x = (i % 4) * (padding + buttonSize) + margin;
   int y = (i / 4) * (padding + buttonSize) + margin;
   return new Rectangle(x, y, buttonSize, buttonSize);
}

//you can edit this method to change how buttons appear

//CHANGED --> notice new parameter boolean stroke 
void drawButton(int i, boolean stroke)
{
  Rectangle bounds = getButtonLocation(i);

  if (trials.get(trialNum) == i) // see if current button is the target
    fill(0, 255, 255); // if so, fill cyan
  else
    fill(200); // if not, fill gray
  
  
  if (stroke) {
    strokeWeight(4);
    stroke(204, 102, 0);
  }
  else {
      noStroke();
  }
  rect(bounds.x, bounds.y, bounds.width, bounds.height); //draw button
}

void mouseMoved()
{
    
   //can do stuff everytime the mouse is moved (i.e., not clicked)
   //https://processing.org/reference/mouseMoved_.html
}

void mouseDragged()
{
  //can do stuff everytime the mouse is dragged
  //https://processing.org/reference/mouseDragged_.html
}

void keyPressed() 
{
  //can use the keyboard if you wish
  //https://processing.org/reference/keyTyped_.html
  //https://processing.org/reference/keyCode.html
}

//CHANGED --> recognizes if mouseX and mouseY are over any rectangle
int overRectangle() 
{
   for (int i = 0; i < 16; i++) {// for all button
     Rectangle bounds = getButtonLocation(i);
     if ((mouseX > bounds.x && mouseX < bounds.x + bounds.width) && (mouseY > bounds.y && mouseY < bounds.y + bounds.height)) {
       return i;
     }
  }
  return -1;
}