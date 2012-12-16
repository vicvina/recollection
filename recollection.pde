int startMode = 1;
int furniture = 1;
boolean validated = true;

boolean gui = true;
boolean limits = false;
boolean axis = false;
boolean material = true;
boolean wireframe =false;
boolean solid = true;
boolean structure =false;
boolean filled = true;
boolean dots = false;
boolean details = false;
boolean light = true;
boolean soft = false;
boolean isometric = false;
boolean ground = false;
boolean grid = true;
boolean rotation = false;
boolean dragged = false;
boolean moved = false;
boolean basics = false;
boolean original = false;
boolean debug = false;
boolean catalog = false;
boolean video = false;

boolean show = false;
boolean auto = false;
boolean validate = false;

import java.util.*;

import toxi.processing.*;
import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.math.*;

ToxiclibsSupport fx;

import rosettamesh.*;

import wblut.geom.core.*;
import wblut.hemesh.creators.*;
import wblut.hemesh.tools.*;
import wblut.geom.grid.*;
import wblut.geom.nurbs.*;
import wblut.core.math.*;
import wblut.hemesh.subdividors.*;
import wblut.core.processing.*;
import wblut.hemesh.composite.*;
import wblut.core.random.*;
import wblut.hemesh.core.*;
import wblut.geom.frame.*;
import wblut.core.structures.*;
import wblut.hemesh.modifiers.*;
//import wblut.hemesh.options.*;
import wblut.hemesh.simplifiers.*;
import wblut.geom.triangulate.*;
import wblut.geom.tree.*;

WB_Render render;
PShape retained;

//int RES = 64;  // increase resolution to 128 for great detail
//float ISO = 0.2;
//float MAX_ISO=0.66;

void setup() {
  size(displayWidth, displayHeight, P3D);
  frameRate(60);
  smooth(smoothLevel);
  fx = new ToxiclibsSupport(this);
  render = new WB_Render(this);
  initGui();
  initCamera();
  initGeometry();
  printConsole("re·collection ready...;");
}

void draw() {
  background(backgroundColor);
  if (show) {
    showCatalog();
  } 
  else {
    pushMatrix();
    updateCamera();
    displayGeometry();
    resetCamera();
    popMatrix();
    updateCatalog(); 
    updateGui();
  }
}

