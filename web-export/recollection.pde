
int startMode = 8;
int furniture = 0;
boolean validated = true;

boolean gui = true;
boolean limits = false;
boolean axis = false;
boolean material = true;
boolean wireframe =false;
boolean solid = true;
boolean structure =false;
boolean filled = true;
boolean dots = false;
boolean details = false;
boolean light = true;
boolean soft = false;
boolean isometric = false;
boolean ground = false;
boolean grid = false;
boolean rotation = false;
boolean dragged = false;
boolean moved = false;
boolean basics = false;
boolean original = false;
boolean debug = false;
boolean catalog = false;
boolean video = false;

boolean show = false;
boolean auto = false;
boolean validate = false;

import toxi.processing.*;
import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.math.MathUtils;

ToxiclibsSupport fx;

import rosettamesh.*;

import wblut.geom.core.*;
import wblut.hemesh.creators.*;
import wblut.hemesh.tools.*;
import wblut.geom.grid.*;
import wblut.geom.nurbs.*;
import wblut.core.math.*;
import wblut.hemesh.subdividors.*;
import wblut.core.processing.*;
import wblut.hemesh.composite.*;
import wblut.core.random.*;
import wblut.hemesh.core.*;
import wblut.geom.frame.*;
import wblut.core.structures.*;
import wblut.hemesh.modifiers.*;
//import wblut.hemesh.options.*;
import wblut.hemesh.simplifiers.*;
import wblut.geom.triangulate.*;
import wblut.geom.tree.*;

WB_Render render;
PShape retained;

//int RES = 64;  // increase resolution to 128 for great detail
//float ISO = 0.2;
//float MAX_ISO=0.66;

void setup() {
  background(backgroundColor);
  size(displayWidth, displayHeight, P3D);
  frameRate(60);
  smooth(smoothLevel);
  fx = new ToxiclibsSupport(this);
  render=new WB_Render(this);
  initGui();
  initCamera();
  initGeometry();
  printConsole("re·collection ready...;");
}

void draw() {
  background(backgroundColor);
  if (show) {
    showCatalog();
  } 
  else {
    pushMatrix();
    updateCamera();
    displayGeometry();
    resetCamera();
    popMatrix();
    updateCatalog(); 
    updateGui();
  }
}

////////////////////////////////////////////////////////////////////////////
//
//  parametric breuer collection with bent steel tube and leather strips
//
////////////////////////////////////////////////////////////////////////////


int bTubeR, bCornerR, bStepLength, bShortStepLength, bStepNum, bRatioShortSteps, bRatioFabric, bFabricThickness, leatherColor, metalColor;

boolean bExtrudeFabric = true;

boolean bClosedPipe;

class Breuer extends Furniture {
  ArrayList<Line3D> segmentList; 
  ArrayList<Line3D> intersectionList;
  ArrayList<Line3D> usedSegmentList;
  ArrayList<Vec3D> connectorList; 
  ArrayList<Line3D> connectionList;

  ToxicMesh breuerMesh;
  Pipe pipe;   // maybe make local ??
  Fabric myFabric;  // maybe make local ??

  Breuer() {
    reset();
    cx = 0;
    cy = 0;
    Group gBreuer = cp5.addGroup("breuer").setPosition(columnx, marginy).hideBar();
    createSlider(gBreuer, "bStepNum", bStepNum, 0, 50, true, "number of steps");
    cy += sh/2;
    createToggle(gBreuer, "bClosedPipe", bClosedPipe, "closed pipe");
    cy += sh/2;
    createSlider(gBreuer, "bStepLength", bStepLength, 0, 10, true, "long step length");
    createSlider(gBreuer, "bShortStepLength", bShortStepLength, 1, 10, true, "short step length");
    createSlider(gBreuer, "bRatioShortSteps", bRatioShortSteps, 0, 10, true, "ratio long/short steps");
    cy += sh/2;
    createSlider(gBreuer, "bRatioFabric", bRatioFabric, 0, 100, true, "ratio strips");
    cy += sh/2;
    createSlider(gBreuer, "bTubeR", bTubeR, 5, 50, true, "tube radius");
    createSlider(gBreuer, "bCornerR", bCornerR, 10, 500, true, "corner radius");

    cy += sh/2;
//    createSlider(gBreuer, "leatherColor", leatherColor, 0, 255, true, "leather color");
//    createSlider(gBreuer, "metalColor", metalColor, 0, 255, true, "metal color");
    updateControllerList.add("bCornerR");
    updateControllerList.add("bTubeR");
    updateControllerList.add("bClosedPipe");
  }

  void reset () {
    bClosedPipe = false;
    bTubeR = 10;
    bCornerR = 50;
    bStepLength = 10;
    bShortStepLength = 3;
    bStepNum = 15;
    bRatioShortSteps = 2;
    bRatioFabric = 3;
    bFabricThickness = 2;
  }

  void update() {
    pipe.cornerR = bCornerR;
    pipe.tubeR = bTubeR;
    for (Part thisPart : partList) {
      thisPart.update();
    }
  }

  void generate() {
    //    updateWorld();
    gridSize = 50;
    partList = new ArrayList<Part>();
    segmentList =  new ArrayList<Line3D>();

    if (original) {
      if (breuerMesh == null) {
//        breuerMesh = new ToxicMesh();
//        breuerMesh.loadMesh("Breuer_m_binary.stl");
//        breuerMesh.setLocation(new Vec3D(0, 0, -bTubeR));
//        breuerMesh.setScale(1000);
//        breuerMesh.offcenter = true;
//        breuerMesh.material = "model";
//        breuerMesh.update();
      }
//      partList.add(breuerMesh);
    }

    if (basics) {
      pipe = new Pipe();
      float stepL = bStepLength*gridSize;
      float stepLL =  (bStepLength+4)*gridSize;
      float stepS = bShortStepLength*gridSize;
      pipe.addPoint(new Vec3D(-stepLL/2, 0, 0));
      pipe.addPoint(new Vec3D(-stepLL/2, -stepL/2, 0));
      pipe.addPoint(new Vec3D(-stepLL/2, -stepL/2, stepL));
      pipe.addPoint(new Vec3D(-stepLL/2+stepS, -stepL/2, stepL));
      pipe.addPoint(new Vec3D(-stepLL/2+stepS, -stepL/2, stepL-stepS));
      pipe.addPoint(new Vec3D(stepLL/2-stepS, -stepL/2, stepL-stepS));
      pipe.addPoint(new Vec3D(stepLL/2-stepS, -stepL/2, stepL));
      pipe.addPoint(new Vec3D(stepLL/2, -stepL/2, stepL));
      pipe.addPoint(new Vec3D(stepLL/2, -stepL/2, 0));
      pipe.addPoint(new Vec3D(stepLL/2, 0, 0));

      // pipe.addPoint(new Vec3D(stepL/2, 0, 0));
      pipe.addPoint(new Vec3D(stepLL/2, stepL/2, 0));
      pipe.addPoint(new Vec3D(stepLL/2, stepL/2, stepL));
      pipe.addPoint(new Vec3D(stepLL/2-stepS, stepL/2, stepL));
      pipe.addPoint(new Vec3D(stepLL/2-stepS, stepL/2, stepL-stepS));
      pipe.addPoint(new Vec3D(-stepLL/2+stepS, stepL/2, stepL-stepS));
      pipe.addPoint(new Vec3D(-stepLL/2+stepS, stepL/2, stepL));
      pipe.addPoint(new Vec3D(-stepLL/2, stepL/2, stepL));
      pipe.addPoint(new Vec3D(-stepLL/2, stepL/2, 0));
      pipe.addPoint(new Vec3D(-stepLL/2, 0, 0));

      //     pipe.addPoint(new Vec3D(+stepL/2-stepS, -stepL/2, stepL-stepS));

      pipe.cornerR = bCornerR;
      pipe.tubeR = bTubeR;
      pipe.material = "metal";
      partList.add(pipe);

      //      float pChairW = 720;
      //      float pChairH = 515;
      //      float pChairD = 640;
      //      float pCornerW = 140;
      //      float pCornerH = 170;
      //      pipe.addPoint(new Vec3D(-pChairW/2, 0, 0));
      //      pipe.addPoint(new Vec3D(-pChairW/2, -pChairD/2, 0));
      //
      //      pipe.addPoint(new Vec3D(-pChairW/2, -pChairD/2, pChairH));
      //      pipe.addPoint(new Vec3D(-pChairW/2+pCornerW, -pChairD/2, pChairH));
      //      pipe.addPoint(new Vec3D(-pChairW/2+pCornerW, -pChairD/2, pChairH-pCornerH));
      //
      //      pipe.addPoint(new Vec3D(+pChairW/2-pCornerW, -pChairD/2, pChairH-pCornerH));
      //      pipe.addPoint(new Vec3D(+pChairW/2-pCornerW, -pChairD/2, pChairH));
      //      pipe.addPoint(new Vec3D(+pChairW/2, -pChairD/2, pChairH));
      //      pipe.addPoint(new Vec3D(+pChairW/2, -pChairD/2, 0));
      //      pipe.addPoint(new Vec3D(+pChairW/2, 0, 0));
      //
      //      pipe.addPoint(new Vec3D(pChairW/2, 0, 0));
      //      pipe.addPoint(new Vec3D(pChairW/2, pChairD/2, 0));
      //
      //      pipe.addPoint(new Vec3D(pChairW/2, pChairD/2, pChairH));
      //      pipe.addPoint(new Vec3D(pChairW/2-pCornerW, pChairD/2, pChairH));
      //      pipe.addPoint(new Vec3D(pChairW/2-pCornerW, pChairD/2, pChairH-pCornerH));
      //
      //      pipe.addPoint(new Vec3D(-pChairW/2+pCornerW, pChairD/2, pChairH-pCornerH));
      //      pipe.addPoint(new Vec3D(-pChairW/2+pCornerW, pChairD/2, pChairH));
      //      pipe.addPoint(new Vec3D(-pChairW/2, pChairD/2, pChairH));
      //
      //      pipe.addPoint(new Vec3D(-pChairW/2, pChairD/2, 0));
      //      pipe.addPoint(new Vec3D(-pChairW/2, 0, 0));
      //
      //      pipe.cornerR = bCornerR;
      //      pipe.tubeR = bTubeR;
      //      pipe.material = 1;
      //      partList.add(pipe);
      for (int i =0;i<pipe.pointList.size()-1;i++) {
        Line3D newSegment = new Line3D(pipe.pointList.get(i), pipe.pointList.get(i+1));
        segmentList.add(newSegment);
      }
    }
    /*
     Cylinder seat = new Cylinder();
     seat.setLocation(new Vec3D(0, 0, 0));
     seat.setRotation(new Vec3D(1, 0, 0));
     seat.setRadius(pTubeSmallR);
     seat.setHeight(pChairD);
     partList.add(seat);
     */
    generateRandomPipe();
    generateFabrics();
    generated = true;
    validated = true;
  }

  void generateRandomPipe() {
    pipe = new Pipe();
    Vec3D newPoint = loc.copy();
    Vec3D lastStep = Vec3D.ZERO.copy();
    Vec3D lastPoint = Vec3D.ZERO.copy();
    pipe.addPoint(newPoint.copy());
    int totalAttempts = 0;
    for (int i=0;i<bStepNum;i++) {
      boolean flag = false;
      int attempts = 0;
      while (flag == false && attempts < 500) {
        // println("attempts "+attempts);
        boolean directionFlag = false; // to check if new direction is equal or opposite to previous one
        boolean boundariesFlag = false; // to check if new end point is within boundaries
        boolean intersectFlag = false; // to check if new segment intersects previous ones
        Vec3D step = normalList[(int)random(6)].copy(); // get random direction
        //Vec3D step = new Vec3D(random(2*PI), random(2*PI), random(PI));
        // check if direction is same or opposite
        if ( step.equals(lastStep.getInverted()) || step.equals(lastStep) ) {
          attempts ++;
          directionFlag = true;
        } 
        if (!directionFlag) {
          // calculate lenght of next step
          int stepLength = 0;
          float n = random(10);      
          if (n>bRatioShortSteps) {
            stepLength = int(bStepLength * gridSize);
          } 
          else {
            stepLength = int(bShortStepLength*gridSize);
          }
          newPoint.addSelf(step.scale(stepLength));
          // check if new point is within boundaries
          if (!newPoint.isInAABB(worldBox)) {
            attempts ++;
            boundariesFlag = true;
            newPoint.subSelf(step.scale(stepLength));
          } 
          if (!boundariesFlag) {
            Line3D newSegment = new Line3D(lastPoint, newPoint);
            /// check for intersections with previous tubes
            for (Line3D thisSegment: segmentList) {
              if (checkLinesCollision(newSegment, thisSegment)) {
                attempts ++;
                intersectFlag = true;
                newPoint.subSelf(step.scale(stepLength));
                break;
              }
            }
            if (!intersectFlag) {
              flag = true;
              segmentList.add(newSegment.copy());
              lastStep = step.copy();
              lastPoint = newPoint.copy();
              pipe.addPoint(newPoint.copy());
            }
          }
        }
      }
      totalAttempts += attempts;
    }
    if (bClosedPipe) {
      pipe.addPoint((Vec3D)pipe.pointList.get(0));
    }

    if (pipe.pointList.size()>1) {
      printConsole("!tested "+totalAttempts+" options for "+ segmentList.size()+" segments;");
      partList.add(pipe);
      pipe.cornerR = bCornerR;
      pipe.tubeR = bTubeR;
      pipe.material = "metal";
    }
  }

  void generateFabrics() {
    usedSegmentList =  new ArrayList<Line3D>();
    connectorList  = new ArrayList<Vec3D>(); 
    connectionList = new ArrayList<Line3D>(); 
    // iterate over all segments of the piece in order to place fabrics
    ArrayList<Vec3D> thisPointList = new ArrayList();
    ArrayList<Vec3D> otherPointList = new ArrayList();
    for (Line3D thisSegment : segmentList) {
      for (Line3D otherSegment : segmentList) {
        ArrayList<Line3D> thisConnectionList = new ArrayList();

        if (!thisSegment.equals(otherSegment) &&           // check we are not connecting the same segments
        checkLinesParallel(thisSegment, otherSegment) &&        // check to connect only parallel segments 
        !checkLinesCoincident(thisSegment, otherSegment) &&          // check segments are not coincident
        !(thisSegment.a.z == 0 && thisSegment.b.z == 0 && otherSegment.a.z == 0 && otherSegment.b.z == 0)) { // check both segments are not on the floor


          // calculate points on segment that might potentially be connected
          thisPointList  = new ArrayList<Vec3D>();
          otherPointList  = new ArrayList<Vec3D>();   
          for (Vec3D thisPoint : thisSegment.splitIntoSegments(null,gridSize,false)) {  // false to ignore first point
            if (!thisPoint.equals(thisSegment.b)) { // and this to ignore last point
              thisPointList.add(thisPoint.copy());
              connectorList.add(thisPoint.copy());  // for displaying connectors only...
            }
          }
          for (Vec3D otherPoint : otherSegment.splitIntoSegments(null,gridSize,false)) {
            if (!otherPoint.equals(otherSegment.b)) { // to avoid including last point
              otherPointList.add(otherPoint.copy());
              connectorList.add(otherPoint.copy());  // for displaying connectors only...
            }
          }
          // calculate all possible connections between the points
          for (Vec3D thisPoint : thisPointList) {
            // we look for the closest point on this point to the other line (which will connect always with a perpendicular line)
            Vec3D closestPoint = otherSegment.closestPointTo(thisPoint);
            Line3D closestLine = new Line3D(thisPoint, closestPoint);
            Vec3D closestDirection = closestLine.getDirection().normalize();
            for (Vec3D otherPoint : otherPointList) {
              Line3D thisLine = new Line3D (thisPoint, otherPoint);
              Vec3D thisDirection = thisLine.getDirection().normalize();
              // and we only add connections that are parallel to the closest line (so they are perpendicular and never skewed or crossing)
              if (thisDirection.equals(closestDirection)) {
                thisConnectionList.add(thisLine);
                connectionList.add(thisLine);  //  for displaying posible connections only...
              }
            }
          }
          // we have all possible connections betwen every pair of parallel segment, let's place the pieces of fabric where appropriate

            // check if segment is free
          //          boolean free = true;
          //          for (Line3D currentSegment : usedSegmentList) {
          //            if (currentSegment.equals(thisSegment) || currentSegment.equals(otherSegment)) {
          //              free = false;
          //              break;
          //            }
          //          }
          //          usedSegmentList.add(thisSegment);
          //          usedSegmentList.add(otherSegment);

          for (int i=0;i<(thisConnectionList.size()/2);i++) {
            if (random(100)<bRatioFabric) {
              Fabric newFabric = new Fabric();
              Line3D firstConnection = thisConnectionList.get((i*2));
              Line3D lastConnection = thisConnectionList.get((i*2)+1); // thisConnectionList.size()-1
              newFabric.a = firstConnection.a; 
              newFabric.b = firstConnection.b;
              newFabric.c = lastConnection.b;
              newFabric.d = lastConnection.a;
              newFabric.thickness = bFabricThickness;
              partList.add(newFabric);
              newFabric.material = "leather";
            }
          }
        }
      }
    }
  }

  void display() {
    for (Part thisPart : partList) {
      thisPart.display();
    }
    if (details) {
      for (Line3D thisSegment : segmentList) {
        stroke(color(strokeColor, 0, 0), strokeAlpha);
        strokeWeight(thinStroke);
        fx.line(thisSegment);
      }
      for (Line3D thisLine : connectionList) {
        stroke(color(strokeColor, 0, 0), strokeAlpha/2);
        strokeWeight(thinStroke);
        fx.line(thisLine);
      }
    }
    if (dots) {
      for (Vec3D thisPoint : connectorList) {
        stroke(blueColor);
        strokeWeight(markerStroke);
        drawMarker(thisPoint);
      }
    }
  }
}

float targetZoom, targetFov, targetZ, targetX;

float currentFov, currentZoom, currentZ, currentX;
float offsetX, offsetY;

float locX = 0;
float locY = 0;

void initCamera() {
  targetFov = 0.6; // radians(60);
  // targetX = radians(60);
  // targetZ = radians(45+180);
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
  translate(width/2, height/2);
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

    float cameraDelay = .1;
   // float cameraJog = .1;
    currentFov += (targetFov-currentFov) * cameraDelay;
    currentZoom += (targetZoom-currentZoom) * cameraDelay;
    currentX += (targetX-currentX) * cameraDelay;
    currentZ += (targetZ-currentZ) * cameraDelay;

    // if (targetZ<0) targetZ = (2*PI)-targetZ;  // update gui for continous rotation !!!
    // if (targetZ>2*PI) targetZ = (targetZ%(2*PI));
    scale(map(currentZoom, 0, 1, currentFov, 2*PI));  // adjust so fov relates to zoom   !!!
    translate(locX, locY);
    rotateX(currentX);
    rotateZ(currentZ);
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

int caBulbScale, caRadius, caSphereRadius;
float caBulbRadiusOffset, caBulbFaceOffset;
int caPlateThickness, caChamferDistance;
int caStructureType;

//int glassAlpha = 100, glassColor = 240;

class Castiglioni extends Furniture {
  ArrayList<ToxicMesh> plateList;
  ArrayList<Bulb> bulbList;

  TriangleMesh bulbMesh;
  HE_Mesh structureMesh;

  Castiglioni () {
    reset();
    cx = 0;
    cy = 0;
    Group gCastiglioni = cp5.addGroup("castiglioni").setPosition(columnx, marginy).hideBar();
    createSlider(gCastiglioni, "caStructureType", caStructureType, 0, 4, true, "polyhedron type");
    createSlider(gCastiglioni, "caRadius", caRadius, 0, 500, true, "lamp radius");
    createSlider(gCastiglioni, "caSphereRadius", caSphereRadius, 0, 500, true, "bulb radius");
    createSlider(gCastiglioni, "caBulbRadiusOffset", caBulbRadiusOffset, 0, 200, true, "bulb radial offset");
    createSlider(gCastiglioni, "caBulbFaceOffset", caBulbFaceOffset, 0, 1, true, "bulb lateral offset");
    createSlider(gCastiglioni, "caPlateThickness", caPlateThickness, 0, 20, true, "plate thickness");
    createSlider(gCastiglioni, "caChamferDistance", caChamferDistance, 0, 20, true, "chamfer distance");
    cy += sh/2;
    // createSlider(gCastiglioni, "metalColor", metalColor, 0, 255, true, "metal color");
   // createSlider(gCastiglioni, "glassAlpha", glassAlpha, 0, 255, true, "glass alpha");
   // createSlider(gCastiglioni, "glassColor", glassColor, 0, 255, true, "glass color");

    updateControllerList.add("caSphereRadius");
    generateControllerList.add("caStructureType");
    generateControllerList.add("caRadius");
    generateControllerList.add("caPlateThickness");
    generateControllerList.add("caChamferDistance");
    generateControllerList.add("caBulbOffset");
    generateControllerList.add("caBulbRadiusOffset");
    generateControllerList.add("caBulbFaceOffset");
  }

  void reset() {
    caStructureType = 0;
    caChamferDistance = 10;
    caPlateThickness = 5;
    caRadius = 300;
    caSphereRadius = 68;
    caBulbRadiusOffset = 90;
    caBulbFaceOffset = .50;
  }

  void generate() {
    partList = new ArrayList<Part>();
    bulbList = new ArrayList<Bulb>();

    switch(caStructureType) {
    case 0:
      HEC_Box creator0 = new HEC_Box().setHeight(caRadius).setWidth(caRadius).setDepth(caRadius);
      structureMesh=new HE_Mesh(creator0);
      break;

    case 1:
      HEC_Tetrahedron creator1=new HEC_Tetrahedron();
      creator1.setEdge(caRadius);// radius of sphere circumscribing cube
      structureMesh=new HE_Mesh(creator1);
      break;
    case 2:
      HEC_Octahedron creator2=new HEC_Octahedron();
      creator2.setEdge(caRadius);// radius of sphere circumscribing cube
      structureMesh=new HE_Mesh(creator2);
      break;
    case 3:
      HEC_Icosahedron creator3=new HEC_Icosahedron();
      creator3.setEdge(caRadius);// radius of sphere circumscribing cube
      structureMesh=new HE_Mesh(creator3);
      break;
    case 4:
      HEC_Dodecahedron creator4=new HEC_Dodecahedron();
      creator4.setEdge(caRadius);// radius of sphere circumscribing cube
      structureMesh=new HE_Mesh(creator4);
      break;
    }
    //alternatively 
    //creator.setInnerRadius(200);// radius of sphere inscribed in cube
    //creator.setMidRadius(200);// radius of sphere tangential to edges

    // loop for every face, create bulbs and plates
    HE_Face[] faceList =  ((HE_MeshStructure)structureMesh).getFacesAsArray();
    for (int i=0;i< faceList.length; i ++) {
      HE_Face thisFace = faceList[i];
      Vec3D thisCenter =  WE_Point3dToVec3D(thisFace.getFaceCenter());
      Vec3D thisNormal = WE_Point3dToVec3D(thisFace.getFaceNormal()).normalize();
      List<HE_Vertex> verticesList = thisFace.getFaceVertices();
      // bulbs
      for (int j=0;j<verticesList.size();j++) {
        Vec3D thisVertex = WE_Point3dToVec3D(verticesList.get(j));
        Line3D newLine = new Line3D(thisVertex, thisCenter);
        Vec3D thisDirection = newLine.getDirection();
        Vec3D thisLocation = thisVertex.add(thisDirection.scale(newLine.getLength()*caBulbFaceOffset).add(thisNormal.scale(caBulbRadiusOffset)));
        addBulb(thisLocation, new Line3D(thisLocation, thisLocation.add(thisNormal)));
      }
      // plates
      //  List<HE_Vertex> thisFaceVertices = thisFace.getFaceVertices();
      int vertexNum = verticesList.size();
      WB_Point3d[] basepoints= new WB_Point3d[vertexNum];
      for (int j=0;j<vertexNum;j++) {
        basepoints[j] = verticesList.get(j);
      }
      WB_Polygon polygon=new WB_ExplicitPolygon(basepoints, vertexNum);
      HEC_Polygon polygonCreator=new HEC_Polygon();
      polygonCreator.setPolygon(polygon);//alternatively polygon can be a WB_Polygon2D
      polygonCreator.setThickness(caPlateThickness);// thickness 0 creates a surface
      HEM_ChamferCorners chamferModifier = new HEM_ChamferCorners().setDistance(caChamferDistance);
      HE_Mesh faceMesh=new HE_Mesh(polygonCreator);
      faceMesh.modify(chamferModifier);

      ToxicMesh plate = new ToxicMesh();
      plate.setMesh(toxi.toToxi(hemesh.fromHemesh(faceMesh)));

      plate.setMaterial("metal");
      plate.setScale(1);
      plate.update();
      partList.add(plate);
    }
    validated = true;
    generated = true;
  }

  void addBulb(Vec3D thisLocation, Line3D thisAxis) {
    Bulb bulb = new Bulb();
    bulb.setLocation(thisLocation);
    bulb.sphereRadius = caSphereRadius;
    bulb.setAxis(thisAxis);
    bulb.setMaterial("glass");
    partList.add(bulb);
    bulbList.add(bulb);
  }

  void display() {
    if (structure) {
      strokeWeight(thickStroke);
      stroke(greenColor, strokeAlpha);
      render.drawEdges(structureMesh);
    }
    for (Part thisPart : partList) {
      thisPart.display();
    }
  }

  void update() {
    for (Bulb thisBulb : bulbList) {
      thisBulb.sphereRadius = caSphereRadius;
    }
    for (Part thisPart : partList) {
      thisPart.update();
    }
  }
}

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

class SuperPlane {
  boolean available = true;
  Vec3D a, b, c, d;
  Vec3D center;
  Line3D axisH, axisV;
  Vec3D directionH, directionV;

  SuperPlane (Vec3D a, Vec3D b, Vec3D c, Vec3D d) {
    this.a = a;
    this.b = b;
    this.c = c;
    this.d = d;
    center = new Line3D(a, c).getMidPoint();
    axisV = new Line3D( new Line3D(a, b).getMidPoint(), new Line3D(c, d).getMidPoint());
    axisH = new Line3D( new Line3D(a, d).getMidPoint(), new Line3D(b, c).getMidPoint());
    directionV = axisV.getDirection().normalize();
    directionH = axisH.getDirection().normalize();
  }    

  boolean isWithinWorld() {
    return checkVectorWithinWorld(a) && checkVectorWithinWorld(b) && checkVectorWithinWorld(c) && checkVectorWithinWorld(d);
  }

  boolean isAboveGround() {
    return a.z > 0 && b.z > 0 && c.z > 0 && d.z > 0;
  }

  boolean intersectsBlock(SuperBlock thisBlock, float thisStep) {
    ArrayList<Vec3D> pointsAB = getPointsFromLine(new Line3D(a, b), thisStep, true);
    ArrayList<Vec3D> pointsDC = getPointsFromLine(new Line3D(d, c), thisStep, true);
    for  (int i=0;i<pointsAB.size();i++) {
      Line3D tempLine = new Line3D(pointsAB.get(i), pointsDC.get(i));
      if (checkLineBlockCollision(tempLine, thisBlock)) {
        return true;
      }
    }
    return false;
  }

  boolean intersectsBlockList(ArrayList<SuperBlock> thisBlockList, float thisStep) {
    for (SuperBlock thisBlock : thisBlockList) {
      if (intersectsBlock(thisBlock, thisStep)) {
        return true;
      }
    }
    return false;
  }

  // probably faster as points are calculated only one per block
  // boolean intersectsBlockList(ArrayList<SuperBlock> thisBlockList, float thisStep) {
  //    ArrayList<Vec3D> pointsAB = getPointsFromLine(new Line3D(a, b), thisStep, true);
  //    ArrayList<Vec3D> pointsDC = getPointsFromLine(new Line3D(d, c), thisStep, true);
  //    for  (int i=0;i<pointsAB.size();i++) {
  //      Line3D tempLine = new Line3D(pointsAB.get(i), pointsDC.get(i));
  //      fx.line(tempLine);
  //      if (checkLineBlockListCollision(tempLine, thisBlockList)) {
  //        return true;
  //      }
  //    }
  //    return false;
  //  }

  //  this is not working yet !!!
  //  boolean intersectsSuperPlane(SuperPlane thisPlane, float thisStep) {
  //    ArrayList<Vec3D> pointsAB = getPointsFromLine(new Line3D(a, b), thisStep, true);
  //    ArrayList<Vec3D> pointsCD = getPointsFromLine(new Line3D(c, d), thisStep, true);
  //    ArrayList<Vec3D> pointsEE = getPointsFromLine(new Line3D(thisPlane.a, thisPlane.b), thisStep, true);
  //    ArrayList<Vec3D> pointsFF = getPointsFromLine(new Line3D(thisPlane.c, thisPlane.d), thisStep, true);
  //
  //    for  (int i=0;i<pointsAB.size();i++) {
  //      Line3D tempLineA = new Line3D(pointsAB.get(i), pointsCD.get(i));
  //      for (int j=0;j<pointsEE.size();j++) {
  //        Line3D tempLineB = new Line3D(pointsEE.get(i), pointsFF.get(i));
  //        if (checkLinesCollision(tempLineA, tempLineB)) {
  //          return true;
  //        }
  //      }
  //    }
  //    return false;
  //  }
  //  

  void display() {
    if (details) {
      noFill();
      stroke(redColor, strokeAlpha/3);
      strokeWeight(thinStroke);
      beginShape(QUAD_STRIP);
      vertex(a.x, a.y, a.z);
      vertex(b.x, b.y, b.z);
      vertex(d.x, d.y, d.z);
      vertex(c.x, c.y, c.z);
      endShape();
      //fx.line(axisV);
      //fx.line(axisH);
    }
    if (dots) {
      //      stroke(blueColor);
      //      strokeWeight(markerStroke);
      //      drawMarker(center);
    }
  }
}

TriangleMesh createBlockMeshFromPlane (Vec3D a, Vec3D b, Vec3D c, Vec3D d, int thisOffset, boolean extrudeInBothDirections) {
  Triangle3D thisTriangle  = new Triangle3D(a, b, c);
  Vec3D nor = thisTriangle.computeNormal().normalize();
  Vec3D offsetA;
  Vec3D offsetB; 
  if (extrudeInBothDirections) {
    offsetA = nor.copy().scaleSelf(thisOffset/2);
    offsetB = nor.getInverted();
  } 
  else {
    offsetA = new Vec3D(0, 0, 0);  
    //    if (nor.z<0) {
    //      nor = nor.getInverted(); // hack to extruse always to z positve ... not correct but it works so far... (most of the time, not in vertical planes!!)
    //    }
    offsetB =  nor.copy().scaleSelf(thisOffset);
  }

  Vec3D aa = a.copy().addSelf(offsetA);
  Vec3D bb = b.copy().addSelf(offsetA);
  Vec3D cc = c.copy().addSelf(offsetA);
  Vec3D dd = d.copy().addSelf(offsetA);
  Vec3D ee = a.copy().addSelf(offsetB);
  Vec3D ff = b.copy().addSelf(offsetB);
  Vec3D gg = c.copy().addSelf(offsetB);
  Vec3D hh = d.copy().addSelf(offsetB);

  TriangleMesh blockShapeMesh = new TriangleMesh();

  blockShapeMesh.addFace(aa, dd, bb);
  blockShapeMesh.addFace(bb, dd, cc);
  blockShapeMesh.addFace(ee, hh, ff);
  blockShapeMesh.addFace(ff, hh, gg);
  blockShapeMesh.addFace(aa, dd, hh);
  blockShapeMesh.addFace(hh, ee, aa);
  blockShapeMesh.addFace(bb, ff, gg);
  blockShapeMesh.addFace(gg, cc, bb);
  blockShapeMesh.addFace(aa, bb, ee);
  blockShapeMesh.addFace(ee, bb, ff);
  blockShapeMesh.addFace(dd, cc, hh);
  blockShapeMesh.addFace(hh, gg, cc);
  return blockShapeMesh;
}

TriangleMesh createCylinderMeshFromLine (Line3D thisLine, int thisR) {
  ZAxisCylinder cyl=new ZAxisCylinder(Vec3D.ZERO, thisR, thisLine.getLength());
  TriangleMesh cylinderMesh = (TriangleMesh)cyl.toMesh(cylinderRes, 0);
  cylinderMesh.pointTowards(thisLine.getDirection());
  cylinderMesh.translate(thisLine.getMidPoint());
  return cylinderMesh;
}

TriangleMesh createCylinderMeshFromLineUsingCone (Line3D thisLine, int thisR, boolean topCap, boolean bottomCap) {
  Vec3D thisRot = thisLine.getDirection().normalize();
  Cone cone= new Cone(thisLine.getMidPoint(), thisRot, thisR, thisR, thisLine.getLength());
  TriangleMesh cylinderMesh = (TriangleMesh)cone.toMesh(new TriangleMesh(), cylinderRes, 0, topCap, bottomCap);
  return cylinderMesh;
}

TriangleMesh createConeMeshFromLine (Line3D thisLine, int thisR1, int thisR2, boolean topCap, boolean bottomCap) {
  Vec3D thisRot = thisLine.getDirection().normalize();
  Cone cone= new Cone(thisLine.getMidPoint(), thisRot, thisR1, thisR2, thisLine.getLength());
  TriangleMesh coneMesh = (TriangleMesh)cone.toMesh(new TriangleMesh(), cylinderRes, 0, topCap, bottomCap);
  return coneMesh;
}


//class PerpendicularCylinder extends Part {
//  AxisAlignedCylinder cyl;
//  float r, h;
//
//  PerpendicularCylinder () {
//    id = millis();
//  }
//  void update() {
//  }
//  void build() {
//    cyl=new ZAxisCylinder(new Vec3D(0, 0, 0), r, h);
//    TriangleMesh cylinderMesh = (TriangleMesh)cyl.toMesh(segmentNum*4, 0);
//    cylinderMesh.rotateZ(rot.z);
//    cylinderMesh.rotateY(rot.y);
//    cylinderMesh.rotateX(rot.x);
//    cylinderMesh.translate(loc);
//    meshList[material].addMesh(cylinderMesh);
//  }
//
//  void display() {
//    pushMatrix();
//    rotateX(rot.x*PI/2);
//    rotateY(rot.y*PI/2);
//    rotateZ(rot.z*PI/2);
//    translate(loc.x, loc.y, loc.z-h/2);
//    if (dots) {
//      strokeWeight(markerStroke);
//      stroke(strokeColor, strokeAlpha);
//      drawMarker(Vec3D.ZERO.copy());
//      drawMarker(new Vec3D(0, 0, h));
//    }
//    noFill();
//    stroke(strokeColor, strokeAlpha);
//    strokeWeight(thinStroke);
//    ellipse(0, 0, 2*r, 2*r);
//    translate(0, 0, h);
//    ellipse(0, 0, 2*r, 2*r);
//    popMatrix();
//  }
//
//  void setHeight(float h ) {
//    this.h = h;
//  }
//
//  void setRadius(float r) {
//    this.r = r;
//  }
//}


//TriangleMesh createAxisAlginedCylinderMeshFromLine (Line3D thisLine, int thisR) {
//  Vec3D rot = thisLine.getDirection().normalize();
//  AxisAlignedCylinder cyl= null;
//  if (rot.equals(new Vec3D(0, 0, 1)) || rot.equals(new Vec3D(0, 0, -1))) {
//    cyl=new ZAxisCylinder(new Vec3D(0, 0, 0), thisR, thisLine.getLength());
//  } 
//  else if (rot.equals(new Vec3D(0, 1, 0)) || rot.equals(new Vec3D(0, -1, 0))) {
//    cyl=new YAxisCylinder(new Vec3D(0, 0, 0), thisR, thisLine.getLength());
//  } 
//  else if (rot.equals(new Vec3D(1, 0, 0)) || rot.equals(new Vec3D(-1, 0, 0))) {
//    cyl=new XAxisCylinder(new Vec3D(0, 0, 0), thisR, thisLine.getLength());
//  }
//  TriangleMesh cylinderMesh = (TriangleMesh)cyl.toMesh(segmentNum, 0);
//  cylinderMesh.translate(thisLine.getMidPoint());
//  return cylinderMesh;
//}



class LineStrip3D implements Iterable<Vec3D> {
  public List<Vec3D> vertices = new ArrayList<Vec3D>();
  protected float[] arcLenIndex;

  public LineStrip3D() {
  }

  public LineStrip3D(Collection<? extends Vec3D> vertices) {
    this.vertices = new ArrayList<Vec3D>(vertices);
  }

  public LineStrip3D add(float x, float y, float z) {
    vertices.add(new Vec3D(x, y, z));
    return this;
  }

  public LineStrip3D add(ReadonlyVec3D p) {
    vertices.add(p.copy());
    return this;
  }

  public LineStrip3D add(Vec3D p) {
    vertices.add(p);
    return this;
  }

  /**
   * Returns the vertex at the given index. This function follows Python
   * convention, in that if the index is negative, it is considered relative
   * to the list end. Therefore the vertex at index -1 is the last vertex in
   * the list.
   * 
   * @param i
   *            index
   * @return vertex
   */
  public Vec3D get(int i) {
    if (i < 0) {
      i += vertices.size();
    }
    return vertices.get(i);
  }

  /**
   * Computes a list of points along the spline which are uniformly separated
   * by the given step distance.
   * 
   * @param step
   * @return point list
   */
  public List<Vec3D> getDecimatedVertices(float step) {
    return getDecimatedVertices(step, true);
  }

  /**
   * Computes a list of points along the spline which are close to uniformly
   * separated by the given step distance. The uniform distribution is only an
   * approximation and is based on the estimated arc length of the polyline.
   * The distance between returned points might vary in places, especially if
   * there're sharp angles between line segments.
   * 
   * @param step
   * @param doAddFinalVertex
   *            true, if the last vertex computed should be added regardless
   *            of its distance.
   * @return point list
   */
  public List<Vec3D> getDecimatedVertices(float step, boolean doAddFinalVertex) {
    ArrayList<Vec3D> uniform = new ArrayList<Vec3D>();
    if (vertices.size() < 3) {
      if (vertices.size() == 2) {
        new Line3D(vertices.get(0), vertices.get(1)).splitIntoSegments(
        uniform, step, true);
        if (!doAddFinalVertex) {
          uniform.remove(uniform.size() - 1);
        }
      } 
      else {
        return null;
      }
    }
    float arcLen = getEstimatedArcLength();
    double delta = (double) step / arcLen;
    int currIdx = 0;
    for (double t = 0; t < 1.0; t += delta) {
      double currT = t * arcLen;
      while (currT >= arcLenIndex[currIdx]) {
        currIdx++;
      }
      ReadonlyVec3D p = vertices.get(currIdx - 1);
      ReadonlyVec3D q = vertices.get(currIdx);
      float frac = (float) ((currT - arcLenIndex[currIdx - 1]) / (arcLenIndex[currIdx] - arcLenIndex[currIdx - 1]));
      Vec3D i = p.interpolateTo(q, frac);
      uniform.add(i);
    }
    if (doAddFinalVertex) {
      uniform.add(vertices.get(vertices.size() - 1).copy());
    }
    return uniform;
  }

  public float getEstimatedArcLength() {
    if (arcLenIndex == null
      || (arcLenIndex != null && arcLenIndex.length != vertices.size())) {
      arcLenIndex = new float[vertices.size()];
    }
    float arcLen = 0;
    for (int i = 1; i < arcLenIndex.length; i++) {
      ReadonlyVec3D p = vertices.get(i - 1);
      ReadonlyVec3D q = vertices.get(i);
      arcLen += p.distanceTo(q);
      arcLenIndex[i] = arcLen;
    }
    return arcLen;
  }

  public List<Line3D> getSegments() {
    final int num = vertices.size();
    List<Line3D> segments = new ArrayList<Line3D>(num - 1);
    for (int i = 1; i < num; i++) {
      segments.add(new Line3D(vertices.get(i - 1), vertices.get(i)));
    }
    return segments;
  }

  /**
   * @return the vertices
   */
  public List<Vec3D> getVertices() {
    return vertices;
  }

  public Iterator<Vec3D> iterator() {
    return vertices.iterator();
  }

  /**
   * @param vertices
   *            the vertices to set
   */
  public void setVertices(List<Vec3D> vertices) {
    this.vertices = vertices;
  }
}


class ParallelTransportFrame extends LineStrip3D implements IFrameCurve {

  protected List<Vec3D> tangents = new ArrayList<Vec3D>();
  protected List<Vec3D> binormals = new ArrayList<Vec3D>();
  protected List<Vec3D> normals = new ArrayList<Vec3D>();

  private int curve_length;

  //-------------------------------------------------------- ctor

  public ParallelTransportFrame(Collection<? extends Vec3D> vertices) {
    super(vertices);
    this.curve_length = vertices.size();
    for (int i=0; i<=curve_length; i++) {
      tangents.add(new Vec3D());
      binormals.add(new Vec3D());
      normals.add(new Vec3D());
    }    
    if (curve_length<3) {
      System.out.println("ERROR: ");
      System.out.println("\t ParallelTransportFrame.java");
      System.out.println("\t Curve must have at least 4 points");
      this.curve_length = 0;
      return;
    }
    if (this.vertices.get(0) == this.vertices.get(1) ||
      this.vertices.get(1) == this.vertices.get(2) ||
      this.vertices.get(0) == this.vertices.get(2)) {
      System.out.println("ERROR: ");
      System.out.println("\t ParallelTransportFrame.java");
      System.out.println("\t Curve must have at least 4 non-equal points");
      this.curve_length = 0;
      return;
    }
    getFirstFrame();
    getTangents();
    parallelTransportFrameApproach();
  }

  //-------------------------------------------------------- algorithm

  void getFirstFrame() {
    // first frame, needed by parallel transport frame approach
    // frenet method is used. 
    // more specific method (in case of complex target-oriented base animation) could be used    
    Vec3D p0, p1, p2, b;    
    // 1° derivate in p0-p1
    p0 = vertices.get(0);
    p1 = vertices.get(1);
    tangents.set(0, getTangentBetweenTwoPoint(p0, p1));    
    // 1° derivate in p1-p2
    p1 = vertices.get(1);
    p2 = vertices.get(2);
    tangents.set(1, getTangentBetweenTwoPoint(p1, p2));    
    // 2° derivate in t0 and t1
    b = tangents.get(0).cross(tangents.get(1));
    b.normalize();
    binormals.set(0, b);    
    normals.set(0, b.cross(tangents.get(0)));
  }

  public List<Vec3D> getTangents() {
    Vec3D p0, p1;
    for (int i=1; i<curve_length-1; i++) {
      p0 = vertices.get(i);
      p1 = vertices.get(i+1);
      tangents.set(i, getTangentBetweenTwoPoint(p0, p1));
    }
    return tangents;
  }

  void parallelTransportFrameApproach() {
    // p.t.f approach from article: Hanson and Ma, 1995
    Vec3D old_normal, p0, p1, b;
    float theta;
    for (int i=1; i<curve_length+1; i++) {
      p0 = tangents.get(i-1);
      p1 = tangents.get(i);

      if (p0==p1) {
        normals.set(i, normals.get(i-1));
        binormals.set(i, binormals.get(i-1));
        continue;
      }

      // this is what is called A in game programming gems
      // and B in Hanson and Ma article
      b = p0.cross(p1);
      b.normalize();

      if (b.magnitude()==0) {
        normals.set(i, normals.get(i-1));
        binormals.set(i, binormals.get(i-1));
        continue;
      }

      // normals
      theta = PApplet.acos(p0.dot(p1));
      old_normal = normals.get(i-1).copy();
      old_normal.normalize();
      old_normal.rotateAroundAxis(b, theta);
      old_normal.scale(normals.get(i-1));
      normals.set(i, old_normal);
      binormals.set(i, tangents.get(i).cross(old_normal));
    }
  }

  Vec3D getTangentBetweenTwoPoint(Vec3D p1, Vec3D p2) {
    Vec3D r = p1.sub(p2);
    r.normalize();
    return r;
  }

  public Vec3D getBinormal(int i) {
    return binormals.get(i);
  }

  public Vec3D getNormal(int i) {
    return normals.get(i);
  }

  public Vec3D getTangent(int i) {
    return tangents.get(i);
  }

  public List<Vec3D> getBinormals() {
    return binormals;
  }

  public List<Vec3D> getNormals() {
    return normals;
  }

  public int getCurveLength() {
    return curve_length;
  }
}

class ParallelTube extends TriangleMesh {
  private ParallelTransportFrame soul;
  private int curveLength;
  private int radius = 10;
  private int diameterQuality = 20;
  private float[] cachedRadius = null;
  private boolean usedCachedRadius = false;

  private List< List<Vec3D> > circles = new ArrayList<List<Vec3D>>();
  private int num_faces;

  //-------------------------------------------------------- ctor

  public ParallelTube(ParallelTransportFrame soul, int radius, int diameter_quality) {
    //  System.out.println("Tube > constructor: " + radius);
    this.soul = soul;
    this.curveLength = soul.getCurveLength();
    this.setRadius(radius);
    this.diameterQuality = diameter_quality;
    if (soul.getCurveLength()==0) return;
    compute();
  }

  //-------------------------------------------------------- vertex computation

  public void compute() {
    num_faces = 0;
    List<Vec3D> circle1, circle2;
    float radius;
    radius = (isUsedCachedRadius() ? cachedRadius[0]: getRadius());
    circle1 = getCircle(0, radius);
    for (int i=1; i<curveLength-1; i++) {
      if (debug) {
        println(i+"/"+curveLength);
      }
      radius = (isUsedCachedRadius() ? cachedRadius[i]: getRadius());
      circle2 = getCircle(i, radius);
      addCircles(circle1, circle2);
      circle1 = circle2;
    }
  }

  List<Vec3D> getCircle(int i, float _radius) {
    int k = diameterQuality;
    List<Vec3D> vert;
    float theta = 0;
    float dt = MathUtils.TWO_PI/(k);

    if (i<this.circles.size()) {
      // circle exists, does not create a new one, just modify it
      vert = circles.get(i);
    } 
    else {
      // new length, we have to allocate new objects
      vert = new ArrayList<Vec3D>(k+1);
      for (int j=0; j<=k; j++) 
        vert.add(new Vec3D());
    }

    for (int j=0; j<=k; j++) {
      float c = MathUtils.cos(theta) * _radius;
      float s = MathUtils.sin(theta) * _radius;

      Vec3D p = vert.get(j);
      p.x = soul.vertices.get(i).x + c*soul.getBinormal(i).x + s*soul.getNormal(i).x;
      p.y = soul.vertices.get(i).y + c*soul.getBinormal(i).y + s*soul.getNormal(i).y;
      p.z = soul.vertices.get(i).z + c*soul.getBinormal(i).z + s*soul.getNormal(i).z;

      theta += dt;
    }  
    // cache the result back
    circles.add(vert);

    return vert;
  }

  void addCircles(List<Vec3D> circle1, List<Vec3D> circle2) {
    Vec3D  p1, p2, p3, p4, p5, p6;
    Face f1, f2;
    boolean must_add = false;

    for (int j=0; j<circle1.size()-1; j++) {
      try { // vertices exists, does not create new ones, just modify them
        f1 = this.faces.get(num_faces++);
        p1 = f1.a; 
        p2 = f1.b; 
        p3 = f1.c;

        f2 = this.faces.get(num_faces++);
        p4 = f2.a; 
        p5 = f2.b; 
        p6 = f2.c;
      } 
      catch (IndexOutOfBoundsException e) { // new length, we have to allocate new objects
        //System.out.println("addCircles > new");
        p1 = new Vec3D(); 
        p2 = new Vec3D(); 
        p3 = new Vec3D();
        p4 = new Vec3D(); 
        p5 = new Vec3D(); 
        p6 = new Vec3D();

        must_add = true;
      }

      p1.set(circle1.get(j).x, circle1.get(j).y, circle1.get(j).z);       
      p2.set(circle2.get(j).x, circle2.get(j).y, circle2.get(j).z);
      p3.set(circle2.get(j+1).x, circle2.get(j+1).y, circle2.get(j+1).z);      

      p4.set(circle2.get(j+1).x, circle2.get(j+1).y, circle2.get(j+1).z); 
      p5.set(circle1.get(j).x, circle1.get(j).y, circle1.get(j).z);       
      p6.set(circle1.get(j+1).x, circle1.get(j+1).y, circle1.get(j+1).z);

      if (must_add) {
        this.addFace(p1, p2, p3);
        this.addFace(p4, p5, p6);
      }
    }
  }

  public void setCachedRadius(float[] c) {
    this.cachedRadius = c;
    if (c!=null) setUsedCachedRadius(true);
    else setUsedCachedRadius(false);
  }

  public void setUsedCachedRadius(boolean usedCachedRadius) {
    this.usedCachedRadius = usedCachedRadius;
  }

  public boolean isUsedCachedRadius() {
    return usedCachedRadius;
  }

  public void setRadius(int radius) {
    this.radius = radius;
  }

  public int getRadius() {
    return radius;
  }

  public int getDiameterQuality() {
    return diameterQuality;
  }

  public void setDiameterQuality(int diameterQuality) {
    this.diameterQuality = diameterQuality;
  }

  public int getCurveLength() {
    return curveLength;
  }

  public void setCurveLength(int curveLength) {
    this.curveLength = curveLength;
  }

  public List<List<Vec3D>> getCircles() {
    return circles;
  }
}

interface IFrameCurve {
  Vec3D getTangent(int i);
  Vec3D getNormal(int i);
  Vec3D getBinormal(int i);
}

// geometry related functions
int pRotX;
int pRotY;
int pRotZ;

int pLocX;
int pLocY;
int pLocZ;

int worldX = 1200;
int worldY = 1200;
int worldZ = 700;
int gridSize = 50;

float tightness = .25;
int segmentRes = 8;
int curveRes = 8;
int cylinderRes = 8;
int sphereRes = 8;

int faceNum = 0;
int vertexNum = 0;
long lastOp;

AABB worldBox;
Vec3D mapDim = new Vec3D(worldX, worldY, worldZ);
AABB[] worldLimits = new AABB[6];
Vec3D[] normalList = new Vec3D[6];

boolean doRebuild = false;

ArrayList <Furniture> furnitureList;
ArrayList <Material> materialList;

class Material {
  HE_Mesh heMesh = null; // = new HE_Mesh();    // he_mesh 
  TriangleMesh toxicMesh = null; // = new TriangleMesh();    // toxic
  PShape shapeMesh;// = new PShape();
  PShape retained;// = createShape(TRIANGLES);
  String name;
  int fillColor;
  int alphaColor;
  boolean softMaterial;

  void updateMaterial() {
    shapeMesh = new PShape();
    if (toxicMesh != null || heMesh != null) {
      shapeMesh = meshToRetained(toxicMesh, heMesh, soft&&softMaterial);
    }
  } 

  PShape meshToRetained(Mesh3D toxicMesh, HE_Mesh heMesh, boolean smth) {        
    retained = createShape(TRIANGLES);
      retained.enableStyle();
    if (solid) {
      if (material) {
        retained.fill(fillColor, alphaColor);
      } 
      else {
        retained.fill(solidColor, solidAlpha);
      }
    } 
    else {
      retained.noFill();
    }
    if (wireframe) {
      retained.stroke(wireframeColor, wireframeAlpha);
    } 
    else {
      retained.noStroke();
    }
    retained.ambient(ambientLightColor, ambientLightColor, ambientLightColor);
    if (smth) {
      if (toxicMesh != null) {
        toxicMesh.computeVertexNormals();
        for (Face f : toxicMesh.getFaces()) {
          retained.normal(f.a.normal.x, f.a.normal.y, f.a.normal.z);
          retained.vertex(f.a.x, f.a.y, f.a.z);
          retained.normal(f.b.normal.x, f.b.normal.y, f.b.normal.z);
          retained.vertex(f.b.x, f.b.y, f.b.z);
          retained.normal(f.c.normal.x, f.c.normal.y, f.c.normal.z);
          retained.vertex(f.c.x, f.c.y, f.c.z);
        }
      }
      if (heMesh != null) {
        HE_Mesh triMesh = heMesh.get();
        triMesh.triangulate();
        HE_Face thisFace;
        for (Iterator<HE_Face> faceItr = triMesh.fItr(); faceItr.hasNext();) {
          thisFace = faceItr.next();
          HE_Halfedge he = thisFace.getHalfedge();
          HE_Vertex vx;
          do {
            vx = he.getVertex();
            WB_Normal3d vn = vx.getVertexNormal();
            retained.normal(vn.xf(), vn.yf(), vn.zf());
            retained.vertex(vx.xf(), vx.yf(), vx.zf());
            he = he.getNextInFace();
          } 
          while (he != thisFace.getHalfedge ());
        }
      }
    } 
    else {
      if (toxicMesh != null) {
        for (Face f : toxicMesh.getFaces()) {
          retained.normal(f.normal.x, f.normal.y, f.normal.z);
          retained.vertex(f.a.x, f.a.y, f.a.z);
          retained.vertex(f.b.x, f.b.y, f.b.z);
          retained.vertex(f.c.x, f.c.y, f.c.z);
        }
      }
      if (heMesh != null) {
        HE_Mesh triMesh = heMesh.get();
        triMesh.triangulate();
        HE_Face thisFace;
        for (Iterator<HE_Face> faceItr = triMesh.fItr(); faceItr.hasNext();) {
          thisFace = faceItr.next();
          HE_Halfedge he = thisFace.getHalfedge();
          HE_Vertex vx;
          WB_Normal3d vn = thisFace.getFaceNormal();
          retained.normal(vn.xf(), vn.yf(), vn.zf());
          do {
            vx = he.getVertex();
            retained.vertex(vx.xf(), vx.yf(), vx.zf());
            he = he.getNextInFace();
          } 
          while (he != thisFace.getHalfedge ());
        }
      }
    }
    retained.end();
    return retained;
  }
}

void addMesh(HE_Mesh thisMesh, String thisName) {
  for (Material thisMaterial : materialList) {
    if (thisMaterial.name == thisName) {
      if (thisMaterial.heMesh == null) { 
        thisMaterial.heMesh = new HE_Mesh();
      }
      thisMaterial.heMesh.add(thisMesh);
    }
  }
}

void addMesh(TriangleMesh thisMesh, String thisName) {
  for (Material thisMaterial : materialList) {
    if (thisMaterial.name == thisName) {
      if (thisMaterial.toxicMesh == null) {
        thisMaterial.toxicMesh = new TriangleMesh();
      }
      thisMaterial.toxicMesh.addMesh(thisMesh);
    }
  }
}


Material getMaterial(String thisName) {
  for (Material thisMaterial : materialList) {
    if (thisMaterial.name == thisName) {
      return thisMaterial;
    }
  }
  return null;
}

void updateMaterials() {
  for (Material thisMaterial : materialList) {
    thisMaterial.updateMaterial();
  }
}

void initMaterials() {
  materialList = new ArrayList();
  addMaterial("model", 200, 255, false);
  addMaterial("metal", 255, 255, true);
  addMaterial("leather", 50, 255, false);
  addMaterial("geometry", 200, 255, false);
  addMaterial("wood", 150, 255, false);
  addMaterial("white", 255, 255, false);
  addMaterial("grey", 150, 255, false);
  addMaterial("black", 50, 255, false);
  addMaterial("red", color(200, 0, 0), 255, false);
  addMaterial("blue", color(0, 0, 200), 255, false);
  addMaterial("green", 200, 255, false);
  addMaterial("yellow", color(240, 240, 0), 255, false);
  addMaterial("glass", 255, 100, true);
}

void addMaterial(String thisName, int thisColor, int thisAlpha, boolean thisSoft) {
  Material newMaterial = new Material();
  newMaterial.name = thisName;
  newMaterial.fillColor = thisColor;
  newMaterial.alphaColor = thisAlpha;
  newMaterial.softMaterial = thisSoft;
  materialList.add(newMaterial);
}

void initGeometry() {
  prepareNormalList();
  initMaterials();
  updateWorld();
  furnitureList = new ArrayList<Furniture>();   

  Furniture radiolaria = new Radiolaria();
  radiolaria.name ="radiolaria";
  furnitureList.add(radiolaria);

//  Furniture jewel = new Jewel();
//  jewel.name ="jewel";
//  furnitureList.add(jewel);
//
  Furniture breuer = new Breuer();
  breuer.name ="breuer";
  furnitureList.add(breuer);
//
//  Furniture rietveld = new Rietveld();
//  rietveld.name ="rietveld";
//  furnitureList.add(rietveld);
//
//  Furniture lack = new Lack();
//  lack.name ="lack";
//  furnitureList.add(lack);
////
////  Furniture thonet = new Thonet();
////  thonet.name ="thonet";
////  furnitureList.add(thonet);
////
//  Furniture vase = new Vase();
//  vase.name ="vase";
//  furnitureList.add(vase);
//
//  Furniture castiglioni = new Castiglioni();
//  castiglioni.name ="castiglioni";
//  furnitureList.add(castiglioni);

  updateWorld();
  generateGeometry();
  updateGeometry();
  buildGeometry();
}

void changeCollection () {
  furniture ++ ;
  if (furniture == furnitureList.size()) furniture = 0;
  updateWorld();
  if (!furnitureList.get(furniture).generated) {
    generateGeometry();
  }
  updateGeometry();
  //  buildGeometry();
}

void resetGeometry() {
  furnitureList.get(furniture).reset();
  generateGeometry();
  updateGeometry();
  //buildGeometry();
}

void randomGeometry() {
  furnitureList.get(furniture).randomize();
  generateGeometry();
  updateGeometry();
  // buildGeometry();
}

void generateGeometry() {
  //gridSize = furnitureList.get(furniture).gridSize;
  long startTime = millis();
  furnitureList.get(furniture).generate();
  lastOp = millis() - startTime;
}

boolean isGeometryValidated() {
  if (furnitureList.get(furniture).validated) {
    return true;
  }
  return false;
}

void updateGeometry() {
  furnitureList.get(furniture).update();
  doRebuild = true;
}

void buildGeometry() {
  if (solid || wireframe) {
    for (Material thisMaterial : materialList) {
      thisMaterial.toxicMesh = null; //.clear();
      thisMaterial.heMesh = null; //clear();
    }
    furnitureList.get(furniture).build();
    doRebuild = false;
    faceNum = 0;
    vertexNum = 0;
    for (Material thisMaterial : materialList) {
      if (thisMaterial.toxicMesh != null) {
        faceNum += thisMaterial.toxicMesh.getNumFaces();
        vertexNum += thisMaterial.toxicMesh.getNumVertices();
      }
    }
    updateMaterials();
  } 
  else {
    doRebuild = true;
  }
}

void displayGeometry() {
  if (ground) {
    pushMatrix();
    translate(0, 0, -.1);
    if (furnitureList.get(furniture).name.equals("breuer")) {   
      translate(0, 0, -bTubeR);
    }
    noStroke();
    fill(groundColor);
    rect(-mapDim.x/2, -mapDim.y/2, mapDim.x, mapDim.y);
    popMatrix();
  }
  if (grid) {
    pushMatrix();
    if (furnitureList.get(furniture).name.equals("breuer")) {   
      translate(0, 0, -bTubeR);
    }
    drawGrid();
    popMatrix();
  }
  if (axis) {
    strokeWeight(thinStroke);
    fx.origin(100);
  }
  if (limits) {
    drawLimits();
  }

  if (light) {
    ambientLight(ambientLightColor, ambientLightColor, ambientLightColor);
    directionalLight(directionalLightColor, directionalLightColor, directionalLightColor, 0, -.4, -.4); 
    directionalLight(200, 200, 200, 0, .3, -.3);
  } 
  else {
    noLights();
  }

  if (!furnitureList.get(furniture).generated) {
    furnitureList.get(furniture).generate();
    doRebuild = true;
  }

  if (dots || structure || filled || details || original) {
    furnitureList.get(furniture).display();
  }

  if (wireframe || solid) {
    if (doRebuild) {
      buildGeometry();
    }
    for (Material thisMaterial : materialList) {
      shape(thisMaterial.shapeMesh);
    }
  }
} 

void updateWorld() {
  worldBox = new AABB(new Vec3D(0, 0, mapDim.z/2), mapDim.scale(.5));
  worldLimits[0] = new AABB(new Vec3D(0, 0, -gridSize/2), new Vec3D(mapDim.x/2, mapDim.y/2, gridSize/2));
  worldLimits[1] = new AABB(new Vec3D(0, 0, mapDim.z+gridSize/2), new Vec3D(mapDim.x/2, mapDim.y/2, gridSize/2));
  worldLimits[2] = new AABB(new Vec3D(mapDim.x/2+gridSize/2, 0, mapDim.z/2), new Vec3D(gridSize/2, mapDim.y/2, mapDim.z/2));
  worldLimits[3] = new AABB(new Vec3D(-mapDim.x/2-gridSize/2, 0, mapDim.z/2), new Vec3D(gridSize/2, mapDim.y/2, mapDim.z/2));
  worldLimits[4] = new AABB(new Vec3D(0, mapDim.y/2+gridSize/2, mapDim.z/2), new Vec3D(mapDim.x/2, gridSize/2, mapDim.z/2));
  worldLimits[5] = new AABB(new Vec3D(0, -mapDim.y/2-gridSize/2, mapDim.z/2), new Vec3D(mapDim.x/2, gridSize/2, mapDim.z/2));
}

void saveSTL() {
  printConsole("saved model at "+nf(hour(), 2)+":"+nf(minute(), 2)+":"+nf(second(), 2)+";");
  for (Material thisMaterial : materialList) {
    TriangleMesh thisMesh = thisMaterial.toxicMesh;
    if (thisMesh.getNumFaces() > 0) {
      thisMesh.computeFaceNormals();
      thisMesh.saveAsSTL(sketchPath("")+"/models/"+getTimeStamp()+"_"+furnitureList.get(furniture).name+"_"+thisMaterial.name+".stl");
    }
  }
}

class Furniture {
  List <Part> partList = new ArrayList<Part>();  
  Vec3D loc = Vec3D.ZERO.copy();
  Vec3D rot = Vec3D.ZERO.copy();
  String name;

  boolean generated = false;
  boolean validated = false;

  void reset() {
  }

  void randomize() {
  }

  void generate() {
  }

  void update() {
    for (Part thisPart : partList) {
      thisPart.update();
    }
  }

  void display() {
    for (Part thisPart : partList) {
      thisPart.display();
    }
  }

  void build() {
    for (Part thisPart : partList) {
      thisPart.build();
    }
  }

  void setLocation (ReadonlyVec3D loc) {
    this.loc = loc.copy();  // not yet implementedx1
  }

  void setRotation(ReadonlyVec3D rot) {
    this.rot = rot.copy();  // not yet implemented
  }
}

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

  cp5 = new ControlP5(this);
  guiFont = new ControlFont(lightFont);
  cp5.setFont(guiFont);
  cp5.setColorForeground(color(activeColor));
  cp5.setColorBackground(color(controllerColor));
  cp5.setColorLabel(color(fontColor));
  cp5.setColorValue(color(fontColor));
  cp5.setColorActive(color(activeColor));
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
  //  createSlider(gWorld, "backgroundColor", backgroundColor, 0, 255, true, "background");
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

void createSlider(Group thisGroup, String thisVariable, float val, float minVal, float maxVal, boolean autoUpdate, String label) {
  Slider s = cp5.addSlider(thisVariable, minVal, maxVal, val, cx, cy, guix, guiy).setAutoUpdate(autoUpdate).
   setGroup(thisGroup);
  s.setLabel(label); // .setDecimalPrecision(1)     .setSliderMode(Slider.FIX)  // .showTickMarks(true).setNumberOfTickMarks(11).setColorTickMark(activeColor).snapToTickMarks(false)
  controlP5.Label l = s.captionLabel();
  l.toUpperCase(false);
  l.style().marginLeft = 2;
  cy+= sh;
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

int jPointNum = 20;
int jRadius = 500;
int jHeight = 500;

int jStructureType = 0;

int jResX = 16;
int jResY = 16;

HE_Mesh myShape;

float jPlateThickness = 0;

int jSubdivide;
int jSubdivideValue;

int jSubdivideRandom;
int jSubdivideRandomValue;

int jSubdivideMidEdge;
int jSubdivideMidEdgeValue;


int jChamfer = 0;
int jChamferDistance = 0;

int jCatmullClark = 0;
int jCatmullClarkValue;

int jLattice = 50;
int jLatticeDepth = 10;
int jLatticeWidth = 10;
int jLatticeAngle = 90;

int jSmooth = 100;
int jSmoothValue;

class Jewel extends Furniture {
  Jewel () {
    reset();
    randomize();
    cx = 0;
    cy = 0;
    Group gJewel = cp5.addGroup("jewel").setPosition(columnx, marginy).hideBar();

    createSlider(gJewel, "jStructureType", jStructureType, 0, 7, true, "polygon type");
    createSlider(gJewel, "jRadius", jRadius, 100, 2000, true, "radius");
    createSlider(gJewel, "jHeight", jHeight, 100, 2000, true, "height");
    createSlider(gJewel, "jResX", jResX, 1, 64, true, "resolution x");
    createSlider(gJewel, "jResY", jResY, 1, 64, true, "resolution y");
    cy += sh/2;
    createSlider(gJewel, "jSubdivide", jSubdivide, 0, 100, true, "subdivide");
    createSlider(gJewel, "jSubdivideValue", jSubdivideValue, 0, 10, true, "subdivide value");
    cy += sh/2;
    createSlider(gJewel, "jSubdivideRandom", jSubdivideRandom, 0, 100, true, "subdivde random");
    createSlider(gJewel, "jSubdivideRandomValue", jSubdivideRandomValue, 0, 10, true, "subdivide random value");
    cy += sh/2;
    createSlider(gJewel, "jSubdivideMidEdge", jSubdivideMidEdge, 0, 100, true, "subdivide edge");
    createSlider(gJewel, "jSubdivideMidEdgeValue", jSubdivideMidEdgeValue, 0, 10, true, "subdivide edge value");
    cy += sh/2;
    createSlider(gJewel, "jChamfer", jChamfer, 0, 100, true, "chamfer");
    createSlider(gJewel, "jChamferDistance", jChamferDistance, 0, 1000, true, "chamfer distance");
    cy += sh/2;
    createSlider(gJewel, "jLattice", jLattice, 0, 100, true, "lattice");
    createSlider(gJewel, "jLatticeDepth", jLatticeDepth, 0, 200, true, "lattice depth");
    createSlider(gJewel, "jLatticeWidth", jLatticeWidth, 0, 200, true, "lattice width");
    createSlider(gJewel, "jLatticeAngle", jLatticeAngle, 0, 90, true, "lattice angle");
    cy += sh/2;
    createSlider(gJewel, "jSmooth", jSmooth, 0, 100, true, "smooth");
    createSlider(gJewel, "jSmoothValue", jSmoothValue, 0, 3, true, "smooth value");

    cy += sh/2;

    createSlider(gJewel, "jCatmullClark", jCatmullClark, 0, 100, true, "catmull clark");
    createSlider(gJewel, "jCatmullClarkValue", jCatmullClarkValue, 0, 3, true, "catmull clark value");

    //    createToggle(gTable, "taCrossRails", taCrossRails, "cross rails");
    //    updateControllerList.add("taTubeR");

    //    generateControllerList.add("jRadius");
    //    generateControllerList.add("jPlateThickness");
    //
    //    generateControllerList.add("jChamfer");
    //    generateControllerList.add("jChamferDistance");
    //
    //    generateControllerList.add("jLattice");
    //    generateControllerList.add("jLatticeDepth");
    //    generateControllerList.add("jLatticeWidth");
    //    generateControllerList.add("jLatticeAngle");
    //
    //    generateControllerList.add("jSmooth");
    //    generateControllerList.add("jSmoothValue");
    //    generateControllerList.add("jCatmullClark");
    //    generateControllerList.add("jCatmullClarkValue");
  }

  void reset() {
  }

  void generate() {
    partList = new ArrayList<Part>();
    switch(jStructureType) {
    case 0:
      myShape=new HE_Mesh(new HEC_Box().setHeight(jRadius).setWidth(jRadius).setDepth(jRadius));
      break;
    case 1:
      myShape=new HE_Mesh(new HEC_Tetrahedron().setEdge(jRadius));
      break;
    case 2:
      myShape=new HE_Mesh(new HEC_Octahedron().setEdge(jRadius));
      break;
    case 3:
      myShape=new HE_Mesh(new HEC_Icosahedron().setEdge(jRadius));
      break;
    case 4:
      myShape=new HE_Mesh(new HEC_Dodecahedron().setEdge(jRadius));
      break;
    case 5: 
      myShape = new HE_Mesh(new HEC_Sphere().setRadius(jRadius).setUFacets(int(jResX)).setVFacets(int(jResY))); 
      break;
    case 6: 
      myShape = new HE_Mesh(new HEC_Cylinder().setRadius(jRadius).setHeight(jHeight).setFacets(int(jResX)).setSteps(int(jResY))); 
      break;
    case 7: 
      myShape = new HE_Mesh(new HEC_Cone().setRadius(jRadius).setHeight(jHeight).setFacets(int(jResX)).setSteps(int(jResY))); 
      break;
    }

    //  HE_Face[] faceList =  ((HE_MeshStructure)structureMesh).getFacesAsArray();

    if (jSubdivide > 0) {
      HE_Selection selection = makeSelection(jSubdivide);
      myShape.subdivideSelected(new HES_Planar().setRandom(false), selection, int(jSubdivideValue));
    }

    if (jSubdivideRandom > 0) {
      HE_Selection selection = makeSelection(jSubdivideRandom);
      myShape.subdivideSelected(new HES_Planar().setRandom(true), selection, int(jSubdivideRandomValue));
    }

    if (jSubdivideMidEdge > 0) {
      HE_Selection selection = makeSelection(jSubdivideMidEdge);
      myShape.subdivideSelected(new HES_PlanarMidEdge(), selection, int(jSubdivideMidEdgeValue));
    }

    if (jChamfer > 0 && jChamferDistance>0) {
      // jChamferDistance = constrain(jChamferDistance, 0, jRadius/2);   ////////
      HE_Selection selection = makeSelection(jChamfer);
      HEM_ChamferCorners chamferModifier = new HEM_ChamferCorners().setDistance(jChamferDistance);
      myShape.modifySelected(chamferModifier, selection);
    }

    if (jLattice > 0 && jLatticeWidth>0 && jLatticeDepth>0) {
      HE_Selection selection = makeSelection(jLattice);
      HEM_Lattice latticeModifier =new HEM_Lattice().setDepth(jLatticeDepth).setWidth(jLatticeWidth).setThresholdAngle(radians(jLatticeAngle)).setFuse(true);
      myShape.modifySelected(latticeModifier, selection);
    }

    if (jCatmullClark > 0 && jCatmullClarkValue > 0) {
      HE_Selection selection = makeSelection(jCatmullClark);
      myShape.subdivideSelected(new HES_CatmullClark(), selection, int(jCatmullClarkValue));
    }

    if (jSmooth>0 && jSmoothValue>0) {
      float value2 = .5;
      float value3 = .5;
      HE_Selection selection = makeSelection(jSmooth);
      myShape.subdivideSelected(new HES_Smooth().setWeight(value2, value3), selection, int(jSmoothValue));
    }

    HeMesh heMesh = new HeMesh();
    heMesh.setMaterial("metal");
    heMesh.setMesh(myShape);
    // heMesh.setScale(1);
    // mesh.update();
    partList.add(heMesh);

    generated = true;
    validated = true;
  }

  HE_Selection makeSelection(int freq) {
    HE_Selection selection = new HE_Selection(myShape);
    Iterator <HE_Face> fItr = myShape.fItr();
    HE_Face f;
    //  randomSeed(int(value4));
    while (fItr.hasNext ()) { 
      f = fItr.next(); 
      if (random(100) < freq) { 
        selection.add(f);
      }
    }
    return selection;
  }


  void randomize() {
  }
}

////////////////////////////////////////////////////////////////////////////
//
// generates a parametric lack chair with painted wooden blocks  
//
////////////////////////////////////////////////////////////////////////////

int lTableNum;
boolean lWithinWorld, lPerpendicularToLast, lCollisionWithAll, lForceToGround, lForceLegsToGround, lForcePlanesHorizontal;
boolean lForceX, lForceY, lForceZ, lConnectToAny, lConnectToLast;
boolean lForceCorner, lForceNextCorner, lForceCornerPerpendicular;

boolean lForceLegsEveryTwo;

String[] lMaterialList = {
  "black", "white", "red", "grey"
};

class Lack extends Furniture {
  Vec3D[] lDimensionList = {   // longest direction should be on x
    new Vec3D(50, 50, 400), 
    new Vec3D(550, 550, 50)
    };
    SuperBlock lastBlock;
  ArrayList<SuperBlock> blockList; 

  int maxAttempts = 1000;

  Lack () {
    reset();
    gridSize = 50;  // gridSize is different for every collection !!!
    cx = 0;
    cy = 0;
    Group gLack = cp5.addGroup("lack").setPosition(columnx, marginy).hideBar();
    createSlider(gLack, "lTableNum", lTableNum, 0, 25, true, "number of tables");
    cy += sh/2;
    createToggle(gLack, "lWithinWorld", lWithinWorld, "world limits");
    createToggle(gLack, "lPerpendicularToLast", lPerpendicularToLast, "perpendicular");
    createToggle(gLack, "lCollisionWithAll", lCollisionWithAll, "collision");
    createToggle(gLack, "lForceToGround", lForceToGround, "on ground");
    createToggle(gLack, "lForceLegsToGround", lForceLegsToGround, "legs on ground");
    createToggle(gLack, "lForceLegsEveryTwo", lForceLegsEveryTwo, "one leg every two pieces");
    createToggle(gLack, "lForcePlanesHorizontal", lForcePlanesHorizontal, "planes horizontal");

    createToggle(gLack, "lForceY", lForceY, "align to Y");
    createToggle(gLack, "lForceX", lForceX, "align to X");
    createToggle(gLack, "lForceZ", lForceZ, "align to Z");
    createToggle(gLack, "lConnectToAny", lConnectToAny, "connect");
    createToggle(gLack, "lConnectToLast", lConnectToLast, "chain");
    createToggle(gLack, "lForceCorner", lForceCorner, "corner");
    createToggle(gLack, "lForceNextCorner", lForceNextCorner, "next to corner");
    createToggle(gLack, "lForceCornerPerpendicular", lForceCornerPerpendicular, "corner perpendicular");

    cy += sh/2;
  }

  void reset() {
    lWithinWorld = true;
    lPerpendicularToLast = false;
    lCollisionWithAll = false;
    lForceToGround = false;
    lForceLegsToGround = false;
    lForceX = false;
    lForceY = false;
    lForceZ = false;
    lConnectToAny = false;
    lConnectToLast = false;
    lForceCorner = false;
    lForceNextCorner = false;
    lTableNum = 1;//rTypeList.length-2;
  }

  void generate() {
    gridSize = 50;
    lastBlock = null;
    partList = new ArrayList<Part>();   // clear parts
    blockList = new ArrayList<SuperBlock>();

    String tableMaterial = lMaterialList[(int)random(lMaterialList.length)];

    if (original) {
      SuperBlock thisBlock = new SuperBlock();
      thisBlock.setDimension(lDimensionList[0]);
      thisBlock.setLocation(new Vec3D(225+gridSize/2, 225+gridSize/2, thisBlock.dim.z/2));
      thisBlock.calculatePoints(true, false, false);
      thisBlock.setMaterial(tableMaterial);
      blockList.add(thisBlock);
      partList.add(thisBlock);
      thisBlock = new SuperBlock();
      thisBlock.setDimension(lDimensionList[0]);
      thisBlock.setLocation(new Vec3D(225+gridSize/2, -225-gridSize/2, thisBlock.dim.z/2));
      thisBlock.calculatePoints(true, false, false);
      thisBlock.setMaterial(tableMaterial);
      blockList.add(thisBlock);
      partList.add(thisBlock);
      thisBlock = new SuperBlock();
      thisBlock.setDimension(lDimensionList[0]);
      thisBlock.setLocation(new Vec3D(-225-gridSize/2, 225+gridSize/2, thisBlock.dim.z/2));
      thisBlock.calculatePoints(true, false, false);
      thisBlock.setMaterial(tableMaterial);
      blockList.add(thisBlock);
      partList.add(thisBlock);
      thisBlock = new SuperBlock();
      thisBlock.setDimension(lDimensionList[0]);
      thisBlock.setLocation(new Vec3D(-225-gridSize/2, -225-gridSize/2, thisBlock.dim.z/2));
      thisBlock.calculatePoints(true, false, false);
      thisBlock.setMaterial(tableMaterial);
      blockList.add(thisBlock);
      partList.add(thisBlock);
      thisBlock = new SuperBlock();
      thisBlock.setDimension(lDimensionList[1]);
      thisBlock.setLocation(new Vec3D(0, 0, 400+gridSize/2));
      thisBlock.setMaterial(tableMaterial);
      thisBlock.calculatePoints(false, false, true);
      blockList.add(thisBlock);
      partList.add(thisBlock);
    }

    String thisMaterial = lMaterialList[(int)random(lMaterialList.length)];
    for (int i=0;i< lTableNum*5; i++) {
      int  blockType = (i%5 == 4 ? 1 : 0);
      addBlock(blockType, thisMaterial, lWithinWorld, lPerpendicularToLast, lCollisionWithAll, lForceToGround, lForceLegsToGround, 
      lForcePlanesHorizontal, lForceLegsEveryTwo, lForceX, lForceY, lForceZ, lConnectToAny, lConnectToLast);   // do not check forceH y forceV true !!!!
      if (i%5 == 4) thisMaterial = lMaterialList[(int)random(lMaterialList.length)];
    }
    if (blockList.size() != lTableNum*5) {
      validated = false;
    } 
    else {
      validated = true;
    }
    generated = true;
  }

  void addBlock(int blockType, String material, boolean withinWorld, boolean perpendicularToLast, boolean collisionWithAll, boolean forceToGround, boolean forceLegsToGround, boolean forcePlanesHorizontal, 
  boolean forceLegsEveryTwo, boolean forceX, boolean forceY, boolean forceZ, boolean connectToAny, boolean connectToLast) {
    SuperBlock thisBlock = new SuperBlock();
    AABB thisBox = thisBlock.myBox;
    int attempts = 0;
    while (attempts < maxAttempts) {
      attempts ++;
      boolean flag = true;
      Vec3D thisLocation = null;

      thisLocation = getRandomWorldLocCenterGrid();
      if (forceToGround ) {
        thisBlock.setLocation(new Vec3D(thisLocation.x, thisLocation.y, thisBlock.dim.z/2));
      }

      Vec3D thisDimension = lDimensionList[blockType].copy();

      if (!(forceLegsEveryTwo && blockList.size()%2==0 && blockType == 0) || 
        !(forcePlanesHorizontal && blockType ==1) ||
        !(forceZ && blockType==0) ||
        !(forceLegsToGround && blockType == 0)  ) {

        thisDimension = shuffleVector(thisDimension);
      }

      if ((forceLegsToGround && blockType == 1) || forceToGround) {
        thisLocation.z =thisDimension.z/2;
      }

      thisBlock.setDimension(thisDimension);
      thisBlock.setLocation(thisLocation);

      if (flag && forceY) {
        if (!checkLinesParallel(thisBlock.myAxis, new Line3D(Vec3D.ZERO, Vec3D.Y_AXIS))) { 
          flag = false;
        }
      }  
      if (flag && forceZ ) {
        if (!checkLinesParallel(thisBlock.myAxis, new Line3D(Vec3D.ZERO, Vec3D.Z_AXIS))) { 
          flag = false;
        }
      }  
      if (flag && forceX) {
        if (!checkLinesParallel(thisBlock.myAxis, new Line3D(Vec3D.ZERO, Vec3D.X_AXIS))) { 
          flag = false;
        }
      }  

      //      if (flag && forceLegsToGround && blockType == 1 ) {
      //        if (!checkLinesParallel(thisBlock.myAxis, new Line3D(Vec3D.ZERO, Vec3D.Z_AXIS))) {
      //          thisBlock.setLocation(new Vec3D(thisLocation.x, thisLocation.y, thisBlock.dim.z/2));
      //        }
      //      }

      //      if (flag && forceLegsToGround && blockType == 0 ) {
      //        if (checkLinesParallel(thisBlock.myAxis, new Line3D(Vec3D.ZERO, Vec3D.Z_AXIS))) {
      //          thisBlock.setLocation(new Vec3D(thisLocation.x, thisLocation.y, thisBlock.dim.z/2));
      //        }
      //      }

      if (flag && perpendicularToLast && blockType == 0) {  // only check legs
        if (lastBlock != null) {
          if (checkLinesParallel(thisBlock.myAxis, lastBlock.myAxis)) {  // if lines are perpendicular (rotation is different) ...
            flag = false;
          }
        }
      }
      if (flag && (connectToLast || connectToAny)) {
        if (lastBlock != null) {
          thisBlock.calculatePoints(lForceCorner, lForceNextCorner, lForceCornerPerpendicular);
          if (thisBlock.joints.size() > 0) {
            Vec3D thisBlockJoint = thisBlock.joints.get((int)random(thisBlock.joints.size())).add(thisBlock.loc);
            SuperBlock otherBlock = lastBlock;
            if (connectToAny) {
              otherBlock = blockList.get((int)random(partList.size()-1));
              if (perpendicularToLast && checkLinesParallel(thisBlock.myAxis, otherBlock.myAxis)) {    /// should be perpendicular to any boolean
                flag = false;
              }
            }
            Vec3D otherBlockOption = otherBlock.options.get((int)random(otherBlock.options.size())).add(otherBlock.loc);
            Vec3D offset = thisBlockJoint.sub(otherBlockOption);   // this offset should only be horizontal (no z component if forced to ground!!!)
            if ((forceToGround || forceLegsToGround) && offset.z != 0) {
              flag = false;
            } 
            else {
              thisBlock.setLocation(thisBlock.loc.sub(offset));
            }
          }
          else {
            println("error, can not connect, no joints on block");
            flag = false; // there are no joints on the block
          }
        }
      }
      if (flag && withinWorld) {
        if (!checkBoxWithinWorld(thisBox)) {
          flag = false;
        }
      }
      if (flag && collisionWithAll) {
        for (SuperBlock otherBlock : blockList) {
          if (thisBox.intersectsBox(otherBlock.myBox)) {
            flag = false;
            break;
          }
        }
      }
      if (flag) {
        thisBlock.calculatePoints(lForceCorner, lForceNextCorner, lForceCornerPerpendicular);
        thisBlock.material = material;
        partList.add(thisBlock);
        blockList.add(thisBlock);
        lastBlock = thisBlock;
        break;
      }
    }
    if (attempts == maxAttempts) {
      printConsole("!error, could not add block ");
    } 
    else {
      printConsole("!tested "+nf(attempts, 4)+" block locations ");
    }
  }
}

class Part {
  long id;
  Vec3D loc = Vec3D.ZERO.copy();
  Vec3D rot = Vec3D.ZERO.copy();
  String material = "model";

  void setLocation(Vec3D loc) {
    this.loc = loc;
  }

  void setRotation(Vec3D rot) {
    this.rot = rot;
  }

  void setMaterial(String material) {
    this.material = material;
  }

  void build() {
  }

  void display() {
  }

  void update() {
  }
}

class SuperBlock extends Part {
  //float axisLength;
  Vec3D dim;
  AABB myBox;
  Line3D myAxis;

  AABB topCap;   // to paint yellow, faces of the cube on opposite sides of axis !!
  AABB bottomCap;
  float capWidth = .01;

  ArrayList <Vec3D> joints;
  ArrayList <Vec3D> options;
  ArrayList <Line3D> edgeList;

  SuperBlock () {
    id = millis();
    myBox = new AABB(Vec3D.ZERO, Vec3D.ZERO);
    dim = Vec3D.ZERO.copy();
  }

  void display() {
    if (dots) {
      //      stroke(redColor, 255);
      strokeWeight(markerStroke);
      //      drawMarker(loc);
      for (Vec3D thisPoint : joints) {
        stroke(redColor, 255);
        drawMarker(thisPoint.add(loc));
      }
      for (Vec3D thisPoint : options) {
        stroke(blueColor, 150);
        drawMarker(thisPoint.add(loc));
      }
    }
    if (structure) {
      stroke(color(strokeColor, 0, 0), strokeAlpha);
      strokeWeight(thinStroke);

      if (filled) {
        fill(fillColor, fillAlpha);
      } 
      else {
        noFill();
      }
      pushMatrix();
      translate(loc.x, loc.y, loc.z);
      box(dim.x, dim.y, dim.z);
      popMatrix();
    }

    if (details) {
      stroke(greenColor, strokeAlpha);
      strokeWeight(thickStroke);
      for (Line3D thisEdge : edgeList) {
        if ( thisEdge != null) {
          //     fx.line(thisEdge);
        }
      }
      stroke(redColor, strokeAlpha);
      strokeWeight(thinStroke);
      fx.line(myAxis);
    }
  }

  void build() {  
    if (material == "black" && furnitureList.get(furniture).name == "rietveld") {  // bad hack !
      TriangleMesh topCapMesh =(TriangleMesh)topCap.toMesh(); 
      addMesh(topCapMesh, "yellow");
      TriangleMesh bottomCapMesh =(TriangleMesh)bottomCap.toMesh(); 
      addMesh(bottomCapMesh, "yellow");
    }
    TriangleMesh blockMesh=(TriangleMesh)myBox.toMesh(); 
    addMesh(blockMesh, material);
  }

  void setLocation(Vec3D loc) {
    this.loc = loc;
    myBox.set(loc);
    myBox.updateBounds() ; // important, in javadocs says it's called automatically, but .... check !!!
    updateAxis();
  }

  void setDimension(Vec3D dim) {
    this.dim = dim;
    myBox.setExtent(dim.scale(.499)); // it should be .5, down to .4999 so adjacent AABB boxes do not collide !!!
    updateAxis();
  }

  void calculatePoints(boolean forceCorner, boolean forceNextCorner, boolean forceCornerPerpendicular) {
    joints = new ArrayList<Vec3D>();
    options = new ArrayList<Vec3D>();
    for (float thisX=(gridSize/2)-dim.x/2; thisX < dim.x/2; thisX += gridSize) {
      for (float thisY=(gridSize/2)-dim.y/2; thisY < dim.y/2; thisY += gridSize) {
        for (float thisZ=(gridSize/2)-dim.z/2; thisZ < dim.z/2; thisZ += gridSize) {
          Vec3D joint = new Vec3D (thisX, thisY, thisZ);
          if (!forceCorner && !forceNextCorner) {
            joints.add(joint);
          }
          if (forceCorner &&   // keep only points on the corner
          (thisX == -dim.x/2+gridSize/2 || thisX == dim.x/2-gridSize/2)  && 
            (thisY == -dim.y/2+gridSize/2 || thisY == dim.y/2-gridSize/2)  && 
            (thisZ == -dim.z/2+gridSize/2 || thisZ == dim.z/2-gridSize/2)) {
            joints.add(joint);
          }
          if (forceNextCorner && (  // keep only points next to corner
          (thisX == (-dim.x/2+gridSize/2)+gridSize || thisX == (dim.x/2-gridSize/2)-gridSize)  || 
            (thisY == (-dim.y/2+gridSize/2)+gridSize || thisY == (dim.y/2-gridSize/2)-gridSize)  || 
            (thisZ == (-dim.z/2+gridSize/2)+gridSize || thisZ == (dim.z/2-gridSize/2)-gridSize))) {
            joints.add(joint);
          }
          if (forceCornerPerpendicular &&   // keep only points perpendicular to corner
          (thisX == -dim.x/2+gridSize/2 || thisX == dim.x/2-gridSize/2)  && 
            (thisY == -dim.y/2+gridSize/2 || thisY == dim.y/2-gridSize/2)  && 
            (thisZ == -dim.z/2+gridSize/2 || thisZ == dim.z/2-gridSize/2)) {
            joints.add(joint);
          }
        }
      }
    }
    for (Vec3D thisJoint : joints) {
      for (int i=0;i<6;i++) {
        Vec3D thisNormal = normalList[i];
        float ox = thisJoint.x + (gridSize*thisNormal.x);
        float oy = thisJoint.y + (gridSize*thisNormal.y);
        float oz = thisJoint.z + (gridSize*thisNormal.z);
        Vec3D option = new Vec3D (ox, oy, oz);
        if (!option.add(loc).isInAABB(myBox)) {  
          if (checkVectorWithinWorld(option.add(loc))) {  // check points are within world limits
            if (!forceCornerPerpendicular || checkLinesCoincident(myAxis, new Line3D(myAxis.a, option.add(loc)))) {
              options.add(option);
            }
          }
        }
      }
    }
  }

  void updateAxis() {
    // X
    myAxis = null;
    if (dim.x > dim.z && dim.x > dim.y) {
      Vec3D a = loc.add(new Vec3D(dim.x/2, 0, 0));
      Vec3D b = loc.sub(new Vec3D(dim.x/2, 0, 0));
      myAxis = new Line3D(a, b);
      topCap = new AABB (a, new Vec3D(capWidth, dim.y/2, dim.z/2));
      bottomCap = new AABB (b, new Vec3D(capWidth, dim.y/2, dim.z/2));
      edgeList = new ArrayList<Line3D>();
      edgeList.add(new Line3D(myAxis.a.add(new Vec3D(0, dim.y/2, dim.z/2)), myAxis.b.add(new Vec3D(0, dim.y/2, dim.z/2)))) ;
      edgeList.add(new Line3D(myAxis.a.add(new Vec3D(0, -dim.y/2, dim.z/2)), myAxis.b.add(new Vec3D(0, -dim.y/2, dim.z/2)))) ;
    }
    // Y
    if (dim.y > dim.z && dim.y > dim.x) {
      Vec3D a = loc.add(new Vec3D(0, dim.y/2, 0));
      Vec3D b = loc.sub(new Vec3D(0, dim.y/2, 0));
      myAxis = new Line3D(a, b);
      topCap = new AABB (a, new Vec3D(dim.x/2, capWidth, dim.z/2));
      bottomCap = new AABB (b, new Vec3D(dim.x/2, capWidth, dim.z/2));  
      edgeList = new ArrayList<Line3D>();
      edgeList.add(new Line3D(myAxis.a.add(new Vec3D(dim.x/2, 0, dim.z/2)), myAxis.b.add(new Vec3D(dim.x/2, 0, dim.z/2)))) ;
      edgeList.add(new Line3D(myAxis.a.add(new Vec3D(-dim.x/2, 0, dim.z/2)), myAxis.b.add(new Vec3D(-dim.x/2, 0, dim.z/2)))) ;
    }
    // Z
    if (dim.z > dim.y && dim.z > dim.x) {
      Vec3D a = loc.add(new Vec3D(0, 0, dim.z/2));
      Vec3D b = loc.sub(new Vec3D(0, 0, dim.z/2));
      myAxis = new Line3D(a, b);
      topCap = new AABB (a, new Vec3D(dim.x/2, dim.y/2, capWidth));
      bottomCap = new AABB (b, new Vec3D(dim.x/2, dim.y/2, capWidth));
      edgeList = new ArrayList<Line3D>();
      // no top edges as it is vertical !!
    }
    // SQUARE BASE, axis is on different side
    if (myAxis == null) {
      if (dim.x == dim.y) {
        Vec3D a = loc.add(new Vec3D(0, 0, dim.z/2));
        Vec3D b = loc.sub(new Vec3D(0, 0, dim.z/2));
        myAxis = new Line3D(a, b);
        edgeList = new ArrayList<Line3D>();
      }
      if (dim.x == dim.z) {
        Vec3D a = loc.add(new Vec3D(0, dim.y/2, 0));
        Vec3D b = loc.sub(new Vec3D(0, dim.y/2, 0));
        myAxis = new Line3D(a, b);
        edgeList = new ArrayList<Line3D>();
      }
      if (dim.z == dim.y) {
        Vec3D a = loc.add(new Vec3D(dim.x/2, 0, 0));
        Vec3D b = loc.sub(new Vec3D(dim.x/2, 0, 0));
        myAxis = new Line3D(a, b);
        edgeList = new ArrayList<Line3D>();
      }
    }
  }
}


class BlockShape extends Part {
  Vec3D a, b, c, d;
  int thickness;
  boolean extrudeInBothDirections = false;

  Vec3D aa, bb, cc, dd, ee, ff, gg, hh;

  BlockShape () {
  }

  boolean isAboveGround() {
    return aa.z > 0 && bb.z > 0 && cc.z > 0 && dd.z > 0 && ee.z > 0 && ff.z > 0 && gg.z > 0 && hh.z > 0;
  }

  boolean isWithinWorld() {
    return checkVectorWithinWorld(aa) && checkVectorWithinWorld(bb) && checkVectorWithinWorld(cc) && checkVectorWithinWorld(dd)
      && checkVectorWithinWorld(ee) && checkVectorWithinWorld(ff) && checkVectorWithinWorld(gg) && checkVectorWithinWorld(hh);
  }

  boolean intersectsBlockShapeList(ArrayList<BlockShape> thisBlockList, int thisStep) {
    for (BlockShape thisBlock : thisBlockList) {
      if (intersectsBlockShape(thisBlock, thisStep)) {
        return true;
      }
    }
    return false;
  } 

  boolean intersectsBlockShape(BlockShape thisBlock, int thisStep) {   /// really harsh approximation to collision, only works when planes are coincident!
    ArrayList<Vec3D> pointsAB = getPointsFromLine(new Line3D(aa, bb), thisStep, true);
    ArrayList<Vec3D> pointsDC = getPointsFromLine(new Line3D(dd, cc), thisStep, true);
    // ArrayList<Vec3D> pointsEF = getPointsFromLine(new Line3D(ee, ff), thisStep, true);
    // ArrayList<Vec3D> pointsHG = getPointsFromLine(new Line3D(hh, gg), thisStep, true);

    ArrayList<Vec3D> thisPointsAD = getPointsFromLine(new Line3D(thisBlock.aa, thisBlock.dd), thisStep, true);
    ArrayList<Vec3D> thisPointsBC = getPointsFromLine(new Line3D(thisBlock.bb, thisBlock.cc), thisStep, true);
    // ArrayList<Vec3D> thisPointsEF = getPointsFromLine(new Line3D(thisBlock.ee, thisBlock.ff), thisStep, true);
    // ArrayList<Vec3D> thisPointsHG = getPointsFromLine(new Line3D(thisBlock.hh, thisBlock.gg), thisStep, true);

    for  (int i=0;i<pointsAB.size();i++) {
      Line3D tempLine = new Line3D(pointsAB.get(i), pointsDC.get(i));
      for  (int j=0;j<thisPointsAD.size();j++) {
        Line3D thisTempLine = new Line3D(thisPointsAD.get(j), thisPointsBC.get(j));
        if (checkLinesCollision(tempLine, thisTempLine)) {
          return true;
        }
      }
    }
    return false;
  }

  boolean intersectsBlockList(ArrayList<SuperBlock> thisBlockList, int thisStep) {
    for (SuperBlock thisBlock : thisBlockList) {
      if (intersectsBlock(thisBlock, thisStep)) {
        return true;
      }
    }
    return false;
  }

  boolean intersectsBlock(SuperBlock thisBlock, int thisStep) {
    // println(aa+" "+bb+" "+cc+" "+dd+" "+ee+" "+ff+" "+gg+" "+hh);
    ArrayList<Vec3D> pointsAB = getPointsFromLine(new Line3D(aa, bb), thisStep, true);
    ArrayList<Vec3D> pointsDC = getPointsFromLine(new Line3D(dd, cc), thisStep, true);
    // println(pointsAB.size()+" "+pointsDC.size());
    for  (int i=0;i<pointsAB.size();i++) {
      Line3D tempLine = new Line3D(pointsAB.get(i), pointsDC.get(i));
      if (checkLineBlockCollision(tempLine, thisBlock)) {
        return true;
      }
    }
    ArrayList<Vec3D> pointsEF = getPointsFromLine(new Line3D(ee, ff), thisStep, true);
    ArrayList<Vec3D> pointsHG = getPointsFromLine(new Line3D(hh, gg), thisStep, true);
    // println(pointsEF.size()+" "+pointsHG.size());

    for  (int i=0;i<pointsEF.size();i++) {
      Line3D tempLine = new Line3D(pointsEF.get(i), pointsHG.get(i));
      if (checkLineBlockCollision(tempLine, thisBlock)) {
        return true;
      }
    }
    return false;
  }

  void calculate() {
    Triangle3D thisTriangle  = new Triangle3D(a, b, c);
    Vec3D nor = thisTriangle.computeNormal().normalize();
    Vec3D offsetA;
    Vec3D offsetB; 
    if (extrudeInBothDirections) {
      offsetA = nor.copy().scaleSelf(thickness/2);
      offsetB = nor.getInverted();
    } 
    else {
      offsetA = new Vec3D(0, 0, 0);  
      offsetB = nor.copy().scaleSelf(thickness);
    }
    aa = a.copy().addSelf(offsetA);
    bb = b.copy().addSelf(offsetA);
    cc = c.copy().addSelf(offsetA);
    dd = d.copy().addSelf(offsetA);
    ee = a.copy().addSelf(offsetB);
    ff = b.copy().addSelf(offsetB);
    gg = c.copy().addSelf(offsetB);
    hh = d.copy().addSelf(offsetB);
  }

  void display() {
    if (structure) {
      stroke(color(strokeColor, 0, 0), strokeAlpha);
      strokeWeight(1);
      // noFill();
      if (filled) {
        fill(fillColor, fillAlpha);
      } 
      else {
        noFill();
      }
      beginShape(QUAD_STRIP);
      vertex(aa.x, aa.y, aa.z);
      vertex(bb.x, bb.y, bb.z);
      vertex(dd.x, dd.y, dd.z);
      vertex(cc.x, cc.y, cc.z);
      endShape();
      beginShape(QUAD_STRIP);
      vertex(ee.x, ee.y, ee.z);
      vertex(ff.x, ff.y, ff.z);
      vertex(hh.x, hh.y, hh.z);
      vertex(gg.x, gg.y, gg.z);
      endShape();
      // maybe add other side ?
    }

    //    stroke(0, 255, 0);
    //    ArrayList<Vec3D> pointsAB = getPointsFromLine(new Line3D(aa, bb), 5, true);
    //    ArrayList<Vec3D> pointsDC = getPointsFromLine(new Line3D(dd, cc), 5, true);
    //    for  (int i=0;i<pointsAB.size();i++) {
    //      Line3D tempLine = new Line3D(pointsAB.get(i), pointsDC.get(i));
    //      fx.line(tempLine);
    //    }
  }

  void build() {  
    addMesh(createBlockMeshFromPlane(a, b, c, d, thickness, false), material);
  }

  void setCorners(Vec3D a, Vec3D b, Vec3D c, Vec3D d) {
    this.a = a;
    this.b = b;
    this.c = c;
    this.d = d;
  }
}

class Block extends Part {
  Vec3D dim;

  Block () {
    id = millis();
  }

  void display() {
    pushMatrix();
    if (dots) {
      stroke(redColor);
      strokeWeight(markerStroke);
      drawMarker(loc);
    }
    if (structure) {
      stroke(color(strokeColor, 0, 0), strokeAlpha);
      if (filled) {
        fill(fillColor, fillAlpha);
      } 
      else {
        noFill();
      }
      translate(loc.x, loc.y, loc.z);
      rotateX(rot.x);
      rotateY(rot.y);
      rotateZ(rot.z);
      box(dim.x, dim.y, dim.z);
    }
    popMatrix();
  }

  void build() {  
    // 1 first option with axis aligned box and rotated mesh
    AABB block=new AABB(new Vec3D(0, 0, 0), dim.scale(.5));
    TriangleMesh blockMesh=(TriangleMesh)block.toMesh(); 
    blockMesh.rotateZ(rot.z);
    blockMesh.rotateY(rot.y);
    blockMesh.rotateX(rot.x);
    blockMesh.translate(loc);
    addMesh(blockMesh, material);
    //2 second option creating mesh from plane
    //      Vec3D aa = locateVector(Vec3D.ZERO, rot, new Vec3D(-dim.x/2, -dim.y/2, 0));
    //      Vec3D bb = locateVector(Vec3D.ZERO, rot, new Vec3D(dim.x/2, -dim.y/2, 0));
    //      Vec3D cc = locateVector(Vec3D.ZERO, rot, new Vec3D(dim.x/2, dim.y/2, 0));
    //      Vec3D dd = locateVector(Vec3D.ZERO, rot, new Vec3D(-dim.x/2, dim.y/2, 0));
    //      TriangleMesh blockShapeMesh = createBlockMeshFromPlane(aa, bb, cc, dd, (int)dim.z);
    //      blockShapeMesh.translate(loc);
    //      meshList[material].addMesh(blockShapeMesh);
  }

  void setDimension(Vec3D dim) {
    this.dim = dim;
  }

  void setRotation(Vec3D rot) {
    this.rot = rot;
  }
}

class Cylinder extends Part {
  float r, h;

  Cylinder () {
    id = millis();
  }

  void display() {
    pushMatrix();
    translate(loc.x, loc.y, loc.z);
    rotateX(rot.x);
    rotateY(rot.y);
    rotateZ(rot.z);


    if (dots) {
      strokeWeight(markerStroke);
      stroke(color(strokeColor, 0, 0), strokeAlpha);
      drawMarker(Vec3D.ZERO.copy());
      drawMarker(new Vec3D(0, 0, -h/2));
      drawMarker(new Vec3D(0, 0, h/2));
    }
    if (structure) {
      //  fill(redColor, solidAlpha);
      noFill();
      stroke(redColor, strokeAlpha);
      strokeWeight(thickStroke);
      translate(0, 0, -h/2);
      ellipse(0, 0, 2*r, 2*r);
      translate(0, 0, h);
      ellipse(0, 0, 2*r, 2*r);
    }
    if (details) {
      //   stroke(redColor, strokeAlpha);
      //   fx.line(new Vec3D(0, 0, -h/2), new Vec3D(0, 0, +h/2));
    }
    popMatrix();
  }

  void build() {   
    AxisAlignedCylinder cyl=new ZAxisCylinder(Vec3D.ZERO, r, h);
    TriangleMesh cylinderMesh = (TriangleMesh)cyl.toMesh(cylinderRes, 0);
    // option A
    // this is how to find point A and point B outside the matrix -> same as locateVector(loc, rot, new Vec3D(0,0,h/2));
    //    Vec3D startPoint = new Vec3D (0, 0, h/2);
    //    startPoint.rotateZ(-rot.z);  
    //    startPoint.rotateY(-rot.y);
    //    startPoint.rotateX(-rot.x);
    //    startPoint.addSelf(loc);
    //    Vec3D endPoint = new Vec3D (0, 0, -h/2);
    //    endPoint.rotateZ(-rot.z);  
    //    endPoint.rotateY(-rot.y);
    //    endPoint.rotateX(-rot.x);
    //    endPoint.addSelf(loc);
    //    Line3D thisLine = new Line3D(startPoint, endPoint);
    Vec3D thisDirection = new Vec3D(0, 0, 1);
    thisDirection.rotateZ(-rot.z);
    thisDirection.rotateY(-rot.y);
    thisDirection.rotateX(-rot.x);
    thisDirection.normalize();
    cylinderMesh.pointTowards(thisDirection); // same as following line
    //cylinderMesh.transform(Quaternion.getAlignmentQuat(thisDirection, Vec3D.Z_AXIS).getMatrix(), true);
    cylinderMesh.translate(loc);
    addMesh(cylinderMesh, material);
  }

  void setHeight(float h ) {
    this.h = h;
  }

  void setRadius(float r) {
    this.r = r;
  }
}

class Fabric extends Part {
  Vec3D a, b, c, d;
  int thickness;

  Fabric () {
    id = millis();
  }

  void display() {
    if (structure) {
      stroke(color(strokeColor, 0, 0), strokeAlpha);
      strokeWeight(1);
      if (filled) {
        fill(color(fillColor, 0, 0), fillAlpha);
      } 
      else {
        noFill();
      }
      beginShape(QUAD_STRIP);
      vertex(a.x, a.y, a.z);
      vertex(b.x, b.y, b.z);
      vertex(d.x, d.y, d.z);
      vertex(c.x, c.y, c.z);
      endShape();
    }
  }

  void build() {  
    addMesh(createBlockMeshFromPlane(a, b, c, d, bFabricThickness/2, true), material);
    addMesh(createCylinderMeshFromLine(new Line3D(b, c), (int)bTubeR+2), material);
    addMesh(createCylinderMeshFromLine(new Line3D(a, d), (int)bTubeR+2), material);
  }
}

class Pipe extends Part {
  //  boolean closed = true;
  LineStrip3D myCurve;
  ParallelTransportFrame ptf;
  ParallelTube tube = null;
  ArrayList<Vec3D> pointList = new ArrayList<Vec3D>();
  //  ArrayList tangentList = new ArrayList();

  int tubeR;
  int cornerR;

  Pipe() {
    id = millis();
  }

  void addPoint(Vec3D loc) {
    pointList.add(loc);
  }

  void update() {
    myCurve = new LineStrip3D();
    Vec3D midPoint = null;
    Vec3D firstPoint = (Vec3D)pointList.get(0);
    Vec3D secondPoint = (Vec3D)pointList.get(1);
    Vec3D lastPoint =  (Vec3D)pointList.get(pointList.size()-1);
    ArrayList<Vec3D> tempPointList =  new ArrayList<Vec3D>();

    for (Vec3D thisPoint : pointList) {
      tempPointList.add(thisPoint);
    }

    if (firstPoint.equals(lastPoint)) {
      midPoint = new Line3D(firstPoint, secondPoint).getMidPoint();
      myCurve.add(midPoint);
      tempPointList.add(midPoint);
    } 
    else {
      myCurve.add((Vec3D)pointList.get(0));
    }

    for (int i=1;i<tempPointList.size()-1;i++) {
      Vec3D previousPoint = (Vec3D)tempPointList.get(i-1);
      Vec3D cornerPoint = (Vec3D)tempPointList.get(i);
      Vec3D nextPoint =  (Vec3D)tempPointList.get(i+1);
      Vec3D vec1 = previousPoint.sub(cornerPoint).normalize();
      Vec3D vec2 = nextPoint.sub(cornerPoint).normalize();
      float cornerAngle = vec2.angleBetween(vec1);
      Triangle3D cornerTriangle = new Triangle3D(previousPoint, cornerPoint, nextPoint);
      Vec3D cornerNormal = cornerTriangle.computeNormal();
      Vec3D cornerBisector = vec1.copy();
      cornerBisector.rotateAroundAxis(cornerNormal, cornerAngle/2);

      Vec3D centerPoint = cornerPoint.add(cornerBisector.scale(cornerR/cos(HALF_PI-cornerAngle/2)));  //// equili qua !!!
      //      Vec3D tangentPoint2 = cornerPoint.sub(nextPoint);
      //      tangentPoint2.normalize();
      //      tangentPoint2.scaleSelf(cornerR);
      //      tangentPoint2.addSelf(centerPoint);
      //      tangentList.add(tangentPoint2);
      //
      //      Vec3D tangentPoint1 = cornerPoint.sub(previousPoint);
      //      tangentPoint1.normalize();
      //      tangentPoint1.scaleSelf(cornerR);
      //      tangentPoint1.addSelf(centerPoint);
      //      tangentList.add(tangentPoint1);

      float arcAngle = cornerAngle-PI;
      float offsetAngle = arcAngle/(float)curveRes;
      for (float j = 0; j<= curveRes; j ++) {
        Vec3D thisPoint = cornerBisector.copy();
        thisPoint.rotateAroundAxis(cornerNormal, (j*offsetAngle)-PI-arcAngle/2);  // important
        thisPoint.scaleSelf(cornerR);
        thisPoint.addSelf(centerPoint);
        myCurve.add(thisPoint);
      }
    }
    myCurve.add((Vec3D)tempPointList.get(tempPointList.size()-1));
    myCurve.add((Vec3D)tempPointList.get(tempPointList.size()-1));
  }

  void build() {
    if (myCurve != null) {
      ptf = new ParallelTransportFrame(myCurve.getVertices());
      tube = new ParallelTube(ptf, tubeR, segmentRes);
      tube.computeVertexNormals();
      addMesh(tube, material);
    }
  }

  void display() {
    if (dots) {
      stroke(redColor);
      strokeWeight(markerStroke);
      for (int i = 0; i < pointList.size() ; i++) {
        Vec3D thisPoint = (Vec3D) pointList.get(i);
        drawMarker(thisPoint);
      }
      //      for (int i = 0; i < tangentList.size() ; i++) {
      //        Vec3D thisPoint = (Vec3D) tangentList.get(i);
      //        fx.point(thisPoint);
      //      }
    }
    if (structure) {
      stroke(redColor, strokeAlpha);
      strokeWeight(thickStroke);
      if (myCurve != null) {
        fx.lineStrip3D(myCurve.getVertices());
      }
    }
    if (dots) {
      if (myCurve != null) {
        List <Vec3D> curvePointList = myCurve.getVertices();
        for (int i = 0; i < curvePointList.size(); i++) {
          Vec3D thisPoint = curvePointList.get(i);
          stroke(blueColor);
          strokeWeight(markerStroke);
          drawMarker(thisPoint);
        }
      }
    }
  }

  void setRadius(int thisRadius) {
    tubeR = thisRadius;
  }

  void setCornerRadius(int thisRadius) {
    cornerR = thisRadius;
  }
}


class BezierTube extends Part {
  LineStrip3D myCurve;
  ParallelTransportFrame ptf;
  ParallelTube tube = null;
  ArrayList pointList;
  ArrayList controlPointListA;
  ArrayList controlPointListB;
  ArrayList bezierPointList;

  float r;

  BezierTube() {
    id = millis();
    pointList = new ArrayList();
    controlPointListA = new ArrayList();
    controlPointListB = new ArrayList();
    bezierPointList = new ArrayList();
  }

  void addPoint(Vec3D loc, Vec3D controlPointA, Vec3D controlPointB) {
    pointList.add(loc);
    controlPointListA.add(controlPointA.addSelf(loc));
    controlPointListB.add(controlPointB.addSelf(loc));
  }

  void update() {
    bezierPointList = new ArrayList();
    for (int i = 0; i < pointList.size()-1 ; i++) {
      for (int j=0;j<=curveRes;j++) {   // curece detail
        float t = j / float(curveRes);
        Vec3D firstPoint = (Vec3D)pointList.get(i);
        Vec3D secondPoint = (Vec3D)pointList.get(i+1);
        Vec3D firstControlPoint = (Vec3D)controlPointListB.get(i);
        Vec3D secondControlPoint = (Vec3D)controlPointListA.get(i+1);
        float thisX = bezierPoint(firstPoint.x, firstControlPoint.x, secondControlPoint.x, secondPoint.x, t);
        float thisY = bezierPoint(firstPoint.y, firstControlPoint.y, secondControlPoint.y, secondPoint.y, t);
        float thisZ = bezierPoint(firstPoint.z, firstControlPoint.z, secondControlPoint.z, secondPoint.z, t);
        bezierPointList.add(new Vec3D(thisX, thisY, thisZ));
      }
      bezierPointList.add((Vec3D)bezierPointList.get(bezierPointList.size()-1)); // needed by PTF constructor
      myCurve = new LineStrip3D(bezierPointList);   //  compute bezier
    }
  }

  void build() {
    ptf = new ParallelTransportFrame(myCurve.getVertices());
    tube = new ParallelTube(ptf, (int)r, segmentRes);    // tube detail
    tube.computeVertexNormals(); 
    addMesh(tube, material);
  }

  void display() {
    if (structure) {
      //      stroke(redColor, strokeColor);
      //      strokeWeight(thickStroke);
      //      noFill();
      //      for (int i = 0; i < pointList.size()-1 ; i=i+2) {
      //        Vec3D firstPoint = (Vec3D)pointList.get(i);
      //        Vec3D secondPoint = (Vec3D)pointList.get(i+1);
      //        Vec3D firstControlPoint = (Vec3D)controlPointListB.get(i);
      //        Vec3D secondControlPoint = (Vec3D)controlPointListA.get(i+1);
      //        bezier(firstPoint.x, firstPoint.y, firstPoint.z, 
      //        firstControlPoint.x, firstControlPoint.y, firstControlPoint.z, 
      //        secondControlPoint.x, secondControlPoint.y, secondControlPoint.z, 
      //        secondPoint.x, secondPoint.y, secondPoint.z);
      //      }
      // fater alternative follow as spline does not need to be computed again
      stroke(redColor, strokeAlpha);
      strokeWeight(thickStroke);
      fx.lineStrip3D(myCurve.getVertices());
    }

    if (details) {
      strokeWeight(markerStroke);
      for (int i = 0; i < pointList.size() ; i++) {
        stroke(blueColor);
        drawMarker((Vec3D)pointList.get(i));  
        drawControlPoint((Vec3D)controlPointListA.get(i));
        drawControlPoint((Vec3D)controlPointListB.get(i));
        strokeWeight(thinStroke);
        fx.line((Vec3D) pointList.get(i), (Vec3D)controlPointListA.get(i));
        fx.line((Vec3D) pointList.get(i), (Vec3D)controlPointListB.get(i));
      }
      List <Vec3D> curvePointList = myCurve.getVertices();
      for (int i = 0; i < curvePointList.size(); i++) {
        stroke(redColor);
        strokeWeight(markerStroke);
        drawMarker((Vec3D)curvePointList.get(i));
      }
    }
  }

  void setRadius(float r) {
    this.r = r;
  }
}

class SplineTube extends Part {
  LineStrip3D myCurve;
  ParallelTransportFrame ptf;
  ParallelTube tube = null;
  ArrayList pointList;
  int r;

  SplineTube() {
    id = millis();
    pointList = new ArrayList();
  }

  void addPoint(Vec3D loc) {
    pointList.add(loc);
  }

  void update() { 
    Spline3D spline = new Spline3D(pointList);
    spline.setTightness(tightness);      //  tight
    myCurve = new LineStrip3D(spline.computeVertices(curveRes));   //  res
  }

  void build() {
    ptf = new ParallelTransportFrame(myCurve.getVertices());
    tube = new ParallelTube(ptf, r, segmentRes);   
    tube.computeVertexNormals(); 
    addMesh(tube, material);
  }

  void display() {
    if (dots) {
      stroke(redColor);
      strokeWeight(markerStroke);
      for (int i = 0; i < pointList.size() ; i++) {
        Vec3D thisPoint = (Vec3D) pointList.get(i);
        drawMarker(thisPoint);
      }
    }

    if (structure) {
      stroke(redColor, strokeAlpha);
      strokeWeight(thickStroke);
      fx.lineStrip3D(myCurve.getVertices());
    }

    if (details) {
      List <Vec3D> curvePointList = myCurve.getVertices();
      for (int i = 0; i < curvePointList.size(); i++) {
        Vec3D thisPoint = curvePointList.get(i);
        stroke(blueColor);
        strokeWeight(markerStroke);
        drawMarker(thisPoint);
      }
    }
  }

  void setRadius(int r) {
    this.r = r;
  }
}

class Torus extends Part {
  LineStrip3D myCurve;
  ParallelTransportFrame ptf;
  ParallelTube tube = null;

  float r;
  float tubeRadius;

  Torus () {
    id = millis();
  }

  void update() { 
    myCurve = new LineStrip3D();
    float offsetAngle = 2*PI/(float)(cylinderRes);
    for (int i = 0; i < (cylinderRes)+2; i++) {
      myCurve.add(loc.x+r*cos(offsetAngle*i), loc.y+r*sin(offsetAngle*i), loc.z);
    }
  }

  void build() {
    ptf = new ParallelTransportFrame(myCurve.getVertices());
    tube = new ParallelTube(ptf, (int)tubeRadius, segmentRes);
    tube.computeVertexNormals();
    addMesh(tube, material);
  }

  void display() {
    if (structure) {
      stroke(redColor, strokeAlpha);
      strokeWeight(thickStroke);
      fx.lineStrip3D(myCurve.getVertices());
    }
    if (dots) {
      stroke(redColor);
      strokeWeight(markerStroke);
      drawMarker(loc);
    }
  }

  void setRadius(float r) {
    this.r = r;
  }

  void setTubeRadius(float tubeRadius) {
    this.tubeRadius = tubeRadius;
  }
}

// tube following a knot curve

class Knot extends Part {
  LineStrip3D myCurve;
  ParallelTransportFrame ptf;
  ParallelTube tube = null;

  float r;
  float p = 3;
  float q = 2;
  float curveLength;
  float knotRadius;

  Knot () {
    id = millis();
  }

  void update() { 
    myCurve = new LineStrip3D();
    curveLength = curveRes*4;
    float theta = 0.1f;
    float dt = ((TWO_PI) / curveLength);
    for (int i=0; i<curveLength+2; i++) {  
      float a = cos(q * theta) + 2;
      float x = a * cos(p * theta) * knotRadius;
      float y = a * sin(p * theta) * knotRadius;
      float z = -sin(q*theta) * knotRadius;
      theta += dt;
      myCurve.add(new Vec3D(x, y, z).add(loc));
    }
  }

  void build() {
    ptf = new ParallelTransportFrame(myCurve.getVertices());
    tube = new ParallelTube(ptf, (int)r, segmentRes);
    tube.computeVertexNormals();
    addMesh(tube, material);
  }

  void display() {
    stroke(strokeColor, strokeAlpha);
    strokeWeight(thickStroke);
    fx.lineStrip3D(myCurve.getVertices());
  }

  void setRadius(float r) {
    this.r = r;
  }

  void setKnotRadius(float knotRadius) {
    this.knotRadius = knotRadius;
  }

  void setP(float p) {
    this.p = p;
  }

  void setQ(float q) {
    this.q = q;
  }
}

class HeMesh extends Part {
  HE_Mesh myMesh;
  //AABB boundingBox;
  //Line3D axis;
  //boolean offcenter = false;

  //float sca = 1;

  HeMesh () {
    id = millis();
  }

//  void setScale (float sca) {
//    this.sca = sca;
//  }

  void setMesh (HE_Mesh thisMesh) {
    myMesh= thisMesh;
  }

//  void setAxis(Line3D axis) {
//    this.axis = axis;
//  }
  
  void display() {
    if (structure) {
       stroke(strokeColor, strokeAlpha);
        render.drawEdges(myMesh);
    }

    if (filled) {
      fill(fillColor, fillAlpha);
      render.drawFaces(myMesh);
    }

    if (dots) {
      stroke(redColor, strokeAlpha);
     // render.drawVertices(myMesh);
    }
    
  }
  
  void update() {

  }

  void build() {
    if (myMesh != null) {
      addMesh(myMesh, material);
    }
  }
}



class ToxicMesh extends Part {
  TriangleMesh myMesh, tempMesh;
  AABB boundingBox;
  Line3D axis;
  boolean offcenter = false;

  float sca = 1;

  ToxicMesh () {
    id = millis();
  }

  void setScale (float sca) {
    this.sca = sca;
  }

  void setMesh (TriangleMesh thisMesh) {
    myMesh= thisMesh;
    myMesh.computeFaceNormals();
  }

  void setAxis(Line3D axis) {
    this.axis = axis;
  }

  void loadMesh(String fileName) {
    println("load mesh");
    myMesh=(TriangleMesh)new STLReader().loadBinary(sketchPath("stl/"+fileName), STLReader.TRIANGLEMESH);
  }

  void update() {
    //    tempMesh = myMesh.copy();
    //   // boundingBox = tempMesh.getBoundingBox();
    //    if (offcenter) {
    //      tempMesh.translate(new Vec3D(-boundingBox.x, -boundingBox.y, 0));  // in case mesh if off center, add boolean !!!
    //    }
    //    tempMesh.scale(sca);
    //    tempMesh.translate(loc);
    //    if (axis != null) {
    //      tempMesh.pointTowards(axis.b);
    //    } 
    //    else {
    //      tempMesh.rotateZ(rot.z);
    //      tempMesh.rotateY(rot.y);
    //      tempMesh.rotateX(rot.x);
    //    }
    //    boundingBox = tempMesh.getBoundingBox();
  }

  void build() {
    if (myMesh != null) {
      addMesh(myMesh, material);
    }
    //addMesh(tempMesh, material);
  }

  void display() {
    //    if (solid) {
    //      stroke(blueColor, strokeAlpha);
    //      strokeWeight(thinStroke);
    //      noFill();
    //      fx.mesh(tempMesh);
    //    }
    if (details) {
      stroke(color(strokeColor, 0, 0), strokeAlpha);
      strokeWeight(thinStroke);
      noFill();
      fx.box(tempMesh.getBoundingBox());
    }
  }
}

class Bulb extends Part {
  Line3D myAxis;
  Sphere mySphere;
  float sphereRadius;

  Bulb () {
    id = millis();
  }

  void setAxis(Line3D thisAxis) {
    myAxis = thisAxis;
  }

  void update() {
    //    Vec3D thisDirection = myAxis.getDirection();
    mySphere = new Sphere(Vec3D.ZERO, sphereRadius);
    //    mySphere.rotateZ(thisDirection.z);
    //    mySphere.rotateY(thisDirection.y);
    //    mySphere.rotateX(thisDirection.x);
    // mySphere.set(loc);
  }

  void build() {
    Vec3D thisDirection = myAxis.getDirection();
    TriangleMesh bulbMesh = (TriangleMesh)mySphere.toMesh(sphereRes);
    bulbMesh.rotateZ(thisDirection.z);
    bulbMesh.rotateY(thisDirection.y);
    bulbMesh.rotateX(thisDirection.x);
    bulbMesh.translate(loc);
    Line3D baseAxis = new Line3D(loc.sub(thisDirection.scale(sphereRadius*.9)), loc.sub(thisDirection.scale(sphereRadius*1.2)));
    TriangleMesh baseMesh = createCylinderMeshFromLine(baseAxis, (int)(sphereRadius*.5));
    addMesh(bulbMesh, "glass");
    addMesh(baseMesh, "metal");
  }

  void display() {
    noFill();
    if (structure) {
      stroke(redColor, strokeAlpha);
      pushMatrix();
      translate(loc.x, loc.y, loc.z);
      Vec3D thisDirection = myAxis.getDirection();
      //      rotateX(-thisDirection.x);
      //      rotateY(-thisDirection.y);
      //      rotateZ(-thisDirection.z);
      strokeWeight(thinStroke);

      fx.sphere(mySphere, sphereRes);

      strokeWeight(thickStroke);
      translate(0, 0, .8*sphereRadius);
      //
      //      ellipse(0, 0, sphereRadius*.5, sphereRadius*.5);
      //      translate(0, 0, .7*sphereRadius);
      //      ellipse(0, 0, sphereRadius*.5, sphereRadius*.5);

      popMatrix();
    }
    if (details) {
      stroke(blueColor, strokeAlpha);
      strokeWeight(thinStroke);
      fx.line(myAxis);
    }
  }
}

int raPointNum = 90;
//int raStep = 90;
int raRadius = 500;
float raa1 = 1;
float rab1 = 1;
float ram1 = 3;
float ran11 = 1;
float ran21 = 1;
float ran31 = 2;

float raa2 = 1;
float rab2 = 1;
float ram2 = 3;
float ran12 = 1;
float ran22 = 1;
float ran32 = 2;

Vec2D[] superFormulaPoints;
Vec3D[][] superShapePoints;

class Radiolaria extends Furniture {

  Radiolaria () {
    reset();
    //  randomize();
    cx = 0;
    cy = 0;
    Group gRadiolaria = cp5.addGroup("radiolaria").setPosition(columnx, marginy).hideBar();
    createSlider(gRadiolaria, "raRadius", raRadius, 0, 500, true, "raduis");
    //createSlider(gRadiolaria, "raStep", raStep, 256, 180, true, "detail");
    createSlider(gRadiolaria, "raPointNum", raPointNum, 12, 180, true, "detail");

    cy += sh/2;
    createSlider(gRadiolaria, "raa1", raa1, 1, 20, true, "a1");
    createSlider(gRadiolaria, "rab1", rab1, 1, 20, true, "b1");
    createSlider(gRadiolaria, "ram1", ram1, 1, 20, true, "m1");
    createSlider(gRadiolaria, "ran11", ran11, 1, 20, true, "n11");
    createSlider(gRadiolaria, "ran21", ran21, 1, 20, true, "n21");
    createSlider(gRadiolaria, "ran31", ran31, 1, 20, true, "n31");
    cy += sh/2;
    createSlider(gRadiolaria, "raa2", raa2, 1, 20, true, "a2");
    createSlider(gRadiolaria, "rab2", rab2, 1, 20, true, "b2");
    createSlider(gRadiolaria, "ram2", ram2, 1, 20, true, "m2");
    createSlider(gRadiolaria, "ran12", ran12, 1, 20, true, "n12");
    createSlider(gRadiolaria, "ran22", ran22, 1, 20, true, "n22");
    createSlider(gRadiolaria, "ran32", ran32, 1, 20, true, "n32");
    //  updateControllerList.add("taTubeR");
    //  updateControllerList.add("taCornerR");
    generateControllerList.add("raa1");
    generateControllerList.add("rab1");
    generateControllerList.add("ram1");
    generateControllerList.add("ran11");
    generateControllerList.add("ran21");
    generateControllerList.add("ran31");

    generateControllerList.add("raa2");
    generateControllerList.add("rab2");
    generateControllerList.add("ram2");
    generateControllerList.add("ran12");
    generateControllerList.add("ran22");
    generateControllerList.add("ran32");

    generateControllerList.add("raPointNum");
    generateControllerList.add("raRadius");
  }

  void generate() {
    partList = new ArrayList<Part>();
    //    pipe = new Pipe();
    //    pipe.material= "metal";
    //    partList.add(pipe);
    //superFormulaPoints = superFormula(raa1, rab1, ram1, ran11, ran21, ran31);
    superShapePoints = superShape(raa1, rab1, ram1, ran11, ran21, ran31, raa2, rab2, ram2, ran12, ran22, ran32);
    generated = true;
    validated = true;
  }

  void display() {
    if (structure) {
      stroke(strokeColor, 0, 0, strokeAlpha);
      noFill();
      //      beginShape();
      //      curveVertex(superFormulaPoints[superFormulaPoints.length-1].x, superFormulaPoints[superFormulaPoints.length-1].y);
      //      for (int i = 0;i < superFormulaPoints.length; i++) {
      //        curveVertex(superFormulaPoints[i].x, superFormulaPoints[i].y);
      //      }
      //      curveVertex(superFormulaPoints[0].x, superFormulaPoints[0].y);
      //      endShape();
      //      stroke(0, 0, strokeColor, strokeAlpha);
      //      beginShape();
      //      for (int i = 0;i < superShapePoints.length; i++) {
      //        curveVertex(superShapePoints[i].x, superShapePoints[i].y, superShapePoints[i].z);
      //      }
      //      endShape();
      for (int i = 0;i < raPointNum; i++) {
        for (int j = 0;j < raPointNum; j++) {
          fx.line(superShapePoints[i][j], superShapePoints[(i+1)%raPointNum][j]);
          fx.line(superShapePoints[i][j], superShapePoints[i][constrain(j+1,0,raPointNum-1)]);
        }
      }
    }

    if (dots) {
      for (int i = 0;i < raPointNum; i++) {
        for (int j = 0;j < raPointNum; j++) {
          fx.point(superShapePoints[i][j]);
        }
      }
    }
  }




  Vec3D[][] superShape(float a1, float b1, float m1, float n11, float n21, float n31, float a2, float b2, float m2, float n12, float n22, float n32) {
    float phi = TWO_PI / raPointNum;
    Vec3D[][] points = new Vec3D[raPointNum][raPointNum];
    int index = 0;
    for (int i=0;i<raPointNum;i++) {
      float s = -PI+(phi*i);
      for (int j=0;j<raPointNum;j++) {
        float p = (-PI/2) + (j*phi/2);
        float f, e, n, d, t, a, q, m, l, k, h;
        float c = 0;
        float o = 0;
        float u = 0;
        f = cos(m1 * s / 4);
        f = 1 / a1 * abs(f);
        f = abs(f);
        e = sin(m1 * s / 4);
        e = 1 / b1 * abs(e);
        e = abs(e);
        m = pow(f, n21);
        l = pow(e, n31);
        d = m + l;
        t = abs(d);
        t = pow(t, (-1 / n11));
        f = cos(m2 * p / 4);
        f = 1 / a2 * abs(f);
        f = abs(f);
        e = sin(m2 * p / 4);
        e = 1 / b2 * abs(e);
        e = abs(e);
        k = pow(f, n22);
        h = pow(e, n32);
        a = k + h;
        q = abs(a);
        q = pow(q, (-1 / n12));
        c = t * cos(s) * q * cos(p) * raRadius;
        o = t * sin(s) * q * cos(p) * raRadius;
        u = q * sin(p) * raRadius;
        points[i][j] = new Vec3D(c, o, u);
      }
    }
    return points;
  }

  Vec2D[] superFormula(float a, float b, float m, float n1, float n2, float n3) {
    float phi = TWO_PI / raPointNum;
    Vec2D[] points = new Vec2D[raPointNum+1];
    for (int i = 0;i <= raPointNum;i++) {
      points[i] = superformulaPoint(a, b, m, n1, n2, n3, phi * i);
    }
    return points;
  }

  Vec2D superformulaPoint(float a, float b, float m, float n1, float n2, float n3, float phi) {
    float r;
    float t1, t2;
    //  float a=1, b=1;
    float x = 0;
    float y = 0;
    t1 = cos(m * phi / 4) / a;
    t1 = abs(t1);
    t1 = pow(t1, n2);
    t2 = sin(m * phi / 4) / b;
    t2 = abs(t2);
    t2 = pow(t2, n3);
    r = pow(t1+t2, 1/n1);
    if (abs(r) == 0) {
      x = 0;
      y = 0;
    }  
    else {
      r = 1 / r;
      x = r * cos(phi) * raRadius;
      y = r * sin(phi) * raRadius;
    }
    return new Vec2D(x, y);
  }

  void randomize() {
    raa1 = 1;//random(20);
    rab1 = 1;//random(20);
    ram1 = random(15);
    ran11 =random(15);
    ran21 = random(15);
    ran31 = random(15);
    raa2 = 1;//random(20);
    rab2 = 1;//random(20);
    ram2 =random(15);
    ran12 = random(15);
    ran22 = random(15);
    ran32 = random(15);
  }
}

int rPieceNum;
boolean rWithinWorld, rPerpendicularToLast, rCollisionWithAll, rForceToGround, rForceVerticalToGround, rForceX, rForceY, rForceZ, rConnectToAny, rConnectToLast;
boolean rForceCorner, rForceNextCorner, rForceCornerPerpendicular;
boolean rAddRedPlane, rAddBluePlane, redFlag, blueFlag;

int redWoodColor = 150;
int blueWoodColor = 150;
int yellowWoodColor = 150;
int blackWoodColor = 50;

class Rietveld extends Furniture {
  int[] rTypeList = {
    0, 0, 0, 0, 1, 1, 2, 2, 2, 3, 3, 4, 4, 4, 4, 5, 6
  };

  String[] rMaterialList = {
    "black", "black", "black", "black", "black", "red", "blue"
  };

  Vec3D[] rDimensionList = {   // convention: biggest dimension should be on x (will define axis)
    new Vec3D(420, 90, 30), 
    new Vec3D(390, 30, 30), 
    new Vec3D(600, 30, 30), 
    new Vec3D(300, 30, 30), 
    new Vec3D(540, 30, 30), 
    new Vec3D(810, 300, 12), 
    new Vec3D(420, 360, 12)
    };

    SuperBlock lastBlock;

  ArrayList<BlockShape> blockShapeList;
  ArrayList<SuperBlock> blockList; 
  ArrayList<SuperPlane> potentialPlaneList; 
  ToxicMesh rietveldMesh;

  int maxAttempts = 2000;

  Rietveld() {
    reset();
    gridSize = 30;

    cx = 0;
    cy = 0;
    Group gRietveld = cp5.addGroup("rietveld").setPosition(columnx, marginy).hideBar();
    createSlider(gRietveld, "rPieceNum", rPieceNum, 0, 100, true, "number of parts");
    // createButton(gRietveld, "rAddBlock", "grow");
    cy += sh/2;
    createToggle(gRietveld, "rWithinWorld", rWithinWorld, "world limits");
    createToggle(gRietveld, "rPerpendicularToLast", rPerpendicularToLast, "perpendicular");
    createToggle(gRietveld, "rCollisionWithAll", rCollisionWithAll, "collision");
    createToggle(gRietveld, "rForceToGround", rForceToGround, "on ground");
    createToggle(gRietveld, "rForceVerticalToGround", rForceVerticalToGround, "legs on ground");
    createToggle(gRietveld, "rForceY", rForceY, "align to Y");
    createToggle(gRietveld, "rForceX", rForceX, "align to X");
    createToggle(gRietveld, "rForceZ", rForceZ, "align to Z");
    createToggle(gRietveld, "rConnectToAny", rConnectToAny, "connect");
    createToggle(gRietveld, "rConnectToLast", rConnectToLast, "chain");
    createToggle(gRietveld, "rForceCorner", rForceCorner, "corner");
    createToggle(gRietveld, "rForceNextCorner", rForceNextCorner, "next to corner");
    cy += sh/2;
    createToggle(gRietveld, "rAddBluePlane", rAddBluePlane, "blue plane");
    createToggle(gRietveld, "rAddRedPlane", rAddRedPlane, "red plane");
    cy += sh/2;
    createSlider(gRietveld, "blackWoodColor", blackWoodColor, 0, 255, true, "black");
    createSlider(gRietveld, "redWoodColor", redWoodColor, 0, 255, true, "red");
    createSlider(gRietveld, "blueWoodColor", blueWoodColor, 0, 255, true, "blue");
    createSlider(gRietveld, "yellowWoodColor", yellowWoodColor, 0, 255, true, "yellow");
  }

  void reset() {
    rWithinWorld = true;
    rPerpendicularToLast = true;
    rCollisionWithAll = true;
    rForceToGround = false;
    rForceVerticalToGround = true;
    rForceX = false;
    rForceY = false;
    rForceZ = false;
    rConnectToAny = true;
    rConnectToLast = false;
    rForceCorner = false;
    rForceNextCorner = true;
    rPieceNum = rTypeList.length-2;
    rAddRedPlane = true;
    rAddBluePlane = true;
  }

  int getRietveldBlockType() {
    int thisType = rTypeList[(int)random(rTypeList.length-2)];
    return thisType;
  }

  void generate() {
    redFlag = false;
    blueFlag = false;
    gridSize = 30;  // gridSize is different for every collection !!!
    lastBlock = null;
    partList = new ArrayList<Part>();   // clear parts
    blockList = new ArrayList<SuperBlock>(); 
    blockShapeList = new ArrayList<BlockShape>(); 
    if (original) {
      if (rietveldMesh == null) {
        //        rietveldMesh = new ToxicMesh();
        //        rietveldMesh.loadMesh("Rietveld_m_binary.stl");
        //        //rietveldMesh.setLocation(Vec3D.ZERO.copy());
        //        rietveldMesh.setScale(1000);
        //        rietveldMesh.offcenter = true;
        //        rietveldMesh.update();
      } 
      //      partList.add(rietveldMesh);
    }


    // generate structure
    for (int i=0;i< rPieceNum; i++) {
      int  blockType = getRietveldBlockType();
      addBlock(blockType, rWithinWorld, rPerpendicularToLast, rCollisionWithAll, rForceToGround, rForceVerticalToGround, rForceX, rForceY, rForceZ, rConnectToAny, rConnectToLast);   // do not check forceH y forceV true !!!!
    }
    calculatePotentialPlanes();


    if (rAddBluePlane) {
      if (addPlane(6)) blueFlag = true;
    }
    if (rAddRedPlane) {
      if (addPlane(5)) redFlag = true;
    }
    if (redFlag && blueFlag) {
      validated = true;
    } 
    else {
      validated = false;
    }   
    generated = true;
  }

  void calculatePotentialPlanes() {
    potentialPlaneList = new ArrayList<SuperPlane>();

    for (SuperBlock thisBlock : blockList) {
      for (Line3D thisEdge : thisBlock.edgeList) { // loop through each valid edge
        for (SuperBlock otherBlock : blockList) {
          if (!thisBlock.equals(otherBlock)) {  // connect only edges on different blocks
            for (Line3D otherEdge : otherBlock.edgeList) { // loop through all other edges 
              if (!checkLinesCoincident(thisEdge, otherEdge)) {
                ArrayList<Line3D> tempPotentialLineList = new ArrayList<Line3D>(); // new temp list for every pair of edges !!!   
                if (checkLinesParallel(thisEdge, otherEdge)) { // ok we have parallel edges, now create points on edges
                  ArrayList<Vec3D> thisPointList = getPointsFromLine(thisEdge, gridSize/2, false);   // check how many points we need !!!
                  ArrayList<Vec3D> otherPointList =  getPointsFromLine(otherEdge, gridSize/2, false);
                  for (Vec3D thisPoint : thisPointList) { // now loop through all points on both edges to get potential connection lines !!
                    Vec3D closestPoint = otherEdge.closestPointTo(thisPoint);
                    Line3D closestLine = new Line3D(thisPoint, closestPoint); // to get a line perpendicular to every edge
                    for (Vec3D otherPoint : otherPointList) {  // try with points on other edge
                      Line3D thisLine = new Line3D (thisPoint, otherPoint);
                      if (checkLinesParallel(thisLine, closestLine)) {  // get rid of non parallel lines
                        if (thisBlock.myBox.intersectsRay(thisLine.toRay3D(), -10000, 10000) == null &&   // make sure we connect right edge (when lines do not intersect blocks)
                        otherBlock.myBox.intersectsRay(thisLine.toRay3D(), -10000, 10000) == null) {  // hack: arbitrary big number to check if we are connecting wrong edges
                          tempPotentialLineList.add(thisLine);
                        }
                      }
                    }
                  }
                }

                if (tempPotentialLineList.size() > 1) {
                  for (int i=0;i<tempPotentialLineList.size()-1;i++) {   // maybe its better to keep the other approach, generating bigger planes, i.e. v38, to keep planes centered
                    Line3D line1 = tempPotentialLineList.get(0);
                    Line3D line2 = tempPotentialLineList.get(i+1);
                    SuperPlane potentialPlane = new SuperPlane (line1.a, line1.b, line2.b, line2.a);
                    potentialPlaneList.add(potentialPlane);
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  boolean addPlane(int thisType) {
    Vec3D thisDimension = rDimensionList[thisType];
    for (SuperPlane thisPlane : potentialPlaneList) {
      //  float thisPlaneWidth =  thisPlane.axisV.getLength();
      float thisPlaneHeight =  thisPlane.axisH.getLength();
      if (thisPlaneHeight > gridSize && thisPlaneHeight < thisDimension.x) 
      {   // update
        Vec3D center = thisPlane.center;
        Vec3D directionH = thisPlane.directionH;
        Vec3D directionV = thisPlane.directionV;
        Vec3D a = center.add(directionV.scale(thisDimension.y/2)).sub(directionH.scale(thisDimension.x/2));
        Vec3D b = center.sub(directionV.scale(thisDimension.y/2)).sub(directionH.scale(thisDimension.x/2));
        Vec3D c = center.sub(directionV.scale(thisDimension.y/2)).add(directionH.scale(thisDimension.x/2));
        Vec3D d = center.add(directionV.scale(thisDimension.y/2)).add(directionH.scale(thisDimension.x/2));
        BlockShape newBlock = new BlockShape();
        newBlock.setCorners(a, b, c, d);
        newBlock.thickness = (int)thisDimension.z;
        newBlock.material = rMaterialList[thisType];
        newBlock.calculate();
        if ((!rWithinWorld || newBlock.isWithinWorld()) && 
          !newBlock.intersectsBlockList(blockList, gridSize/2) && 
          !newBlock.intersectsBlockShapeList(blockShapeList, gridSize/2)) {
          partList.add(newBlock);
          blockShapeList.add(newBlock);
          return true;
        } 
        else {
          newBlock.thickness = -(int)thisDimension.z;  // to flip normal!!!
          newBlock.calculate();
          if ((!rWithinWorld || newBlock.isWithinWorld()) &&
            !newBlock.intersectsBlockList(blockList, gridSize/2) &&
            !newBlock.intersectsBlockShapeList(blockShapeList, gridSize/2)) {
            partList.add(newBlock);
            blockShapeList.add(newBlock);
            return true;
          }
        }
      }
    }
    return false;
  }

  void addBlock(int blockType, boolean withinWorld, boolean perpendicularToLast, boolean collisionWithAll, boolean forceToGround, boolean forceVerticalToGround, 
  boolean forceX, boolean forceY, boolean forceZ, boolean connectToAny, boolean connectToLast) {
    SuperBlock thisBlock = new SuperBlock();
    AABB thisBox = thisBlock.myBox;
    int attempts = 0;
    while (attempts < maxAttempts) {
      attempts ++;
      boolean flag = true;
      Vec3D thisLocation = null;
      if (lastBlock != null) {
        thisLocation = getRandomWorldLocCenterGrid();
      } 
      else {
        thisLocation = Vec3D.ZERO.copy().add(new Vec3D(0, 0, mapDim.z/2));
      }
      thisBlock.setLocation(thisLocation);
      Vec3D thisDimension = rDimensionList[blockType].copy();
      thisDimension = shuffleVector(thisDimension);
      thisBlock.setDimension(thisDimension);
      if (flag && forceY) {
        if (!checkLinesParallel(thisBlock.myAxis, new Line3D(Vec3D.ZERO, Vec3D.Y_AXIS))) { 
          flag = false;
        }
      }  
      if (flag && forceZ) {
        if (!checkLinesParallel(thisBlock.myAxis, new Line3D(Vec3D.ZERO, Vec3D.Z_AXIS))) { 
          flag = false;
        }
      }  
      if (flag && forceX) {
        if (!checkLinesParallel(thisBlock.myAxis, new Line3D(Vec3D.ZERO, Vec3D.X_AXIS))) { 
          flag = false;
        }
      }  
      if (flag && forceVerticalToGround && lastBlock == null) {   // trick to make first part a leg  !!
        if (!checkLinesParallel(thisBlock.myAxis, new Line3D(Vec3D.ZERO, Vec3D.Z_AXIS))) {
          flag = false;
        }
      }
      if (flag && forceToGround) {
        thisBlock.setLocation(new Vec3D(thisLocation.x, thisLocation.y, thisBlock.dim.z/2));
      }
      if (flag && forceVerticalToGround) {
        if (checkLinesParallel(thisBlock.myAxis, new Line3D(Vec3D.ZERO, Vec3D.Z_AXIS))) {
          thisBlock.setLocation(new Vec3D(thisLocation.x, thisLocation.y, thisBlock.dim.z/2));
        }
      }
      if (flag && perpendicularToLast) {
        if (lastBlock != null) {
          if (checkLinesParallel(thisBlock.myAxis, lastBlock.myAxis)) {  // if lines are perpendicular (rotation is different) ...
            flag = false;
          }
        }
      }
      if (flag && (connectToLast || connectToAny)) {
        if (lastBlock != null) {
          thisBlock.calculatePoints(rForceCorner, rForceNextCorner, rForceCornerPerpendicular);
          if (thisBlock.joints.size() > 0) {
            Vec3D thisBlockJoint = thisBlock.joints.get((int)random(thisBlock.joints.size())).add(thisBlock.loc);
            SuperBlock otherBlock = lastBlock;
            if (connectToAny) {
              otherBlock = blockList.get((int)random(partList.size()-1));
              if (perpendicularToLast && checkLinesParallel(thisBlock.myAxis, otherBlock.myAxis)) {    /// should be perpendicular to any boolean
                flag = false;
              }
            }
            Vec3D otherBlockOption = otherBlock.options.get((int)random(otherBlock.options.size())).add(otherBlock.loc);
            Vec3D offset = thisBlockJoint.sub(otherBlockOption);   // this offset should only be horizontal (no z component if forced to ground!!!)
            if ((forceToGround || forceVerticalToGround) && offset.z != 0) {
              flag = false;
            } 
            else {
              thisBlock.setLocation(thisBlock.loc.sub(offset));
            }
          }
          else {
            println("error, can not connect, no joints on block");
            flag = false; // there are no joints on the block
          }
        }
      }
      if (flag && withinWorld) {
        if (!checkBoxWithinWorld(thisBox)) {
          flag = false;
        }
      }
      if (flag && collisionWithAll) {
        for (SuperBlock otherBlock : blockList) {
          if (thisBox.intersectsBox(otherBlock.myBox)) {
            flag = false;
            break;
          }
        }
      }
      if (flag) {
        thisBlock.calculatePoints(rForceCorner, rForceNextCorner, rForceCornerPerpendicular);
        thisBlock.material = rMaterialList[blockType];
        partList.add(thisBlock);
        blockList.add(thisBlock);
        lastBlock = thisBlock;
        break;
      }
    }
    if (attempts == maxAttempts) {
      printConsole("!error, could not add block ");
    } 
    else {
      printConsole("!tested "+nf(attempts, 4)+" block locations ");
    }
  }

  void display() {
    for (Part thisPart : partList) {
      thisPart.display();
    }

    if (details) {
      for (SuperPlane thisPlane : potentialPlaneList) {
        thisPlane.display();
      }
    }
  }

  void generateOriginal() {
    /*
    
     Vec3D armRestDim = new Vec3D(420, 90, 30);
     Vec3D backLegDim = new Vec3D(420, 30, 30);
     Vec3D armRestPostDim = new Vec3D(390, 30, 30);
     Vec3D longRailDim = new Vec3D(600, 30, 30);
     Vec3D frontLegDim = new Vec3D(300, 30, 30);
     Vec3D crossRailDim = new Vec3D(540, 30, 30);
     Vec3D backBattenDim = new Vec3D(600, 30, 30);
     Vec3D backDim = new Vec3D(300, 810, 12);
     Vec3D seatDim = new Vec3D(350, 430, 12);
     
     Vec3D armRestLocL = new Vec3D(-225, -108, backLegDim.x+15).add(loc);
     Vec3D armRestLocR = new Vec3D(225, -108, backLegDim.x+15).add(loc);
     
     Vec3D backLegLocL = new Vec3D(-225, -245, backLegDim.x/2).add(loc);
     Vec3D backLegLocR = new Vec3D(225, -245, backLegDim.x/2).add(loc);
     
     Vec3D armRestPostLocL = new Vec3D(-225, -95, armRestLocL.z-15-armRestPostDim.x/2).add(loc);
     Vec3D armRestPostLocR = new Vec3D(225, -95, armRestLocR.z-15-armRestPostDim.x/2).add(loc);
     
     Vec3D frontLegLocL = new Vec3D(-225, 265, frontLegDim.x/2).add(loc);
     Vec3D frontLegLocR = new Vec3D(225, 265, frontLegDim.x/2).add(loc);
     
     Vec3D longRailLocL = new Vec3D(-195, 10, 75).add(loc);
     Vec3D longRailLocR = new Vec3D(195, 10, 75).add(loc);
     
     Vec3D crossRailLocFU = new Vec3D(0, 265-30, frontLegDim.x-45).add(loc);
     Vec3D crossRailLocFD = new Vec3D(0, 265-30, longRailLocL.z+30).add(loc);
     Vec3D crossRailLocBU = new Vec3D(0, -95+30, 195).add(loc);
     Vec3D crossRailLocBD = new Vec3D(0, -95-30, 75+30).add(loc);
     
     Vec3D backBattenLoc = new Vec3D(0, -275, backLegDim.x-15).add(loc);
     
     Vec3D seatLoc = new Vec3D(0, 100, 250).add(loc);
     Vec3D backLoc = new Vec3D(0, -250, 425).add(loc);
     
     Block block = new Block();
     block.setLocation(armRestLocL);
     block.setDimension(armRestDim);
     block.setRotation(armRestRot);
     partList.add(block);
     
     block = new Block();
     block.setLocation(armRestLocR);
     block.setDimension(armRestDim);
     block.setRotation(armRestRot);
     partList.add(block);
     
     block = new Block();
     block.setLocation(backLegLocL);
     block.setDimension(backLegDim);
     block.setRotation(backLegRot);
     partList.add(block);
     
     
     block = new Block();
     block.setLocation(backLegLocR);
     block.setDimension(backLegDim);
     block.setRotation(backLegRot);
     partList.add(block);
     
     block = new Block();
     block.setLocation(armRestPostLocL);
     block.setDimension(armRestPostDim);
     block.setRotation(armRestPostRot);
     partList.add(block);
     
     block = new Block();
     block.setLocation(armRestPostLocR);
     block.setDimension(armRestPostDim);
     block.setRotation(armRestPostRot);
     partList.add(block);
     
     block = new Block();
     block.setLocation(frontLegLocL);
     block.setDimension(frontLegDim);
     block.setRotation(frontLegRot);
     partList.add(block);
     
     block = new Block();
     block.setLocation(frontLegLocR);
     block.setDimension(frontLegDim);
     block.setRotation(frontLegRot);
     partList.add(block);
     
     block = new Block();
     block.setLocation(longRailLocL);
     block.setDimension(longRailDim);
     block.setRotation(longRailRot);
     partList.add(block);
     
     block = new Block();
     block.setLocation(longRailLocR);
     block.setDimension(longRailDim);
     block.setRotation(longRailRot);
     partList.add(block);
     
     block = new Block();
     block.setLocation(crossRailLocFU);
     block.setDimension(crossRailDim);
     block.setRotation(crossRailRot);
     partList.add(block);
     
     block = new Block();
     block.setLocation(crossRailLocFD);
     block.setDimension(crossRailDim);
     block.setRotation(crossRailRot);
     partList.add(block);
     
     block = new Block();
     block.setLocation(crossRailLocBU);
     block.setDimension(crossRailDim);
     block.setRotation(crossRailRot);
     partList.add(block);
     
     block = new Block();
     block.setLocation(crossRailLocBD);
     block.setDimension(crossRailDim);
     block.setRotation(crossRailRot);
     partList.add(block);
     
     block = new Block();
     block.setLocation(backBattenLoc);
     block.setDimension(backBattenDim);
     block.setRotation(backBattenRot);
     partList.add(block);
     
     block = new Block();
     block.setLocation(backLoc);
     block.setDimension(backDim);
     block.setRotation(backRot);
     partList.add(block);
     
     block = new Block();
     block.setLocation(seatLoc);
     block.setDimension(seatDim);
     block.setRotation(seatRot);
     partList.add(block);
     */
  }
}

int taPointNum, taTubeR, taCornerR, taHeight, taTopRadius, taBottomRadius;
float tOffsetAngleX, tOffsetAngleY;
boolean taCrossRails;

class Vase extends Furniture {
  Pipe pipe;

  Vase () {
    reset();
    randomize();
    cx = 0;
    cy = 0;
    Group gTable = cp5.addGroup("vase").setPosition(columnx, marginy).hideBar();
    createSlider(gTable, "taPointNum", tTubeR, 2, 100, true, "number of legs");
    createSlider(gTable, "taTubeR", taTubeR, 1, 50, true, "tube radius");
    createSlider(gTable, "taCornerR", taCornerR, 2, 100, true, "tube bent radius");
    createSlider(gTable, "taHeight", taHeight, 50, 3000, true, "table height");
    createSlider(gTable, "taTopRadius", taTopRadius, 50, 1000, true, "top radius");
    createSlider(gTable, "taBottomRadius", taBottomRadius, 50, 1000, true, "bottom radius");
    createSlider(gTable, "tOffsetAngleX", tOffsetAngleX, 0, PI, true, "offset angle X");
    createSlider(gTable, "tOffsetAngleY", tOffsetAngleX, 0, PI, true, "offset angle Y");
    createToggle(gTable, "taCrossRails", taCrossRails, "cross rails");
    
    updateControllerList.add("taTubeR");
    updateControllerList.add("taCornerR");
    generateControllerList.add("taTopRadius");
    generateControllerList.add("taBottomRadius");
    generateControllerList.add("taHeight");
    generateControllerList.add("taPointNum");
    generateControllerList.add("tOffsetAngleY");
    generateControllerList.add("tOffsetAngleX");
    generateControllerList.add("taCrossRails");
  }

  void reset() {
    taPointNum = 10;
    taTubeR = 10;
    taCornerR = 20;
    taHeight = 700;
    taTopRadius = 500;
    taBottomRadius = 200;
    tOffsetAngleY = 0;
    tOffsetAngleX = 0;
    taCrossRails = true;
  }

  void generate() {
    partList = new ArrayList<Part>();
    pipe = new Pipe();
    float offsetAngle = 2*PI/(float)(taPointNum);
    for (int i = 0; i < taPointNum*2; i++) {
      float newPointZ = ( i%2 == 0 ? taHeight : 0);
      float newPointX, newPointY;
      if (!taCrossRails ) {
        newPointX = ( i%2 == 0 ? taTopRadius*(cos(tOffsetAngleX+(offsetAngle*i))) : taBottomRadius*(cos(offsetAngle*i)));
        newPointY = ( i%2 == 0 ? taTopRadius*(sin(tOffsetAngleY+(offsetAngle*i))) : taBottomRadius*(sin(offsetAngle*i)));
      } 
      else {
        newPointX = ( i%2 == 0 ? taTopRadius*(-cos(tOffsetAngleX+(offsetAngle*i))) : taBottomRadius*cos(offsetAngle*i));
        newPointY = ( i%2 == 0 ? taTopRadius*(sin(tOffsetAngleY+(offsetAngle*i))) : taBottomRadius*sin(offsetAngle*i));
      }
      Vec3D newPoint = new Vec3D(newPointX, newPointY, newPointZ);
      pipe.addPoint(newPoint.copy());
    }
    pipe.addPoint((Vec3D)pipe.pointList.get(0));
    pipe.cornerR = taCornerR;
    pipe.tubeR = taTubeR;
    pipe.material= "metal";
    partList.add(pipe);
    generated = true;
    validated = true;
  }

  void update() {
    pipe.cornerR = taCornerR;
    pipe.tubeR = taTubeR;
    for (Part thisPart : partList) {
      thisPart.update();
    }
  }

  void randomize() {
    //  taPointNum = 100;//3+(int)random(3);
    //  taTubeR = 5;
    //  taCornerR = 10;
    //  taHeight = 1000;//100+int(random(10))*50;
    taTopRadius = 100+int(random(500));
    taBottomRadius = 100+int(random(500));
    tOffsetAngleX = random(PI);
    tOffsetAngleY = random(PI);
    taCrossRails = (random(10)<5 ? true : false);
  }
}

////////////////////////////////////////////////////////////////////////////
//
// generates a parametric thonet chair
//
////////////////////////////////////////////////////////////////////////////


int tTubeR, tTubeSmallR;
float tChairZ, tSeatR, tSeatH, tDiscZratio, tSeatZratio, tFrontLegOffset, tBackLegOffset, tFrontLegA, tBackLegA, tBackRestA, tBackWratio, tBackYratio, tBackCurveZratio;
ToxicMesh thonetMesh;

class Thonet extends Furniture {
  Thonet () {
    reset();
    cx = 0;
    cy = 0;
    Group gThonet = cp5.addGroup("thonet").setPosition(columnx, marginy).hideBar();
    createSlider(gThonet, "tTubeR", tTubeR, 5, 50, true, "tube radius");
    createSlider(gThonet, "tTubeSmallR", tTubeSmallR, 2, 20, true, "small tube radius");
    createSlider(gThonet, "tChairZ", tChairZ, 200, 1400, true, "chair height");
    createSlider(gThonet, "tSeatR", tSeatR, 100, 300, true, "seat radius");
    createSlider(gThonet, "tSeatH", tSeatH, 10, 60, true, "seat height");
    createSlider(gThonet, "tSeatZratio", tSeatZratio, 0, 1, true, "seat height ratio");
    createSlider(gThonet, "tDiscZratio", tDiscZratio, 0, 1, true, "disc height ratio");
    createSlider(gThonet, "tFrontLegOffset", tFrontLegOffset, 0, 50, true, "front leg offset");
    createSlider(gThonet, "tBackLegOffset", tBackLegOffset, 0, 50, true, "backleg offset");
    createSlider(gThonet, "tBackWratio", tBackWratio, 20, 500, true, "back width");
 //   createSlider(gThonet, "tBackYratio", tBackYratio, 0, 1, true, "back depth ratio");
  //  createSlider(gThonet, "tBackCurveZratio", tBackCurveZratio, 0.5, .9, true, "back curve ratio");
    createSlider(gThonet, "tFrontLegA", tFrontLegA, 0, HALF_PI, true, "front leg angle");  
    createSlider(gThonet, "tBackLegA", tBackLegA, 0, HALF_PI, true, "back leg angle");
    createSlider(gThonet, "tBackRestA", tBackRestA, 0, HALF_PI, true, "back rest angle");
    cy += sh/2;
    createSlider(gThonet, "woodColor", metalColor, 0, 255, true, "wood color");

    generateControllerList.add("tTubeR");
    generateControllerList.add("tTubeSmallR");
    generateControllerList.add("tChairZ");
    generateControllerList.add("tSeatR");
    generateControllerList.add("tSeatH");
    generateControllerList.add("tDiscZratio");
    generateControllerList.add("tSeatZratio");
    generateControllerList.add("tFrontLegOffset");
    generateControllerList.add("tBackLegOffset");
    generateControllerList.add("tFrontLegA");
    generateControllerList.add("tBackLegA");
    generateControllerList.add("tBackRestA");
    generateControllerList.add("tBackWratio");
    generateControllerList.add("tBackYratio");
    generateControllerList.add("tBackCurveZratio");
  }

  void generate() {
    gridSize = 30;
    partList = new ArrayList<Part>();   // clear parts

    if (thonetMesh == null) {
//      thonetMesh = new ToxicMesh();
//      thonetMesh.loadMesh("Thonet14_m_binary.stl");
//      thonetMesh.setLocation(Vec3D.ZERO.copy());
//      thonetMesh.setMaterial("wood");
    }
//    partList.add(thonetMesh);

    float tFrontLegY =  loc.y+((tSeatR-tTubeR-5) * sin((PI/2)-tFrontLegA));
    float tFrontLegXR = loc.x+((tSeatR-tTubeR-5) * cos((PI/2)+tFrontLegA));
    float tFrontLegXL = loc.x+((tSeatR-tTubeR-5) * cos((PI/2)-tFrontLegA));

    float tBackLegY =  loc.y-((tTubeR+tSeatR) * sin((PI/2)+tBackLegA));
    float tBackLegXR = loc.x+((tTubeR+tSeatR) * cos((PI/2)+tBackLegA));
    float tBackLegXL = loc.x+((tTubeR+tSeatR) * cos((PI/2)-tBackLegA));

    //  float qBackRestY =  origin.y-((tubeSmallRadius+pSeatR) * sin((PI/2)+backRestAngle));
    //  float qBackRestXR = origin.x+((tubeSmallRadius+pSeatR) * cos((PI/2)+backRestAngle));
    //  float qBackRestXL = origin.x+((tubeSmallRadius+pSeatR) * cos((PI/2)-backRestAngle));

    float tBackY = tBackLegY - (tSeatR*tBackYratio);
    float tSeatZ = tChairZ * tSeatZratio;
    float tDiscR = tSeatR - (tTubeR*2);
    float tDiscZ = tSeatZ * tDiscZratio;
    float tDiscYoffset = (tTubeR*2);

    BezierTube backPiece = new BezierTube();
    backPiece.addPoint(new Vec3D(tBackLegXR-tBackLegOffset, tBackLegY-tBackLegOffset*3, loc.z), Vec3D.ZERO.copy(), Vec3D.Z_AXIS.copy().scaleSelf(20));  // leg R
    backPiece.addPoint(new Vec3D(tBackLegXR, tBackLegY, tDiscZ), Vec3D.Z_AXIS.copy().scaleSelf(100).getInverted(), Vec3D.ZERO.copy());  // disc R
    backPiece.addPoint(new Vec3D(tBackLegXR, tBackLegY, tSeatZ), Vec3D.ZERO.copy(), Vec3D.Z_AXIS.copy().scaleSelf(100));  // seat R
    backPiece.addPoint(new Vec3D(loc.x, tBackY, tChairZ), Vec3D.X_AXIS.copy().getInverted().scaleSelf(tBackWratio), Vec3D.X_AXIS.copy().scaleSelf(tBackWratio));    // top
    backPiece.addPoint(new Vec3D(tBackLegXL, tBackLegY, tSeatZ), Vec3D.Z_AXIS.copy().scaleSelf(100), Vec3D.Z_AXIS.copy().scaleSelf(25).getInverted());  // seat L
    backPiece.addPoint(new Vec3D(tBackLegXL, tBackLegY, tDiscZ), Vec3D.Z_AXIS.copy().scaleSelf(25), Vec3D.Z_AXIS.copy().scaleSelf(100).getInverted()); // disc L
    backPiece.addPoint(new Vec3D(tBackLegXL+tBackLegOffset, tBackLegY-tBackLegOffset*3, loc.z), Vec3D.Z_AXIS.copy().scaleSelf(20), Vec3D.ZERO.copy());  // leg L
    backPiece.setRadius(tTubeR);
    partList.add(backPiece);

    BezierTube frontLegR = new BezierTube();
    frontLegR.addPoint(new Vec3D(tFrontLegXR-tFrontLegOffset*.9, tFrontLegY+tFrontLegOffset*2.5, loc.z), Vec3D.ZERO.copy(), Vec3D.Z_AXIS.copy().scaleSelf(50)); 
    frontLegR.addPoint(new Vec3D(tFrontLegXR, tFrontLegY, tDiscZ), Vec3D.Z_AXIS.copy().scaleSelf(20).getInverted(), Vec3D.Z_AXIS.copy().scaleSelf(10));
    frontLegR.addPoint(new Vec3D(tFrontLegXR, tFrontLegY, tSeatZ), Vec3D.Z_AXIS.copy().scaleSelf(10).getInverted(), Vec3D.ZERO.copy());
    frontLegR.setRadius(tTubeR);
    partList.add(frontLegR);

    BezierTube frontLegL = new BezierTube();
    frontLegL.addPoint(new Vec3D(tFrontLegXL+tFrontLegOffset*.9, tFrontLegY+tFrontLegOffset*2.5, loc.z), Vec3D.ZERO.copy(), Vec3D.Z_AXIS.copy().scaleSelf(50)); 
    frontLegL.addPoint(new Vec3D(tFrontLegXL, tFrontLegY, tDiscZ), Vec3D.Z_AXIS.copy().scaleSelf(20).getInverted(), Vec3D.Z_AXIS.copy().scaleSelf(10));
    frontLegL.addPoint(new Vec3D(tFrontLegXL, tFrontLegY, tSeatZ), Vec3D.Z_AXIS.copy().scaleSelf(10).getInverted(), Vec3D.ZERO.copy());
    frontLegL.setRadius(tTubeR);
    partList.add(frontLegL);

    //  back rest
    //  mySpline = new Spline();
    //  float backRestZ = backZ-tubeSmallRadius-tubeRadius;
    //  mySpline.addHandle(new Vec3D(backRestXR, backRestY, seatZ));
    //  mySpline.addHandle(new Vec3D(origin.x-(seatRadius*backWidthRatio/2*.7), backY-((backY-backLegY)/2), backRestZ-((backRestZ-seatZ)*backZoffset)));
    //  mySpline.addHandle(new Vec3D(origin.x, backY, backRestZ ));
    //  mySpline.addHandle(new Vec3D(origin.x+(seatRadius*backWidthRatio/2*.7), backY-((backY-backLegY)/2), backRestZ-((backRestZ-seatZ)*backZoffset)));
    //  mySpline.addHandle(new Vec3D(backRestXL, backRestY, seatZ));
    //  mySpline.setRadius(tubeSmallRadius);
    //  partList.add(mySpline);

    Torus disc= new Torus();
    disc.setLocation(new Vec3D(loc.x, loc.y-tDiscYoffset, tDiscZ));
    disc.setRotation(new Vec3D(0, 0, HALF_PI));
    disc.setTubeRadius(tTubeSmallR);
    disc.setRadius(tDiscR);
    partList.add(disc);

    Cylinder seat = new Cylinder();
    seat.setLocation(new Vec3D(loc.x, loc.y, tSeatZ));
    seat.setRotation(new Vec3D(0, 0, HALF_PI));
    seat.setRadius(tSeatR);
    seat.setHeight(tSeatH);
    partList.add(seat);

    Torus seatBevel = new Torus();
    seatBevel.setLocation(new Vec3D(loc.x, loc.y, tSeatZ+tSeatH/2));
    seatBevel.setRotation(new Vec3D(0, 0, HALF_PI));
    seatBevel.setTubeRadius(5);
    seatBevel.setRadius(tSeatR-5);
    partList.add(seatBevel);

    validated = true;
    generated = true;
  }

  void reset() {
    tTubeR = 14;
    tTubeSmallR = 10;
    tChairZ = 956;
    tSeatR = 202;
    tSeatH = 41;
    tDiscZratio = .76;
    tSeatZratio = .495;
    tFrontLegOffset = 20;
    tBackLegOffset = 20;
    tFrontLegA = .8;
    tBackLegA = .62;
    tBackRestA = (PI/14);
    tBackWratio = 300;
    tBackYratio = .5;
    tBackCurveZratio = .75;
  }

  void randomize() {
    tChairZ = 300+random(800);
    tSeatR = 100+random(200);
    tSeatZratio = .4+random(.2);
    tDiscZratio = .6+random(.2);
    tBackWratio = 100+random(400);
    tBackYratio = .2+random(.5);
   // tBackCurveZratio = .2+random(.8);

    //    tTubeR = 14;
    //    tTubeSmallR = 10;
    //    tSeatH = 20;
    //    tFrontLegOffset = 20;
    //    tBackLegOffset = 40;
    //    tFrontLegA = .70;
    //    tBackLegA = .58;
    //    tBackRestA = (PI/14);
  }
}

String getTimeStamp() {

  return str(year()).substring(2, 4)+""+ nf(month(), 2)+""+ nf(day(), 2)+""+nf(hour(), 2)+""+nf(minute(), 2)+""+nf(second(), 2);
}

ArrayList<Vec3D> getPointsFromLine(Line3D thisLine, float thisStep, boolean includeFirstLast) {
  ArrayList<Vec3D> thisPointList = new ArrayList<Vec3D>();
  for (Vec3D thisPoint : thisLine.splitIntoSegments(null,thisStep,includeFirstLast)) {  
    if (!thisPoint.equals(thisLine.b) || includeFirstLast) { 
      thisPointList.add(thisPoint);
    }
  }
  return thisPointList;
}

void prepareNormalList() {
  normalList[0] = new Vec3D(0, 0, 1);
  normalList[1] = new Vec3D(0, 1, 0);
  normalList[2] = new Vec3D(1, 0, 0);
  normalList[3] = new Vec3D(0, 0, -1);
  normalList[4] = new Vec3D(0, -1, 0);
  normalList[5] = new Vec3D(-1, 0, 0);
}

Vec3D shuffleVector (Vec3D thisVector) {
  int i = (int)random(6);
  switch(i) {
  case 0:
    return (new Vec3D(thisVector.x, thisVector.y, thisVector.z));
  case 1:
    return (new Vec3D(thisVector.x, thisVector.z, thisVector.y));
  case 2:
    return (new Vec3D(thisVector.z, thisVector.x, thisVector.y));
  case 3:
    return (new Vec3D(thisVector.z, thisVector.y, thisVector.x));
  case 4:
    return (new Vec3D(thisVector.y, thisVector.x, thisVector.z));  
  case 5:
    return (new Vec3D(thisVector.y, thisVector.z, thisVector.x));
  }
  return null;
}

//Vec3D locateVector(Vec3D thisLoc, Vec3D thisRot, Vec3D thisOffset) {
//  Vec3D thisVector = thisOffset.copy();
//  thisVector.rotateZ(thisRot.z);
//  thisVector.rotateY(-thisRot.y);
//  thisVector.rotateX(-thisRot.x);
//  thisVector.addSelf(thisLoc.copy());
//  return( thisVector);
//}

Vec3D getRandomWorldLoc() {
  float thisX = random(mapDim.x)-mapDim.x/2;
  float thisY = random(mapDim.y)-mapDim.y/2;
  float thisZ = random(mapDim.z);
  return (new Vec3D(thisX, thisY, thisZ));
}

Vec3D getRandomWorldLocGrid() {
  int thisX = int(((int(random(mapDim.x))/gridSize)*gridSize)-mapDim.x/2);
  int thisY = int(((int(random(mapDim.y))/gridSize)*gridSize)-mapDim.y/2);
  int thisZ = int(((int(random(mapDim.z))/gridSize)*gridSize));
  return (new Vec3D(thisX, thisY, thisZ));
}

Vec3D getRandomWorldLocCenterGrid() {
  int thisX = int(((int(random(mapDim.x))/gridSize)*gridSize)-mapDim.x/2)+gridSize/2;
  int thisY = int(((int(random(mapDim.y))/gridSize)*gridSize)-mapDim.y/2)+gridSize/2;
  int thisZ = int(((int(random(mapDim.z))/gridSize)*gridSize))+gridSize/2;
  return (new Vec3D(thisX, thisY, thisZ));
}

boolean checkVectorWithinWorld(Vec3D thisVector) {
  return (thisVector.isInAABB(worldBox));
}

boolean checkBoxWithinWorld(AABB thisBox) {
  for (int j=0;j<6;j++) { 
    if (thisBox.intersectsBox(worldLimits[j])) {
      return false;
    }
  }
  return true;
}

boolean checkLineBlockListCollision(Line3D thisLine, ArrayList<SuperBlock> thisBlockList) {
  for (SuperBlock thisBlock : thisBlockList) {
    if (thisBlock.myBox.intersectsRay(thisLine.toRay3D(), 0, thisLine.getLength()) != null ) {
      return true;
    }
  }
  return false;
}

boolean checkLineBlockCollision(Line3D thisLine, SuperBlock thisBlock) {
  if (thisBlock.myBox.intersectsRay(thisLine.toRay3D(), 0, thisLine.getLength()) != null ) {
    return true;
  }
  return false;
}

boolean checkBoxesCollision(AABB boxA, AABB boxB) {
  return (boxA.intersectsBox(boxB));
}

boolean checkBlocksParallel(SuperBlock a, SuperBlock b) {
  if (a.rot.equals(b.rot) || a.rot.equals(b.rot.getInverted())) {
    return true;
  } 
  else {
    return false;
  }
}

boolean checkLinesParallel(Line3D a, Line3D b) {
  Vec3D aDir = a.getDirection();//.normalize();
  Vec3D bDir = b.getDirection();//.normalize();
  if (aDir.equals(bDir) || aDir.equals(bDir.getInverted())) {
    return true;
  } 
  else {
    return false;
  }
}

boolean checkLinesCoincident(Line3D a, Line3D b) {
  Line3D.LineIntersection closestLine = a.closestLineTo(b);
  if (closestLine.getType().equals(Line3D.LineIntersection.Type.valueOf("INTERSECTING"))) {
    // lines intersect at some point, so not parallel nor coincident
    return false;
  }
  else { 
    // lines are coincident or parallel
    Line3D midPointLine = new Line3D(a.getMidPoint(), b.getMidPoint());
    Vec3D midPointLineDirection = midPointLine.getDirection().normalize();
    float midPointLineLength = midPointLine.getLength();
    if (a.equals(b)  || a.getDirection().equals(midPointLineDirection) || a.getDirection().add(midPointLineDirection).isZeroVector() ) {
      // lines are equal or coincident
      return true;
    }
    else {
      // lines are parallel but not coincident
      return false;
    }
  }
}

boolean checkLinesCollision(Line3D a, Line3D b) {
  Line3D.LineIntersection closestLine = a.closestLineTo(b);
  if (closestLine.getType().equals(Line3D.LineIntersection.Type.valueOf("INTERSECTING"))) {
    // lines intersect
    float[] coefficients = closestLine.getCoefficients();
    if ((coefficients[0] > 0 && coefficients[0] < 1 && coefficients[1] > -1 && coefficients[1] < 0)) {
      // intersection point is inside segments
      return true; // true INTERSECTING: COLLISION
    }  
    else {
      // intersection point is outside segments
      return false;
    }
  }
  else { 
    // lines are coincident or parallel
    Line3D midPointLine = new Line3D(a.getMidPoint(), b.getMidPoint());
    Vec3D midPointLineDirection = midPointLine.getDirection().normalize();
    float midPointLineLength = midPointLine.getLength();
    if (a.equals(b)) {
      // lines are equal
      return true;
    } 
    else if (a.getDirection().equals(midPointLineDirection) || a.getDirection().add(midPointLineDirection).isZeroVector()) {
      // lines are parallel and coincident
      if (midPointLineLength < ((a.getLength()/2) + (b.getLength()/2))) {
        // lines are coincident and segments intersect
        return true;
      } 
      else {
        // lines are coincident but segments DO NOT intersect
        return false;
      }
    }
    else {
      // lines are parallel but not coincident
      return false;
    }
  }
}

boolean isOnScreen(Vec3D thisVector) {
  if (screenX(thisVector.x, thisVector.y) > -200 && screenX(thisVector.x, thisVector.y) < width+200 &&
    screenY(thisVector.x, thisVector.y) > -200 && screenY(thisVector.x, thisVector.y) < height+200) {
    return true;
  } 
  else {
    return false;
  }
}

void drawMarkerLine(Vec3D a, Vec3D b, float dotStepSize) {
  Line3D l = new Line3D(a, b);
  List<Vec3D> markerList =l.splitIntoSegments(null, dotStepSize, true) ; 
  for (Vec3D thisMarker : markerList) {
    drawMarker(thisMarker);
  }
}

void drawDottedLine(Vec3D a, Vec3D b, float dotStepSize) {
  Line3D l = new Line3D(a, b);
  List<Vec3D> markerList =l.splitIntoSegments(null, dotStepSize, true) ; 
  for (Vec3D thisMarker : markerList) {
    fx.point(thisMarker);
  }
}

void drawMarker(Vec3D pos) {
  fx.line(new Vec3D(pos.x-markerLength, pos.y, pos.z), new Vec3D(pos.x+markerLength, pos.y, pos.z));
  fx.line(new Vec3D(pos.x, pos.y-markerLength, pos.z), new Vec3D(pos.x, pos.y+markerLength, pos.z));
  fx.line(new Vec3D(pos.x, pos.y, pos.z-markerLength), new Vec3D(pos.x, pos.y, pos.z+markerLength));
}

void drawControlPoint(Vec3D pos) {
  strokeWeight(controlPointWeight);
  fx.point(pos);
}

void drawVectorOnPoint(Vec3D pos, Vec3D vector, float k) {
  beginShape();
  vertex(pos.x, pos.y, pos.z);
  vertex(pos.x + vector.x*k, pos.y + vector.y*k, pos.z + vector.z*k);
  endShape();
}


void drawLimits() {
  Vec3D aa = new Vec3D(-mapDim.x/2, -mapDim.y/2, 0);
  Vec3D bb = new Vec3D(mapDim.x/2, -mapDim.y/2, 0);
  Vec3D cc = new Vec3D(mapDim.x/2, mapDim.y/2, 0);
  Vec3D dd = new Vec3D(-mapDim.x/2, mapDim.y/2, 0);
  Vec3D ee = new Vec3D(-mapDim.x/2, -mapDim.y/2, mapDim.z);
  Vec3D ff = new Vec3D(mapDim.x/2, -mapDim.y/2, mapDim.z);
  Vec3D gg = new Vec3D(mapDim.x/2, mapDim.y/2, mapDim.z);
  Vec3D hh = new Vec3D(-mapDim.x/2, mapDim.y/2, mapDim.z);
  stroke(gridColor);
  strokeWeight(thinStroke);
  switch(gridMode) {
  case 0:
    fx.line(aa, bb);
    fx.line(bb, cc);
    fx.line(cc, dd);
    fx.line(dd, aa);    
    fx.line(ee, ff);
    fx.line(ff, gg);
    fx.line(gg, hh);
    fx.line(hh, ee);
    fx.line(aa, ee);
    fx.line(ff, bb);
    fx.line(gg, cc);
    fx.line(hh, dd);
    break;
  case 1:
    drawMarkerLine(aa, bb, gridSize);
    drawMarkerLine(bb, cc, gridSize);
    drawMarkerLine(cc, dd, gridSize);
    drawMarkerLine(dd, aa, gridSize);
    drawMarkerLine(ee, ff, gridSize);
    drawMarkerLine(ff, gg, gridSize);
    drawMarkerLine(gg, hh, gridSize);
    drawMarkerLine(hh, ee, gridSize);
    drawMarkerLine(aa, ee, gridSize);
    drawMarkerLine(ff, bb, gridSize);
    drawMarkerLine(gg, cc, gridSize);
    drawMarkerLine(hh, dd, gridSize);
    break;
  case 2:
    stroke(gridColor);
    strokeWeight(markerStroke);
    drawDottedLine(aa, bb, gridSize);
    drawDottedLine(bb, cc, gridSize);
    drawDottedLine(cc, dd, gridSize);
    drawDottedLine(dd, aa, gridSize);
    drawDottedLine(ee, ff, gridSize);
    drawDottedLine(ff, gg, gridSize);
    drawDottedLine(gg, hh, gridSize);
    drawDottedLine(hh, ee, gridSize);
    drawDottedLine(aa, ee, gridSize);
    drawDottedLine(ff, bb, gridSize);
    drawDottedLine(gg, cc, gridSize);
    drawDottedLine(hh, dd, gridSize);
    break;
  }
}

void drawGrid() {
  pushMatrix();
  stroke(gridColor);
  strokeWeight(thinStroke);
  for (float x=-mapDim.x/2;x<=mapDim.x/2; x = x+gridSize) {
    switch(gridMode) {
    case 0:
      if (x/gridSize%5 == 0) { 
        strokeWeight(2);
      } 
      else {
        strokeWeight(thinStroke);
      }
      line(x, -mapDim.y/2, x, mapDim.y/2);
      break;
    case 1:
      drawMarkerLine(new Vec3D(x, -mapDim.y/2, 0), new Vec3D(x, mapDim.y/2, 0), gridSize);
      break;
    case 2:
      drawDottedLine(new Vec3D(x, -mapDim.y/2, 0), new Vec3D(x, mapDim.y/2, 0), gridSize);
      break;
    }
  }
  for (float y=-mapDim.y/2;y<=mapDim.y/2; y = y+gridSize) {
    switch(gridMode) {
    case 0:
      if (y/gridSize%5 == 0) { 
        strokeWeight(2);
      } 
      else {
        strokeWeight(thinStroke);
      }
      line(-mapDim.x/2, y, mapDim.x/2, y);
      break;
    case 1:
      drawMarkerLine(new Vec3D(-mapDim.x/2, y, 0), new Vec3D(mapDim.x/2, y, 0), gridSize);
      break;
    case 2:
      drawDottedLine(new Vec3D(-mapDim.x/2, y, 0), new Vec3D(mapDim.x/2, y, 0), gridSize);
      break;
    }
  }
  popMatrix();
}


//Vec3D getTangentBetweenTwoPoint(Vec3D p1, Vec3D p2) {
//  Vec3D r = new Vec3D( 
//  p1.x-p2.x, 
//  p1.y-p2.y, 
//  p1.z-p2.z);
//  //r.normalize();
//  return r;
//}

//void drawArrowOnPoint(Vec3D pos, Vec3D vector, float k) {
//  pushMatrix();
//  float arrowsize = 6;
//  // Translate to location to render vector
//  //translate(loc.x,loc.y);
//  stroke(0);
//  strokeWeight(2);
//  // Call vector heading function to get direction (pointing up is a heading of 0)
// // rotate(v.heading2D());
//  // Calculate length of vector & scale it to be bigger or smaller if necessary
//  //float len = v.mag()*scayl;
//  // Draw three lines to make an arrow 
//  //line(0,0,len,0);
//  //line(len,0,len-arrowsize,+arrowsize/2);
// // line(len,0,len-arrowsize,-arrowsize/2);
//  popMatrix();
//}

//void drawLine2D(Vec2D s, Vec2D e) {
//  fx.line(s, e);
//}
// 
//void drawDottedLine2D(Vec2D s, Vec2D e, float dotStepSize) {
//  Line2D l = new Line2D(s, e);
//  fx.points2D(l.splitIntoSegments(null, dotStepSize, true));
//}
//
//
//import toxi.util.*;
//import java.awt.FileDialog;
//
//String selectFile () {
//   String path = FileUtils.showFileDialog(
//    frame,
//    "Select file",
//    dataPath(""),
//    new String[]{ ".tga",".png",".jpg",".stl" },
//    FileDialog.LOAD
//  );
//  // the path variable will be null if the user has cancelled
//  if (path != null) {
//    return path;
//    // get an descriptor for this base path
//    // this will analyse and identify the length of the sequence
//    // see javadocs for further details
//   // fsd=FileUtils.getFileSequenceDescriptorFor(path);
//   // println("start: "+fsd.getStartIndex()+" end: "+fsd.getFinalIndex());
//    // now ask descriptor for an iterator which will return
//    // absolute file paths for all images in this sequence in succession
//   // images=fsd.iterator();
//  }
//  else {
//    // quit if user cancelled dialog...
//    exit();
//  }
//}


Vec3D WE_Point3dToVec3D(WB_Point3d thisPoint) {
  return new Vec3D((float)thisPoint.x, (float)thisPoint.y, (float)thisPoint.z);
}


