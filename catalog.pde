int autoDelay = 500;
long last;

PGraphics canvas;
PImage frame;
PImage catalogImage;

int catalogColumns = 4;
int catalogRows = 4;
int posterWidth;
int posterHeight;
boolean firstFrame;

int catalogY, catalogX;
int catalogRes = 4;
float res;

boolean doneFlag = false;

void initCatalog() {
  res = 1.0/catalogRes;
  canvas = null;
  posterWidth = int(width * catalogColumns * res);
  posterHeight = int(height * catalogRows * res);
  canvas = createGraphics(posterWidth, posterHeight, P3D); 
  // canvas.smooth(8);
  catalogY = 0;
  catalogX = 0;
  //printConsole("canvas created "+posterWidth+"x"+posterHeight);
  canvas.beginDraw();
  canvas.background(255);
  canvas.endDraw();
}

void takeFrame() {
  if (doneFlag) {
    doneFlag = false;
    saveCatalog();
    //catalogY = 0;
    //initCanvas();
    show = true;
    auto = false;
    catalog = false;
    //  gui = true;
  } 
  else {
    printConsole("!frame "+(1+(catalogY*catalogColumns)+catalogX)+" of "+(catalogColumns*catalogRows)+" "+width+"x"+height+";");
    if (firstFrame) {
      if (validate == false || isGeometryValidated()) {
        background(backgroundColor);
        pushMatrix();
        updateCamera();
        displayGeometry();
        popMatrix();
        resetCamera();
        frame=get(0, 0, width, height);
        canvas.beginDraw();
        canvas.scale(res);
        canvas.translate(catalogX*width, catalogY*(height));
        canvas.image(frame, 0, 0);
        canvas.endDraw();
        catalogX++;
        if (catalogX == catalogColumns) {
          catalogX = 0;
          catalogY++;
          if (catalogY == catalogRows) {
            doneFlag = true;
          }
        }
      }
    } 
    else {
      firstFrame = true;
    }
  }
}

void saveFrames() {
  background(backgroundColor);
  pushMatrix();
  updateCamera();
  displayGeometry();
  popMatrix();
  resetCamera();
  frame=get(0, 0, width, height);
  frame.save("frames/"+getTimeStamp()+"_"+furnitureList.get(furniture).name+"_frame"+".png");
  printConsole("saved frame "+width+"x"+height+"px at "+nf(hour(), 2)+":"+nf(minute(), 2)+":"+nf(second(), 2)+";");
}

void makeCatalog () {
  initCatalog();
  auto = true;
  catalog = true;
  gui = false;
  firstFrame = false; // to avoid capturing interface and openGL glitch !!!
}

void saveCatalog() {
  canvas.save("canvas/"+getTimeStamp()+"_"+furnitureList.get(furniture).name+"_catalog"+".png");
  printConsole("!saved canvas "+posterWidth+"x"+posterHeight+"px at "+nf(hour(), 2)+":"+nf(minute(), 2)+":"+nf(second(), 2)+";");
}

void showCatalog() {
  cp5.hide();
  float displayRes = 1;
  if (canvas.width > displayWidth) {
    displayRes = displayWidth*1.0 / canvas.width*1.0;
  }
  translate(width/2 -(canvas.width/2*displayRes), height/2 - (canvas.height/2*displayRes));
  scale(displayRes);
  image(canvas, 0, 0);
  stroke(100);
  noFill();
  rect(0, 0, canvas.width, canvas.height);
}

void updateCatalog() {
  if (catalog) {
    if (auto) {
      randomGeometry();
    }
    takeFrame();
    if (rotation) {
      targetZ += .1;
    }
  }
  else if (auto) {
    if (millis()-last>autoDelay) {
      last = millis();
      randomGeometry();
    }
  } 
  else {
    if (validate) {
      if (!isGeometryValidated()) {
        randomGeometry();
      }
    }
  }
}

