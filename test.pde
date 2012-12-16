int tNum = 100;

class Test extends Furniture {
  ArrayList<Line3D> segmentList; 
  ArrayList<Line3D> closingSegmentList; 


  Test () {
    gridSize = 50;
    Group gTest = cp5.addGroup("test").setPosition(columnx, marginy).hideBar();
    createSlider(gTest, "tNum", tNum, 0, 500, true, "number of steps");
  }


  void generate() {

    partList = new ArrayList<Part>();
    segmentList =  new ArrayList<Line3D>();
    for (int i=0;i<tNum;i++) {
      int attempts = 0;
      while (attempts < 5000) {
        Vec3D segmentDirection = normalList[(int)random(6)].copy(); // get random direction
        float segmentLength = random(10) > 5 ? int(3 * gridSize) : int(9*gridSize);
        Vec3D thisA = getRandomWorldLocGrid();
        Vec3D thisB = thisA.copy();
        thisB.addSelf(segmentDirection.scale(segmentLength));
        if (thisB.isInAABB(worldBox)) {
          Line3D newSegment = new Line3D(thisA, thisB);
          boolean flag = false;
          for (Line3D otherSegment : segmentList) {
            if (checkLinesCollision(newSegment, otherSegment)) {
              flag = true;
              break;
            }
          }
          if (flag || segmentList.size() == 0) {
            segmentList.add(newSegment);
            break;
          }
        }
      } 
      attempts ++;
    }
    // totalAttempts += attempts;
    generated = true;
  }

  void display() {
    for (Line3D thisSegment : segmentList) {
      //  println(thisSegment);

      stroke(color(0, 0, strokeColor), strokeAlpha);
      strokeWeight(thinStroke);
     // for (Line3D otherSegment : segmentList) {

        //if (!thisSegment.equals(otherSegment) && checkLinesCoincident(thisSegment, otherSegment)) {
          //  stroke(color(random(255), random(255), random(255)), strokeAlpha);
      //    stroke(redColor, 100);
      //    strokeWeight(thickStroke);
          // fx.line(thisSegment);
       //   fx.line(otherSegment);
          strokeWeight(thinStroke);

          stroke(blueColor, 50);

          fx.line(thisSegment);
       // }
//        else {
//            fx.line(thisSegment);
//        }
      //}
    }
  }
}

