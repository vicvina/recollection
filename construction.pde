class SuperPlane {
  boolean available = true;
  Vec3D a, b, c, d;
  Vec3D center;
  Line3D axisH, axisV;
  Vec3D directionH, directionV;

  SuperPlane (Vec3D a, Vec3D b, Vec3D c, Vec3D d) {
    this.a = a;
    this.b = b;
    this.c = c;
    this.d = d;
    center = new Line3D(a, c).getMidPoint();
    axisV = new Line3D( new Line3D(a, b).getMidPoint(), new Line3D(c, d).getMidPoint());
    axisH = new Line3D( new Line3D(a, d).getMidPoint(), new Line3D(b, c).getMidPoint());
    directionV = axisV.getDirection().normalize();
    directionH = axisH.getDirection().normalize();
  }    

  boolean isWithinWorld() {
    return checkVectorWithinWorld(a) && checkVectorWithinWorld(b) && checkVectorWithinWorld(c) && checkVectorWithinWorld(d);
  }

  boolean isAboveGround() {
    return a.z > 0 && b.z > 0 && c.z > 0 && d.z > 0;
  }

  boolean intersectsBlock(SuperBlock thisBlock, float thisStep) {
    ArrayList<Vec3D> pointsAB = getPointsFromLine(new Line3D(a, b), thisStep, true);
    ArrayList<Vec3D> pointsDC = getPointsFromLine(new Line3D(d, c), thisStep, true);
    for  (int i=0;i<pointsAB.size();i++) {
      Line3D tempLine = new Line3D(pointsAB.get(i), pointsDC.get(i));
      if (checkLineBlockCollision(tempLine, thisBlock)) {
        return true;
      }
    }
    return false;
  }

  boolean intersectsBlockList(ArrayList<SuperBlock> thisBlockList, float thisStep) {
    for (SuperBlock thisBlock : thisBlockList) {
      if (intersectsBlock(thisBlock, thisStep)) {
        return true;
      }
    }
    return false;
  }

  // probably faster as points are calculated only one per block
  // boolean intersectsBlockList(ArrayList<SuperBlock> thisBlockList, float thisStep) {
  //    ArrayList<Vec3D> pointsAB = getPointsFromLine(new Line3D(a, b), thisStep, true);
  //    ArrayList<Vec3D> pointsDC = getPointsFromLine(new Line3D(d, c), thisStep, true);
  //    for  (int i=0;i<pointsAB.size();i++) {
  //      Line3D tempLine = new Line3D(pointsAB.get(i), pointsDC.get(i));
  //      fx.line(tempLine);
  //      if (checkLineBlockListCollision(tempLine, thisBlockList)) {
  //        return true;
  //      }
  //    }
  //    return false;
  //  }

  //  this is not working yet !!!
  //  boolean intersectsSuperPlane(SuperPlane thisPlane, float thisStep) {
  //    ArrayList<Vec3D> pointsAB = getPointsFromLine(new Line3D(a, b), thisStep, true);
  //    ArrayList<Vec3D> pointsCD = getPointsFromLine(new Line3D(c, d), thisStep, true);
  //    ArrayList<Vec3D> pointsEE = getPointsFromLine(new Line3D(thisPlane.a, thisPlane.b), thisStep, true);
  //    ArrayList<Vec3D> pointsFF = getPointsFromLine(new Line3D(thisPlane.c, thisPlane.d), thisStep, true);
  //
  //    for  (int i=0;i<pointsAB.size();i++) {
  //      Line3D tempLineA = new Line3D(pointsAB.get(i), pointsCD.get(i));
  //      for (int j=0;j<pointsEE.size();j++) {
  //        Line3D tempLineB = new Line3D(pointsEE.get(i), pointsFF.get(i));
  //        if (checkLinesCollision(tempLineA, tempLineB)) {
  //          return true;
  //        }
  //      }
  //    }
  //    return false;
  //  }
  //  

  void display() {
    if (details) {
      noFill();
      stroke(redColor, strokeAlpha/3);
      strokeWeight(thinStroke);
      beginShape(QUAD_STRIP);
      vertex(a.x, a.y, a.z);
      vertex(b.x, b.y, b.z);
      vertex(d.x, d.y, d.z);
      vertex(c.x, c.y, c.z);
      endShape();
      //fx.line(axisV);
      //fx.line(axisH);
    }
    if (dots) {
      //      stroke(blueColor);
      //      strokeWeight(markerStroke);
      //      drawMarker(center);
    }
  }
}

TriangleMesh createBlockMeshFromPlane (Vec3D a, Vec3D b, Vec3D c, Vec3D d, int thisOffset, boolean extrudeInBothDirections) {
  Triangle3D thisTriangle  = new Triangle3D(a, b, c);
  Vec3D nor = thisTriangle.computeNormal().normalize();
  Vec3D offsetA;
  Vec3D offsetB; 
  if (extrudeInBothDirections) {
    offsetA = nor.copy().scaleSelf(thisOffset/2);
    offsetB = nor.getInverted();
  } 
  else {
    offsetA = new Vec3D(0, 0, 0);  
    //    if (nor.z<0) {
    //      nor = nor.getInverted(); // hack to extruse always to z positve ... not correct but it works so far... (most of the time, not in vertical planes!!)
    //    }
    offsetB =  nor.copy().scaleSelf(thisOffset);
  }

  Vec3D aa = a.copy().addSelf(offsetA);
  Vec3D bb = b.copy().addSelf(offsetA);
  Vec3D cc = c.copy().addSelf(offsetA);
  Vec3D dd = d.copy().addSelf(offsetA);
  Vec3D ee = a.copy().addSelf(offsetB);
  Vec3D ff = b.copy().addSelf(offsetB);
  Vec3D gg = c.copy().addSelf(offsetB);
  Vec3D hh = d.copy().addSelf(offsetB);

  TriangleMesh blockShapeMesh = new TriangleMesh();

  blockShapeMesh.addFace(aa, dd, bb);
  blockShapeMesh.addFace(bb, dd, cc);
  blockShapeMesh.addFace(ee, hh, ff);
  blockShapeMesh.addFace(ff, hh, gg);
  blockShapeMesh.addFace(aa, dd, hh);
  blockShapeMesh.addFace(hh, ee, aa);
  blockShapeMesh.addFace(bb, ff, gg);
  blockShapeMesh.addFace(gg, cc, bb);
  blockShapeMesh.addFace(aa, bb, ee);
  blockShapeMesh.addFace(ee, bb, ff);
  blockShapeMesh.addFace(dd, cc, hh);
  blockShapeMesh.addFace(hh, gg, cc);
  return blockShapeMesh;
}

TriangleMesh createCylinderMeshFromLine (Line3D thisLine, int thisR) {
  ZAxisCylinder cyl=new ZAxisCylinder(Vec3D.ZERO, thisR, thisLine.getLength());
  TriangleMesh cylinderMesh = (TriangleMesh)cyl.toMesh(cylinderRes, 0);
  cylinderMesh.pointTowards(thisLine.getDirection());
  cylinderMesh.translate(thisLine.getMidPoint());
  return cylinderMesh;
}

TriangleMesh createCylinderMeshFromLineUsingCone (Line3D thisLine, int thisR, boolean topCap, boolean bottomCap) {
  Vec3D thisRot = thisLine.getDirection().normalize();
  Cone cone= new Cone(thisLine.getMidPoint(), thisRot, thisR, thisR, thisLine.getLength());
  TriangleMesh cylinderMesh = (TriangleMesh)cone.toMesh(new TriangleMesh(), cylinderRes, 0, topCap, bottomCap);
  return cylinderMesh;
}

TriangleMesh createConeMeshFromLine (Line3D thisLine, int thisR1, int thisR2, boolean topCap, boolean bottomCap) {
  Vec3D thisRot = thisLine.getDirection().normalize();
  Cone cone= new Cone(thisLine.getMidPoint(), thisRot, thisR1, thisR2, thisLine.getLength());
  TriangleMesh coneMesh = (TriangleMesh)cone.toMesh(new TriangleMesh(), cylinderRes, 0, topCap, bottomCap);
  return coneMesh;
}


//class PerpendicularCylinder extends Part {
//  AxisAlignedCylinder cyl;
//  float r, h;
//
//  PerpendicularCylinder () {
//    id = millis();
//  }
//  void update() {
//  }
//  void build() {
//    cyl=new ZAxisCylinder(new Vec3D(0, 0, 0), r, h);
//    TriangleMesh cylinderMesh = (TriangleMesh)cyl.toMesh(segmentNum*4, 0);
//    cylinderMesh.rotateZ(rot.z);
//    cylinderMesh.rotateY(rot.y);
//    cylinderMesh.rotateX(rot.x);
//    cylinderMesh.translate(loc);
//    meshList[material].addMesh(cylinderMesh);
//  }
//
//  void display() {
//    pushMatrix();
//    rotateX(rot.x*PI/2);
//    rotateY(rot.y*PI/2);
//    rotateZ(rot.z*PI/2);
//    translate(loc.x, loc.y, loc.z-h/2);
//    if (dots) {
//      strokeWeight(markerStroke);
//      stroke(strokeColor, strokeAlpha);
//      drawMarker(Vec3D.ZERO.copy());
//      drawMarker(new Vec3D(0, 0, h));
//    }
//    noFill();
//    stroke(strokeColor, strokeAlpha);
//    strokeWeight(thinStroke);
//    ellipse(0, 0, 2*r, 2*r);
//    translate(0, 0, h);
//    ellipse(0, 0, 2*r, 2*r);
//    popMatrix();
//  }
//
//  void setHeight(float h ) {
//    this.h = h;
//  }
//
//  void setRadius(float r) {
//    this.r = r;
//  }
//}


//TriangleMesh createAxisAlginedCylinderMeshFromLine (Line3D thisLine, int thisR) {
//  Vec3D rot = thisLine.getDirection().normalize();
//  AxisAlignedCylinder cyl= null;
//  if (rot.equals(new Vec3D(0, 0, 1)) || rot.equals(new Vec3D(0, 0, -1))) {
//    cyl=new ZAxisCylinder(new Vec3D(0, 0, 0), thisR, thisLine.getLength());
//  } 
//  else if (rot.equals(new Vec3D(0, 1, 0)) || rot.equals(new Vec3D(0, -1, 0))) {
//    cyl=new YAxisCylinder(new Vec3D(0, 0, 0), thisR, thisLine.getLength());
//  } 
//  else if (rot.equals(new Vec3D(1, 0, 0)) || rot.equals(new Vec3D(-1, 0, 0))) {
//    cyl=new XAxisCylinder(new Vec3D(0, 0, 0), thisR, thisLine.getLength());
//  }
//  TriangleMesh cylinderMesh = (TriangleMesh)cyl.toMesh(segmentNum, 0);
//  cylinderMesh.translate(thisLine.getMidPoint());
//  return cylinderMesh;
//}



class LineStrip3D implements Iterable<Vec3D> {
  public List<Vec3D> vertices = new ArrayList<Vec3D>();
  protected float[] arcLenIndex;

  public LineStrip3D() {
  }

  public LineStrip3D(Collection<? extends Vec3D> vertices) {
    this.vertices = new ArrayList<Vec3D>(vertices);
  }

  public LineStrip3D add(float x, float y, float z) {
    vertices.add(new Vec3D(x, y, z));
    return this;
  }

  public LineStrip3D add(ReadonlyVec3D p) {
    vertices.add(p.copy());
    return this;
  }

  public LineStrip3D add(Vec3D p) {
    vertices.add(p);
    return this;
  }

  /**
   * Returns the vertex at the given index. This function follows Python
   * convention, in that if the index is negative, it is considered relative
   * to the list end. Therefore the vertex at index -1 is the last vertex in
   * the list.
   * 
   * @param i
   *            index
   * @return vertex
   */
  public Vec3D get(int i) {
    if (i < 0) {
      i += vertices.size();
    }
    return vertices.get(i);
  }

  /**
   * Computes a list of points along the spline which are uniformly separated
   * by the given step distance.
   * 
   * @param step
   * @return point list
   */
  public List<Vec3D> getDecimatedVertices(float step) {
    return getDecimatedVertices(step, true);
  }

  /**
   * Computes a list of points along the spline which are close to uniformly
   * separated by the given step distance. The uniform distribution is only an
   * approximation and is based on the estimated arc length of the polyline.
   * The distance between returned points might vary in places, especially if
   * there're sharp angles between line segments.
   * 
   * @param step
   * @param doAddFinalVertex
   *            true, if the last vertex computed should be added regardless
   *            of its distance.
   * @return point list
   */
  public List<Vec3D> getDecimatedVertices(float step, boolean doAddFinalVertex) {
    ArrayList<Vec3D> uniform = new ArrayList<Vec3D>();
    if (vertices.size() < 3) {
      if (vertices.size() == 2) {
        new Line3D(vertices.get(0), vertices.get(1)).splitIntoSegments(
        uniform, step, true);
        if (!doAddFinalVertex) {
          uniform.remove(uniform.size() - 1);
        }
      } 
      else {
        return null;
      }
    }
    float arcLen = getEstimatedArcLength();
    double delta = (double) step / arcLen;
    int currIdx = 0;
    for (double t = 0; t < 1.0; t += delta) {
      double currT = t * arcLen;
      while (currT >= arcLenIndex[currIdx]) {
        currIdx++;
      }
      ReadonlyVec3D p = vertices.get(currIdx - 1);
      ReadonlyVec3D q = vertices.get(currIdx);
      float frac = (float) ((currT - arcLenIndex[currIdx - 1]) / (arcLenIndex[currIdx] - arcLenIndex[currIdx - 1]));
      Vec3D i = p.interpolateTo(q, frac);
      uniform.add(i);
    }
    if (doAddFinalVertex) {
      uniform.add(vertices.get(vertices.size() - 1).copy());
    }
    return uniform;
  }

  public float getEstimatedArcLength() {
    if (arcLenIndex == null
      || (arcLenIndex != null && arcLenIndex.length != vertices.size())) {
      arcLenIndex = new float[vertices.size()];
    }
    float arcLen = 0;
    for (int i = 1; i < arcLenIndex.length; i++) {
      ReadonlyVec3D p = vertices.get(i - 1);
      ReadonlyVec3D q = vertices.get(i);
      arcLen += p.distanceTo(q);
      arcLenIndex[i] = arcLen;
    }
    return arcLen;
  }

  public List<Line3D> getSegments() {
    final int num = vertices.size();
    List<Line3D> segments = new ArrayList<Line3D>(num - 1);
    for (int i = 1; i < num; i++) {
      segments.add(new Line3D(vertices.get(i - 1), vertices.get(i)));
    }
    return segments;
  }

  /**
   * @return the vertices
   */
  public List<Vec3D> getVertices() {
    return vertices;
  }

  public Iterator<Vec3D> iterator() {
    return vertices.iterator();
  }

  /**
   * @param vertices
   *            the vertices to set
   */
  public void setVertices(List<Vec3D> vertices) {
    this.vertices = vertices;
  }
}


class ParallelTransportFrame extends LineStrip3D implements IFrameCurve {

  protected List<Vec3D> tangents = new ArrayList<Vec3D>();
  protected List<Vec3D> binormals = new ArrayList<Vec3D>();
  protected List<Vec3D> normals = new ArrayList<Vec3D>();

  private int curve_length;

  //-------------------------------------------------------- ctor

  public ParallelTransportFrame(Collection<? extends Vec3D> vertices) {
    super(vertices);
    this.curve_length = vertices.size();
    for (int i=0; i<=curve_length; i++) {
      tangents.add(new Vec3D());
      binormals.add(new Vec3D());
      normals.add(new Vec3D());
    }    
    if (curve_length<3) {
      System.out.println("ERROR: ");
      System.out.println("\t ParallelTransportFrame.java");
      System.out.println("\t Curve must have at least 4 points");
      this.curve_length = 0;
      return;
    }
    if (this.vertices.get(0) == this.vertices.get(1) ||
      this.vertices.get(1) == this.vertices.get(2) ||
      this.vertices.get(0) == this.vertices.get(2)) {
      System.out.println("ERROR: ");
      System.out.println("\t ParallelTransportFrame.java");
      System.out.println("\t Curve must have at least 4 non-equal points");
      this.curve_length = 0;
      return;
    }
    getFirstFrame();
    getTangents();
    parallelTransportFrameApproach();
  }

  //-------------------------------------------------------- algorithm

  void getFirstFrame() {
    // first frame, needed by parallel transport frame approach
    // frenet method is used. 
    // more specific method (in case of complex target-oriented base animation) could be used    
    Vec3D p0, p1, p2, b;    
    // 1° derivate in p0-p1
    p0 = vertices.get(0);
    p1 = vertices.get(1);
    tangents.set(0, getTangentBetweenTwoPoint(p0, p1));    
    // 1° derivate in p1-p2
    p1 = vertices.get(1);
    p2 = vertices.get(2);
    tangents.set(1, getTangentBetweenTwoPoint(p1, p2));    
    // 2° derivate in t0 and t1
    b = tangents.get(0).cross(tangents.get(1));
    b.normalize();
    binormals.set(0, b);    
    normals.set(0, b.cross(tangents.get(0)));
  }

  public List<Vec3D> getTangents() {
    Vec3D p0, p1;
    for (int i=1; i<curve_length-1; i++) {
      p0 = vertices.get(i);
      p1 = vertices.get(i+1);
      tangents.set(i, getTangentBetweenTwoPoint(p0, p1));
    }
    return tangents;
  }

  void parallelTransportFrameApproach() {
    // p.t.f approach from article: Hanson and Ma, 1995
    Vec3D old_normal, p0, p1, b;
    float theta;
    for (int i=1; i<curve_length+1; i++) {
      p0 = tangents.get(i-1);
      p1 = tangents.get(i);

      if (p0==p1) {
        normals.set(i, normals.get(i-1));
        binormals.set(i, binormals.get(i-1));
        continue;
      }

      // this is what is called A in game programming gems
      // and B in Hanson and Ma article
      b = p0.cross(p1);
      b.normalize();

      if (b.magnitude()==0) {
        normals.set(i, normals.get(i-1));
        binormals.set(i, binormals.get(i-1));
        continue;
      }

      // normals
      theta = PApplet.acos(p0.dot(p1));
      old_normal = normals.get(i-1).copy();
      old_normal.normalize();
      old_normal.rotateAroundAxis(b, theta);
      old_normal.scale(normals.get(i-1));
      normals.set(i, old_normal);
      binormals.set(i, tangents.get(i).cross(old_normal));
    }
  }

  Vec3D getTangentBetweenTwoPoint(Vec3D p1, Vec3D p2) {
    Vec3D r = p1.sub(p2);
    r.normalize();
    return r;
  }

  public Vec3D getBinormal(int i) {
    return binormals.get(i);
  }

  public Vec3D getNormal(int i) {
    return normals.get(i);
  }

  public Vec3D getTangent(int i) {
    return tangents.get(i);
  }

  public List<Vec3D> getBinormals() {
    return binormals;
  }

  public List<Vec3D> getNormals() {
    return normals;
  }

  public int getCurveLength() {
    return curve_length;
  }
}

class ParallelTube extends TriangleMesh {
  private ParallelTransportFrame soul;
  private int curveLength;
  private int radius = 10;
  private int diameterQuality = 20;
  private float[] cachedRadius = null;
  private boolean usedCachedRadius = false;

  private List< List<Vec3D> > circles = new ArrayList<List<Vec3D>>();
  private int num_faces;

  //-------------------------------------------------------- ctor

  public ParallelTube(ParallelTransportFrame soul, int radius, int diameter_quality) {
    //  System.out.println("Tube > constructor: " + radius);
    this.soul = soul;
    this.curveLength = soul.getCurveLength();
    this.setRadius(radius);
    this.diameterQuality = diameter_quality;
    if (soul.getCurveLength()==0) return;
    compute();
  }

  //-------------------------------------------------------- vertex computation

  public void compute() {
    num_faces = 0;
    List<Vec3D> circle1, circle2;
    float radius;
    radius = (isUsedCachedRadius() ? cachedRadius[0]: getRadius());
    circle1 = getCircle(0, radius);
    for (int i=1; i<curveLength-1; i++) {
      if (debug) {
        println(i+"/"+curveLength);
      }
      radius = (isUsedCachedRadius() ? cachedRadius[i]: getRadius());
      circle2 = getCircle(i, radius);
      addCircles(circle1, circle2);
      circle1 = circle2;
    }
  }

  List<Vec3D> getCircle(int i, float _radius) {
    int k = diameterQuality;
    List<Vec3D> vert;
    float theta = 0;
    float dt = MathUtils.TWO_PI/(k);

    if (i<this.circles.size()) {
      // circle exists, does not create a new one, just modify it
      vert = circles.get(i);
    } 
    else {
      // new length, we have to allocate new objects
      vert = new ArrayList<Vec3D>(k+1);
      for (int j=0; j<=k; j++) 
        vert.add(new Vec3D());
    }

    for (int j=0; j<=k; j++) {
      float c = MathUtils.cos(theta) * _radius;
      float s = MathUtils.sin(theta) * _radius;

      Vec3D p = vert.get(j);
      p.x = soul.vertices.get(i).x + c*soul.getBinormal(i).x + s*soul.getNormal(i).x;
      p.y = soul.vertices.get(i).y + c*soul.getBinormal(i).y + s*soul.getNormal(i).y;
      p.z = soul.vertices.get(i).z + c*soul.getBinormal(i).z + s*soul.getNormal(i).z;

      theta += dt;
    }  
    // cache the result back
    circles.add(vert);

    return vert;
  }

  void addCircles(List<Vec3D> circle1, List<Vec3D> circle2) {
    Vec3D  p1, p2, p3, p4, p5, p6;
    Face f1, f2;
    boolean must_add = false;

    for (int j=0; j<circle1.size()-1; j++) {
      try { // vertices exists, does not create new ones, just modify them
        f1 = this.faces.get(num_faces++);
        p1 = f1.a; 
        p2 = f1.b; 
        p3 = f1.c;

        f2 = this.faces.get(num_faces++);
        p4 = f2.a; 
        p5 = f2.b; 
        p6 = f2.c;
      } 
      catch (IndexOutOfBoundsException e) { // new length, we have to allocate new objects
        //System.out.println("addCircles > new");
        p1 = new Vec3D(); 
        p2 = new Vec3D(); 
        p3 = new Vec3D();
        p4 = new Vec3D(); 
        p5 = new Vec3D(); 
        p6 = new Vec3D();

        must_add = true;
      }

      p1.set(circle1.get(j).x, circle1.get(j).y, circle1.get(j).z);       
      p2.set(circle2.get(j).x, circle2.get(j).y, circle2.get(j).z);
      p3.set(circle2.get(j+1).x, circle2.get(j+1).y, circle2.get(j+1).z);      

      p4.set(circle2.get(j+1).x, circle2.get(j+1).y, circle2.get(j+1).z); 
      p5.set(circle1.get(j).x, circle1.get(j).y, circle1.get(j).z);       
      p6.set(circle1.get(j+1).x, circle1.get(j+1).y, circle1.get(j+1).z);

      if (must_add) {
        this.addFace(p1, p2, p3);
        this.addFace(p4, p5, p6);
      }
    }
  }

  public void setCachedRadius(float[] c) {
    this.cachedRadius = c;
    if (c!=null) setUsedCachedRadius(true);
    else setUsedCachedRadius(false);
  }

  public void setUsedCachedRadius(boolean usedCachedRadius) {
    this.usedCachedRadius = usedCachedRadius;
  }

  public boolean isUsedCachedRadius() {
    return usedCachedRadius;
  }

  public void setRadius(int radius) {
    this.radius = radius;
  }

  public int getRadius() {
    return radius;
  }

  public int getDiameterQuality() {
    return diameterQuality;
  }

  public void setDiameterQuality(int diameterQuality) {
    this.diameterQuality = diameterQuality;
  }

  public int getCurveLength() {
    return curveLength;
  }

  public void setCurveLength(int curveLength) {
    this.curveLength = curveLength;
  }

  public List<List<Vec3D>> getCircles() {
    return circles;
  }
}

interface IFrameCurve {
  Vec3D getTangent(int i);
  Vec3D getNormal(int i);
  Vec3D getBinormal(int i);
}

