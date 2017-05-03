import gab.opencv.*;
import org.opencv.core.Core;
import org.opencv.core.CvType;
import org.opencv.core.Mat;
import org.opencv.core.Rect;
import org.opencv.core.Scalar;
import org.opencv.imgproc.Imgproc;
import org.opencv.highgui.Highgui;
import java.util.*;
import java.nio.*;

PImage img,test;
OpenCV opencv;
//互动相关变量
int x,y;
int xf,yf;
int rectx,recty,rectx2,recty2;
boolean selection=false;
boolean cut=false;
Point[] ver=new Point[2];

void settings(){
  //设置窗口大小
  opencv = new OpenCV(this, "test.jpg");
  size(opencv.width, opencv.height);
}
void setup(){
  smooth();
  background(0);
  test=loadImage("test.jpg");
  rectMode(CORNERS);
}
void draw(){
  
   background(0);
   //画矩框后，若按下键1，则进行分割，分割后可按键2进行保存，鼠标按下可重新选矩形，重新分割
   if(keyPressed){
     if(key=='1'){
       cut=true;
     }else{
       cut=false;
     }
   }
   if(cut==false){
     image(test,0,0);
   }else{
     grabcut(rectx,recty,rectx2-rectx,recty2-recty);
   }
   //画矩形   
   noFill();
   stroke(0,255,0);
   strokeWeight(4);  
   if(selection)
     rect(x,y,xf,yf);      
}
void mousePressed(){
  x=mouseX;
  y=mouseY;
  xf=x;
  yf=y;
  selection=true;
  cut=false;
}
void mouseDragged(){
  xf=mouseX;
  yf=mouseY;
  cut=false;
}
void mouseReleased(){
  ver[0]=new Point(Math.min(x, xf), Math.min(y, yf));
  ver[1]=new Point(Math.max(x, xf), Math.max(y, yf));
  rectx=ver[0].x;recty=ver[0].y; 
  rectx2=ver[1].x;recty2=ver[1].y;
}
void grabcut(int x,int y,int x1,int y1){
  //传入选择的矩形的相关变量
  Rect rect=new Rect(x,y,x1,y1);   
  Mat mat=null;
  mat = Highgui.imread("F:/images/test.jpg");//加载原图
  
  Mat result=new Mat();//用于存放处理后图片的模型
  Mat bgModel=new Mat();// 定义背景模型
  Mat fgModel=new Mat();//定义前景模型
  Mat source = new Mat(1, 1, CvType.CV_8U, new Scalar(3));//用于筛选的模型
  Imgproc.grabCut(mat, result, rect, bgModel, fgModel,2,Imgproc.GC_INIT_WITH_RECT);
  //经过比较函数，利用source模型筛选出可能的前景（与3/GC_PR_FGD相同则返回对应值）
  Core.compare(result,source,result,Core.CMP_EQ);
  Mat foreground= new Mat(mat.size(), CvType.CV_8UC3, new Scalar(0, 0, 0)); //初始化前景模型
  //将分割后的前景进行赋值
  mat.copyTo(foreground, result);
  
  //图像显示时以字节形式需将mat转化 因为有多个通道叠加所以需通道分离再合并
  Mat out = new Mat(mat.rows(), mat.cols(), CvType.CV_8UC4);
  Mat alpha = new Mat(mat.rows(), mat.cols(), CvType.CV_8UC1, Scalar.all(255));
  byte [] bArray = new byte[mat.rows()*mat.cols()*4];
  img = createImage(mat.cols(), mat.rows(), ARGB);
  List<Mat> ch1 = new ArrayList<Mat>(3);
  List<Mat> ch2 = new ArrayList<Mat>(4);
  Core.split(foreground, ch1);
  ch2.add(alpha);
  ch2.add(ch1.get(2));
  ch2.add(ch1.get(1));
  ch2.add(ch1.get(0));
  Core.merge(ch2, out);
  out.get(0, 0, bArray);
  ByteBuffer.wrap(bArray).asIntBuffer().get(img.pixels);
  img.updatePixels();
  image(img,0,0);
  //截图保存
  if(key == '2') {
    int n = int(random(100000));
    save(n + ".png");
    println("image saved!");
  }
  out.release();
}