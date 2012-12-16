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
  //  if (a.equals(b) || a.equals(b.getInverted())) {
  //    return true;
  //  }
  if (!checkLinesParallel(a, b)) {
    return false;
  }
  // lines are coincident or parallel
  Line3D midPointLine = new Line3D(a.getMidPoint(), b.getMidPoint());
  Vec3D midPointLineDirection = midPointLine.getDirection().normalize();
  float midPointLineLength = midPointLine.getLength();
  //

  //println(a.getDirection()+" "+b.getDirection()+" "+midPointLineDirection+" "+       midPointLineDirection.getInverted());  
  if (a.getDirection().equals(midPointLineDirection.getInverted()) ) {

    // lines are equal or coincident
    return true;
  }
  else {
    // lines are parallel but not coincident
    return false;
  }
}

boolean checkLinesCollision(Line3D a, Line3D b) {
  Vec3D aDir = a.getDirection();
  Vec3D bDir = b.getDirection();
  if (!aDir.equals(bDir) && !aDir.equals(bDir.getInverted())) {
    Line3D.LineIntersection closestLine = a.closestLineTo(b);
    // if (closestLine.getType().equals(Line3D.LineIntersection.Type.valueOf("INTERSECTING"))) {
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
    if (a.equals(b) || a.getMidPoint().equals(b.getMidPoint())) {
      // lines are equal or have same center !! important otherwise following conditions are not valid !!!
      return true;
    } 
    else if (a.getDirection().equals(midPointLineDirection) || a.getDirection().equals(midPointLineDirection.getInverted())) {
      // lines are parallel and coincident
      if (midPointLineLength < ((a.getLength()/2) + (b.getLength()/2))) {   // is this fucking working ???
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

//boolean checkLinesCollisionBis(Line3D a, Line3D b) {
//  Line3D.LineIntersection closestLine = a.closestLineTo(b);
//  if (closestLine.getType().equals(Line3D.LineIntersection.Type.valueOf("INTERSECTING"))) {
//    // lines intersect
//    float[] coefficients = closestLine.getCoefficients();
//    if ((coefficients[0] > 0 && coefficients[0] < 1 && coefficients[1] > -1 && coefficients[1] < 0)) {
//      // intersection point is inside segments
//      println("collision intersecting");
//      return true; // true INTERSECTING: COLLISION
//    }  
//    else {
//      // intersection point is outside segments
//      return false;
//    }
//  }
//  else { 
//    // lines are coincident or parallel
//    Line3D midPointLine = new Line3D(a.getMidPoint(), b.getMidPoint());
//    Vec3D midPointLineDirection = midPointLine.getDirection();
//    float midPointLineLength = midPointLine.getLength();
////    if (a.equals(b)) {
////      // lines are equal
////      return true;
////    } 
//     if (a.getDirection().equals(midPointLineDirection) || a.getDirection().equals(midPointLineDirection.getInverted())) {
//      // lines are parallel and coincident
//      if (midPointLineLength < ((a.getLength()/2) + (b.getLength()/2))) {
//        // lines are coincident and segments intersect
//        // println("coincident intersection");
//        return true;
//      } 
//      else {
//        // lines are coincident but segments DO NOT intersect
//        // println("coincident not intersection");
//        return false;
//      }
//    }
//    else {
//      // lines are parallel but not coincident
//      return false;
//    }
//  }
//}



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

