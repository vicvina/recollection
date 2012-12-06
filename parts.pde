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
  
  void update() {

  }

  void build() {
    if (myMesh != null) {
      addMesh(myMesh, material);
    }
  }

  void display() {
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

