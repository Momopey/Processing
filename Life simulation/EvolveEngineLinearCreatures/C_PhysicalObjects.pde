class Smart{
  String Type;//"Input","Node", or "Output"
  float State=0;
  float[]Weights;
  float Bias;
  float[]Inputs=new float[0];// All the Inputs given to node
  float[]UncheckedIn;
  String Activation;//"Relu", or "Sigmoid" 
  int InputsUsed=0;
  
  Smart(String dType,float[]dWeights,float dBias,float[] Din){
    Type=dType;
    Weights=dWeights;
    Bias=dBias;
    UncheckedIn=Din;
    if(Type=="Input"){
      Activation="Sigmoid";
    }else if(Type=="Node"){
      Activation="Sigmoid";//"Relu";
    }else if(Type=="Output"){
      Activation="Sigmoid";
    }
  }
  float Activation(float Val){
      if(Activation=="Relu"){
        return max(0,Val);
      }else if(Activation=="Sigmoid"){
        return 1.0/(1+exp(-Val));
      }else{
        return Val;
      }
  }
  void CalcState(){// Calculates the result of the node
    if(Type!="Input"){
      float out=0;
      for(int i=0;i<Inputs.length;i++){
        if(i<Weights.length){
          out+=Weights[i]*Inputs[i];
        }
      }
      out+=Bias;
      State=Activation(out);
    }
  }
  void MutateSmart(float MuteAmount){
    for(int i=0;i<Weights.length;i++){
      Weights[i]+=MuteAmount*randomGaussian()*0.1;
    }
    Bias+=MuteAmount*randomGaussian()*0.02;
  }
}

class Point extends Smart{
  PVector Pos;
  PVector Vel;
  PVector Acc=new PVector(0,0);
  float Mass;
  float Friction;//0,No friction, 1 Complete friction.
  float Radius;

  Point(PVector dPos,PVector dVel,float dMass,float dFriction,float[]dWeights,float dBias,float[] dIn){
     super("Node",dWeights,dBias,dIn);
    Pos=dPos; Vel=dVel; Mass= dMass; Friction=dFriction;//LogicType=DLogic;
    Radius=11;
  }
  Point(PVector dPos,PVector dVel,float dMass,float dFriction){//For Eye
    super("Input",new float[]{},0,new float[]{});
    Pos=dPos; Vel=dVel; Mass= dMass; Friction=dFriction;
    Radius=9;
  }
  Point ClonePoint(){ //Returns a Copy of a Particular Point.
    Point P;
    if(Type=="Input"){
     P=new Eye(Pos.copy(),Vel.copy(),Mass,Friction,((Eye)this).EyeRay.Dir.copy()); 
    }else{ //if(Type=="Node"){, Otherwise Node
     P=new Point(Pos.copy(),Vel.copy(),Mass,Friction,FArrayCopy(Weights),Bias,FArrayCopy(UncheckedIn));
    }
    return P;
  }
  PVector NextPos(){// Calc the next position of Point.
    return PVadd(Pos,PVadd(Vel,PVextend(Acc,0.5)));
  }
  void UpdateP(){// Updates the Positions, Velocities,and so on of the point.
    Pos=NextPos();
    Vel=PVadd(Vel,Acc);
    Acc=new PVector(0,0.3);//Grav
  }
  //void ApplyForce(PVector force){
  //  Acc=PVadd(Acc,PVextend(force,1/Mass));
  //}
  void DrawP(Camera Cam,PGraphics Canvas){// Draws Point.
     //if(Type!="Input"){
      Canvas.strokeWeight(2);
      //Canvas.text("State:"+State,Cam.RealToScreenX(Pos.x),Cam.RealToScreenY(Pos.y));  
      //Canvas.text("Weights:"+Weights.length,Cam.RealToScreenX(Pos.x),Cam.RealToScreenY(Pos.y+20));
      Canvas.stroke(0);
      Canvas.strokeWeight(1*Cam.Zoom);
      Canvas.fill(0,State*200,255);
      Canvas.ellipse(Cam.RealToScreenX(Pos.x),Cam.RealToScreenY(Pos.y),Radius*2*Cam.Zoom,Radius*2*Cam.Zoom);
      Canvas.stroke(0);
      for(int i=0;i<Inputs.length;i++){
        PVector DotPos= new PVector(Pos.x+(i-(float)(Inputs.length-1)/2.0)*10,Pos.y+16);
        
        Canvas.strokeWeight(3*Cam.Zoom);
        Canvas.stroke(0,Activation(Weights[i])*200,255);
        Canvas.line(Cam.RealToScreenX(DotPos.x),Cam.RealToScreenY(DotPos.y),Cam.RealToScreenX(Pos.x),Cam.RealToScreenY(Pos.y));
        
        
        Canvas.strokeWeight(1*Cam.Zoom);
        Canvas.stroke(0);
        Canvas.fill(0,Activation(Inputs[i])*200,255);
        Canvas.ellipse(Cam.RealToScreenX(DotPos.x),Cam.RealToScreenY(DotPos.y),8*Cam.Zoom,8*Cam.Zoom);
      }
      
      Canvas.stroke(0,100);
      Canvas.fill(0,Activation(Bias)*200,255,100);
      Canvas.ellipse(Cam.RealToScreenX(Pos.x),Cam.RealToScreenY(Pos.y),8*Cam.Zoom,8*Cam.Zoom);
     //}else{//Eye
      
     //}
  }
}
class Eye extends Point{
  Ray EyeRay;
  Eye(PVector dPos,PVector dVel,float dMass,float  dFriction,PVector RayDir){
     super(dPos,dVel,dMass,dFriction);
     EyeRay= new Ray(dPos, RayDir);
  }
  
  void DrawP(Camera Cam,PGraphics Canvas){// Draws Point.
    Canvas.strokeWeight(1*Cam.Zoom);
    if(State>0){
        Canvas.fill(State*200,0,255);
    }else{
        Canvas.fill(0,-State*200,255);
    }
    Canvas.ellipse(Cam.RealToScreenX(Pos.x),Cam.RealToScreenY(Pos.y),Radius*2*Cam.Zoom,Radius*2*Cam.Zoom);
    Canvas.strokeWeight(3*Cam.Zoom);
    Canvas.line(Cam.RealToScreenX(Pos.x),Cam.RealToScreenY(Pos.y),Cam.RealToScreenX(Pos.x+PVsetmag(EyeRay.Dir,Radius).x),Cam.RealToScreenY(Pos.y+PVsetmag(EyeRay.Dir,Radius).y));
    Canvas.strokeWeight(1.5*Cam.Zoom);
    Canvas.line(Cam.RealToScreenX(Pos.x),Cam.RealToScreenY(Pos.y),Cam.RealToScreenX(EyeRay.PrevInt.x),Cam.RealToScreenY(EyeRay.PrevInt.y));
    
  } 
  void UpdateP(){// Add eyeray update
    super.UpdateP();
    EyeRay.Pos=Pos;//Update raycaster pos
  }
  
  void SetState(Enviroment E){
    //State=E.InGround(this)? -1:1;
    State= EyeRay.RayValue(E.BList);
    //State= Activation(EyeRay.RayValue(E.BList));
  }
}
//class Logic extends Point{
//  int LogicType;
//  boolean[]Inputs=new boolean[0];// All the Inputs given to node
//  boolean[]UncheckedIn;
//  int InputsUsed=0;
//  Logic(PVector dPos,PVector dVel,float dMass,float dFriction,int dLogic,boolean[] Din){
//    super(dPos,dVel,dMass,dFriction);
//    LogicType=dLogic;
//    UncheckedIn=Din;
//  }
//  void CalcLogic(){// Calculates the result of the node.
//    boolean out= false;
//    if(LogicType==0){
//       out=Inputs[0]&&Inputs[1]; // and
//    }if(LogicType==1){
//      out= Inputs[0]||Inputs[1]; // or
//    }if(LogicType==2){
//      out= (Inputs[0]==false);  // not
//    }
//    State=out;
//  }
//  Boolean CalcPossible(){// Checks if calcultion is possible.   Just a precaution
//    boolean out= false;
//    if(LogicType==0){
//       out=(Inputs.length>=2)||(UncheckedIn.length>=2);
//    }if(LogicType==1){
//      out= (Inputs.length>=2)||(UncheckedIn.length>=2);
//    }if(LogicType==2){
//      out= (Inputs.length>=1)||(UncheckedIn.length>=1);
//    }
//    return out;
//  }
//  void DrawLogic(Camera Cam,PGraphics Canvas){
//    Canvas.stroke(0);
//    Canvas.strokeWeight(1.2*Cam.Zoom);
//    if(State){
//      Canvas.fill(215*lerp(1,0.2,Friction),255*lerp(1,0.2,Friction),215*lerp(1,0.2,Friction));
//    }else{
//      Canvas.fill(0,200*lerp(1,0.2,Friction),0);
//    }
//    Canvas.ellipse(Cam.RealToScreenX(Pos.x),Cam.RealToScreenY(Pos.y),17*Cam.Zoom,17*Cam.Zoom);
//    Canvas.fill(0,0,0,100);
//    String Symbol="";
//    if(LogicType==0){
//      Symbol="&";
//    }if(LogicType==1){
//      Symbol="||";
//    }if(LogicType==2){
//      Symbol=" !";
//    }
//    Canvas.textSize(12*Cam.Zoom);
//    Canvas.text(Symbol,Cam.RealToScreenX(Pos.x-4),Cam.RealToScreenY(Pos.y+4));
//    for(int i=0;i<Inputs.length;i++){
//      if(Inputs[i]){
//        Canvas.fill(215,255,215);
//      }else{
//        Canvas.fill(0,200,0);
//      }
//      Canvas.ellipse(Cam.RealToScreenX(Pos.x+i*10),Cam.RealToScreenY(Pos.y+13),6*Cam.Zoom,6*Cam.Zoom);
//    }
//  }
//}
class Muscle extends Smart{
  int APoiNum;
  int BPoiNum;
  Point A;
  Point B;
  float Force;
  float Length;
  float Damp;
  float[] StateA=new float[3];// The force,length, damp of the muscle in state true,
  float[] StateB=new float[3];// In False..
  Organism O;
 
  Muscle(int dAPoiNum,int dBPoiNum,float[] dStateA,float[] dStateB,float[]dWeights,float dBias,float[] dIn){
    super("Output",dWeights,dBias,dIn);
    APoiNum= dAPoiNum; BPoiNum= dBPoiNum;
    StateA=dStateA;
    StateB=dStateB;
  }
  void SetPois(){// Sets the Points after a organism is given.
    A=O.PList.get(APoiNum);
    B=O.PList.get(BPoiNum);
  }
  Muscle CloneMuscle(){// Returns Copy of the muscle.
    return new Muscle(APoiNum,BPoiNum,FArrayCopy(StateA),FArrayCopy(StateB),FArrayCopy(Weights),Bias,FArrayCopy(UncheckedIn));
  }
  void CalcForce(){// Sets the state,and updates the velocity of the two particles using spring physics.
    Force=FlLerp(StateA[0],StateB[0],State);Length=FlLerp(StateA[1],StateB[1],State);Damp=FlLerp(StateA[2],StateB[2],State);
    PVector Dist=new PVector(B.Pos.x-A.Pos.x,B.Pos.y-A.Pos.y);
    float Len=sqrt(Dist.x*Dist.x+Dist.y*Dist.y);
    //PVector NDist=PVextend(Dist,1.0/Len);
    A.Vel=PVDivide(A.Vel,Dist);
    B.Vel=PVDivide(B.Vel,Dist);
    
    PVector Slide=PVextend(PVadd(PVextend(A.Vel,A.Mass),PVextend(B.Vel,B.Mass)),1.0/(A.Mass+B.Mass));

    A.Vel=PVadd(A.Vel,new PVector((1-Length/Len)*Force/A.Mass,0));
   
    A.Vel.x-=Slide.x;
    A.Vel.x*=Damp;
    A.Vel.x+=Slide.x;
    
    B.Vel=PVadd(B.Vel,new PVector(-(1-Length/Len)*Force/B.Mass,0));

    B.Vel.x-=Slide.x;
    B.Vel.x*=Damp;
    B.Vel.x+=Slide.x;
    
    A.Vel=PVMult(A.Vel,Dist);
    B.Vel=PVMult(B.Vel,Dist);
  }  
  PVector Middle(){//Returns middle of points.
    return new PVector((A.Pos.x+B.Pos.x)/2,(A.Pos.y+B.Pos.y)/2);
  }
  void DrawM(Camera Cam ,PGraphics Canvas){// Draws Muscle.
    Force=FlLerp(StateA[0],StateB[0],State);
    Canvas.stroke(0,0,0,(Force/(0.5))*255);
    Canvas.strokeWeight(11*Cam.Zoom);
    Canvas.line(Cam.RealToScreenX(A.Pos.x),Cam.RealToScreenY(A.Pos.y),Cam.RealToScreenX(B.Pos.x),Cam.RealToScreenY(B.Pos.y));
    if(State>0){
      Canvas.fill(0,State*200,255);
    }else{
      Canvas.fill(-State*200,0,255);
    }
    ///Canvas.text("State:"+State,Cam.RealToScreenX(Middle().x),Cam.RealToScreenY(Middle().y));
    //for(int i=0;i<Inputs.length;i++){
    //  Canvas.text("Input "+i+" :"+Inputs[i],Cam.RealToScreenX(Middle().x),Cam.RealToScreenY(Middle().y+10+i*15));
    //}
  }
}
class Nerve{
  int IPoiNum;
  boolean Final;  // Final means it goes into a muscle  
  int EPoiNum;
  int Delay;
  Smart I;
  Smart O;
  Organism C;
 float[] StateList=new float[2*60];// List of states over time (2 seconds)
  Nerve(int dIPoiNum,boolean dFinal,int dEPoiNum,int dDelay){
    IPoiNum=dIPoiNum; Final=dFinal; EPoiNum=dEPoiNum; Delay=dDelay;
  }
  
  void SetPois(){//Sets up Points and muscles given a organism
    I=(Smart)C.PList.get(IPoiNum);
    if(Final){
      O=(Smart)C.MList.get(EPoiNum);
    }else{
      O=(Smart)C.PList.get(EPoiNum);
    }
    for(int i=0;i<StateList.length;i++){StateList[i]=0;}
  }
  Nerve CloneNerve(){// Returns copy of Nerve.
    return new Nerve(IPoiNum,Final,EPoiNum,Delay);
  }
  void DrawNeuLine(PVector Pa,PVector Pb,Camera Cam,PGraphics Canvas){
    PVector line= PVextend(PVadd(Pb,PVextend(Pa,-1)),1/float(Delay+1));
    Canvas.strokeWeight(3*Cam.Zoom);
    for(int I=0;I<Delay+1;I++){
      float val=StateList[Delay+1-I];
      if(val>0){
        Canvas.stroke(0,val*200,255);
      }else{
        Canvas.stroke(-val*200,0,255);
      }
      Canvas.line(Pa.x+line.x*(Delay-I),Pa.y+line.y
      *(Delay-I),Pa.x+line.x*(Delay+1-I),Pa.y+line.y*(Delay+1-I));
    }
  }
  void DrawNerve(Camera Cam, PGraphics Canvas){// Draws Nerve.
    Canvas.strokeWeight(2);
    Canvas.stroke(255,0,0);
    if(Final==false){// Dangerous casting
      DrawNeuLine(Cam.RealToScreen(((Point)I).Pos),Cam.RealToScreen(((Point)O).Pos),Cam,Canvas);
    }else{
      DrawNeuLine(Cam.RealToScreen(((Point)I).Pos),Cam.RealToScreen(((Muscle)O).Middle()),Cam,Canvas);
    }
  }
}
class Ray{
  PVector Pos;
  PVector Dir;
  
  PVector PrevInt;
  Ray( PVector dPos,PVector dDir){
    Pos=dPos;
    Dir=dDir;
    PrevInt=PVextend(Dir,Float.MAX_VALUE);
  }
  
  boolean Intersects(ArrayList<Barrier> B){
    for(Barrier b: B){
       if(Intersects(b)){
          return true; 
       }
    }
    return false;
  }
  PVector IntersectPoint(ArrayList<Barrier> B){
     float dist=Float.MAX_VALUE;
     PVector point=new PVector(Float.MAX_VALUE,Float.MAX_VALUE);
     for(Barrier b: B){
       if( Intersects(b)){
         PVector inter= IntersectPoint(b);
         if(PVmag(inter)<dist){
            dist= PVmag(inter);
            point= inter;
         }
       } 
     }
     PrevInt=point;
     return point;
  }
  float RayLength(ArrayList<Barrier> B){
     float dist=1000000000;
     for(Barrier b: B){
       if( Intersects(b)){
         PVector inter= IntersectPoint(b);
         if(PVmag(inter)<dist){
            dist= PVmag(inter);
         }
       } 
     }
     return dist;
  }
  float RayValue(ArrayList<Barrier> B){
     PVector inter= IntersectPoint(B);
     return PVDivide(PVadd(inter,PVminus(Pos)),Dir).x; 
  }
  
  boolean Intersects(Barrier b){
    PVector relPos= b.RelPos(Pos);
    PVector relDir= PVDivide(Dir,b.Base);
    return FLtween(0,1,relPos.x-relPos.y*relDir.x/relDir.y);
  }
  float RayLength(Barrier b){
    return PVmag(IntersectPoint(b));
  }
  PVector IntersectPoint(Barrier b){
    PVector relPos= b.RelPos(Pos);
    PVector relDir= PVDivide(Dir,b.Base);
    PVector intersect= new PVector(relPos.x-relPos.y*relDir.x/relDir.y,0);
    return b.ToPos(intersect);
  }
}

class Barrier{// Class for barr
  PVector Corner;
  PVector Base;
  
  float Bounce;
  float Slide;
  Barrier(PVector DCorner,PVector DBase,float DBounce,float DSlide){
    Corner=DCorner; Base=DBase; Bounce= DBounce; Slide = DSlide;
  }
  Barrier CloneBarrier(){
    return new Barrier(Corner,Base,Bounce,Slide);
  }
  PVector RelPos(PVector p){// Point -> relative point
    return PVDivide(PVadd(p,PVextend(Corner,-1)),Base);
  }
  PVector ToPos(PVector rel){// Relative Point -> point;
    return PVadd(PVMult(rel,Base),Corner); 
  }
   boolean CollidesGiven(Point Po,PVector Posr,PVector Nextr){// Checks if a Point is going to collide this frame.
    float radius=-8.5/PVmag(Base);
    return (((Posr.y>radius)&&(Nextr.y<=radius))||((Posr.y<0)&&(Nextr.y>radius))
    ||((Posr.y==radius)&&(Nextr.y>=radius))
    )&&
    (BetweenBarrier(Po,Posr,Nextr));
  }
  boolean Collides(Point Po){
    PVector Posr=PVDivide(PVadd(Po.Pos,PVextend(Corner,-1)),Base);
    PVector Nextr=PVDivide(PVadd(Po.NextPos(),PVextend(Corner,-1)),Base);
    return CollidesGiven(Po,Posr,Nextr);
  }
  boolean BetweenBarrier(Point Po,PVector Posr,PVector Nextr){// checks if the Point is in the middle
    //PVector Posr=PVDivide(PVadd(Po.Pos,PVextend(Corner,-1)),Base);
    //PVector Nextr=PVDivide(PVadd(Po.NextPos(),PVextend(Corner,-1)),Base);
    return ((Posr.x>=0)&&(Posr.x<=1))||((Nextr.x>=0)&&(Nextr.x<=1));
  }
  
  boolean Rests(Point Po){ // Checks if a point has stopped bouncing and is stable
    //Point PoS= new Point(Po.Pos,Po.Vel,Po.Mass);
    //PoS.Acc=Po.Acc;
    //boolean Rest=false;
    //if(Collides(PoS)){
    //  BouncePoi(PoS);
    //  if(Collides(PoS)){
    //    Rest=true;
    //  }
    //}
    print("Checks for rest now, fix pls");
    return false;
  }
  
  void BouncePoi(Point Po,PVector Rvel,PVector RAcc){// Applies bouncy physics
    //PVector Rvel=PVDivide(Po.Vel,Base);
    //PVector RAcc=PVDivide(Po.Acc,Base);
    RAcc.x*=1+Slide*(Rvel.y+RAcc.y); 
    Rvel.y*=-Bounce;
    Rvel.x*=1-Po.Friction;
    Po.Vel=PVMult(Rvel,Base);
    Po.Acc=PVMult(RAcc,Base); 
  }
  void StablisePoi(Point Po, PVector RVel,PVector RAcc){// Stableises point, stops fallthrough
    //PVector RVel=PVDivide(Po.Vel,Base);
    RVel.y=0;
    Po.Vel=PVMult(RVel,Base); 
    
    //PVector RAcc=PVDivide(Po.Acc,Base);
    RAcc.y=0;
    //Po.Acc=PVMult(RAcc,Base); 
  }
  void CheckColl(Point Po){// Checks and updates point according to bouncy.
    PVector Posr=PVDivide(PVadd(Po.Pos,PVextend(Corner,-1)),Base);
    PVector Nextr=PVDivide(PVadd(Po.NextPos(),PVextend(Corner,-1)),Base);
    PVector Rvel=PVDivide(Po.Vel,Base);
    PVector RAcc=PVDivide(Po.Acc,Base);
    if(CollidesGiven(Po,Posr,Nextr)){
      //BouncePoi(Po,Rvel,RAcc);
      //Bounce the particle
      RAcc.x*=1+Slide*(Rvel.y+RAcc.y); 
      Rvel.y*=-Bounce;
      Rvel.x*=1-Po.Friction;
  
      Nextr=PVadd(Posr,PVadd(Rvel,PVextend(RAcc,0.5)));
      if(CollidesGiven(Po,Posr,Nextr)){// Still collides
        Rvel.y=0;//Stablize
        RAcc.y=0;
      }
    }
    Po.Vel=PVMult(Rvel,Base);
    Po.Acc=PVMult(RAcc,Base); 
  }
  boolean WithinBarr(Point P){// checks if Point is under the barrier
    return (PVDivide(PVadd(P.Pos,PVextend(Corner,-1)),Base).y>0)
    &&(FLtween(Corner.x,Base.x+Corner.x,P.Pos.x));
  }
  void DrawBarr(Camera Cam,PGraphics Canvas){
    Canvas.stroke(25, 178, 50);
    Canvas.fill(25, 178, 50);
    Canvas.triangle(Cam.RealToScreenX(Corner.x),Cam.RealToScreenY(Corner.y),Cam.RealToScreenX(Corner.x+Base.x),Cam.RealToScreenY(Corner.y+Base.y),Cam.RealToScreenX(Corner.x),height);
    Canvas.triangle(Cam.RealToScreenX(Corner.x),height,Cam.RealToScreenX(Corner.x+Base.x),height,Cam.RealToScreenX(Corner.x+Base.x),Cam.RealToScreenY(Corner.y+Base.y));
    Canvas.strokeWeight(3*Cam.Zoom);
    Canvas.stroke(0, 127, 20);
    Canvas.line(Cam.RealToScreenX(Corner.x),Cam.RealToScreenY(Corner.y),Cam.RealToScreenX(Corner.x+Base.x),Cam.RealToScreenY(Corner.y+Base.y));
  }
}