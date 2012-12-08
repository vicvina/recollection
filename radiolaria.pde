
int raStep = 64;
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

Vec2D[] superFormulaPoints;
Vec3D[] superShapePoints;

class Radiolaria extends Furniture {

  Radiolaria () {
    reset();
    //  randomize();
    cx = 0;
    cy = 0;
    Group gRadiolaria = cp5.addGroup("radiolaria").setPosition(columnx, marginy).hideBar();
    createSlider(gRadiolaria, "raRadius", raRadius, 0, 500, true, "raduis");
    createSlider(gRadiolaria, "raStep", raStep, 128, 256, true, "detail");
    cy += sh/2;
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
    //  updateControllerList.add("taTubeR");
    //  updateControllerList.add("taCornerR");
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

    generateControllerList.add("raRadius");
  }

  void generate() {
    partList = new ArrayList<Part>();
    //    pipe = new Pipe();
    //    pipe.material= "metal";
    //    partList.add(pipe);
    superFormulaPoints = superFormula(raa1, rab1, ram1, ran11, ran21, ran31);
    superShapePoints = superShape(raa1, rab1, ram1, ran11, ran21, ran31, raa2, rab2, ram2, ran12, ran22, ran32);
    generated = true;
    validated = true;
  }

  void display() {
    if (structure) {
      stroke(strokeColor, 0, 0, strokeAlpha);
      noFill();
      beginShape();
      curveVertex(superFormulaPoints[superFormulaPoints.length-1].x, superFormulaPoints[superFormulaPoints.length-1].y);
      for (int i = 0;i < superFormulaPoints.length; i++) {
        curveVertex(superFormulaPoints[i].x, superFormulaPoints[i].y);
      }
      curveVertex(superFormulaPoints[0].x, superFormulaPoints[0].y);
      endShape();
      stroke(0, 0, strokeColor, strokeAlpha);
      beginShape();
      for (int i = 0;i < superShapePoints.length; i++) {
        curveVertex(superShapePoints[i].x, superShapePoints[i].y, superShapePoints[i].z);
      }
      endShape();
    }

    if (dots) {
      for (int i = 0;i < superShapePoints.length; i++) {
        fx.point(superShapePoints[i]);
      }
    }
  }

  int index;

  Vec3D[] superShape(float a1, float b1, float m1, float n11, float n21, float n31, float a2, float b2, float m2, float n12, float n22, float n32) {
    float b = .1;
    int numPoints = 24;
    float phi = TWO_PI / numPoints;
    Vec3D[] points = new Vec3D[numPoints*numPoints];
    int index = 0;
    for (int i=0;i<numPoints;i++) {
      float s = -PI+(phi*i);
      //  geometry = new THREE.Geometry();
      // Vec3D[] section = 
      for (int j=0;j<numPoints;j++) {
        float p = (-PI/2) + (j*phi/2);
        //  for (float p = -PI / 2; p < PI / 2; p += b) {
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

        points[index++] = new Vec3D(c, o, u);
      }
    }
    println(index);
    return points;
  }

  Vec2D[] superFormula(float a, float b, float m, float n1, float n2, float n3) {
    int numPoints = 360;
    float phi = TWO_PI / numPoints;
    Vec2D[] points = new Vec2D[numPoints+1];
    for (int i = 0;i <= numPoints;i++) {
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
    raa1 = 1;//random(20);
    rab1 = 1;//random(20);
    ram1 = random(32);
    ran11 =random(20);
    ran21 = random(20);
    ran31 = (int)random(20);
    raa2 = 1;//random(20);
    rab2 = 1;//random(20);
    ram2 =random(32);
    ran12 = random(20);
    ran22 = random(20);
    ran32 = random(20);
  }
}

