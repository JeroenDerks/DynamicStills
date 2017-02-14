/**
 * Blob Class
 *
 * Based on this example by Daniel Shiffman:
 * http://shiffman.net/2011/04/26/opencv-matching-faces-over-time/
 * 
 * @author: Jordi Tost (@jorditost)
 * 
 * University of Applied Sciences Potsdam, 2014
 */
import java.util.*;

public enum Modes {
  idle, direct, track
}

class Robot {
  private LinkedList<PVector> track = new LinkedList();
  private Modes mode;
  public String name;
  public int currentX, currentY;
  private PVector Target = new PVector();
  private PVector Correction = new PVector();

  // int speed = 80;

  Robot(String _inputName) {
    name = _inputName;
    mode = Modes.idle;
  }
  void run() {
    while (true) {
      if (mode == Modes.direct) {
        Correction = calcSomething(Target);
        if (Correction.z < 5) mode = Modes.idle;
        redis.publish(name, int(Correction.y) + " , " + int(Correction.x));
      } else if (mode == Modes.track) {
        Correction = calcSomething(Target);
        if (Correction.z < 40) {
          if (track.size()>0) {
            println(track.size());
            Target = track.poll();
          } else {
            mode = Modes.idle;
            println("'Idle");
          }
        }
        redis.publish(name, int(Correction.y) + " , " + int(Correction.x));
      } else {
        redis.publish(name, 0 + " , " + 0);
      }
      delay(10);
    }
  }
  void goTo(int _x, int _y, int _speed) {
    speed = _speed;
    mode = Modes.direct;
    Target.x = float(_x);
    Target.y = float(_y);
  }
  void trackAdd(PVector p) {
    // speed = hartvig.z;
    if (mode != Modes.track)Target = p;
    mode = Modes.track;
    track.add(p);
    println(track.size());
  }

  private PVector calcSomething(PVector p) {
    float a = atan2(p.y- currentY, p.x - currentX);
    a = degrees(a);
    a = 360-a;
    a += 90;
    a = a%360;
   // println("relation dyna to point: " + a);
    //println("dynaHeading: " + dynaHeading);
    errorHeading = dynaHeading-a; 
    if (errorHeading < -180) errorHeading = 360+errorHeading;
    if (errorHeading > 180) errorHeading = -360+errorHeading;

    // println("error : " + errorHeading);
    float errorDist = dist(p.x, p.y, currentX, currentY);
    PVector ret = new PVector();
    ret.x = int(errorHeading * (speed * 0.1));
    ret.x = constrain(ret.x, -100, 100);
    ret.y = 0;
    if (errorHeading > -60 && errorHeading < 60) {
      ret.y = int(errorDist/2);
      ret.y = constrain(ret.y, -100, speed);
      ret.y = ret.y - constrain(int(abs(errorHeading)/5), 0, 100);
    }
    ret.z = errorDist;
    return ret;
  }

  void addPoint(PVector p) {
    track.add(p);
  }
}