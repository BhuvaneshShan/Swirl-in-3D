pt initialPoint, finalPoint, fixedPoint;
FR initialFrame, finalFrame, middleFrame;
Ball ballInitialFrame, ballFinalFrame, ballFixedPoint, ballMiddleFrame;
int numOfIntermediateFrames = 10;
float time = 0f;
float timeIncrement = 0.01f;
vec FP_IP, FP_FP;
float angle, rotation = 0.0f, rotationIncrement = 0.0f;
float scaling;
vec translation = V();
vec translationIncrement = V();
vec normal, axis;

void init(){
  ballFixedPoint = new Ball(); 
  ballMiddleFrame = new Ball(); //ball to show intermediate frames
  scaling = 1.05f;
  normal = new vec(0,0,1);
}

void customizedInit(){
  initialPoint = new pt(-200, 0, 0);
  finalPoint = new pt(200,200,200);
  initialFrame =  new FR(new vec(1.0f,-1.0f,0), new vec(1.0f,1.0f,0), new vec(0,0,1),initialPoint); //3 -5 5 5 //1 -1 1 1
  finalFrame =  new FR(new vec(-1.0f,1.0f,0), new vec(1.0f,1.0f,0), new vec(0,0,1),finalPoint); //5 3 -3 5 //1 1 -1 1
  middleFrame = new FR();
  ballInitialFrame = new Ball(initialFrame);
  ballFinalFrame = new Ball(finalFrame);
  
  
  //FP_IP = V(initialPoint,fixedPoint);
  //FP_FP = V(finalPoint,fixedPoint);
  axis = GetSpiralAxis(initialFrame, finalFrame);
  angle = GetRotAngle(initialFrame.I,finalFrame.I,axis);
  println("Axis:",axis.x,axis.y,axis.z);
  println("Angle:",angle*180/3.14159);
  rotationIncrement = -angle/100.0;
  fixedPoint = GetFixedPoint(initialFrame,finalFrame);
  println("Fixed Point:",fixedPoint.x, fixedPoint.y, fixedPoint.z);
  ballFixedPoint.setPt(fixedPoint);
  // = axis.mul(d(axis,V(initialFrame.O,finalFrame.O))).div(100.0); // Along the axis
  translationIncrement = V(d(axis,V(initialFrame.O,finalFrame.O)),axis).div(100.0);
}

void Interpolate(){
  
  showFrameArrows(initialFrame);
  showFrameArrows(finalFrame);
  drawIntermediateFramePlaceHolders();
  
  time = time + timeIncrement;
  translation = translation.add(translationIncrement);
  rotation += rotationIncrement;
  if(time>1){
    time = 0f;
    ballMiddleFrame.setRadius(5);
    translation = V();
    rotation = 0.0f;
  }
  
  drawIntermediateFrame();
    
  fill(green);
  show(ballInitialFrame.pos,5);
  show(ballFinalFrame.pos,5);  
  fill(red);
  show(ballFixedPoint.pos,5);
  fill(orange);
  show(ballMiddleFrame.pos,5);
}

void drawIntermediateFrame(){
  
  vec midII = R(initialFrame.I, rotation, axis);
  //println(midII.x, midII.y, midII.z);
  vec midJJ = R(initialFrame.J, rotation, axis);
  vec midKK = R(initialFrame.K, rotation, axis);
  pt midOO = P(fixedPoint,(R(V(fixedPoint, initialFrame.O), rotation, axis)));
  
  midOO.add(translation);
  middleFrame.set(midII, midJJ, midKK, midOO);
  //println(midOO.x, midOO.y, midOO.z);
  ballMiddleFrame.setValues(middleFrame);
}

void drawIntermediateFramePlaceHolders(){
  FR[] intermediateFramePlaceHolders = new FR[numOfIntermediateFrames];
  vec perpendiToFp = N(FP_IP,normal);
  float translationForPlaceHolders = initialPoint.z;
  float translationPlaceHolderIncrement = (finalPoint.z - initialPoint.z)/(numOfIntermediateFrames+1);
  float ang = 0;
  for(int i=0;i<numOfIntermediateFrames; i++){
    ang = (angle/(numOfIntermediateFrames+1))*(i+1);
    vec fpn = A(V(cos(ang),FP_IP),M(V(sin(ang),perpendiToFp))); // cos*FP_IP+sin*PerpendicularToFP_IP
    vec II = V(initialFrame.I);
    vec JJ = V(initialFrame.J);
    vec KK = V(initialFrame.K);
    pt ptn = P(fixedPoint,M(fpn));
    ptn.z = translationForPlaceHolders+(i+1)*translationPlaceHolderIncrement;
    intermediateFramePlaceHolders[i] = new FR(II,JJ,KK,ptn);
    showFrameArrows(intermediateFramePlaceHolders[i]);
  }
}

public pt GetSpiralCenter(FR Fa, FR Fb){
  float a = angle(Fa.I,Fb.I); 
  float s = n(Fb.I)/n(Fa.I);
  pt G = spiralCenter(a,s,Fa.O,Fb.O);
  return G;
}

public float GetRotAngle(vec Ia, vec Ib, vec Axis){
  return angle(ProjectOntoPlane(Ia, Axis),ProjectOntoPlane(Ib, Axis));
}

public pt GetFixedPoint(FR Fa, FR Fb){
  vec o = V(Fa.O,Fb.O);
  
  //pt P = (Fa.O.add(Fb.O).add(N(axis,o).div(tan(angle/2.0)))).div(2.0);
  
  pt P = P(A(Fa.O,Fb.O),N(axis,o).div(tan(angle/2.0))).div(2.0);
  
  return P;
}

public vec GetSpiralAxis(FR Fa, FR Fb){
  vec i = V(A(Fa.I,M(Fb.I)));
  vec j = V(A(Fa.J,M(Fb.J)));
  vec k = V(A(Fa.K,M(Fb.K)));
  
  vec Axis = V(A(A(N(i,j), N(j,k)), N(k,i)));
  Axis.normalize();
  return Axis;
}

public pt spiralCenter(float a, float z, pt A, pt C) {
  float c=cos(a), s=sin(a);
  float D = sq(c*z-1)+sq(s*z);
  float ex = c*z*A.x - C.x - s*z*A.y;
  float ey = c*z*A.y - C.y + s*z*A.x;
  float x=(ex*(c*z-1) + ey*s*z) / D;
  float y=(ey*(c*z-1) - ex*s*z) / D;
  return P(x,y);
}

void showFrameArrows(FR frameToShow){
  int d = 30;
  pushMatrix();
  translate(frameToShow.O.x,frameToShow.O.y,frameToShow.O.z);
  noStroke(); 
  fill(metal); sphere(d/10);
  fill(blue);  showArrow(d,d/10);
  fill(red); pushMatrix(); rotateY(PI/2); showArrow(d,d/10); popMatrix();
  fill(green); pushMatrix(); rotateX(-PI/2); showArrow(d,d/10); popMatrix();
  popMatrix();
}
class FR { 
  pt O; vec I; vec J; vec K;
  FR () {O=P(); I=V(1,0,0); J=V(0,1,0); K=V(0,0,1);}
  FR(vec II, vec JJ, vec KK, pt OO) {I=V(II); J=V(JJ); K = V(KK); O=P(OO);}
  void set (vec II, vec JJ, vec KK, pt OO) {I=V(II); J=V(JJ); K = V(KK); O=P(OO);}
  //FR(pt A, pt B) {O=P(A); I=V(A,B); J=R(I);}
  /*vec of(vec V) {return W(V.x,I,V.y,J);}
  pt of(pt P) {return P(O,W(P.x,I,P.y,J));}
  FR of(FR F) {return F(of(F.I),of(F.J),of(F.O));}
  vec invertedOf(vec V) {return V(det(V,J)/det(I,J),det(V,I)/det(J,I));}
  pt invertedOf(pt P) {vec V = V(O,P); return P(det(V,J)/det(I,J),det(V,I)/det(J,I));}
  FR invertedOf(FR F) {return F(invertedOf(F.I),invertedOf(F.J),invertedOf(F.O));}
  FR showArrow() {show(O,4); arrow(O,I); return this;}
  FR showArrows() {show(O,4); arrow(O,I); arrow(O,J); return this; }
  void printFR(){
    println("Frame:");
    print("Pt:"+O.x+","+O.y);
    print("Vec I:"+I.x+","+I.y);
    print("Vec J:"+J.x+","+J.y);
  }*/
  }
class Ball{
  pt pos;
  float radius = 5;
  Ball(){
    pos = new pt();
  }
  Ball(float x, float y, float z){
    pos = new pt(x,y,z);
  }
  Ball(FR fr){
    pos = new pt(fr.O.x,fr.O.y,fr.O.z);
  }
  public void show(){
    pushMatrix();
    translate(pos.x,pos.y,pos.z);
    sphere(radius);
    popMatrix();
  }
  public void setXYZ(float x, float y, float z){
    pos = pos.setTo(x,y,z);
  }
  public void setPt(pt loc){
    pos = pos.setTo(loc);
  }
  public void setValues(FR fr){
    pos = pos.setTo(fr.O);
  }
  public void setRadius(float rad){
    radius = rad;
  }
}

class Sphere{
  float x,y,z;
  float radius;
  Sphere(float x, float y, float z, float radius){
    this.x = x;
    this.y = y;
    this.z = z;
    this.radius = radius;
  }
  public void show(){
    pushMatrix();
    translate(x,y,z);
    sphere(radius);
    popMatrix();
  }
}