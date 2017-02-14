import de.voidplus.redis.*;
import ddf.minim.*;

Redis redis, redisSubscriber;
float dynaHeading, hartvigHeading, errorHeading; 
PVector dynaPos, hartvig;
int sketch = 0;

Minim minim;
AudioInput in;
int s = 0;
int speed;


class mySub extends redis.clients.jedis.JedisPubSub {
  public void onMessage(String channel, String message) {
    if (channel.equals("dynaHeading")) {
      dynaHeading = float(message);
      // println("dynaHead: " + dynaHeading);
    } else if (channel.equals("hartvigPos")) {
      float [] hh = float(split(message, " "));
      hartvig.x = int(map(hh[0], 0, 7, 0, width));    // 0 - 100 is current range
      hartvig.y = int(map(hh[1], 0, 7, 0, height));   // 0 - 100 is current range
      hartvig.z = int(map(hh[2], 0, 3, 0, 80)); 
      // println(hartvig.z);
      // println("hartvig x: " + hartvig.x + "    hartvig y: " + hartvig.y);
    } else if (channel.equals("dynaPos")) {
      // println(message);
      float [] nums = float(split(message, " "));
      dynaPos.x = int(map(nums[0], 0, 7, 0, width));    // 0 - 100 is current range
      dynaPos.y = int(map(nums[1], 0, 7, 0, height));   // 0 - 100 is current range
      println("dyna x: " + dynaPos.x + "   dyna y: " + dynaPos.y);
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
int targetx, targety;


void setup() {
  size(512, 424);
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
  Dyna.currentX = int(dynaPos.x);
  Dyna.currentY = int(dynaPos.y);
  stroke(0);
  fill(0, 0, 255);
  ellipse(Dyna.currentX, Dyna.currentY, 20, 20);
  fill(255, 0, 0);
  ellipse(hartvig.x, hartvig.y, 20, 20);
  speed = int(hartvig.z);
  if (sketch == 0) Dyna.goTo(int(hartvig.x), int(hartvig.y), int(hartvig.z));
  else if (sketch == 2) {
    s = int (10000*(in.left.level()));
    if (s > 2000) {
      PVector loc = new PVector(random(100, width-100), random(100, height-200));
      println(loc.x + " , " + loc.y);
      Dyna.goTo(int(loc.x), int(loc.y), 50);
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

void mousePressed() {
  PVector m = new PVector(mouseX, mouseY);
  Dyna.trackAdd(m);
  // Dyna.goTo(mouseX, mouseY, 30);
}


void keyPressed() {
  if (key == 'b' || key == 'B') sketch = 1;
  else if ( key =='c' || key =='C') sketch =0;
  else if ( key =='p' || key == 'P') sketch =2;
}