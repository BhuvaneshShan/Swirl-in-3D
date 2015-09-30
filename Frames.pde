pt initialPoint, finalPoint, fixedPoint;
FR initialFrame, finalFrame, middleFrame;
FR[] frame;
Ball ballInitialFrame, ballFinalFrame, ballFixedPoint, ballMiddleFrame;
int numOfIntermediateFrames = 10;
float time = 0f;
float timeIncrement = 0.01f;
float angle, rotation = 0.0f, rotationIncrement = 0.0f;

float initialBallSize = 5;
//float initialScaleValue = 1.0f;
float scalingIncrement = 2.5f;
//float finalScaleValue = 2.0f;
float finalBallSize = 5;
float scaling=1.0f;

vec translation = V();
vec translationIncrement = V();
vec normal, axis;
int pickedFrame=-1; //can be 0 or 1 ; 0 - initial frame , 1 - final frame
boolean positionChanged = false;

void init(){
  ballFixedPoint = new Ball(); 
  ballMiddleFrame = new Ball(); //ball to show intermediate frames
  //scaling = 1.0f;
  normal = new vec(0,0,1);
  frame = new FR[2];
}

void customizedInit(){
  initialPoint = new pt(-200, 0, 0);
  finalPoint = new pt(200,0,200);
  //frame[0] = new FR(new vec(1.0f,0,0),new vec(0,0.8f,0.6f) , new vec(0,-0.6f,0.8f),initialPoint);//new vec(1.0f,1.0f,0)
  //frame[0] = new FR(I,J , R(K,PI/2,J), initialPoint);
  frame[0] = new FR(I,J,K,initialPoint);
  //initialFrame = frame[0]; //3 -5 5 5 //1 -1 1 1
  //frame[1] =  new FR(new vec(1.0f,0.0f,0),new vec(0.0f,0.0f,1.0f), new vec(0,-1,0.0f), finalPoint);//new vec(-1.0f,1.0f,0)
  //frame[1] =  new FR(R(frame[0].I,PI/2,K),R(frame[0].J,PI/2,K), new vec(0,0,1), finalPoint);
  frame[1] = new FR(new vec(1,0,0), new vec(0,0.6f,0.8f), new vec(0,-0.8f,0.6f),finalPoint);
  //finalFrame = frame[1]; //5 3 -3 5 //1 1 -1 1
  
  middleFrame = new FR();
  ballInitialFrame = new Ball(frame[0]);
  ballFinalFrame = new Ball(frame[1]);
  calculateValues();
}

void calculateValues(){
  axis = GetSpiralAxis(frame[0], frame[1]);
  angle = GetRotAngle(frame[0],frame[1],axis);
  println("Axis:",axis.x,axis.y,axis.z);
  println("Angle:",angle*180/3.14159);
  rotationIncrement = -angle/100.0;
  fixedPoint = GetFixedPoint(frame[0],frame[1]);
  println("Fixed Point:",fixedPoint.x, fixedPoint.y, fixedPoint.z);
  ballFixedPoint.setPt(fixedPoint);
  // = axis.mul(d(axis,V(initialFrame.O,finalFrame.O))).div(100.0); // Along the axis
  translationIncrement = V(d(axis,V(frame[0].O,frame[1].O)),axis).div(100.0);
  
}

void Interpolate(){
  
  showRotatedFrame(frame[0],initialBallSize);
  //frame[0].showArrows();
  //println("final frame: "+finalBallSize);
  showRotatedFrame(frame[1],finalBallSize);
  if(positionChanged){ 
    calculateValues();
    positionChanged = false;
  }
  
  time = time + timeIncrement;
  translation = translation.add(translationIncrement);
  rotation += rotationIncrement;
  if(time>1){
    time = 0f;
    ballMiddleFrame.setRadius(initialBallSize);
    translation = V();
    rotation = 0.0f;
  }
 
  drawIntermediateFramePlaceHolders();
   
  FR mf = drawIntermediateFrame(rotation, translation);
  
  //To move initial and final frames/balls
  if(mousePressed&&!keyPressed){
     pickedFrame = -1;
     pt pickedPt = pick( mouseX, mouseY);  
     print("Picked position:"+Of.x+","+Of.y+","+Of.z);   
     for(int i=0 ; i<2; i++){
       if(isPicked(pickedPt,frame[i])){
         pickedFrame = i;
       }
     }
  } 
    
  fill(green);
  show(frame[0].O,4,false);
  show(frame[1].O,4,false);  
  fill(red);
  show(ballFixedPoint.pos,4,false);
  fill(orange);
  show(mf,ballMiddleFrame.radius,true);
  
}
void show(FR frameToShow, float side, boolean cube)
{
  if(cube){
    float theta = acos((trace(frameToShow)-1)/2);
    vec axis = AxisAngleVec(frameToShow).div(2*sin(theta));
    float ang = axis.norm();
    axis = axis.normalize();
    pushMatrix(); translate(frameToShow.O.x,frameToShow.O.y,frameToShow.O.z); rotate(ang,axis.x,axis.y,axis.z); box(side); popMatrix();
    }
  else{pushMatrix(); translate(frameToShow.O.x,frameToShow.O.y,frameToShow.O.z); sphere(side); popMatrix();}
}

void show(pt p, float side, boolean cube)
{
  if(cube){
    pushMatrix(); translate(p.x,p.y,p.z); box(side); popMatrix();
    }
  else{pushMatrix(); translate(p.x,p.y,p.z); sphere(side); popMatrix();}
}

FR drawIntermediateFrame(float rotation, vec translation){
  
  vec midII = R(frame[0].I, rotation, axis);
  vec midJJ = R(frame[0].J, rotation, axis);
  vec midKK = R(frame[0].K, rotation, axis);
  pt midOO = P(fixedPoint,(R(V(fixedPoint, frame[0].O), rotation, axis)));
  
  midOO.add(translation);
  middleFrame.set(midII, midJJ, midKK, midOO);
  ballMiddleFrame.setValues(middleFrame);
  ballMiddleFrame.setRadius(initialBallSize* pow(scaling,time));
  return middleFrame;
}

void drawIntermediateFramePlaceHolders(){
  //FR[] intermediateFramePlaceHolders = new FR[numOfIntermediateFrames];
  //float translationForPlaceHolders = initialPoint.z;
  //float translationPlaceHolderIncrement = (finalPoint.z - initialPoint.z)/(numOfIntermediateFrames+1);
  float ang = 0;
  vec trans = V();
  for(int i=0;i<numOfIntermediateFrames; i++){
    ang = (-angle/(numOfIntermediateFrames))*(i*10.0/9);
    trans = V(i*10.0/9, V(10,translationIncrement));
    float sfactor = pow(scaling,(i+1)*(1.0f/numOfIntermediateFrames));
    if(i!=0 && i!=numOfIntermediateFrames-1){
      showRotatedFrame(drawIntermediateFrame(ang, trans),initialBallSize*sfactor);//i*(1/numOfIntermediateFrames)
    }
  }
}

public pt GetSpiralCenter(FR Fa, FR Fb){
  float a = angle(Fa.I,Fb.I); 
  float s = n(Fb.I)/n(Fa.I);
  pt G = spiralCenter(a,s,Fa.O,Fb.O);
  return G;
}

public float GetRotAngle(FR A, FR B, vec Axis){
 float angI = angle(ProjectOntoPlane(A.I, Axis),ProjectOntoPlane(B.I, Axis));
  float angJ = angle(ProjectOntoPlane(A.J, Axis),ProjectOntoPlane(B.J, Axis));
  float angK = angle(ProjectOntoPlane(A.K, Axis),ProjectOntoPlane(B.K, Axis));
  if (!Float.isNaN(angI)) return angI;
  else if (!Float.isNaN(angJ)) return angJ;
  return angK;
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
  
  //vec i = V(A(Fb.I,M(Fa.I)));
  //vec j = V(A(Fb.J,M(Fa.J)));
  //vec k = V(A(Fb.K,M(Fa.K)));
  
  
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

void showRotatedFrame(FR frameToShow,float scale) {
  float d = scale*4;//30;
  noStroke();
  pushMatrix();
  translate(frameToShow.O.x, frameToShow.O.y, frameToShow.O.z);
  stroke(red);
  strokeWeight(4);
  line(0,0,0,d*frameToShow.I.x,d*frameToShow.I.y,d*frameToShow.I.z);
  stroke(green);
  line(0,0,0,d*frameToShow.J.x,d*frameToShow.J.y,d*frameToShow.J.z);
  stroke(blue);
  line(0,0,0,d*frameToShow.K.x,d*frameToShow.K.y,d*frameToShow.K.z);
  noStroke();
  
  /*float theta = acos((trace(frameToShow)-1)/2);
  vec axis = AxisAngleVec(frameToShow).div(2*sin(theta));
  float ang = axis.norm();
  axis = axis.normalize();
  rotate(ang,axis.x,axis.y,axis.z);
  
  
  frameToShow.I = R(frameToShow.I,ang,axis);
  frameToShow.J = R(frameToShow.J,ang,axis);
  frameToShow.K = R(frameToShow.K,ang,axis);
  */
  /*float iangle = asin(frameToShow.I.y/frameToShow.I.norm());//angle(new vec(1,0,0),frameToShow.I);
  float jangle = asin(frameToShow.J.x/frameToShow.J.norm());//angle(new vec(0,1,0),frameToShow.J);
  
  fill(metal); sphere(4); //d/10
  fill(blue); showArrow(d,d/10); //z - k
  fill(red);  pushMatrix();  rotateY(PI/2); rotateX(-iangle); showArrow(d,d/10); popMatrix(); //x - i  
  fill(green); pushMatrix(); rotateX(-PI/2); rotateY(jangle); showArrow(d,d/10); popMatrix(); //y - j  
  */
  popMatrix();
  }
vec AxisAngleVec(FR f){
  return new vec(f.K.y - f.J.z,f.I.z-f.K.x,f.J.x -f.I.y);
}
float trace(FR f){
  return f.I.x+f.J.y+f.K.z;
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

boolean isPicked(pt of,FR fr){
  if(fr.O.x + 5 > of.x && fr.O.x-5 < of.x)
    if(fr.O.y + 5 > of.y && fr.O.y-5 < of.y)
      if(fr.O.z + 5 > of.z && fr.O.z-5 < of.z)
        return true;
  return false;
}

class FR { 
  pt O; vec I; vec J; vec K;
  FR () {O=P(); I=V(1,0,0); J=V(0,1,0); K=V(0,0,1);}
  FR(vec II, vec JJ, vec KK, pt OO) {I=V(II); J=V(JJ); K = V(KK); O=P(OO);}
  void set (vec II, vec JJ, vec KK, pt OO) {I=V(II); J=V(JJ); K = V(KK); O=P(OO);}
  
  void movePicked(vec V) { O.add(V);}
  
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