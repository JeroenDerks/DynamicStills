import java.util.*;

public enum Modes {
  idle, direct, track, heading, face
}
public class trackPoint {
  PVector Pos = new PVector();
  float Speed;
}


class Robot {
  public LinkedList<trackPoint> track = new LinkedList();
  //  public LinkedList<> trackSpeed = new LinkedList();
  private Modes mode;
  public String name;
  public PVector current = new PVector();
  private trackPoint Target = new trackPoint();
  private float Heading;
  private PVector Correction = new PVector();
  private float rotSpeed; 
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
      } else if (mode == Modes.track) {
        Correction = calcSomething(Target);
        if (Correction.z < 0.15) {       // 10 cm f
          if (track.size() == 0) {
            counter = 0;
            state = 1;
            println("end of track size: " + track.size());
            mode = Modes.idle;
          } else {
            println("track size: " + track.size());
            Target = track.poll();
          }
        }
        redis.publish(name, int(Correction.y) + " , " + int(Correction.x));
      } else if (mode == Modes.heading) {
        Correction = calcHeading(Heading);
        redis.publish(name, int(Correction.y) + " , " + int(Correction.x));    // this publishes to the Redis
      } else if (mode == Modes.face) {
        Correction = calcHeading(Heading);
        redis.publish(name, int(Correction.y) + " , " + int(Correction.x));    // this publishes to the Redis
      } else {
        redis.publish(name, 0 + " , " + 0);
      }
      delay(10);
    }
  }
  void goTo(PVector _target, float _speed) {
    mode = Modes.direct;
    Target.Pos = _target;
    Target.Speed = _speed;
  }
  void face(PVector _target, float _rotSpeed) {
    rotSpeed = _rotSpeed;
    mode = Modes.face;
    Heading = degrees(atan2(_target.x - current.x, _target.y- current.y));
  }
  void setHeading(float _heading) {
    mode = Modes.heading;
    Heading = _heading;
  }
  void trackAdd(PVector p, float _speed) {
    trackPoint point = new trackPoint();
    point.Pos = p;
    point.Speed = _speed;
    track.add(point);
  }

  public void trackStart() {
    if (mode != Modes.track && track.size() != 0) mode = Modes.track;
    if (track.size() == 0 ) {
      counter = 0;
      state = 1;
    }
    Target = track.poll();
    counter = 0;
  }

  private PVector calcSomething(trackPoint _target) {      //This takes care of understanding where Dyna is, and returns variables with how Dyna should drive to her target.
    float a = degrees(atan2(_target.Pos.x - current.x, _target.Pos.y- current.y));
    errorHeading = dynaHeading-a; 
    if (errorHeading < -180) errorHeading = 360+errorHeading;
    if (errorHeading > 180) errorHeading = -360+errorHeading;
    float errorDist = dist(_target.Pos.x, _target.Pos.y, current.x, current.y);
    if (sketch == 3) { 
      if ( errorDist < 0.15) errorDist=0;
    } else { 
      if (errorDist < 0.5) errorDist=0;
    }
    PVector ret = new PVector();
    ret.x = int(errorHeading * (3));
    ret.x = constrain(ret.x, -100, 100);
    ret.y = 0;
    if (errorHeading > -90 && errorHeading < 90) {
      if (sketch == 3) {
        // println(_target.Speed);
        ret.y = _target.Speed;
        ret.y = ret.y - constrain(int(abs(errorHeading)/5), 0, 19);
      } else {
        ret.y = errorDist * 50;
        ret.y = constrain(ret.y, -100, 100);
        ret.y = ret.y - constrain(int(abs(errorHeading)/5), 0, 100);
      }
    }
    ret.z = errorDist;
    return ret;
  }
  private PVector calcHeading(float a) {      //This takes care of understanding where Dyna is, and returns variables with how Dyna should drive to her target.
    a = a%360;
    errorHeading = dynaHeading-a; 
    if (stateBool) errorHeading = 360+errorHeading;
    else {
      if (errorHeading < -180) errorHeading = 360+errorHeading;
      if (errorHeading > 180) errorHeading = -360+errorHeading;
    }
    PVector ret = new PVector();
    ret.x = int(errorHeading*rotSpeed);
    ret.x = constrain(ret.x, -100, 100);
    ret.y = 0;
    return ret;
  }

  void setMode(Modes _mode) {
    mode = _mode;
  }

  public boolean isFinished() {
    println("IS FINISHED");
    return true;
  }
}