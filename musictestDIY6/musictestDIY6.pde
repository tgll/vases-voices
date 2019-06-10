//=============================================================================
// GILLIARD Tallulah / avril 2018
//
//=============================================================================
import ddf.minim.*;
import processing.svg.*;
PrintWriter output;
Minim minim;
AudioInput in;
AudioRecorder recorder;

int sizeX; // screen size x
int sizeY; // screen size y
int i; // pixels
int dec = 20; // Décalage des points de contrôle
float previousValue = -2;

ArrayList values = new ArrayList<Float>();
ArrayList bezierVertexes = new ArrayList<Integer[]>();


//=============================================================================
// SETUP
//=============================================================================
void setup()
{
  frameRate(60);
  background(0); 
  size(600, 600, P2D);
  sizeX = 600;
  sizeY = 600;
  i = 0;
  minim = new Minim(this);
 
  in = minim.getLineIn();
  // create a recorder that will record from the input to the filename specified
  // the file will be located in the sketch's root folder.
  recorder = minim.createRecorder(in, "myrecording.wav");
 
  // Add the first point
  bezierVertexes.add(new int[] {-1, -1, -1, -1, -1, -1});
  textFont(createFont("Arial", 12));
  
  // Create a new .svg file in the sketch directory
  output = createWriter("curvesbeziersVASE.svg"); 

}


//=============================================================================
// DRAW LOOP
//=============================================================================
void draw()
{
    int step = 20;
    if(frameCount % (60 / 50) == 0 && i < sizeX)
    {
      float currentValue = abs(in.left.get(in.bufferSize()/2)) * 500;       
      if(i > 1 && i % step == 0) {
        stroke(255,0,0);
        strokeWeight(2);
        stroke(255,255,255);
        strokeWeight(1);
        
        // Mise en mémoire des points de béziers pour pouvoir les afficher ensuite
        if(i >= step) {
          int[] previousValue = (int[]) bezierVertexes.get(i / step - 1);
          if(previousValue[0] == -1)
            // first
            bezierVertexes.add(new int[] {0, sizeY / 2, i - dec, sizeY / 2 - (int) currentValue, i, sizeY / 2 - (int) currentValue});
          else
            bezierVertexes.add(new int[] {previousValue[4] + dec, previousValue[5], i - dec, sizeY / 2 - (int) currentValue, i, sizeY / 2 - (int) currentValue });
        }
      }
      i+= 1;
      values.add(currentValue);
    }
    
    // SVG storage process
    if (i >= sizeX){
        // SVG file if recording at the end of screen
        WriteSVG(); 
    }
    else
      // display curve on screen
      drawBezierCurve();
    
}

//=============================================================================
// FUNCTIONS
//=============================================================================

void drawBezierCurve(){
    // Beziers drawing process on processing screen
    createShape();
    beginShape();
    noFill();
    vertex(0, sizeY / 2);
    for(int i = 1; i < bezierVertexes.size(); i++) {
      int[] currentValue = (int[])  bezierVertexes.get(i);
      if(currentValue[0] != -1)
        bezierVertex(currentValue[0], currentValue[1], currentValue[2], currentValue[3], currentValue[4], currentValue[5]);
    }
    endShape();
}

void WriteSVG(){
    // write the svg inside the file
    output.println("<?xml version=\"1.0\" standalone=\"no\"?>");
    output.println("<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\""); 
    output.println("\"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">");
    output.println("<svg width=\"500\" height=\"500\" version=\"1.1\"");
    output.println("xmlns=\"http://www.w3.org/2000/svg\">");
    output.println(" ");
    output.print("<path d=\"M 0 " + sizeY / 2 + " C ");
    for(int i = 1; i < bezierVertexes.size(); i++) {
      int[] currentValue = (int[])  bezierVertexes.get(i);
      if(currentValue[0] != -1)
          if (i == 1)
            output.print(currentValue[0] + " " + currentValue[1] + " " + currentValue[2] + " " + currentValue[3] + " " + currentValue[4] + " " +  currentValue[5]);
          else
            output.print(" S " + currentValue[2] + " " + currentValue[3] + ", " + currentValue[4] + " " + currentValue[5]);
    }           
    output.println("\" stroke=\"black\" fill=\"transparent\"/>");
    output.println("</svg>");
   
    output.flush(); // Writes the remaining data to the file
    output.close(); // Finishes the file
}