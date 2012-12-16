int backgroundColor = 255;
int fontColor = 50;
int controllerColor = 245;
int activeColor = 210;
int redColor = color(255, 0, 0);
int blueColor = color(0, 0, 255);
int greenColor = color(0, 255, 0);

int strokeColor, strokeAlpha, solidColor, solidAlpha, wireframeColor, wireframeAlpha, fillColor, fillAlpha, gridColor, groundColor;
int ambientLightColor, directionalLightColor;

int smoothLevel = 8;

int gridMode = 0;
int thickStroke = 3;
int thinStroke = 1;
int markerStroke = 1;
int markerLength = 3;
int controlPointWeight = 3;

int cx, cy, sh = 20;
int guix = 80;
int guiy = 12;
int columnx = 220;
int marginy = 60;
int consolex = 440;
int consoley = 12; // not used yet
String consoleText = "";
String bufferText = "";
long consoleLast;
long consoleTic;
int consoleDelay = 2000;
char consoleCursor = '_';
boolean consoleReady = false;

import controlP5.*;
ControlP5 cp5;
ControlFont guiFont;

PFont lightFont;
PFont boldFont;
PFont titleBoldFont;
PFont titleLightFont;

ArrayList<String> generateControllerList = new ArrayList<String>();
ArrayList<String> updateControllerList = new ArrayList<String>();
ArrayList<String> retainControllerList = new ArrayList<String>();

String[] limitControllerList = {
  "worldX", "worldY", "worldZ"
};

void updateGui() {
  mapDim.x = int(worldX/gridSize)*gridSize;
  mapDim.y = int(worldY/gridSize)*gridSize;
  mapDim.z = int(worldZ/gridSize)*gridSize;

  worldX = (int)mapDim.x;
  worldY = (int)mapDim.y;
  worldZ = (int)mapDim.z;

  if (gui) {
    for (int i=0;i<furnitureList.size();i++) {
      String thisFurniture = furnitureList.get(i).name;
      if (cp5.getGroup(thisFurniture)!=null) {
        if (furniture == i) {
          cp5.getGroup(thisFurniture).setVisible(true);
        }
        else {
          cp5.getGroup(thisFurniture).setVisible(false);
        }
      }
    }
    updateConsole();
    fill(0);
    noStroke();
    textAlign(BOTTOM);
    textFont(titleBoldFont);
    text("re·collection", 20, 40);
    fill(200);
    textFont(titleLightFont);
    text(furnitureList.get(furniture).name, columnx, 40) ;
    textFont(boldFont);
    fill(fontColor);
    // move this to build geometry and set some global geometry variables...
    int partCount = 0;
    String validatedString = (validated ? "OK" : "KO");
    String geometryInfo = nf(partCount, 3)+" parts  "+nf(faceNum, 5)+" faces  "+ nf(vertexNum, 5)+ " vertex  "+nf((int)lastOp, 4)+" miliseconds "+validatedString;
    text(nf(day(), 2)+"/"+nf(month(), 2)+"/"+(year()+"").substring(2, 4)+" "+nf(hour(), 2)+":"+nf(minute(), 2)+":"+nf(second(), 2)+"  "+
      nf(frameRate, 2, 2)+" fps  "+width+"x"+height+"px  "+geometryInfo, consolex, 40) ;
    textFont(lightFont);
    fill(fontColor);
    text(consoleText+((millis()%1000 < 500) ? "" : "_"), consolex, 26);
    cp5.show();
  } 
  else {
    cp5.hide();
  }
}

void updateConsole() {
  if (millis() > consoleTic) {
    if (consoleReady) {
      consoleReady = false;
      consoleText = "";
    }
    consoleTic = millis() + 0;
    if (bufferText.length() > 0) {
      if (bufferText.charAt(0) == ';') {
        bufferText = bufferText.substring(1, bufferText.length());
        consoleReady = true;
        consoleTic = millis()+consoleDelay;
      }
      else {
        consoleText = consoleText+bufferText.charAt(0);
        bufferText = bufferText.substring(1, bufferText.length());
      }
    }
  }
}

void printConsole(String thisString) {
  if (thisString.charAt(0) == '!') {
    consoleText = thisString.substring(1, thisString.length()-1);
    bufferText = ";";
    consoleTic = millis()+consoleDelay;
  } 
  else {
    bufferText = bufferText+thisString;
  }
}

void initGui() {
  ambientLightColor = 100;
  directionalLightColor = 80  ;
  gridColor = 220;
  groundColor = 240;
  solidColor = 255;
  solidAlpha = 255;
  wireframeColor = 0;
  wireframeAlpha = 50;
  strokeColor = 100;
  strokeAlpha = 200;
  fillAlpha = 255;
  fillColor = 255;

  setMode(startMode);

  lightFont = createFont("HelveticaNeue-Light", 10);
  boldFont = createFont("HelveticaNeue-Bold", 10);
  titleBoldFont = createFont("HelveticaNeue-Bold", 24);
  titleLightFont = createFont("HelveticaNeue-Light", 24);
  //
  cp5 = new ControlP5(this);
  guiFont = new ControlFont(lightFont);
  cp5.setFont(guiFont);
  cp5.setColorForeground(color(activeColor));
  cp5.setColorBackground(color(controllerColor));
  cp5.setColorLabel(color(fontColor));
  cp5.setColorValue(color(fontColor));
  cp5.setColorActive(color(activeColor));
  cp5.lock();
  /////////////////////////
  // main group
  /////////////////////////
  cx = 0;
  cy = 0;
  Group gMain = cp5.addGroup("main").setPosition(20, marginy).hideBar();
  createButton(gMain, "changeCollection", "change collection");
  //  createButton(gMain, "buildGeometry", "build");
  //  createButton(gMain, "updateGeometry", "update");
  createButton(gMain, "randomGeometry", "generate model");
  createButton(gMain, "resetGeometry", "reset parameters");
  cy += sh/2;
  createButton(gMain, "saveFrames", "save image");
  //  createToggle(gMain, "video", video, "save movie");
  createButton(gMain, "makeCatalog", "save catalog");
  createSlider(gMain, "catalogColumns", catalogColumns, 1, 10, true, "catalog columns");
  createSlider(gMain, "catalogRows", catalogRows, 1, 10, true, "catalog rows");
  createSlider(gMain, "catalogRes", catalogRes, 1, 10, true, "catalog res");
  cy += sh/2;
  createButton(gMain, "saveSTL", "save model");
  //createSlider(gMain, "tightness", tightness, .1, .4, true, "tightness");
  createSlider(gMain, "segmentRes", segmentRes, 4, 32, true, "tube detail");
  createSlider(gMain, "curveRes", curveRes, 4, 32, true, "curve detail");
  createSlider(gMain, "cylinderRes", curveRes, 4, 32, true, "cylinder detail");
  createSlider(gMain, "sphereRes", sphereRes, 4, 32, true, "sphere detail");
  cy += sh/2;
  createSlider(gMain, "autoDelay", autoDelay, 0, 2000, false, "auto speed");
  createToggle(gMain, "auto", auto, "auto");
  createToggle(gMain, "validate", validate, "validate");
  cy += sh/2;
  createSlider(gMain, "worldX", worldX, 0, 4000, true, "width");
  createSlider(gMain, "worldY", worldY, 0, 4000, true, "depth");
  createSlider(gMain, "worldZ", worldZ, 0, 2000, true, "height");
  //  cy += sh;
  //  createSlider(gMain, "pRotX", pRotX, 0, PI, true, "X rotation");
  //  createSlider(gMain, "pRotY", pRotY, 0, PI, true, "Y rotation");
  //  createSlider(gMain, "pRotZ", pRotZ, 0, PI, true, "Z rotation");
  //  cy += sh;
  //  createSlider(gMain, "pLocX", pLocX, -mapDim.x, mapDim.x, true, "X location");
  //  createSlider(gMain, "pLocY", pLocY, -mapDim.y, mapDim.y, true, "Y location");
  //  createSlider(gMain, "pLocZ", pLocZ, -mapDim.z, mapDim.z, true, "Z location");
  generateControllerList.add("basics");
  generateControllerList.add("original");

  updateControllerList.add("segmentRes");
  updateControllerList.add("curveRes");
  updateControllerList.add("sphereRes");
  updateControllerList.add("cylinderRes");
  updateControllerList.add("tightness");


  /////////////////////////
  // world group
  /////////////////////////
  cx = 0;
  cy = 0;
  Group gWorld = cp5.addGroup("world").setPosition(width-200, marginy).hideBar();
  //  createSlider(gWorld, "targetZoom", targetZoom, -.15, .09, true, "zoom");
  //  createSlider(gWorld, "targetFov", targetFov, PI/5, PI/2, true, "field of view");
  //  createSlider(gWorld, "targetX", targetX, 0, PI/2, true, "Z rotation");
  //  createSlider(gWorld, "targetZ", targetZ, 0, (2*PI), false, "Y rotation");
  //  createSlider(gWorld, "locY", locY, 0, height*2, true, "Y location");
  createToggle(gWorld, "rotation", rotation, "rotate");
  createToggle(gWorld, "grid", grid, "grid");
  createToggle(gWorld, "ground", ground, "floor");
  createToggle(gWorld, "limits", limits, "limits");
  createToggle(gWorld, "axis", axis, "origin");
  createToggle(gWorld, "isometric", rotation, "isometric");
  //  createToggle(gWorld, "original", original, "original");
  //  createToggle(gWorld, "basics", basics, "frame");
  createToggle(gWorld, "wireframe", wireframe, "wireframe");

  createToggle(gWorld, "solid", solid, "solid");
  createToggle(gWorld, "material", material, "color");

  createToggle(gWorld, "filled", filled, "filled");
  createToggle(gWorld, "structure", structure, "geometry");
  createToggle(gWorld, "dots", dots, "points");
  createToggle(gWorld, "details", details, "construction");  
  createToggle(gWorld, "light", light, "lights");
  createToggle(gWorld, "soft", soft, "smooth");
  cy += sh/2;
  createSlider(gWorld, "backgroundColor", backgroundColor, 0, 255, true, "background");
  //  createSlider(gWorld, "fontColor", fontColor, 0, 255, true, "font color");
  //  createSlider(gWorld, "sliderColor", sliderColor, 0, 255, true, "slider color");
  //  createSlider(gWorld, "activeColor", activeColor, 0, 255, true, "active color");
  createSlider(gWorld, "ambientLightColor", ambientLightColor, 0, 255, true, "ambient light");
  createSlider(gWorld, "directionalLightColor", directionalLightColor, 0, 255, true, "directional light");
  // createSlider(gWorld, "specularAlpha", specularAlpha, 0, 255, true, "specular light");
  createSlider(gWorld, "solidColor", solidColor, 0, 255, true, "solid color");
  createSlider(gWorld, "solidAlpha", solidAlpha, 0, 255, true, "solid alpha");
  createSlider(gWorld, "wireframeColor", wireframeColor, 0, 255, true, "wireframe color");
  createSlider(gWorld, "wireframeAlpha", wireframeAlpha, 0, 255, true, "wireframe alpha");
  createSlider(gWorld, "fillColor", fillColor, 0, 255, true, "fill color");
  createSlider(gWorld, "fillAlpha", fillAlpha, 0, 255, true, "fill alpha");
  createSlider(gWorld, "strokeColor", strokeColor, 0, 255, true, "stroke color");
  createSlider(gWorld, "strokeAlpha", strokeAlpha, 0, 255, true, "stroke alpha");
  createSlider(gWorld, "gridColor", gridColor, 0, 255, true, "grid color");
  createSlider(gWorld, "groundColor", groundColor, 0, 255, true, "ground color");

  retainControllerList.add("wireframe");
  retainControllerList.add("solid");
  retainControllerList.add("material");
  retainControllerList.add("filled");
  retainControllerList.add("light");
  retainControllerList.add("soft");
  retainControllerList.add("ambientLightColor");
  retainControllerList.add("solidColor");
  retainControllerList.add("solidAlpha");
  retainControllerList.add("wireframeColor");
  retainControllerList.add("wireframeAlpha");
  retainControllerList.add("fillAlpha");

  cp5.mapKeyFor(new ControlKey() { 
    public void keyEvent() { 
      gridMode = (gridMode+1)%3;
    }
  }
  , 'g', SHIFT);

  cp5.mapKeyFor(new ControlKey() { 
    public void keyEvent() { 
      soft=!soft;
    }
  }
  , 's');

  cp5.mapKeyFor(new ControlKey() { 
    public void keyEvent() { 
      original=!original;
      buildGeometry();
    }
  }
  , '-');

  cp5.mapKeyFor(new ControlKey() { 
    public void keyEvent() { 
      basics=!basics;
      buildGeometry();
    }
  }
  , '=');

  cp5.mapKeyFor(new ControlKey() { 
    public void keyEvent() { 
      dots=!dots;
    }
  }
  , 'p');

  cp5.mapKeyFor(new ControlKey() { 
    public void keyEvent() {
      saveFrames();
    }
  }
  , 'z');  

  cp5.mapKeyFor(new ControlKey() { 
    public void keyEvent() { 
      randomGeometry();
      // doRebuild = true;
    }
  }
  , ' ');  

  cp5.mapKeyFor(new ControlKey() { 
    public void keyEvent() { 
      rotation=!rotation;
    }
  }
  , 'r');

  cp5.mapKeyFor(new ControlKey() { 
    public void keyEvent() { 
      gui=!gui;
    }
  }
  , ENTER);

  cp5.mapKeyFor(new ControlKey() { 
    public void keyEvent() { 
      grid=!grid;
    }
  }
  , 'g');

  cp5.mapKeyFor(new ControlKey() { 
    public void keyEvent() { 
      light=!light;
    }
  }
  , 'l');

  cp5.mapKeyFor(new ControlKey() { 
    public void keyEvent() { 
      ground=!ground;
    }
  }
  , 'f');

  cp5.mapKeyFor(new ControlKey() { 
    public void keyEvent() { 
      details=!details;
    }
  }
  , 'c');

  cp5.mapKeyFor(new ControlKey() { 
    public void keyEvent() { 
      auto=!auto
        ;
    }
  }
  , 'a');

  cp5.mapKeyFor(new ControlKey() { 
    public void keyEvent() { 
      saveSTL();
    }
  }
  , 'z');

  cp5.mapKeyFor(new ControlKey() { 
    public void keyEvent() { 
      axis = !axis;
    }
  }
  , 'o');

  cp5.mapKeyFor(new ControlKey() { 
    public void keyEvent() { 
      targetX = radians(60);
      targetZ = radians(45);
    }
  }
  , 'r', SHIFT);

  //  cp5.mapKeyFor(new ControlKey() { 
  //    public void keyEvent() { 
  //      saveCanvas();
  //    }
  //  }
  //  , '/');
  //
  //  cp5.mapKeyFor(new ControlKey() { 
  //    public void keyEvent() { 
  //      initCanvas();
  //    }
  //  }
  //  , '/', SHIFT);

  cp5.mapKeyFor(new ControlKey() { 
    public void keyEvent() { 
      isometric = !isometric;
    }
  }
  , 'i');

  cp5.mapKeyFor(new ControlKey() { 
    public void keyEvent() { 
      wireframe = !wireframe;
    }
  }
  , 'w');
}

int lastControllerValue;
String lastControllerName;

void controlEvent(ControlEvent theEvent) {  
  if (mousePressed) { // update only when updates come from user interaction with gui!!!
    if (theEvent.isGroup()) {
     // println(theEvent.group().value());
      raMaterial = materialList.get((int)theEvent.group().value()).name;       //////////////////
      if (theEvent.group().name().equals("materials")) {
        println(theEvent.group().name());
        // furnitureList.get(furniture).update();
      }
    } 
    else if (theEvent.isController()) {    
      Controller c=theEvent.controller();
      String controllerName = c.name();

      if (!controllerName.equals(lastControllerName) || int(c.getValue()) != lastControllerValue) { // hack to debounce float returned values, improve !!!
        lastControllerName = controllerName;
        lastControllerValue = int(c.getValue());
        boolean retainFlag = false;
        for (String thisRetainController : retainControllerList) {
          if (thisRetainController.equals(controllerName)) {
            retainFlag = true;
            break;
          }
        }
        if (retainFlag) {    
          if (solid || wireframe) {
            updateMaterials();
          }
        }
        boolean updateFlag = false;
        for (String thisUpdateController : updateControllerList) {
          if (thisUpdateController.equals(controllerName)) {
            updateFlag = true;
            break;
          }
        }
        if (updateFlag) {   
          updateGeometry();
        }
        boolean generateFlag = false;
        for (String thisGenerateController : generateControllerList) {
          if (thisGenerateController.equals(controllerName)) {
            generateFlag = true;
            break;
          }
        }
        if (generateFlag) {      
          generateGeometry();
        }
        boolean limitsFlag = false;
        for (int i=0;i<limitControllerList.length;i++) {
          String thisController = limitControllerList[i];
          if (thisController.equals(controllerName)) {
            limitsFlag = true;
            break;
          }
        }
        if (limitsFlag) {        
          updateWorld();
        }
        if (controllerName.equals("mesh")) {
          doRebuild = true;
        }
      }
    }
  }
}

void createDropdownList(Group thisGroup, String label, String[] items) {
  cy+= sh;
  DropdownList d = cp5.addDropdownList("label", cx, cy, guix, 100).setGroup(thisGroup).setLabel(label).setBarHeight(guiy);
  controlP5.Label l = d.captionLabel();
  d.toUpperCase(false);
  //  for (int i=0;i<items.length;i++) {
  d.addItems(items);
  // d.style().marginLeft = 2;
  cy+= sh;
}

Slider createSlider(Group thisGroup, String thisVariable, float val, float minVal, float maxVal, boolean autoUpdate, String label) {
  Slider s = cp5.addSlider(thisVariable, minVal, maxVal, val, cx, cy, guix, guiy).setAutoUpdate(autoUpdate).setGroup(thisGroup);

  s.setLabel(label); // .setDecimalPrecision(1).setSliderMode(Slider.FIX)  // .showTickMarks(true).setNumberOfTickMarks(11).setColorTickMark(activeColor).snapToTickMarks(false)
  controlP5.Label l = s.captionLabel();
  l.toUpperCase(false);
  l.style().marginLeft = 2;
  cy+= sh;
  return s;
}

void createButton(Group thisGroup, String thisFunction, String label) {
  Button b = cp5.addButton(thisFunction, 100, cx, cy, guix, guiy).setGroup(thisGroup);
  b.captionLabel().toUpperCase(false);
  b.setLabel(label);
  controlP5.Label l = b.captionLabel();
  l.style().marginLeft = guix+2; 
  cy+= sh;
}

void createToggle(Group thisGroup, String thisFunction, boolean val, String label) {
  Toggle t = cp5.addToggle(thisFunction, val, cx, cy, guix, guiy).setAutoUpdate(true).setGroup(thisGroup); 
  t.captionLabel().toUpperCase(false);
  t.setLabel(label);
  controlP5.Label l = t.captionLabel();
  l.style().marginTop = -17;
  l.style().marginLeft = guix+6;
  cy+= sh;
}

void setMode (int thisMode) {
  switch(thisMode) {
  case 1:
    material = true;
    light = true;
    soft = true;
    solid = true;
    wireframe = false;
    filled = false;
    structure = false;
    details = false;
    dots = false;
    //solidColor = 255;
    //solidAlpha = 255;
    break;
  case 2:
    material = true;
    light = true;
    soft = false;
    solid = true;
    wireframe = false;
    structure = false;
    filled = false;
    details = false;
    dots = false;  
    //solidColor = 255;
    //solidAlpha = 255;
    break;
  case 3:
    material = false;
    light = true;
    soft = false;
    solid = true;
    wireframe = false;
    structure = false;
    filled = false;
    details = false;
    dots = false;  
    //solidColor = 255;
    //solidAlpha = 255;
    break;
  case 4:
    material = true;
    light = true;
    soft = false;
    solid = true;
    wireframe = true;
    structure = false;
    filled = false;
    details = false;
    dots = false;   
    solidColor = 255;
    solidAlpha = 255;
    break;
  case 5:
    material = false;
    light = false;
    soft = false;
    solid = true;
    wireframe = true;
    structure = false;
    filled = false;
    details = false;
    dots = false;   
    //solidColor = 255;
    // solidAlpha = 255;
    break;    
  case 6:
    material = false;
    light = false;
    soft = false;
    solid = false;
    wireframe = true;
    filled = true;
    structure = false;
    details = false;
    dots = false;      
    break;
  case 7:
    material = false;
    light = false;
    soft = false;
    solid = false;
    wireframe = true;
    filled = true;
    structure = true;
    details = false;
    dots = false;    
    fillAlpha = 255;   
    break;
  case 8:
    material = false;
    light = false;
    soft = false;
    solid = false;
    wireframe = false;
    filled = true;
    structure = true;
    details = false;
    dots = false;   
    fillAlpha = 150;
    break;
  case 9:
    material = false;
    light = false;
    soft = false;
    solid = false;
    wireframe = false;
    filled = true;
    structure = true;
    details = true;
    dots = true; 
    fillAlpha = 150;   
    break;
  case 0:
    grid = false;
    ground = false;
    material = false;
    light = false;
    soft = false;
    solid = true;
    wireframe = false;
    structure = false;
    details = false;
    dots = false;    
    solidColor = 0;
    solidAlpha = 255;
    break;
  }
}

//
//boolean[] keys = new boolean[526];
// 
//void draw(){}
// 
//boolean checkKey(int k)
//{
//  if (keys.length >= k) {
//    return keys[k];  
//  }
//  return false;
//}
// 
//void keyPressed()
//{ 
//  keys[keyCode] = true;
//  println(KeyEvent.getKeyText(keyCode));
//  if(checkKey(CONTROL) && checkKey(KeyEvent.VK_S)) println("CTRL+S");
//}
// 
//void keyReleased()
//{ 
//  keys[keyCode] = false; 
//}

