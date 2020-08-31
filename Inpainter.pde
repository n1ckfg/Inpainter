PImage img;

void setup() {
  size(640,480,P2D);
  img = loadImage("mirror.png");
  img = img.get(0,120,640,480);
  
  setupShaders();
}

void draw() {
  runShaders();
  image(img,0,0);
}
