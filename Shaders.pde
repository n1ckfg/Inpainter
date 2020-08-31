PShader shader_inpainting; 

PVector shaderMousePos = new PVector(0,0);
PVector shaderMouseClick = new PVector(0,0);

void setupShaders() {
  shader_inpainting = loadShader("shaders/inpainting.glsl"); 
  shaderSetSize(shader_inpainting);
}

void updateShaders() {
  shaderSetFrame(shader_inpainting);
  shaderSetMouse(shader_inpainting);
  //shaderSetTime(shader);
  shaderSetTexture(shader_inpainting, "tex0", img);
}

void drawShaders() {
  filter(shader_inpainting);
}

void runShaders() {
  updateShaders();
  drawShaders();
}

// ~ ~ ~ ~ ~ ~ ~

void shaderSetVar(PShader ps, String name, float val) {
    ps.set(name, val);
}

void shaderSetSize(PShader ps) {
  ps.set("iResolution", float(width), float(height), 1.0);
}

void shaderSetSize(PShader ps, float w, float h) {
  ps.set("iResolution", w, h, 1.0);
}

void shaderSetMouse(PShader ps) {
  if (mousePressed) shaderMousePos = new PVector(mouseX, height - mouseY);
  ps.set("iMouse", shaderMousePos.x, shaderMousePos.y, shaderMouseClick.x, shaderMouseClick.y);
}

void shaderSetTime(PShader ps) {
  ps.set("iGlobalTime", float(millis()) / 1000.0);
}

void shaderMousePressed() {
  shaderMouseClick = new PVector(mouseX, height - mouseY);
}

void shaderMouseReleased() {
  shaderMouseClick = new PVector(-shaderMouseClick.x, -shaderMouseClick.y);
}

void shaderSetTexture(PShader ps, String name, PImage tex) {
  ps.set(name, tex);
}

void shaderSetFrame(PShader ps) {
  ps.set("iFrame", frameCount);
}
