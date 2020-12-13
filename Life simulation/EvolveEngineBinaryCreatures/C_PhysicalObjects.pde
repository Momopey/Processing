class Point{
  PVector Pos;
  PVector Vel;
  PVector Acc=new PVector(0,0);
  float Mass;
  float Friction;//0,No friction, 1 Complete friction.
  boolean State=false;

  Point(PVector dPos,PVector dVel,float dMass,float dFriction){
    Pos=dPos; Vel=dVel; Mass= dMass; Friction=dFriction;//LogicType=DLogic;
  }
  Point ClonePoint(){ //Returns a Copy of a Particular Point.
    Point P=new Point(Pos.copy(),Vel.copy(),Mass,Friction);
    if(this instanceof Eye){
      P= new Eye(Pos.copy(),Vel.copy(),Mass,0);
    }if(this instanceof Logic){
      boolean[] B=new boolean[((Logic)this).UncheckedIn.length];
      arrayCopy(((Logic)this).UncheckedIn,B);
      P=new Logic(Pos.copy(),Vel.copy(),Mass,Friction,((Logic)this).LogicType,B);
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
    if(this instanceof Eye){
      if(State){
        Canvas.fill(255,215,215);
      }else{
        Canvas.fill(255,0,0);
      }
      Canvas.stroke(0);
      Canvas.strokeWeight(1*Cam.Zoom);
      Canvas.ellipse(Cam.RealToScreenX(Pos.x),Cam.RealToScreenY(Pos.y),15*Cam.Zoom,15*Cam.Zoom);
    }else if(this instanceof Logic){
      ((Logic)this).DrawLogic(Cam,Canvas);

    }else{
      Canvas.fill(255*lerp(1,0.2,Friction));
      Canvas.stroke(0);
      Canvas.strokeWeight(1.2*Cam.Zoom);
      Canvas.ellipse(Cam.RealToScreenX(Pos.x),Cam.RealToScreenY(Pos.y),17*Cam.Zoom,17*Cam.Zoom);
    }
  }
}
class Eye extends Point{
  Eye(PVector dPos,PVector dVel,float dMass,float  dFriction){
     super(dPos,dVel,dMass,dFriction);
  }
}
class Logic extends Point{
  int LogicType;
  boolean[]Inputs=new boolean[0];// All the Inputs given to node
  boolean[]UncheckedIn;
  int InputsUsed=0;
  Logic(PVector dPos,PVector dVel,float dMass,float dFriction,int dLogic,boolean[] Din){
    super(dPos,dVel,dMass,dFriction);
    LogicType=dLogic;
    UncheckedIn=Din;
  }
  void CalcLogic(){// Calculates the result of the node.
    boolean out= false;
    if(LogicType==0){
       out=Inputs[0]&&Inputs[1]; // and
    }if(LogicType==1){
      out= Inputs[0]||Inputs[1]; // or
    }if(LogicType==2){
      out= (Inputs[0]==false);  // not
    }
    State=out;
  }
  Boolean CalcPossible(){// Checks if calcultion is possible.   Just a precaution
    boolean out= false;
    if(LogicType==0){
       out=(Inputs.length>=2)||(UncheckedIn.length>=2);
    }if(LogicType==1){
      out= (Inputs.length>=2)||(UncheckedIn.length>=2);
    }if(LogicType==2){
      out= (Inputs.length>=1)||(UncheckedIn.length>=1);
    }
    return out;
  }
  void DrawLogic(Camera Cam,PGraphics Canvas){
    Canvas.stroke(0);
    Canvas.strokeWeight(1.2*Cam.Zoom);
    if(State){
      Canvas.fill(215*lerp(1,0.2,Friction),255*lerp(1,0.2,Friction),215*lerp(1,0.2,Friction));
    }else{
      Canvas.fill(0,200*lerp(1,0.2,Friction),0);
    }
    Canvas.ellipse(Cam.RealToScreenX(Pos.x),Cam.RealToScreenY(Pos.y),17*Cam.Zoom,17*Cam.Zoom);
    Canvas.fill(0,0,0,100);
    String Symbol="";
    if(LogicType==0){
      Symbol="&";
    }if(LogicType==1){
      Symbol="||";
    }if(LogicType==2){
      Symbol=" !";
    }
    Canvas.textSize(12*Cam.Zoom);
    Canvas.text(Symbol,Cam.RealToScreenX(Pos.x-4),Cam.RealToScreenY(Pos.y+4));
    for(int i=0;i<Inputs.length;i++){
      if(Inputs[i]){
        Canvas.fill(215,255,215);
      }else{
        Canvas.fill(0,200,0);
      }
      Canvas.ellipse(Cam.RealToScreenX(Pos.x+i*10),Cam.RealToScreenY(Pos.y+13),6*Cam.Zoom,6*Cam.Zoom);
    }
  }
}
class Muscle{
  int APoiNum;
  int BPoiNum;
  Point A;
  Point B;
  float Force;
  float Length;
  float Damp;
  float[] StateA=new float[3];// The force,length, damp of the muscle in state true,
  float[] StateB=new float[3];// In False.
  Boolean State=false;// State Given to Muscle.
  Organism O;
 
  Muscle(int dAPoiNum,int dBPoiNum,float dForceA,float dLengthA,float dDampA,float dForceB,float dLengthB,float dDampB){
    APoiNum= dAPoiNum; BPoiNum= dBPoiNum;
    StateA[0]=dForceA;StateA[1]=dLengthA; StateA[2]=dDampA;
    StateB[0]=dForceB;StateB[1]=dLengthB; StateB[2]=dDampB;
  }
  void SetPois(){// Sets the Points after a organism is given.
    A=O.PList.get(APoiNum);
    B=O.PList.get(BPoiNum);
  }
  Muscle CloneMuscle(){// Returns Copy of the muscle.
    return new Muscle(APoiNum,BPoiNum,StateA[0],StateA[1],StateA[2],StateB[0],StateB[1],StateB[2]);
  }
  void CalcForce(){// Sets the state,and updates the velocity of the two particles using spring physics.
   if(State){
      Force=StateA[0];Length=StateA[1];Damp=StateA[2];
   }else{
      Force=StateB[0];Length=StateB[1];Damp=StateB[2];
   }
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
    if(State){
        Force=StateA[0];Length=StateA[1];Damp=StateA[2];
    }else{
        Force=StateB[0];Length=StateB[1];Damp=StateB[2];
    }
    Canvas.stroke(0,0,0,(Force/(0.5))*255);
    Canvas.strokeWeight((9+Force*3)*Cam.Zoom);
    Canvas.line(Cam.RealToScreenX(A.Pos.x),Cam.RealToScreenY(A.Pos.y),Cam.RealToScreenX(B.Pos.x),Cam.RealToScreenY(B.Pos.y));
  }
}
class Neuron{
  int IPoiNum;
  boolean Final;  // Final means it goes into a muscle  
  int EPoiNum;
  int Delay;
  Point Ip;
  Point Ep;
  Muscle Em;
  Organism C;
 Boolean[] StateList=new Boolean[2*60];// List of states over time (2 seconds)
  Neuron(int dIPoiNum,boolean dFinal,int dEPoiNum,int dDelay){
    IPoiNum=dIPoiNum; Final=dFinal; EPoiNum=dEPoiNum; Delay=dDelay;
  }
  
  void SetPois(){//Sets up Points and muscles given a organism
    Ip=C.PList.get(IPoiNum);
    if(Final){
      Em=C.MList.get(EPoiNum);
    }else{
      Ep=C.PList.get(EPoiNum);
    }
    for(int i=0;i<StateList.length;i++){StateList[i]=false;}
  }
  Neuron CloneNeuron(){// Returns copy of neuron.
    return new Neuron(IPoiNum,Final,EPoiNum,Delay);
  }
  void DrawNeuLine(PVector Pa,PVector Pb,Camera Cam,PGraphics Canvas){
    PVector line= PVextend(PVadd(Pb,PVextend(Pa,-1)),1/float(Delay+1));
    Canvas.strokeWeight(2*Cam.Zoom);
    for(int I=0;I<Delay+1;I++){
      if(StateList[Delay+1-I]){
        Canvas.stroke(255,255,10);
      }else{
        Canvas.stroke(255,0,0);
      }
      Canvas.line(Pa.x+line.x*(Delay-I),Pa.y+line.y
      *(Delay-I),Pa.x+line.x*(Delay+1-I),Pa.y+line.y*(Delay+1-I));
    }
  }
  void DrawNeuron(Camera Cam, PGraphics Canvas){// Draws neuron.
    Canvas.strokeWeight(2);
    Canvas.stroke(255,0,0);
    if(Final==false){
      DrawNeuLine(Cam.RealToScreen(Ip.Pos),Cam.RealToScreen(Ep.Pos),Cam,Canvas);
    }else{
      DrawNeuLine(Cam.RealToScreen(Ip.Pos),Cam.RealToScreen(Em.Middle()),Cam,Canvas);
    }
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