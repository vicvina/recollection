////////////////////////////////////////////////////////////////////////////
//
//  parametric breuer collection with bent steel tube and leather strips
//
////////////////////////////////////////////////////////////////////////////


int bTubeR, bCornerR, bStepLength, bShortStepLength, bStepNum, bRatioShortSteps, bRatioFabric, bFabricThickness;

boolean bExtrudeFabric = true;

boolean bClosedPipe;

class Breuer extends Furniture {
  ArrayList<Line3D> segmentList; 
  //ArrayList<Line3D> closingSegmentList; 

  float tubeLength; 

  //ArrayList<Line3D> intersectionList;

  //  ArrayList<Line3D> usedSegmentList;
  ArrayList<Line3D> connectionList;
  ArrayList<Vec3D> connectorList; 

  ToxicMesh breuerMesh;
  Pipe pipe;
  Fabric myFabric;

  Breuer() {
    reset();
    cx = 0;
    cy = 0;
    Group gBreuer = cp5.addGroup("breuer").setPosition(columnx, marginy).hideBar();
    createSlider(gBreuer, "bStepNum", bStepNum, 1, 50, true, "number of steps");
    cy += sh/2;
    createToggle(gBreuer, "bClosedPipe", bClosedPipe, "closed pipe");
    cy += sh/2;
    createSlider(gBreuer, "bStepLength", bStepLength, 0, 12, true, "long step length");
    createSlider(gBreuer, "bShortStepLength", bShortStepLength, 1, 10, true, "short step length");
    createSlider(gBreuer, "bRatioShortSteps", bRatioShortSteps, 0, 10, true, "ratio long/short steps");
    cy += sh/2;
    createSlider(gBreuer, "bRatioFabric", bRatioFabric, 0, 100, true, "ratio strips");
    cy += sh/2;
    createSlider(gBreuer, "bTubeR", bTubeR, 5, 50, true, "tube radius");
    createSlider(gBreuer, "bCornerR", bCornerR, 10, 500, true, "corner radius");
    cy += sh/2;
    updateControllerList.add("bCornerR");
    updateControllerList.add("bTubeR");
    updateControllerList.add("bClosedPipe");
  }

  void reset () {
    bClosedPipe = false;
    bTubeR = 10;
    bCornerR = 60;
    bStepLength = 12;
    bShortStepLength = 4;
    bStepNum = 25;
    bRatioShortSteps = 2;
    bRatioFabric = 0;
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
    gridSize = 50;
    tubeLength = 0;
    partList = new ArrayList<Part>();
    segmentList =  new ArrayList<Line3D>();
    // closingSegmentList =  new ArrayList<Line3D>();
    // if (original) {
    //   if (breuerMesh == null) {
    //        breuerMesh = new ToxicMesh();
    //        breuerMesh.loadMesh("Breuer_m_binary.stl");
    //        breuerMesh.setLocation(new Vec3D(0, 0, -bTubeR));
    //        breuerMesh.setScale(1000);
    //        breuerMesh.offcenter = true;
    //        breuerMesh.material = "model";
    //        breuerMesh.update();
    //  }
    //      partList.add(breuerMesh);
    //  }

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
      pipe.addPoint(new Vec3D(stepLL/2, stepL/2, 0));
      pipe.addPoint(new Vec3D(stepLL/2, stepL/2, stepL));
      pipe.addPoint(new Vec3D(stepLL/2-stepS, stepL/2, stepL));
      pipe.addPoint(new Vec3D(stepLL/2-stepS, stepL/2, stepL-stepS));
      pipe.addPoint(new Vec3D(-stepLL/2+stepS, stepL/2, stepL-stepS));
      pipe.addPoint(new Vec3D(-stepLL/2+stepS, stepL/2, stepL));
      pipe.addPoint(new Vec3D(-stepLL/2, stepL/2, stepL));
      pipe.addPoint(new Vec3D(-stepLL/2, stepL/2, 0));
      pipe.addPoint(new Vec3D(-stepLL/2, 0, 0));

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
        tubeLength += newSegment.getLength();
      }
    }
    generateRandomPipe();
    generateFabrics();
    generated = true;
  }

  void generateRandomPipe() {
    pipe = new Pipe();
    validated = true;
    int[] lengthList = { 
      int(bShortStepLength * gridSize), int(bStepLength * gridSize)
    };
    Vec3D lastDirection = Vec3D.ZERO.copy();
    Vec3D lastPoint = loc.copy();
    pipe.addPoint(lastPoint.copy());
    for (int i=0;i<bStepNum;i++) {
      ArrayList<Vec3D> potentialPoints = new ArrayList<Vec3D>();
      ArrayList<Vec3D> potentialDirections = new ArrayList<Vec3D>();
      for (int j=0; j<normalList.length; j++) {
        Vec3D newDirection = normalList[j].copy(); // get  direction
        for (int k=0; k < lengthList.length; k++) {
          int newLength = lengthList[k]; // get length
          //   println(newDirection+" "+newLength);
          if (stepIsValid(lastPoint, lastDirection, newDirection, newLength)) {
            Vec3D newPoint = lastPoint.copy();
            newPoint.addSelf(newDirection.scale(newLength));
            potentialPoints.add(newPoint);
            potentialDirections.add(newDirection);
          }
        }
      }
      if (potentialPoints.size() > 0) {
        //// here we need to include ratio of short / long strips  !!!
        int randomPointNum = int(random(potentialPoints.size()));
        Vec3D newPoint = potentialPoints.get(randomPointNum);
        pipe.addPoint(newPoint.copy());
        Line3D newSegment = new Line3D(lastPoint, newPoint);
        segmentList.add(newSegment);
        tubeLength += newSegment.getLength();
        lastPoint = newPoint.copy();
        lastDirection = potentialDirections.get(randomPointNum);
      } 
      else { // we got stacked !
        validated = false;
        println("error");
      }
    }
    if (bClosedPipe) {
      validated = true;
      while (!lastPoint.equals(loc)) {   
        /// loop through all lentgth/direction combinations and keep good ones
        ArrayList<Vec3D> potentialPoints = new ArrayList<Vec3D>();
        ArrayList<Vec3D> potentialDirections = new ArrayList<Vec3D>();
        float bestDistance = lastPoint.distanceTo(loc);
        Vec3D bestDirection = null;
        Vec3D bestPoint = null;
        for (int i=0; i<normalList.length; i++) {
          for (int j=0; j< lengthList.length; j++) {
            Vec3D potentialDirection = normalList[i].copy();
            int stepLength = lengthList[j];
            if (stepIsValid(lastPoint, lastDirection, potentialDirection, stepLength)) {
              Vec3D potentialPoint = lastPoint.copy();
              potentialPoint.addSelf(potentialDirection.scale(stepLength));
              potentialPoints.add(potentialPoint.copy());   
              potentialDirections.add(potentialDirection.copy());
              float potentialDistance = potentialPoint.distanceTo(loc);
              if (bestDistance > potentialDistance) {
                bestPoint = potentialPoint.copy();
                bestDirection = potentialDirection.copy();
                bestDistance = potentialDistance;
              }
            }
          }
        }
        if (bestPoint == null) {  // no points get us closer to target :(
          if (potentialPoints.size() > 0) {  // check there are at least one potential point to try a different path
            int randomPoint = int(random(potentialPoints.size()));
            bestPoint = potentialPoints.get(randomPoint);
            bestDirection = potentialDirections.get(randomPoint);
          }
        }
        if (bestPoint != null) {  // ok we got a point !
          pipe.addPoint(bestPoint);
          Line3D newSegment = new Line3D(lastPoint, bestPoint);
          segmentList.add(newSegment);
          tubeLength += newSegment.getLength();
          // 
          //closingSegmentList.add(newSegment);
          lastDirection = bestDirection.copy();
          lastPoint = bestPoint.copy();
        } 
        else { // we got stacked :(
          validated = false;
          break;
        }
      }
    }
    if (pipe.pointList.size()>0) {
      printConsole("!"+tubeLength+" mm tube longitute in "+segmentList.size()+" segments ");
      partList.add(pipe);
      pipe.cornerR = bCornerR;
      pipe.tubeR = bTubeR;
      pipe.material = "metal";
    }
  }

  boolean stepIsValid(Vec3D lastPoint, Vec3D lastStepDirection, Vec3D stepDirection, float stepLength) {
    // check if direction is same or opposite
    if (stepDirection.equals(lastStepDirection)) { // || stepDirection.equals(lastStepDirection.getInverted()) ) {
      return false;
    } 
    Vec3D newPoint = lastPoint.copy();
    newPoint.addSelf(stepDirection.scale(stepLength));
    // check if new point is within boundaries
    if (!newPoint.isInAABB(worldBox)) {
      return false;
    } 
    // check intersections
    Line3D newSegment = new Line3D(lastPoint, newPoint);
    for (Line3D thisSegment : segmentList) {
      if (checkLinesCollision(newSegment, thisSegment)) {
        return false;
      }
    }
    return true;
  }

  void generateFabrics() {
    // usedSegmentList =  new ArrayList<Line3D>();
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
      for (Line3D thisSegment :segmentList) {
        stroke(color(0, 0, strokeColor), strokeAlpha);
        strokeWeight(thickStroke);
        fx.line(thisSegment);
      }

      //      for (Line3D thisSegment : segmentList) {
      //        for (Line3D otherSegment : segmentList) {
      //          stroke(color(0, 0, strokeColor), strokeAlpha);
      //          strokeWeight(thinStroke);
      //          if (!thisSegment.equals(otherSegment) && checkLinesCollision(thisSegment, otherSegment)) {
      //            stroke(color(strokeColor, 0, 0), strokeAlpha);
      //            strokeWeight(thickStroke);
      //            fx.line(thisSegment);
      //            fx.line(otherSegment);
      //          }
      //          fx.line(thisSegment);
      //        }
      //      }

      for (Line3D thisLine : connectionList) {
        stroke(color(strokeColor, 0, 0), strokeAlpha/2);
        strokeWeight(thinStroke);
        //  fx.line(thisLine);
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

