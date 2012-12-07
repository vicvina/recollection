// geometry related functions
int pRotX;
int pRotY;
int pRotZ;

int pLocX;
int pLocY;
int pLocZ;

int worldX = 1200;
int worldY = 1200;
int worldZ = 700;
int gridSize = 50;

float tightness = .25;
int segmentRes = 8;
int curveRes = 8;
int cylinderRes = 8;
int sphereRes = 8;

int faceNum = 0;
int vertexNum = 0;
long lastOp;

AABB worldBox;
Vec3D mapDim = new Vec3D(worldX, worldY, worldZ);
AABB[] worldLimits = new AABB[6];
Vec3D[] normalList = new Vec3D[6];

boolean doRebuild = false;

ArrayList <Furniture> furnitureList;
ArrayList <Material> materialList;

class Material {
  HE_Mesh heMesh = null; // = new HE_Mesh();    // he_mesh 
  TriangleMesh toxicMesh = null; // = new TriangleMesh();    // toxic
  PShape shapeMesh;// = new PShape();
  PShape retained;// = createShape(TRIANGLES);
  String name;
  int fillColor;
  int alphaColor;
  boolean softMaterial;

  void updateMaterial() {
    shapeMesh = new PShape();
    if (toxicMesh != null || heMesh != null) {
      shapeMesh = meshToRetained(toxicMesh, heMesh, soft&&softMaterial);
    }
  } 

  PShape meshToRetained(Mesh3D toxicMesh, HE_Mesh heMesh, boolean smth) {        
    retained = createShape(TRIANGLES);
      retained.enableStyle();
    if (solid) {
      if (material) {
        retained.fill(fillColor, alphaColor);
      } 
      else {
        retained.fill(solidColor, solidAlpha);
      }
    } 
    else {
      retained.noFill();
    }
    if (wireframe) {
      retained.stroke(wireframeColor, wireframeAlpha);
    } 
    else {
      retained.noStroke();
    }
    retained.ambient(ambientLightColor, ambientLightColor, ambientLightColor);
    if (smth) {
      if (toxicMesh != null) {
        toxicMesh.computeVertexNormals();
        for (Face f : toxicMesh.getFaces()) {
          retained.normal(f.a.normal.x, f.a.normal.y, f.a.normal.z);
          retained.vertex(f.a.x, f.a.y, f.a.z);
          retained.normal(f.b.normal.x, f.b.normal.y, f.b.normal.z);
          retained.vertex(f.b.x, f.b.y, f.b.z);
          retained.normal(f.c.normal.x, f.c.normal.y, f.c.normal.z);
          retained.vertex(f.c.x, f.c.y, f.c.z);
        }
      }
      if (heMesh != null) {
        HE_Mesh triMesh = heMesh.get();
        triMesh.triangulate();
        HE_Face thisFace;
        for (Iterator<HE_Face> faceItr = triMesh.fItr(); faceItr.hasNext();) {
          thisFace = faceItr.next();
          HE_Halfedge he = thisFace.getHalfedge();
          HE_Vertex vx;
          do {
            vx = he.getVertex();
            WB_Normal3d vn = vx.getVertexNormal();
            retained.normal(vn.xf(), vn.yf(), vn.zf());
            retained.vertex(vx.xf(), vx.yf(), vx.zf());
            he = he.getNextInFace();
          } 
          while (he != thisFace.getHalfedge ());
        }
      }
    } 
    else {
      if (toxicMesh != null) {
        for (Face f : toxicMesh.getFaces()) {
          retained.normal(f.normal.x, f.normal.y, f.normal.z);
          retained.vertex(f.a.x, f.a.y, f.a.z);
          retained.vertex(f.b.x, f.b.y, f.b.z);
          retained.vertex(f.c.x, f.c.y, f.c.z);
        }
      }
      if (heMesh != null) {
        HE_Mesh triMesh = heMesh.get();
        triMesh.triangulate();
        HE_Face thisFace;
        for (Iterator<HE_Face> faceItr = triMesh.fItr(); faceItr.hasNext();) {
          thisFace = faceItr.next();
          HE_Halfedge he = thisFace.getHalfedge();
          HE_Vertex vx;
          WB_Normal3d vn = thisFace.getFaceNormal();
          retained.normal(vn.xf(), vn.yf(), vn.zf());
          do {
            vx = he.getVertex();
            retained.vertex(vx.xf(), vx.yf(), vx.zf());
            he = he.getNextInFace();
          } 
          while (he != thisFace.getHalfedge ());
        }
      }
    }
    retained.end();
    return retained;
  }
}

void addMesh(HE_Mesh thisMesh, String thisName) {
  for (Material thisMaterial : materialList) {
    if (thisMaterial.name == thisName) {
      if (thisMaterial.heMesh == null) { 
        thisMaterial.heMesh = new HE_Mesh();
      }
      thisMaterial.heMesh.add(thisMesh);
    }
  }
}

void addMesh(TriangleMesh thisMesh, String thisName) {
  for (Material thisMaterial : materialList) {
    if (thisMaterial.name == thisName) {
      if (thisMaterial.toxicMesh == null) {
        thisMaterial.toxicMesh = new TriangleMesh();
      }
      thisMaterial.toxicMesh.addMesh(thisMesh);
    }
  }
}


Material getMaterial(String thisName) {
  for (Material thisMaterial : materialList) {
    if (thisMaterial.name == thisName) {
      return thisMaterial;
    }
  }
  return null;
}

void updateMaterials() {
  for (Material thisMaterial : materialList) {
    thisMaterial.updateMaterial();
  }
}

void initMaterials() {
  materialList = new ArrayList();
  addMaterial("model", 200, 255, false);
  addMaterial("metal", 255, 255, true);
  addMaterial("leather", 50, 255, false);
  addMaterial("geometry", 200, 255, false);
  addMaterial("wood", 150, 255, false);
  addMaterial("white", 255, 255, false);
  addMaterial("grey", 150, 255, false);
  addMaterial("black", 50, 255, false);
  addMaterial("red", color(200, 0, 0), 255, false);
  addMaterial("blue", color(0, 0, 200), 255, false);
  addMaterial("green", 200, 255, false);
  addMaterial("yellow", color(240, 240, 0), 255, false);
  addMaterial("glass", 255, 100, true);
}

void addMaterial(String thisName, int thisColor, int thisAlpha, boolean thisSoft) {
  Material newMaterial = new Material();
  newMaterial.name = thisName;
  newMaterial.fillColor = thisColor;
  newMaterial.alphaColor = thisAlpha;
  newMaterial.softMaterial = thisSoft;
  materialList.add(newMaterial);
}

void initGeometry() {
  prepareNormalList();
  initMaterials();
  updateWorld();
  furnitureList = new ArrayList<Furniture>();   

  Furniture radiolaria = new Radiolaria();
  radiolaria.name ="radiolaria";
  furnitureList.add(radiolaria);

//  Furniture jewel = new Jewel();
//  jewel.name ="jewel";
//  furnitureList.add(jewel);
//
//  Furniture breuer = new Breuer();
//  breuer.name ="breuer";
//  furnitureList.add(breuer);
//
//  Furniture rietveld = new Rietveld();
//  rietveld.name ="rietveld";
//  furnitureList.add(rietveld);
//
//  Furniture lack = new Lack();
//  lack.name ="lack";
//  furnitureList.add(lack);
////
////  Furniture thonet = new Thonet();
////  thonet.name ="thonet";
////  furnitureList.add(thonet);
////
//  Furniture vase = new Vase();
//  vase.name ="vase";
//  furnitureList.add(vase);
//
//  Furniture castiglioni = new Castiglioni();
//  castiglioni.name ="castiglioni";
//  furnitureList.add(castiglioni);

  updateWorld();
  generateGeometry();
  updateGeometry();
  buildGeometry();
}

void changeCollection () {
  furniture ++ ;
  if (furniture == furnitureList.size()) furniture = 0;
  updateWorld();
  if (!furnitureList.get(furniture).generated) {
    generateGeometry();
  }
  updateGeometry();
  //  buildGeometry();
}

void resetGeometry() {
  furnitureList.get(furniture).reset();
  generateGeometry();
  updateGeometry();
  //buildGeometry();
}

void randomGeometry() {
  furnitureList.get(furniture).randomize();
  generateGeometry();
  updateGeometry();
  // buildGeometry();
}

void generateGeometry() {
  //gridSize = furnitureList.get(furniture).gridSize;
  long startTime = millis();
  furnitureList.get(furniture).generate();
  lastOp = millis() - startTime;
}

boolean isGeometryValidated() {
  if (furnitureList.get(furniture).validated) {
    return true;
  }
  return false;
}

void updateGeometry() {
  furnitureList.get(furniture).update();
  doRebuild = true;
}

void buildGeometry() {
  if (solid || wireframe) {
    for (Material thisMaterial : materialList) {
      thisMaterial.toxicMesh = null; //.clear();
      thisMaterial.heMesh = null; //clear();
    }
    furnitureList.get(furniture).build();
    doRebuild = false;
    faceNum = 0;
    vertexNum = 0;
    for (Material thisMaterial : materialList) {
      if (thisMaterial.toxicMesh != null) {
        faceNum += thisMaterial.toxicMesh.getNumFaces();
        vertexNum += thisMaterial.toxicMesh.getNumVertices();
      }
    }
    updateMaterials();
  } 
  else {
    doRebuild = true;
  }
}

void displayGeometry() {
  if (ground) {
    pushMatrix();
    translate(0, 0, -.1);
    if (furnitureList.get(furniture).name.equals("breuer")) {   
      translate(0, 0, -bTubeR);
    }
    noStroke();
    fill(groundColor);
    rect(-mapDim.x/2, -mapDim.y/2, mapDim.x, mapDim.y);
    popMatrix();
  }
  if (grid) {
    pushMatrix();
    if (furnitureList.get(furniture).name.equals("breuer")) {   
      translate(0, 0, -bTubeR);
    }
    drawGrid();
    popMatrix();
  }
  if (axis) {
    strokeWeight(thinStroke);
    fx.origin(100);
  }
  if (limits) {
    drawLimits();
  }

  if (light) {
    ambientLight(ambientLightColor, ambientLightColor, ambientLightColor);
    directionalLight(directionalLightColor, directionalLightColor, directionalLightColor, 0, -.4, -.4); 
    directionalLight(200, 200, 200, 0, .3, -.3);
  } 
  else {
    noLights();
  }

  if (!furnitureList.get(furniture).generated) {
    furnitureList.get(furniture).generate();
    doRebuild = true;
  }

  if (dots || structure || filled || details || original) {
    furnitureList.get(furniture).display();
  }

  if (wireframe || solid) {
    if (doRebuild) {
      buildGeometry();
    }
    for (Material thisMaterial : materialList) {
      shape(thisMaterial.shapeMesh);
    }
  }
} 

void updateWorld() {
  worldBox = new AABB(new Vec3D(0, 0, mapDim.z/2), mapDim.scale(.5));
  worldLimits[0] = new AABB(new Vec3D(0, 0, -gridSize/2), new Vec3D(mapDim.x/2, mapDim.y/2, gridSize/2));
  worldLimits[1] = new AABB(new Vec3D(0, 0, mapDim.z+gridSize/2), new Vec3D(mapDim.x/2, mapDim.y/2, gridSize/2));
  worldLimits[2] = new AABB(new Vec3D(mapDim.x/2+gridSize/2, 0, mapDim.z/2), new Vec3D(gridSize/2, mapDim.y/2, mapDim.z/2));
  worldLimits[3] = new AABB(new Vec3D(-mapDim.x/2-gridSize/2, 0, mapDim.z/2), new Vec3D(gridSize/2, mapDim.y/2, mapDim.z/2));
  worldLimits[4] = new AABB(new Vec3D(0, mapDim.y/2+gridSize/2, mapDim.z/2), new Vec3D(mapDim.x/2, gridSize/2, mapDim.z/2));
  worldLimits[5] = new AABB(new Vec3D(0, -mapDim.y/2-gridSize/2, mapDim.z/2), new Vec3D(mapDim.x/2, gridSize/2, mapDim.z/2));
}

void saveSTL() {
  printConsole("saved model at "+nf(hour(), 2)+":"+nf(minute(), 2)+":"+nf(second(), 2)+";");
  for (Material thisMaterial : materialList) {
    TriangleMesh thisMesh = thisMaterial.toxicMesh;
    if (thisMesh.getNumFaces() > 0) {
      thisMesh.computeFaceNormals();
      thisMesh.saveAsSTL(sketchPath("")+"/models/"+getTimeStamp()+"_"+furnitureList.get(furniture).name+"_"+thisMaterial.name+".stl");
    }
  }
}

class Furniture {
  List <Part> partList = new ArrayList<Part>();  
  Vec3D loc = Vec3D.ZERO.copy();
  Vec3D rot = Vec3D.ZERO.copy();
  String name;

  boolean generated = false;
  boolean validated = false;

  void reset() {
  }

  void randomize() {
  }

  void generate() {
  }

  void update() {
    for (Part thisPart : partList) {
      thisPart.update();
    }
  }

  void display() {
    for (Part thisPart : partList) {
      thisPart.display();
    }
  }

  void build() {
    for (Part thisPart : partList) {
      thisPart.build();
    }
  }

  void setLocation (ReadonlyVec3D loc) {
    this.loc = loc.copy();  // not yet implementedx1
  }

  void setRotation(ReadonlyVec3D rot) {
    this.rot = rot.copy();  // not yet implemented
  }
}

