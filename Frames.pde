pt initialPoint, finalPoint, fixedPoint;
FR initialFrame, finalFrame, middleFrame;
FR[] frame;
Ball ballInitialFrame, ballFinalFrame, ballFixedPoint;
int numOfIntermediateFrames = 10;
float time = 0f;
float timeIncrement = 0.01f;
float angle, rotation = 0.0f, rotationIncrement = 0.0f;

float initialBallSize = 5;
float scalingIncrement = 2.5f;
float finalBallSize = 5;
float scaling=1.0f;

vec translation = V();
vec translationIncrement = V();
vec normal, axis;
int pickedFrame=-1; //can be 0 or 1 ; 0 - initial frame , 1 - final frame
boolean positionChanged = false;
float magicSizeFactor = 4;

void init(){
  ballFixedPoint = new Ball(); 
  //ballMiddleFrame = new Ball(); //ball to show intermediate frames
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
  
  showRotatedFrame(frame[0],initialBallSize,0);
  showRotatedFrame(frame[1],finalBallSize,0);
  if(positionChanged){ 
    calculateValues();
    positionChanged = false;
  }
  
  if(animating){
  time = time + timeIncrement;
  translation = translation.add(translationIncrement);
  rotation += rotationIncrement;
  }
  if(time>1){
    resetValues();
  }
 
  drawIntermediateFramePlaceHolders();
  
  if(animating){ 
    drawIntermediateFrame(rotation, translation);
  }
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
     if(isPickedForRotating(pickedPt,frame[0],initialBallSize)){
         pickedFrame = 0;
       }
      if(isPickedForRotating(pickedPt,frame[1],finalBallSize)){
         pickedFrame = 1;
       }
  } 
    
  fill(green);
  show(frame[0].O,4,false);
  show(frame[1].O,4,false);  
  fill(red);
  show(ballFixedPoint.pos,4,false);
}
void resetValues(){
    time = 0f;
    //ballMiddleFrame.setRadius(initialBallSize);
    translation = V();
    rotation = 0.0f;
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

void drawIntermediateFrame(float rotation, vec translation){
  
  vec midII = R(frame[0].I, rotation, axis);
  vec midJJ = R(frame[0].J, rotation, axis);
  vec midKK = R(frame[0].K, rotation, axis);
  pt midOO = P(fixedPoint,(R(V(fixedPoint, frame[0].O), rotation, axis)));
  
  midOO.add(translation);
  middleFrame.set(midII, midJJ, midKK, midOO);
  //ballMiddleFrame.setValues(middleFrame);
  //ballMiddleFrame.setRadius(initialBallSize* pow(scaling,time));
  showRotatedFrame(middleFrame,initialBallSize* pow(scaling,time),2);
}

FR getIntermediateFrame(float rotation, vec translation){
  
  vec midII = R(frame[0].I, rotation, axis);
  vec midJJ = R(frame[0].J, rotation, axis);
  vec midKK = R(frame[0].K, rotation, axis);
  pt midOO = P(fixedPoint,(R(V(fixedPoint, frame[0].O), rotation, axis)));
  
  midOO.add(translation);
  middleFrame.set(midII, midJJ, midKK, midOO);
  //ballMiddleFrame.setValues(middleFrame);
  //ballMiddleFrame.setRadius(initialBallSize* pow(scaling,time));
  return middleFrame;
}

void drawIntermediateFramePlaceHolders(){
  float ang = 0;
  vec trans = V();
  for(int i=0;i<numOfIntermediateFrames; i++){
    ang = (-angle/(numOfIntermediateFrames))*(i*10.0/9);
    trans = V(i*10.0/9, V(10,translationIncrement));
    float sfactor = pow(scaling,(i+1)*(1.0f/numOfIntermediateFrames));
    if(i!=0 && i!=numOfIntermediateFrames-1){
      showRotatedFrame(getIntermediateFrame(ang, trans),initialBallSize*sfactor,1);//i*(1/numOfIntermediateFrames)
    }
  }
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

void showRotatedFrame(FR frameToShow,float scale, int type) {
  float d = scale*magicSizeFactor;
  noStroke();
  pushMatrix();
  translate(frameToShow.O.x, frameToShow.O.y, frameToShow.O.z);
  stroke(red);
  strokeWeight(magicSizeFactor);
  line(0,0,0,d*frameToShow.I.x,d*frameToShow.I.y,d*frameToShow.I.z);
  stroke(green);
  line(0,0,0,d*frameToShow.J.x,d*frameToShow.J.y,d*frameToShow.J.z);
  stroke(blue);
  line(0,0,0,d*frameToShow.K.x,d*frameToShow.K.y,d*frameToShow.K.z);
  noStroke();
  
  switch(type){
    case 0:
      fill(magenta);
      break;
    case 1:
      fill(metal);
      break;
    case 2:
      fill(black);
      break;
  }
  show(P(d*frameToShow.I.x,d*frameToShow.I.y,d*frameToShow.I.z),magicSizeFactor);
  show(P(d*frameToShow.J.x,d*frameToShow.J.y,d*frameToShow.J.z),magicSizeFactor);
  show(P(d*frameToShow.K.x,d*frameToShow.K.y,d*frameToShow.K.z),magicSizeFactor);
  popMatrix();
  }
vec AxisAngleVec(FR f){
  return new vec(f.K.y - f.J.z,f.I.z-f.K.x,f.J.x -f.I.y);
}
float trace(FR f){
  return f.I.x+f.J.y+f.K.z;
}

boolean isPicked(pt of,FR fr){
  if(fr.O.x + 5 > of.x && fr.O.x-5 < of.x)
    if(fr.O.y + 5 > of.y && fr.O.y-5 < of.y)
      if(fr.O.z + 5 > of.z && fr.O.z-5 < of.z)
        return true;
  return false;
}

boolean isPickedForRotating(pt of, FR fr, float size){
  float s = size * magicSizeFactor;
  pt i = P(fr.O);
  i = i.add(s,fr.I);
  pt j  = P(fr.O);
  j = j.add(s,fr.J);
  pt k = P(fr.O);
  k = k.add(s,fr.K);
  if(i.x + 5 > of.x && i.x-5 < of.x)
    if(i.y + 5 > of.y && i.y-5 < of.y)
      if(i.z + 5 > of.z && i.z-5 < of.z)
        return true;
  if(j.x + 5 > of.x && j.x-5 < of.x)
    if(j.y + 5 > of.y && j.y-5 < of.y)
      if(j.z + 5 > of.z && j.z-5 < of.z)
        return true;
  if(k.x + 5 > of.x && k.x-5 < of.x)
    if(k.y +5 > of.y && k.y-5 < of.y)
      if(k.z + 5 > of.z && k.z-5 < of.z)
        return true;
   return false;
}

class FR { 
  pt O; vec I; vec J; vec K;
  FR () {O=P(); I=V(1,0,0); J=V(0,1,0); K=V(0,0,1);}
  FR(vec II, vec JJ, vec KK, pt OO) {I=V(II); J=V(JJ); K = V(KK); O=P(OO);}
  void set (vec II, vec JJ, vec KK, pt OO) {I=V(II); J=V(JJ); K = V(KK); O=P(OO);}
  
  void movePicked(vec V) { O.add(V);}
  void rotatePicked(float v){ 
    float angle = 0.05*v;
    println("\nAngle to rotate:"+angle);
    I = R(this.I,angle,this.K);
    J = R(this.J,angle,this.K);
    //K = R(this.K,angle,this.J);
  }
  void rotatePickedZ(float v){
    float angle = 0.05*v;
    println("\nAngle to rotate:"+angle);
    K = R(this.K,angle,this.I);
    //I = R(this.I,angle,this.K);
    J = R(this.J,angle,this.I);
    
  }

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