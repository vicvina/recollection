float raRatio = 1;
int raPointNum = 90;
int raRadius = 500;
float raa1 = 1;
float rab1 = 1;
float ram1 = 3;
float ran11 = 1;
float ran21 = 1;
float ran31 = 2;

float raa2 = 1;
float rab2 = 1;
float ram2 = 3;
float ran12 = 1;
float ran22 = 1;
float ran32 = 2;

String raMaterial = "red";
boolean raAnimate = true;

class Radiolaria extends Furniture {

  Vec2D[] superFormulaPoints;
  Vec3D[][] superShapePoints;


  ToxicMesh myMesh;

  Radiolaria () {
    reset();
    //  randomize();
    cx = 0;
    cy = 0;
    Group gRadiolaria = cp5.addGroup("radiolaria").setPosition(columnx, marginy).hideBar();
    createSlider(gRadiolaria, "raRadius", raRadius, 0, 500, true, "radius");
    createSlider(gRadiolaria, "raPointNum", raPointNum, 12, 180, true, "detail"); //.plugTo(this);

    //createSlider(gRadiolaria, "raStep", raStep, 256, 180, true, "detail");
    //    
    //    Slider s = cp5.addSlider("raPointNum", 0, 50, cx, cy, guix, guiy).setGroup("radiolaria");
    //    //
    //    s.plugTo(this, "raPointNum");
    //      s.setLabel("point num").setAutoUpdate(true); // .setDecimalPrecision(1).setSliderMode(Slider.FIX)  // .showTickMarks(true).setNumberOfTickMarks(11).setColorTickMark(activeColor).snapToTickMarks(false)
    //  controlP5.Label l = s.captionLabel();
    //  l.toUpperCase(false);
    //  l.style().marginLeft = 2;
    //  cy+= sh;
    //  //return s;



    cy += sh/2;

    createToggle(gRadiolaria, "raAnimate", raAnimate, "animate");
    createSlider(gRadiolaria, "raRatio", raRatio, 0, 2, true, "growth");

    createSlider(gRadiolaria, "raa1", raa1, 1, 20, true, "a1");
    createSlider(gRadiolaria, "rab1", rab1, 1, 20, true, "b1");
    createSlider(gRadiolaria, "ram1", ram1, 1, 20, true, "m1");
    createSlider(gRadiolaria, "ran11", ran11, 1, 20, true, "n11");
    createSlider(gRadiolaria, "ran21", ran21, 1, 20, true, "n21");
    createSlider(gRadiolaria, "ran31", ran31, 1, 20, true, "n31");
    cy += sh/2;
    createSlider(gRadiolaria, "raa2", raa2, 1, 20, true, "a2");
    createSlider(gRadiolaria, "rab2", rab2, 1, 20, true, "b2");
    createSlider(gRadiolaria, "ram2", ram2, 1, 20, true, "m2");
    createSlider(gRadiolaria, "ran12", ran12, 1, 20, true, "n12");
    createSlider(gRadiolaria, "ran22", ran22, 1, 20, true, "n22");
    createSlider(gRadiolaria, "ran32", ran32, 1, 20, true, "n32");

    String[] materialNames = new String[materialList.size()];
    for (int i=0;i<materialList.size();i++) {
      Material thisMaterial = materialList.get(i);
      materialNames[i] = thisMaterial.name;
    }
    createDropdownList(gRadiolaria, "materials", materialNames);

    generateControllerList.add("raa1");
    generateControllerList.add("rab1");
    generateControllerList.add("ram1");
    generateControllerList.add("ran11");
    generateControllerList.add("ran21");
    generateControllerList.add("ran31");
    generateControllerList.add("raa2");
    generateControllerList.add("rab2");
    generateControllerList.add("ram2");
    generateControllerList.add("ran12");
    generateControllerList.add("ran22");
    generateControllerList.add("ran32");
    generateControllerList.add("raPointNum");
    generateControllerList.add("raRadius");
  }

  void generate() {
    partList = new ArrayList<Part>();
    myMesh = new ToxicMesh();
    myMesh.material = raMaterial;
    partList.add(myMesh);

    //superFormulaPoints = superFormula(raa1, rab1, ram1, ran11, ran21, ran31);

    if (raAnimate) {
      float inc = 1+sin(millis()/1000.0)/2*raRatio;
      superShapePoints = superShape(raa1, rab1, ram1, ran11*inc, ran21*inc, ran31*inc, raa2, rab2, ram2, ran12*inc, ran22*inc, ran32*inc);
    } 
    else {
      superShapePoints = superShape(raa1, rab1, ram1, ran11, ran21, ran31, raa2, rab2, ram2, ran12, ran22, ran32);
    }

    TriangleMesh superSurface = new TriangleMesh();
    for (int i = 0;i < raPointNum; i++) {
      for (int j = 0;j < raPointNum; j++) {
        int ni = (i+1)%raPointNum;
        int nj = constrain(j+1, 0, raPointNum-1);
        superSurface.addFace(superShapePoints[i][j], superShapePoints[i][nj], superShapePoints[ni][j]);
        superSurface.addFace(superShapePoints[ni][j], superShapePoints[ni][nj], superShapePoints[i][nj]);
      }
    }
    myMesh.setMesh(superSurface);
    generated = true;
    validated = true;
  }

  void update() {
    println("update");
    myMesh.material = raMaterial;
    // updateMaterials();
  }


  InterpolateStrategy tween=new CosineInterpolation();

  void display() {

    if (raAnimate) {
      generate();
      buildGeometry();
      // float inc = sin(millis()%1000/1000);

      //  float inc = tween.interpolate(0.5,1.5,(millis()%1000)/1000.0);
      //  raa1 += random(1);
      //rab1 += random(1);
      //ram1 += random(15);
      //    ran11 *= inc;
      //    ran21  *= inc;
      //    ran31  *= inc;
      //   // raa2 += random(2);
      //   // rab2 += random(2);
      //   // ram2 +=random(15);
      //    ran12  *= inc;
      //    ran22  *= inc;
      //    ran32  *= inc;
      //generate();
    }

    if (structure) {
      strokeWeight(thinStroke);
      stroke(strokeColor, strokeAlpha);
      noFill();
      //      beginShape();
      //      curveVertex(superFormulaPoints[superFormulaPoints.length-1].x, superFormulaPoints[superFormulaPoints.length-1].y);
      //      for (int i = 0;i < superFormulaPoints.length; i++) {
      //        curveVertex(superFormulaPoints[i].x, superFormulaPoints[i].y);
      //      }
      //      curveVertex(superFormulaPoints[0].x, superFormulaPoints[0].y);
      //      endShape();
      //      stroke(0, 0, strokeColor, strokeAlpha);
      //      beginShape();
      //      for (int i = 0;i < superShapePoints.length; i++) {
      //        curveVertex(superShapePoints[i].x, superShapePoints[i].y, superShapePoints[i].z);
      //      }
      //      endShape();
      for (int i = 0;i < raPointNum; i++) {
        for (int j = 0;j < raPointNum; j++) {
          fx.line(superShapePoints[i][j], superShapePoints[(i+1)%raPointNum][j]);
          fx.line(superShapePoints[i][j], superShapePoints[i][constrain(j+1, 0, raPointNum-1)]);
        }
      }
    }

    if (dots) {
      for (int i = 0;i < raPointNum; i++) {
        for (int j = 0;j < raPointNum; j++) {
          fx.point(superShapePoints[i][j]);
        }
      }
    }
  }

  Vec3D[][] superShape(float a1, float b1, float m1, float n11, float n21, float n31, float a2, float b2, float m2, float n12, float n22, float n32) {
    float phi = TWO_PI / raPointNum;
    Vec3D[][] points = new Vec3D[raPointNum][raPointNum];
    int index = 0;
    for (int i=0;i<raPointNum;i++) {
      float s = -PI+(phi*i);
      for (int j=0;j<raPointNum;j++) {
        float p = (-PI/2) + (j*phi/2);
        float f, e, n, d, t, a, q, m, l, k, h;
        float c = 0;
        float o = 0;
        float u = 0;
        f = cos(m1 * s / 4);
        f = 1 / a1 * abs(f);
        f = abs(f);
        e = sin(m1 * s / 4);
        e = 1 / b1 * abs(e);
        e = abs(e);
        m = pow(f, n21);
        l = pow(e, n31);
        d = m + l;
        t = abs(d);
        t = pow(t, (-1 / n11));
        f = cos(m2 * p / 4);
        f = 1 / a2 * abs(f);
        f = abs(f);
        e = sin(m2 * p / 4);
        e = 1 / b2 * abs(e);
        e = abs(e);
        k = pow(f, n22);
        h = pow(e, n32);
        a = k + h;
        q = abs(a);
        q = pow(q, (-1 / n12));
        c = t * cos(s) * q * cos(p) * raRadius;
        o = t * sin(s) * q * cos(p) * raRadius;
        u = q * sin(p) * raRadius;
        points[i][j] = new Vec3D(c, o, u);
      }
    }
    return points;
  }

  Vec2D[] superFormula(float a, float b, float m, float n1, float n2, float n3) {
    float phi = TWO_PI / raPointNum;
    Vec2D[] points = new Vec2D[raPointNum+1];
    for (int i = 0;i <= raPointNum;i++) {
      points[i] = superformulaPoint(a, b, m, n1, n2, n3, phi * i);
    }
    return points;
  }

  Vec2D superformulaPoint(float a, float b, float m, float n1, float n2, float n3, float phi) {
    float r;
    float t1, t2;
    //  float a=1, b=1;
    float x = 0;
    float y = 0;
    t1 = cos(m * phi / 4) / a;
    t1 = abs(t1);
    t1 = pow(t1, n2);
    t2 = sin(m * phi / 4) / b;
    t2 = abs(t2);
    t2 = pow(t2, n3);
    r = pow(t1+t2, 1/n1);
    if (abs(r) == 0) {
      x = 0;
      y = 0;
    }  
    else {
      r = 1 / r;
      x = r * cos(phi) * raRadius;
      y = r * sin(phi) * raRadius;
    }
    return new Vec2D(x, y);
  }

  void randomize() {
    raa1 = .5+random(1);//random(20);
    rab1 = .5+random(1);//random(20);
    ram1 = random(15);
    ran11 =random(15);
    ran21 = random(5);
    ran31 = random(5);
    raa2 = .5+random(2);//random(20);
    rab2 = .5+
      random(2);//random(20);
    ram2 =random(15);
    ran12 = random(15);
    ran22 = random(5);
    ran32 = random(5);
  }
}

