PImage img;
PShader shader;

void setup() {
  size(640,480,P2D);
  img = loadImage("mirror.png");
  img = img.get(0,120,640,480);
  shader = loadShader("shaders/inpainting.glsl");
}

void draw() {
  filter(shader);
  image(img,0,0);
}
