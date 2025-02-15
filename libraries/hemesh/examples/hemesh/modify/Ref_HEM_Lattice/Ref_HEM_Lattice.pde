import wblut.math.*;
import wblut.processing.*;
import wblut.core.*;
import wblut.hemesh.*;
import wblut.geom.*;


HE_Mesh mesh;
WB_Render render;

void setup() {
  size(1000,1000,P3D);
  smooth(8);
  createMesh();
  // Tries to create a mesh lattice by insetting all faces,making an expanded copy and
  // then connect the inset faces...
  HEM_Lattice modifier=new HEM_Lattice();
  modifier.setWidth(10);// desired width of struts
  modifier.setDepth(10);// depth of struts
  modifier.setFuse(true);
  mesh.modify(modifier);
  
  render=new WB_Render(this);
}

void draw() {
  background(120);
  directionalLight(255, 255, 255, 1, 1, -1);
  directionalLight(127, 127, 127, -1, -1, 1);
  translate(width/2,height/2);
  rotateY(mouseX*1.0f/width*TWO_PI);
  rotateX(mouseY*1.0f/height*TWO_PI);
  fill(255);
  noStroke();
  render.drawFaces(mesh);

  stroke(0);
  render.drawEdges(mesh);
}


void createMesh(){
  HEC_Geodesic creator=new HEC_Geodesic().setC(2).setB(2).setRadius(300);
  mesh=new HE_Mesh(creator); 
  mesh.add(new HE_Mesh(new HEC_Grid(10,10,700,700).setCenter(0,0,-350)));
  
}
