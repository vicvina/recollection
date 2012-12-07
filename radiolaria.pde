
int raStep = 64;
int raRadius = 500;
int raa = 1;
int rab = 1;
int ram = 3;
int ran1 = 1;
int ran2 = 1;
int ran3 = 2;

class Radiolaria extends Furniture {

  Radiolaria () {
    reset();
    //  randomize();
    cx = 0;
    cy = 0;
    Group gRadiolaria = cp5.addGroup("radiolaria").setPosition(columnx, marginy).hideBar();
    createSlider(gRadiolaria, "raa", raa, 1, 20, true, "a");
    createSlider(gRadiolaria, "rab", rab, 1, 20, true, "b");
    createSlider(gRadiolaria, "ram", ram, 1, 20, true, "m");
    createSlider(gRadiolaria, "ran1", ran1, 1, 20, true, "n1");
    createSlider(gRadiolaria, "ran2", ran2, 1, 20, true, "n2");
    createSlider(gRadiolaria, "ran3", ran3, 1, 20, true, "n3");
    createSlider(gRadiolaria, "raRadius", raRadius, 0, 500, true, "raduis");
    createSlider(gRadiolaria, "raStep", raStep, 128, 256, true, "detail");
    //    updateControllerList.add("taTubeR");
    //    updateControllerList.add("taCornerR");
    generateControllerList.add("raa");
    generateControllerList.add("rab");
    generateControllerList.add("ram");
    generateControllerList.add("ran1");
    generateControllerList.add("ran2");
    generateControllerList.add("ran3");
    generateControllerList.add("raRadius");
  }

  void generate() {
    partList = new ArrayList<Part>();
    //    pipe = new Pipe();
    //    pipe.material= "metal";
    //    partList.add(pipe);
    generated = true;
    validated = true;
  }

  void display() {
    if (structure) {
      stroke(strokeColor, 0, 0, strokeAlpha);
      noFill();
      PVector[] points = superformula(ram, ran1, ran2, ran3);

      beginShape();
     // curveVertex(points[points.length-1].x * raRadius, points[points.length-1].y * raRadius);
      for (int i = 0;i < points.length; i++) {
        curveVertex(points[i].x * raRadius, points[i].y * raRadius);
      }
      curveVertex(points[0].x * raRadius, points[0].y * raRadius);
      endShape();

      //    
      //      for (float f = -PI; f <= PI +(PI/raStep); f += PI/raStep) {
      //        float r= pow((pow(abs(cos(ram*f/4)/raa), ran2) + pow(abs(sin(ram*f/4)/rab), ran3)), -(1/ran1));
      //        float x =  r * cos (f) * raRadius;
      //        float y =  r * sin (f) * raRadius;
      //        vertex(x, y);
      //      }
     // endShape();
    }
  }

  PVector[] superformula(float m, float n1, float n2, float n3) {
    int numPoints = 360;
    float phi = TWO_PI / numPoints;
    PVector[] points = new PVector[numPoints+1];
    for (int i = 0;i <= numPoints;i++) {
      points[i] = superformulaPoint(m, n1, n2, n3, phi * i);
    }
    return points;
  }

  PVector superformulaPoint(float m, float n1, float n2, float n3, float phi) {
    float r;
    float t1, t2;
    float a=1, b=1;
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
      x = r * cos(phi);
      y = r * sin(phi);
    }

    return new PVector(x, y);
  }

  void update() {

    for (Part thisPart : partList) {
      thisPart.update();
    }
  }

  void reset() {
  }

  void randomize() {
    raa = 1;//random(20);
    rab = 1;//random(20);
    ram = (int)random(20);
    ran1 = (int)random(20);
    ran2 = (int)random(20);
    ran3 = (int)random(20);
  }
}

