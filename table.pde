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

