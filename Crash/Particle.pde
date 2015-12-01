class Particle {

  float x;
  float y;
  float xspeed;
  float yspeed;
  int radius;

  Particle() {
    x = width/2;
    y = height/2;
    xspeed = random(-1, 1);
    yspeed = random(-1, 1);
    radius = 3;
  }

  void run() {
    x = x + xspeed;
    y = y + yspeed;
  }

  void display() {
    noStroke();
    fill(255);
    ellipse(x, y, radius, radius);
  }
}

