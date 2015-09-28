pt initialPoint, finalPoint, fixedPoint;
FR initialFrame, finalFrame;
Ball ballInitialFrame, ballFinalFrame, ballFixedPoint, ballMiddleFrame;
int numOfIntermediateFrames = 10;
float time = 0f;
float timeIncrement = 0.01f;
vec FP_IP, FP_FP;
float angle;
float scaling;
vec normal;

void init(){
  ballFixedPoint = new Ball(); 
  ballMiddleFrame = new Ball(); //ball to show intermediate frames
  scaling = 1.05f;
  normal = new vec(0,0,1);
}

void customizedInit(){
  initialPoint = new pt(-200, 0, 0);
  finalPoint = new pt(200,0,0);
  initialFrame =  new FR(new vec(1.0f,-1.0f,0), new vec(1.0f,1.0f,0), new vec(0,0,1),initialPoint); //3 -5 5 5 //1 -1 1 1
  finalFrame =  new FR(new vec(1.0f,1.0f,0), new vec(-1.0f,1.0f,0), new vec(0,0,1),finalPoint); //5 3 -3 5 //1 1 -1 1
  ballInitialFrame = new Ball(initialFrame);
  ballFinalFrame = new Ball(finalFrame);
  fixedPoint = GetSpiralCenter(initialFrame,finalFrame);
  ballFixedPoint.setPt(fixedPoint);
  
  FP_IP = V(initialPoint,fixedPoint);
  FP_FP = V(finalPoint,fixedPoint);
  angle = angle(FP_IP,FP_FP);
}

void Interpolate(){
  time = time + timeIncrement;
  if(time>1){
    time = 0f;
    ballMiddleFrame.setRadius(5);
  }
  
  drawIntermediateFrame();
    
  fill(green);
  show(ballInitialFrame.pos,5);
  show(ballFinalFrame.pos,5);  
  fill(red);
  show(ballFixedPoint.pos,5);
  fill(orange);
  show(ballMiddleFrame.pos,ballMiddleFrame.radius);
}

void drawIntermediateFrame(){
  vec perpendiToFp = N(FP_IP,normal);
  vec fpn = A(V(cos(angle*time),FP_IP),M(V(sin(angle*time),perpendiToFp))); // cos*FP_IP+sin*PerpendicularToFP_IP
  //fpn = V(pow(scaling,time),fpn); //for scaling - not sure if this is the desired way.
  pt ptn = P(fixedPoint,M(fpn));
  ballMiddleFrame.setPt(ptn);
  ballMiddleFrame.setRadius(pow(scaling,time)*ballMiddleFrame.radius); // for scaling - this should be the desired  method
}

public pt GetSpiralCenter(FR Fa, FR Fb){
  float a = angle(Fa.I,Fb.I); 
  float s = n(Fb.I)/n(Fa.I);
  pt G = spiralCenter(a,s,Fa.O,Fb.O);
  return G;
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

class FR { 
  pt O; vec I; vec J; vec K;
  FR () {O=P(); I=V(1,0,0); J=V(0,1,0); K=V(0,0,1);}
  FR(vec II, vec JJ, vec KK, pt OO) {I=V(II); J=V(JJ); K = V(KK); O=P(OO);}
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