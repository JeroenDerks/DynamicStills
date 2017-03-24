import de.voidplus.redis.*;

Redis redis, redisSubscriber;
float dynaHeading, hartvigHeading, errorHeading, lastHeading; 
PVector dynaPos, hartvig;
float speed = 12.0;
float distance;
boolean setDynaHeading = true;

class mySub extends redis.clients.jedis.JedisPubSub {            // This takes care of all the incoming Redis subscriptions. 
  public void onMessage(String channel, String message) {
    if (channel.equals("dynaHeading")) {
      dynaHeading = float(message);
      if (setDynaHeading) {
        dynaInitH =  dynaHeading; 
        setDynaHeading = false;
      }
    } else if (channel.equals("hartvigPos")) {
      float [] hh = float(split(message, " "));
      hartvig.x = hh[0];    // 0 - 100 is current range
      hartvig.y = hh[1];   // 0 - 100 is current range
      hartvig.z = hh[2];

      //println(hh[0] + " " + hh[1]);
    } else if (channel.equals("dynaPos")) {
      float [] nums = float(split(message, " "));
      Dyna.current.x = nums[0];    // 0 - 100 is current range
      Dyna.current.y = nums[1];   // 0 - 100 is current range
    } else if (channel.equals("hartvigHeading")) {
      hartvigHeading = float(message);
    }
  }
  public void onSubscribe(String channel, int message) {
    println("Subscribed on channel: " + channel + " " + "total subscriptions: " + message);
  }
}

mySub subscriber;
Robot Dyna;
//int targetx, targety;

float facetoface = 30.0;
float distanceVar = 2.0;
float minHeight = 1.6;
float dynaInitH;
int s2counter = 0;
int s3counter = 0;
int sketch = 1;
boolean newPos = false;
PVector mirroredHartvig = new PVector();
PVector behindDyna = new PVector();
int timer = 0;
int wigglecounter = 0;
int speedcounter = 0;

float px =0;
float py = 0;
int ctime, ptime;
int state = 1;
int counter;
float s2speed = 5;


float[] storedspeed = new float[100];


float h1x = 50;   // 1st point x
float h1y = 50;   // 1st point y
float h2x = 200;  // 2nd point x
float h2y = 300;  // 2nd point y

float d1x = 350;  // 3rd point x
float d1y = 80;   // 3rd point y
float d2x;        // 4th point x
float d2y;        // 4th point y

float r = 0;
boolean right = false;
boolean stateBool = false; 

void setup() {
  size(512, 424, P3D);
  Dyna = new Robot("dyna");
  redisSubscriber = new Redis(this, "127.0.0.1", 6379); //this instance is only used for subcribing 
  redis = new Redis(this, "127.0.0.1", 6379);    //this instance is used for everything else
  subscriber = new mySub();
  dynaPos = new PVector(0, 0);
  hartvig = new PVector(0, 0);
  thread("go_Subscribe");
  thread("run");
}

void draw() {
  //smooth();
  //noStroke();
  //background(150);
  //pushMatrix();
  //translate(width/2, height/2);
  //scale(100, 100);                //this is just for drawing where Dyna and Hartvig are.
  //fill(0, 0, 255);
  //ellipse(Dyna.current.x, Dyna.current.y, 0.1, 0.1);
  //fill(255, 0, 0);
  //ellipse(hartvig.x, hartvig.y, 0.1, 0.1);
  //stroke(0);
  //strokeWeight(0.1);

  if (sketch == 1) {
    float distance = dist(hartvig.x, hartvig.y, Dyna.current.x, Dyna.current.y);
    float viewfield = - 0.8 + (distance * 0.6);
    if(viewfield < 0.05) viewfield = 0;
    facetoface = distance * 10;
    println(facetoface);
    if (distance > 0.8 && (abs(hartvigHeading - dynaHeading) > 180 - facetoface && abs(hartvigHeading - dynaHeading) < 180 + facetoface)) {
      stateBool = true;
      background(0, 255, 255);
      pushMatrix();
      translate(hartvig.x, hartvig.y);
      rotate(radians(360-hartvigHeading));
      h1x = modelX(0, 0, 0);
      h1y = modelY(0, 0, 0);
      h2x = modelX(0, 6, 0);
      h2y = modelY(0, 6, 0);
      popMatrix();
      pushMatrix();
      translate(Dyna.current.x, Dyna.current.y);
      rotate(radians(360-dynaHeading));
      d1x = modelX(-viewfield, 0.2, 0);
      d1y = modelY(-viewfield, 0.2, 0);
      d2x = modelX(viewfield, 0.2, 0);
      d2y = modelY(viewfield, 0.2, 0);
      translate(3, 0);
      float x = modelX(0, 0, 0);
      float y = modelY(0, 0, 0);
      behindDyna = new PVector(x, y);
      popMatrix();
      //println("D init H: " + dynaInitH);
      //println("D curr H: " + dynaHeading);
      //println("difference " +  (dynaInitH - dynaHeading));
      if ((lineLineIntersect(h1x, h1y, h2x, h2y, d1x, d1y, d2x, d2y))) {
        // Dyna.face(behindDyna, 80);
        background(255, 0, 0);
      } else {
        Dyna.setMode(Modes.idle);
        background(255);
      }
    } else if (distance < 0.5) {
      timer++;
      stateBool = false; 
      translate(Dyna.current.x, Dyna.current.y);
      rotate(radians(360-dynaHeading));
      if (timer % random(int(30)) == 0) { 
        translate(random(3, 3), random(3, 3));
        timer = 0;
      }      
      float x = modelX(0, 0, 0);
      float y = modelY(0, 0, 0);
      behindDyna = new PVector(x, y);
      Dyna.face(behindDyna, 10);
    } else { 
      Dyna.setMode(Modes.idle);
    }
    if ((dynaInitH - dynaHeading > 180) || (dynaInitH - dynaHeading > - 180 && dynaInitH - dynaHeading < -5)) {
      sketch =2;
      stateBool = false;
      timer = 0;
    }
  } else if (sketch == 2) {
    timer++;
    s2speed += 0.04;
    if (s2speed >= 80) s2speed = 80;
    println(s2speed);
    if (dist(hartvig.x, hartvig.y, Dyna.current.x, Dyna.current.y) < 2.0 && timer > 60) {
      newPos = true;
      mirroredHartvig.x = -hartvig.x;
      mirroredHartvig.y = -hartvig.y;
      timer = 0;
    } 
    if (newPos) {
      Dyna.goTo(mirroredHartvig, s2speed);
    }
    if (dist(mirroredHartvig.x, mirroredHartvig.y, Dyna.current.x, Dyna.current.y) < 0.4) {
      wigglecounter++;
      if (wigglecounter > 2000) { 
        s2speed = 11;
        sketch = 3;
      }
      newPos = false;
      float r = 0.3;
      float t = millis()/500.0f;
      float rotx = hartvig.x+r*cos(t);
      float roty = hartvig.y+r*sin(t);
      PVector aroundHartvig = new PVector(rotx, roty);
      fill(50);
      ellipse(aroundHartvig.x, aroundHartvig.y, 0.1, 0.1);
      Dyna.face(aroundHartvig, int(10 + (s2speed * 0.5)));
    }
  } else if (sketch ==3) {
    if (state == 1) {
      counter++;
      if (dist(hartvig.x, hartvig.y, px, py) > 0.3) {
        counter = 0;
      }
      Dyna.face(hartvig, 10);
      if (abs(hartvigHeading - lastHeading) > 20 && dist(hartvig.x, hartvig.y, px, py) > 0.2) { 
        counter = 0;
        float pointdistance = dist(hartvig.x, hartvig.y, px, py);
        ctime = millis();
        float distspeed = (pointdistance * 150) / ((ctime - ptime) * 0.005);
        distspeed = constrain(distspeed, 30, 80);
        PVector trackVec = new PVector(hartvig.x, hartvig.y);
        Dyna.trackAdd(trackVec, distspeed);
        pushMatrix();
        translate(width/2, height/2);
        scale(100, 100);
        noStroke();
        fill(2*distspeed, 0, 0);
        ellipse(hartvig.x, hartvig.y, 0.1, 0.1);
        popMatrix();
        px = hartvig.x;
        py = hartvig.y;
        ptime = ctime;
        lastHeading = hartvigHeading;
      }
      println("counter in draw: " + counter);

      if (counter >= 200) { 
        state = 2;
        Dyna.trackStart();
        println("trackStart");
      }
    }
  }
}

void go_Subscribe() {
  redisSubscriber.subscribe(subscriber, "dynaPos", "dynaHeading", "hartvigPos", "hartvigHeading"); //blocking call
  println("this will newer print");
}

void run() {
  Dyna.run();
}


boolean lineLineIntersect(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4 ) {
  boolean over = false;
  float a1 = y2 - y1;
  float b1 = x1 - x2;
  float c1 = a1*x1 + b1*y1;

  float a2 = y4 - y3;
  float b2 = x3 - x4;
  float c2 = a2*x3 + b2*y3;

  float det = a1*b2 - a2*b1;
  if (det == 0) {
    // Lines are parallel
  } else {
    float x = (b2*c1 - b1*c2)/det;
    float y = (a1*c2 - a2*c1)/det;
    if (x > min(x1, x2) && x < max(x1, x2) && 
      x > min(x3, x4) && x < max(x3, x4) &&
      y > min(y1, y2) && y < max(y1, y2) &&
      y > min(y3, y4) && y < max(y3, y4)) {
      over = true;
    }
  }
  return over;
}

void keyPressed() {
  if (key == '1') sketch = 1;
  else if (key =='2') sketch = 2;
  else if (key =='3') sketch = 3;
  else if (key =='4') sketch = 4;

  else if (key =='8') state = 1;
  else if (key =='9') state = 2;
}