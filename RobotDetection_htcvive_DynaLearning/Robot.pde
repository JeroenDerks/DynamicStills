import java.util.*;

public enum Modes {
  idle, direct, track,heading,face
}

class Robot {
  private LinkedList<PVector> track = new LinkedList();
  private Modes mode;
  public String name;
  public PVector current = new PVector();
  private PVector Target = new PVector();
  private float Heading;
  private PVector Correction = new PVector();
  private int rotSpeed; 
  // int speed = 80;

  Robot(String _inputName) {
    name = _inputName;
    mode = Modes.direct;
  }
  void run() {
    while (true) {
      if (mode == Modes.direct) {
        Correction = calcSomething(Target);
        redis.publish(name, int(Correction.y) + " , " + int(Correction.x));    // this publishes to the Redis
      } else if (mode == Modes.heading){
        Correction = calcHeading(Heading);
        redis.publish(name, int(Correction.y) + " , " + int(Correction.x));    // this publishes to the Redis
      }else if (mode == Modes.face){
        Correction = calcHeading(Heading);
        redis.publish(name, int(Correction.y) + " , " + int(Correction.x));    // this publishes to the Redis
      }else {
        redis.publish(name, 0 + " , " + 0);
      }
      delay(10);
    }
  }
  void goTo(PVector _target, int _speed) {
    speed = _speed;
    mode = Modes.direct;
    Target = _target;
  }
  void face(PVector _target,int _rotSpeed) {
    rotSpeed = _rotSpeed;
    mode = Modes.face;
    Heading = degrees(atan2(_target.x - current.x,_target.y- current.y));
    // println(Heading);
    
  }
  void setHeading(float _heading){
    mode = Modes.heading;
    Heading = _heading;
    
  }

  private PVector calcSomething(PVector _target) {      //This takes care of understanding where Dyna is, and returns variables with how Dyna should drive to her target.
    float a = degrees(atan2(_target.x - current.x,_target.y- current.y));
    errorHeading = dynaHeading-a; 
    if (errorHeading < -180) errorHeading = 360+errorHeading;
    if (errorHeading > 180) errorHeading = -360+errorHeading;

    // println("error : " + errorHeading);
 
    float errorDist = dist(_target.x, _target.y, current.x, current.y);
    if (errorDist < 0.5)errorDist=0;
    PVector ret = new PVector();
   
      ret.x = int(errorHeading * (3));
      ret.x = constrain(ret.x, -100, 100);
    
    ret.y = 0;
    if (errorHeading > -60 && errorHeading < 60) {
      ret.y = errorDist*50;
      ret.y = constrain(ret.y, -100, speed);
      ret.y = ret.y - constrain(int(abs(errorHeading)/5), 0, 100);
      println(ret.y);
    }
    
    return ret;
  }
   private PVector calcHeading(float a) {      //This takes care of understanding where Dyna is, and returns variables with how Dyna should drive to her target.
    a = a%360;
    errorHeading = dynaHeading-a; 
    if (errorHeading < -180) errorHeading = 360+errorHeading;
    if (errorHeading > 180) errorHeading = -360+errorHeading;
    //println(errorHeading);
    PVector ret = new PVector();
    ret.x = int(errorHeading*rotSpeed);
    ret.x = constrain(ret.x, -100, 100);
    ret.y = 0;
    return ret;
  }
  void setMode(Modes _mode){
    mode = _mode;
  }
void draw(){
  
    
}
}