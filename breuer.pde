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
        breuerMesh = new ToxicMesh();
        breuerMesh.loadMesh("Breuer_m_binary.stl");
        breuerMesh.setLocation(new Vec3D(0, 0, -bTubeR));
        breuerMesh.setScale(1000);
        breuerMesh.offcenter = true;
        breuerMesh.material = "model";
        breuerMesh.update();
      }
      partList.add(breuerMesh);
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

