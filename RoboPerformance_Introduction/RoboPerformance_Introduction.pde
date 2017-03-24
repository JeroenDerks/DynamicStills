import de.voidplus.redis.*;
import ddf.minim.*;

Redis redis, redisSubscriber;
float dynaHeading, hartvigHeading, errorHeading, lastHeading; 
PVector dynaPos, hartvig, mirrored;
float speed;

class mySub extends redis.clients.jedis.JedisPubSub {            // This takes care of all the incoming Redis subscriptions. 
  public void onMessage(String channel, String message) {
    if (channel.equals("dynaHeading")) {
      dynaHeading = float(message);
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
Minim minim;
AudioInput in;
float s = 0;
//int targetx, targety;


PVector mirroredHartvig = new PVector();
PVector behindDyna = new PVector();
PVector audience = new PVector();
int sketch = 1;
int timer = 0;
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
  audience = new PVector(10, 0);
  if(dist(hartvig.x, hartvig.y, Dyna.current.x, Dyna.current.y) < 0.3) Dyna.face(audience);
  else {
  timer++;
  if (sketch == 1) {
    s = in.left.level();
    if (s > 0.5 && timer > 60) {
      timer = 0;
      println(s); 
      background(255, 0, 0);
      sketch = 2;
    } else background(150);
    Dyna.face(audience);
  } else if (sketch == 2) {
    s = in.left.level();
    PVector center = new PVector(0, 0);
    if (s > 0.5 && timer > 60) {
      timer = 0;
      println(s); 
      background(255, 0, 0);
      sketch = 3;
    } else background(150);
    Dyna.goTo(center, 25);
  } else if (sketch == 3) {
    s = in.left.level();
    if (s > 0.5 && timer > 60) {
      timer = 0;
      println(s); 
      sketch = 4;
      background(255, 0, 0);
    } else background(150);
    Dyna.goTo(hartvig, 30);
  } else if (sketch == 4) {
    s = in.left.level();
    if (s > 0.5 && timer > 60) {
      timer = 0;
      println(s); 
      sketch = 5;
      background(255, 0, 0);
    } else background(150);
    mirrored = new PVector(hartvig.x, -hartvig.y);
    Dyna.goTo(mirrored, 50);
  }
  else if (sketch == 5) {
    Dyna.setMode(Modes.idle);
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


void keyPressed() {
  if (key == '1') sketch = 1;
  else if (key =='2') sketch = 2;
  else if (key =='3') sketch = 3;
  else if (key =='4') sketch = 4;
}