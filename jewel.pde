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
    // createSlider(gJewel, "jPlateThickness", jPlateThickness, 1, 100, true, "plate thickness");
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

  void display() {

    if (structure) {
       stroke(strokeColor, strokeAlpha);
        render.drawEdges(myShape);
    }


    if (filled) {
      fill(fillColor, fillAlpha);
      render.drawFaces(myShape);
    }

    if (structure) {
      //stroke(redColor, strokeAlpha);
      //  render.drawVertex(myShape);
    }
    for (Part thisPart : partList) {
      thisPart.update();
    }
  }

  void update() {
    //    pipe.cornerR = taCornerR;
    //    pipe.tubeR = taTubeR;
    for (Part thisPart : partList) {
      thisPart.update();
    }
  }

  void randomize() {
  }
}

