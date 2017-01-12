

ArrayList<Seven> sevens = new ArrayList<Seven>();
int mouseClickUp, mouseClickDown;
int mod;
int startx, starty;
boolean newloc = true;
void setup() {
  size(1200, 600);
}

void draw() {
  background(0);

  for (int i=0; i<sevens.size(); i++) sevens.get(i).display();
  strokeWeight(3);

  stroke(255, 0, 255);
  line(startx, starty, mouseX, mouseY);
  if ((mouseX > startx + 50 && mouseX < startx -50) && (mouseY > starty + 50 && mouseY < starty - 50)) newloc = true;

  if (newloc && mouseX != startx || mouseX > width - 50 || mouseX < 50 || mouseY != starty && mouseY > height - 50 || mouseY < 50) {
    sevens.add(new Seven(startx, starty, mouseX, mouseY));
    startx = mouseX;
    starty = mouseY;
    newloc = false;
  }
  fill(0);
  noStroke();
  rect(0, 0, width, 50);
  rect(0, 0, 50, height);
  rect(width-50, 0, 50, height);
  rect(0, height-50, width, 50);
}


class Seven {
  int stx, sty, endx, endy;
  float c = 1.;
  float s;
  Seven(int _startx, int _starty, int _endx, int _endy) {
    stx = _startx;
    sty = _starty;
    endx = _endx;
    endy = _endy;
  }

  void display() {
    c += 0.01;
    s = random(1, c);
    if (c > 20) stroke(0);
    else    stroke(255, 0, 255);
    strokeWeight(3 +s);

    line(stx, sty, endx, endy);
  }
}