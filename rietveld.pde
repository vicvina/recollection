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
    "black","black","black","black","black","red","blue"
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
          //  break;
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
            //  break;
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

