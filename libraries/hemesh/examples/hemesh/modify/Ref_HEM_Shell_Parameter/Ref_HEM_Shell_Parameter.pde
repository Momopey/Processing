import wblut.math.*;
import wblut.processing.*;
import wblut.core.*;
import wblut.hemesh.*;
import wblut.geom.*;

HE_Mesh mesh;
WB_Render render;
HE_Selection sel;


class XGradient implements WB_ScalarParameter {
  public double evaluate(double...x ) {
    return map((float)x[0], -400.0, 400.0, 2, 50)*(1.0-0.5*sin(map((float)x[2], -400.0, 400.0, 0, 4*TWO_PI)));
  }
}

void setup() {
  size(1000, 1000, P3D);
  smooth(8);
  createMesh();
  HEM_Shell shell=new HEM_Shell().setThickness(new XGradient());//.setTwoSided(true);
  mesh.modify(new HEM_Slice().setPlane(0,0,0,0,1,0));
  mesh.modify(shell);
  render=new WB_Render(this);
}

void draw() {
  background(55);
  directionalLight(255, 255, 255, 1, 1, -1);
  directionalLight(127, 127, 127, -1, -1, 1);
  translate(width/2, height/2);
  rotateY(mouseX*1.0f/width*TWO_PI);
  rotateX(mouseY*1.0f/height*TWO_PI);
  stroke(0);
  render.drawEdges(mesh);
  noStroke();
  fill(255);
  render.drawFaces(mesh);
  fill(255,0,0);
  render.drawFaces(mesh.getSelection("boundary"));
}

void createMesh() {
  HEC_Creator creator=new HEC_Cube(200, 1, 1, 1);
  mesh=new HE_Mesh(creator); 
  HEM_Extrude ext=new HEM_Extrude().setDistance(300);
  mesh.modify(ext);
 
  HE_Selection sel=mesh.getSelection("extruded");
  mesh.deleteFaces(sel);
  mesh.subdivide(new HES_CatmullClark(), 4);
  
}
