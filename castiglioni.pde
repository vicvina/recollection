int caBulbScale, caRadius, caSphereRadius;
float caBulbRadiusOffset, caBulbFaceOffset;
int caPlateThickness, caChamferDistance;
int caStructureType;

//int glassAlpha = 100, glassColor = 240;

class Castiglioni extends Furniture {
  ArrayList<ToxicMesh> plateList;
  ArrayList<Bulb> bulbList;

  TriangleMesh bulbMesh;
  HE_Mesh structureMesh;

  Castiglioni () {
    reset();
    cx = 0;
    cy = 0;
    Group gCastiglioni = cp5.addGroup("castiglioni").setPosition(columnx, marginy).hideBar();
    createSlider(gCastiglioni, "caStructureType", caStructureType, 0, 4, true, "polyhedron type");
    createSlider(gCastiglioni, "caRadius", caRadius, 0, 500, true, "lamp radius");
    createSlider(gCastiglioni, "caSphereRadius", caSphereRadius, 0, 500, true, "bulb radius");
    createSlider(gCastiglioni, "caBulbRadiusOffset", caBulbRadiusOffset, 0, 200, true, "bulb radial offset");
    createSlider(gCastiglioni, "caBulbFaceOffset", caBulbFaceOffset, 0, 1, true, "bulb lateral offset");
    createSlider(gCastiglioni, "caPlateThickness", caPlateThickness, 0, 20, true, "plate thickness");
    createSlider(gCastiglioni, "caChamferDistance", caChamferDistance, 0, 20, true, "chamfer distance");
    cy += sh/2;
    // createSlider(gCastiglioni, "metalColor", metalColor, 0, 255, true, "metal color");
   // createSlider(gCastiglioni, "glassAlpha", glassAlpha, 0, 255, true, "glass alpha");
   // createSlider(gCastiglioni, "glassColor", glassColor, 0, 255, true, "glass color");

    updateControllerList.add("caSphereRadius");
    generateControllerList.add("caStructureType");
    generateControllerList.add("caRadius");
    generateControllerList.add("caPlateThickness");
    generateControllerList.add("caChamferDistance");
    generateControllerList.add("caBulbOffset");
    generateControllerList.add("caBulbRadiusOffset");
    generateControllerList.add("caBulbFaceOffset");
  }

  void reset() {
    caStructureType = 0;
    caChamferDistance = 10;
    caPlateThickness = 5;
    caRadius = 300;
    caSphereRadius = 68;
    caBulbRadiusOffset = 90;
    caBulbFaceOffset = .50;
  }

  void generate() {
    partList = new ArrayList<Part>();
    bulbList = new ArrayList<Bulb>();

    switch(caStructureType) {
    case 0:
      HEC_Box creator0 = new HEC_Box().setHeight(caRadius).setWidth(caRadius).setDepth(caRadius);
      structureMesh=new HE_Mesh(creator0);
      break;

    case 1:
      HEC_Tetrahedron creator1=new HEC_Tetrahedron();
      creator1.setEdge(caRadius);// radius of sphere circumscribing cube
      structureMesh=new HE_Mesh(creator1);
      break;
    case 2:
      HEC_Octahedron creator2=new HEC_Octahedron();
      creator2.setEdge(caRadius);// radius of sphere circumscribing cube
      structureMesh=new HE_Mesh(creator2);
      break;
    case 3:
      HEC_Icosahedron creator3=new HEC_Icosahedron();
      creator3.setEdge(caRadius);// radius of sphere circumscribing cube
      structureMesh=new HE_Mesh(creator3);
      break;
    case 4:
      HEC_Dodecahedron creator4=new HEC_Dodecahedron();
      creator4.setEdge(caRadius);// radius of sphere circumscribing cube
      structureMesh=new HE_Mesh(creator4);
      break;
    }
    //alternatively 
    //creator.setInnerRadius(200);// radius of sphere inscribed in cube
    //creator.setMidRadius(200);// radius of sphere tangential to edges

    // loop for every face, create bulbs and plates
    HE_Face[] faceList =  ((HE_MeshStructure)structureMesh).getFacesAsArray();
    for (int i=0;i< faceList.length; i ++) {
      HE_Face thisFace = faceList[i];
      Vec3D thisCenter =  WE_Point3dToVec3D(thisFace.getFaceCenter());
      Vec3D thisNormal = WE_Point3dToVec3D(thisFace.getFaceNormal()).normalize();
      List<HE_Vertex> verticesList = thisFace.getFaceVertices();
      // bulbs
      for (int j=0;j<verticesList.size();j++) {
        Vec3D thisVertex = WE_Point3dToVec3D(verticesList.get(j));
        Line3D newLine = new Line3D(thisVertex, thisCenter);
        Vec3D thisDirection = newLine.getDirection();
        Vec3D thisLocation = thisVertex.add(thisDirection.scale(newLine.getLength()*caBulbFaceOffset).add(thisNormal.scale(caBulbRadiusOffset)));
        addBulb(thisLocation, new Line3D(thisLocation, thisLocation.add(thisNormal)));
      }
      // plates
      //  List<HE_Vertex> thisFaceVertices = thisFace.getFaceVertices();
      int vertexNum = verticesList.size();
      WB_Point3d[] basepoints= new WB_Point3d[vertexNum];
      for (int j=0;j<vertexNum;j++) {
        basepoints[j] = verticesList.get(j);
      }
      WB_Polygon polygon=new WB_ExplicitPolygon(basepoints, vertexNum);
      HEC_Polygon polygonCreator=new HEC_Polygon();
      polygonCreator.setPolygon(polygon);//alternatively polygon can be a WB_Polygon2D
      polygonCreator.setThickness(caPlateThickness);// thickness 0 creates a surface
      HEM_ChamferCorners chamferModifier = new HEM_ChamferCorners().setDistance(caChamferDistance);
      HE_Mesh faceMesh=new HE_Mesh(polygonCreator);
      faceMesh.modify(chamferModifier);

      ToxicMesh plate = new ToxicMesh();
      plate.setMesh(toxi.toToxi(hemesh.fromHemesh(faceMesh)));

      plate.setMaterial("metal");
      plate.setScale(1);
      plate.update();
      partList.add(plate);
    }
    validated = true;
    generated = true;
  }

  void addBulb(Vec3D thisLocation, Line3D thisAxis) {
    Bulb bulb = new Bulb();
    bulb.setLocation(thisLocation);
    bulb.sphereRadius = caSphereRadius;
    bulb.setAxis(thisAxis);
    bulb.setMaterial("glass");
    partList.add(bulb);
    bulbList.add(bulb);
  }

  void display() {
    if (structure) {
      strokeWeight(thickStroke);
      stroke(greenColor, strokeAlpha);
      render.drawEdges(structureMesh);
    }
    for (Part thisPart : partList) {
      thisPart.display();
    }
  }

  void update() {
    for (Bulb thisBulb : bulbList) {
      thisBulb.sphereRadius = caSphereRadius;
    }
    for (Part thisPart : partList) {
      thisPart.update();
    }
  }
}

