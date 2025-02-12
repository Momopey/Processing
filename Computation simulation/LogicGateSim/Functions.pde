/* Bunch a unbelivably useful functions */

PVector PVadd(PVector A,PVector B){
  return new PVector(A.x+B.x,A.y+B.y);
}
PVector PVscale(PVector A,float B){
  return new PVector(A.x*B,A.y*B);
}

PVector PVlerp(PVector A, PVector B, float l){
 return new PVector(A.x*(1-l)+B.x*l, A.y*(1-l)+B.y*l);
}
PVector PVsetmag(PVector P,float L){
  return PVscale(P,L/PVmag(P));
}
PVector PVminus(PVector P){
  return PVscale(P,-1);
}
float PVmag(PVector P){
  return dist(0,0,P.x,P.y);
}
PVector PVmult(PVector A,PVector B){
  return new PVector(A.x*B.x-A.y*B.y,A.x*B.y+A.y*B.x);
}
PVector PVdivide(PVector P,PVector C){
  return new PVector((C.x*P.x+C.y*P.y)/((C.x*C.x)+(C.y*C.y)),
  (C.x*P.y-C.y*P.x)/((C.x*C.x)+(C.y*C.y)));
}

String PVstring(PVector P){
  return " X:"+ P.x+" Y:"+P.y;
}

Boolean FLtween(float A,float B,float M){
  return ((M>=A)&&(M<=B))||((M<=A)&&(M>=B));
}


public <T> ArrayList<T> intersection(ArrayList<T> list1, ArrayList<T> list2) {
    ArrayList<T> list = new ArrayList<T>();

    for (T t : list1) {
        if(list2.contains(t)) {
            list.add(t);
        }
    }

    return list;
}