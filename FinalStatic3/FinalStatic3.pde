/** 
 * BakeOff 1 Final 3
 * Mod     : StaticLineArrow && MovingDot && StickyOverlay && MouseInPlace.
 * Code    : Line 19~32 && 102~142 && 162~168 && 181~225 && 236~245
 * Tests   : 3 Tests, AvgTime(9.491) AvgButtonTime(0.5931)
 * Author  : Archana Ajith, David Song, Sumedha Mehta
 * Version : 1.0.0
 */

import java.awt.AWTException;
import java.awt.Rectangle;
import java.awt.Robot;
import java.util.ArrayList;
import java.util.Collections;
import processing.core.PApplet;

//when in doubt, consult the Processsing reference: https://processing.org/reference/

/* CODE MODIFICATION
 * Line 19 ~ 32
 * Add global variables to control red dot movement.
 */
// Velocity of the red dot.
int velocity = 8;
// Whether the red dot is currently racing with the user.
boolean isCompeting = false;
// x,y velocity && x,y position for the red dot.
float dx, dy, dotX, dotY;
// x,y distance between targets && 
// x,y position of the current target square &&
// x,y position of the previous target square.
int distX, distY, currCenterX, currCenterY, prevCenterX, prevCenterY;

int margin = 200; //set the margina around the squares
final int padding = 50; // padding between buttons and also their width/height
final int buttonSize = 40; // padding between buttons and also their width/height
ArrayList<Integer> trials = new ArrayList<Integer>(); //contains the order of buttons that activate in the test
int trialNum = 0; //the current trial number (indexes into trials array above)
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
int hits = 0; //number of successful clicks
int misses = 0; //number of missed clicks
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

  /* CODE MODIFICATION
   * Line 102 ~ 142
   */
  // Create Clickable Sticky Overlay on nearet square.
  for (int i = 0; i < 16; i++) {
    Rectangle bounds = getButtonLocation(i);
    fill(255,0,0,150);
    if ((mouseX > bounds.x - (0.5 * padding) && mouseX < bounds.x + bounds.width + (0.5 * padding)) && 
        (mouseY > bounds.y - (0.5 * padding) && mouseY < bounds.y + bounds.height + (0.5 * padding))) 
      rect(bounds.x - (0.5 * padding), bounds.y - (0.5 * padding), bounds.width + padding, bounds.height + padding);
  } 
   
  // Draw Squares and Hover Border.
  for (int i = 0; i < 16; i++) drawButton(i, false);

  // Draw Line between two target squares.
  strokeWeight(9);
  stroke(0,0,255);
  line(prevCenterX, prevCenterY, currCenterX, currCenterY);

  // draw a triangle at (x2, y2)
  pushMatrix();
  translate(currCenterX, currCenterY);
  float a = atan2(prevCenterX-currCenterX, currCenterY-prevCenterY);
  rotate(a);
  line(0, 0, -10, -10);
  line(0, 0, 10, -10);
  popMatrix();
  
  // Draw moving red dot guiding to the next target.
  noStroke();
  if (isCompeting) {
    fill(255,0,0,200);
    ellipse(dotX, dotY, 35, 35);
    dotX += dx;
    dotY += dy;
    if      (distX > 0 && dotX >= currCenterX) isCompeting = false;
    else if (distX < 0 && dotX <= currCenterX) isCompeting = false;
    else if (distY > 0 && dotY >= currCenterY) isCompeting = false;
    else if (distY < 0 && dotY <= currCenterY) isCompeting = false;
  }
}

void mousePressed() // test to see if hit was in target!
{
  if (trialNum >= trials.size()) //if task is over, just return
    return;

  //check if first click, if so, start timer
  if (trialNum == 0) 
    startTime = millis();

  if (trialNum == trials.size() - 1) //check if final click
  {
    finishTime = millis();
    //write to terminal some output. Useful for debugging too.
    println("we're done!");
  }

  Rectangle bounds = getButtonLocation(trials.get(trialNum));

  /* CODE MODIFICATION
   * Line 162 ~ 168
   * A Hit click is accepted if the mouse was anywhere on the overlay of a square.
   */
  if ((mouseX > bounds.x - (0.5 * padding) && mouseX < bounds.x + bounds.width + (0.5 * padding)) && 
      (mouseY > bounds.y - (0.5 * padding) && mouseY < bounds.y + bounds.height + (0.5 * padding)))
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

  /* CODE MODIFICATION
   * Line 181 ~ 225
   * Enable Competition and set up red dot's starting position and x,y velocity.
   */
  if (trialNum > 0 && trialNum < 16) {
    // Setting to true will enable the red dot to be drawn.
    isCompeting = true;
    
    // Get previous, current trial items by index.
    int prevTrial = trials.get(trialNum - 1);
    int currTrial = trials.get(trialNum);
    
    // Get Rectangle Bounds of previous, current trial items.
    Rectangle prevBound = getButtonLocation(prevTrial);
    Rectangle currBound = getButtonLocation(currTrial);
    
    // Calculate center position for both.
    prevCenterX = prevBound.x + (int)(0.5 * prevBound.width);
    prevCenterY = prevBound.y + (int)(0.5 * prevBound.height);
    currCenterX = currBound.x + (int)(0.5 * currBound.width);
    currCenterY = currBound.y + (int)(0.5 * currBound.height);
    
    // Calculate x,y distance between the two squares.
    distX = currCenterX - prevCenterX;
    distY = currCenterY - prevCenterY;
    float distXY = sqrt(sq(distX) + sq(distY));
    
    // Set up the x,y velocity for the red dot.
    if (distX == 0) {
      dx = 0;
      dy = velocity * (distY / abs(distY));
    }
    else if (distY == 0) {
      dx = velocity * (distX / abs(distX));
      dy = 0;
    }
    else {
      dx = velocity * (abs(distX) / distXY) * (distX / abs(distX));
      dy = velocity * (abs(distY) / distXY) * (distY / abs(distY));
    }
    
    // Initialize the position of the red dot.
    dotX = prevCenterX;
    dotY = prevCenterY;
  }
}  

//probably shouldn't have to edit this method
Rectangle getButtonLocation(int i) //for a given button ID, what is its location and size
{
   int x = (i % 4) * (padding + buttonSize) + margin;
   int y = (i / 4) * (padding + buttonSize) + margin;
   return new Rectangle(x, y, buttonSize, buttonSize);
}

/* CODE MODIFICATION
 * Line 236 ~ 245
 */
void drawButton(int i, boolean stroke) {
  Rectangle bounds = getButtonLocation(i);
  noStroke();
  if (trials.get(trialNum) == i) fill(255, 255, 0); 
  else                           fill(200);
  rect(bounds.x, bounds.y, bounds.width, bounds.height);
}

void mouseMoved(){}
void mouseDragged(){}
void keyPressed(){}