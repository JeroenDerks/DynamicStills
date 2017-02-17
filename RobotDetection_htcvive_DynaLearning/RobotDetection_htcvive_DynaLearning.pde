import de.voidplus.redis.*;
import ddf.minim.*;
float minX = -5;
float minY = -5;
float maxX = 5;
float maxY = 5;


Redis redis, redisSubscriber;
float dynaHeading, hartvigHeading, errorHeading; 
PVector dynaPos, hartvig;
int sketch = 0;

Minim minim;
AudioInput in;
int s = 0;
int speed;
float distance;
boolean setDynaHeading = true;
class mySub extends redis.clients.jedis.JedisPubSub {            // This takes care of all the incoming Redis subscriptions. 
  public void onMessage(String channel, String message) {
    if (channel.equals("dynaHeading")) {
      dynaHeading = float(message);
      if (setDynaHeading) {
        dynaInitH = dynaHeading; 
        setDynaHeading = false;
      }
      // println("dynaHead: " + dynaHeading);
    } else if (channel.equals("hartvigPos")) {
      float [] hh = float(split(message, " "));
      hartvig.x = hh[0];    // 0 - 100 is current range
      hartvig.y = hh[1];   // 0 - 100 is current range
      hartvig.z = hh[2];
      // println(hartvig.z);
      // println("hartvig x: " + hartvig.x + "    hartvig y: " + hartvig.y);
    } else if (channel.equals("dynaPos")) {
      // println(message);
      float [] nums = float(split(message, " "));
      Dyna.current.x = nums[0];    // 0 - 100 is current range
      Dyna.current.y = nums[1];   // 0 - 100 is current range
      // println("dyna x: " + dynaPos.x + "   dyna y: " + dynaPos.y);
    } else if (channel.equals("hartvigHeading")) {
      hartvigHeading = float(message);
      // println("hartHead: " + hartvigHeading);
    }
  }
  public void onSubscribe(String channel, int message) {
    println("Subscribed on channel: " + channel + " " + "total subscriptions: " + message);
  }
}

mySub subscriber;
Robot Dyna;
//int targetx, targety;

float facetoface = 5.0;
float distanceVar = 100;
float minHeight = 1.0;
boolean DynaX = false;
boolean DynaY = false;
float dynaInitH;
void setup() {
  size(512, 424, P3D);
  Dyna = new Robot("dyna");
  redisSubscriber = new Redis(this, "127.0.0.1", 6379); //this instance is only used for subcribing 
  redis = new Redis(this, "127.0.0.1", 6379);    //this instance is used for everything else
  subscriber = new mySub();
  dynaPos = new PVector(0, 0);
  hartvig = new PVector(0, 0);
  minim = new Minim(this);
  in = minim.getLineIn();
  thread("go_Subscribe");
  thread("run");
}

void draw() {

  noStroke();
  background(150);

  stroke(0);                      //this is just for drawing where Dyna and Hartvig are.
  fill(0, 0, 255);
  ellipse(Dyna.current.x, Dyna.current.y, 20, 20);
  fill(255, 0, 0);
  ellipse(hartvig.x, hartvig.y, 20, 20);
  // println("dynaHeading: " + dynaHeading);
  //println("dyna init heading: " + dynaInitH);
  //println("dynaHeading: " + dynaHeading + " hartvigHeading: " + hartvigHeading);
  //println("dyna - Hartvig " + abs(dynaHeading - hartvigHeading));
  // println(dist(hartvig.x, hartvig.y, Dyna.currentX, Dyna.currentY));
  // println("hartvigHeight: " + hartvig.z + " minHeight: " + minHeight);
  // println("facetoFace: " + facetoface);
  // println("ddyna180);


  //Dyna.setHeading(hartvigHeading);
  //Dyna.goTo(hartvig,30);
  //Dyna.face(hartvig);

  if (hartvig.z < minHeight && 
    dist(hartvig.x, hartvig.y, Dyna.current.x, Dyna.current.y) < distanceVar &&
    abs(hartvigHeading - dynaHeading) > 180 - facetoface && abs(hartvigHeading - dynaHeading) < 180 + facetoface) {
    facetoface += 0.01;
    minHeight += 0.001;
    distanceVar += 0.01;

    // println("facetoFace: " + facetoface);
    // println("hartvigHeight: " + hartvig.z + " minHeight: " + minHeight);
    // println("distanceVar: " + distanceVar);
    DynaX = true;
    background(200, 255, 200);
    if (dynaInitH - dynaHeading > 180  ||dynaInitH - dynaHeading < -180) {
      DynaY = true;
      // println("dynaY triggered");
    }
  } else {
    DynaX = false;
  }

  //distance = hartvig.z*50;
  //pushMatrix();
  //translate(hartvig.x, hartvig.y);
  //rotate(radians(360-hartvigHeading));
  //fill(255, 0, 0, 100);
  //rect(-5, -130, 10, 160);                // Hartvig current    (-130 for pointing to Y=0)
  //translate(0, distance);
  //fill(0, 0, 255, 100);
  //rect(-10, -10, 20, 20);                  //  Dyna's target
  //float x = modelX(0, 0, 0);
  //float y = modelY(0, 0, 0);
  //popMatrix();
  // println("x: " +  x + " y: " +   y);
  if (DynaX && DynaY) Dyna.goTo(hartvig, 30);
  if (DynaX && !DynaY) Dyna.face(hartvig, int((facetoface-5)/5));
  if (!DynaX) Dyna.setMode(Modes.idle);
 
}







//speed = int(hartvig.z);
//s = int (10000*(in.left.level()));          // This is sound threshold.
//if (s > 2000) {
//  PVector loc = new PVector(random(100, width-100), random(100, height-200)); //find a random position in the window.
//  Dyna.goTo(int(loc.x), int(loc.y), speed);        // tell Dyna to go there
//}
////}


void go_Subscribe() {
  redisSubscriber.subscribe(subscriber, "dynaPos", "dynaHeading", "hartvigPos", "hartvigHeading"); //blocking call
  println("this will newer print");
}

void run() {
  Dyna.run();
}

int mapToScreen(float val, String axe) {
  if (axe == "x") {
    return int(map(val, minX, maxX, 0, width));
  } else if (axe == "y") {
    return int(map(val, minY, maxY, 0, height));
  }
  return 0;
}