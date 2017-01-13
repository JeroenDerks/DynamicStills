import de.voidplus.redis.*;

Redis redis, redisSubscriber;

class mySub extends redis.clients.jedis.JedisPubSub {
  public void onMessage(String channel, String message) {
    println("channel: " + channel + " " + "message: " + message);
  }
  public void onSubscribe(String channel, int message) {
    println("Subscribed on channel: " + channel + " " + "total subscriptions: " + message);
  }
}

mySub subscriber;

int i;
long time,last;
void setup() {

  redisSubscriber = new Redis(this, "127.0.0.1", 6379); //this instance is only used for subcribing 
  redis = new Redis(this, "127.0.0.1", 6379);    //this instance is used for everything else
  subscriber = new mySub();
  thread("go_Subscribe");
}

void draw() {
  i++;
  time = millis() - last;
  redis.publish("dyna", str(i));
  //redis.publish("test", str(i%1000));
  
}

void go_Subscribe() {
  redisSubscriber.subscribe(subscriber, "dyna", "test"); //blocking call
  println("this will newer print"); 
}