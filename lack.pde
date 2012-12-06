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

