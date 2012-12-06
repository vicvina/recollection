float targetZoom, targetFov, targetZ, targetY, targetX;
float offsetX, offsetY;

float locX = 0;
float locY = 0;

void initCamera() {
  targetFov = 0.6; // radians(60);
  targetX = radians(60);
  targetZ = radians(45+180);
  targetZoom = -0.07;
  addMouseWheelListener(new java.awt.event.MouseWheelListener() { 
    public void mouseWheelMoved(java.awt.event.MouseWheelEvent evt) { 
      mouseWheel(evt.getWheelRotation());
    }
  }
  );
  hint(DISABLE_OPENGL_ERRORS);  // not sure it works in 2.0b6
  //hint(ENABLE_DEPTH_SORT);
  //hint(ENABLE_ACCURATE_2D ); really bad performance !!
}

void updateCamera() {
  hint(ENABLE_DEPTH_TEST);
  translate(width/2, locY+(height/2));
  if (isometric) { // isometric
    ortho(-width/2, width/2, (-height/2), (height/2), -2000, 2000);
    scale(map(targetZoom, 0, 2, targetFov, 2*PI));  // adjust later so fov relates to zoom
    rotateX(radians(60));
    rotateZ(radians(45+180));
    translate(0, 200);
  } 
  else {  // perspective
    float cameraZ = (height/2.0) / tan(targetFov/2.0);
    perspective(targetFov, float(width)/float(height), cameraZ/10.0, cameraZ*10.0); 
    if (dragged) {
      targetZ -= (mouseX-offsetX)/200;
      offsetX = mouseX;
      targetX -= (mouseY-offsetY)/200;
      offsetY = mouseY;
    }
    if (moved) {
      locY += (mouseY-offsetY);
      offsetY = mouseY;
    }
    if (rotation && !dragged) {
      targetZ += .005;
    }
    // if (targetZ<0) targetZ = (2*PI)-targetZ;  // update gui for continous rotation !!!
    // if (targetZ>2*PI) targetZ = (targetZ%(2*PI));
    scale(map(targetZoom, 0, 1, targetFov, 2*PI));  // adjust so fov relates to zoom  !!!
    rotateX(targetX);
    rotateZ(targetZ);
  }
}

void resetCamera() {
  noLights();
  perspective();
  hint(DISABLE_DEPTH_TEST);
}

void pressCamera() {
  if (show) {
    show = false;
    gui = true;
  } 
  else {
    if (!cp5.isMouseOver()) {
      offsetX = mouseX;
      offsetY = mouseY;
      if (keyCode == 157) {
        moved = true;
      } 
      else {
        dragged = true;
      }
    }
  }
}

void releaseCamera() {
  dragged = false;
  moved = false;
}

void keyPressed() {   
  if (keyCode >48 && keyCode <58) {
    setMode(keyCode-48);
    updateMaterials();
  }
  if (keyCode == 48) setMode(0);
  if (keyCode == TAB) {
    gui = !gui;
  }
}

void keyReleased() {
  keyCode = 0;
}

void mousePressed() {
  if (!cp5.isMouseOver()) {
    pressCamera();
  }
}

void mouseReleased() {
  releaseCamera();
}

void mouseWheel(int delta) {
  if (!cp5.isMouseOver()) {
    if (keyCode == 157) {
      targetFov -= delta/100.0;
    } 
    else {
      targetZoom -= delta/2000.0;
    }
  }
}

