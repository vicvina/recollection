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
      thonetMesh = new ToxicMesh();
      thonetMesh.loadMesh("Thonet14_m_binary.stl");
      thonetMesh.setLocation(Vec3D.ZERO.copy());
      thonetMesh.setMaterial("wood");
    }
    partList.add(thonetMesh);

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

