import processing.serial.*;
Serial myPort;

BufferedReader reader;
String line;

PrintWriter output;

int bx = 50;
int by = 60;
boolean locked = false, read_button = false, write_button = false ;
int pointX =0 , pointY = 0, prev_px =0 , prev_py = 0, i = 0, page_no = 1;
int penDOWN = 0  ;
int  tempo, k = -1, ra=200 , _portCount;
String z;
PFont fontA;

void setup() 
{
  size(1000, 700 );
  background(50, 50, 100);
  fill(0);
  rect( bx , by , 900 , 600);
  rect( 960 , 10 ,30, 30);    
  //rect(500 , 10 , 80, 30);
  //rect(600 , 10, 80, 30);
  //rect(700 , 10, 80, 30);

  fontA = loadFont("Stencil.vlw");
  textFont(fontA, 48);
  text("S C A R A", 50, 45);

  println(Serial.list());
  Serial_try_catch();

  fill(150);
  textSize(26);
  text("r", 965, 35);
  textFont(fontA, 22);

  //text("open", 500 , 40); 
  //text("saveA", 600 , 40); 
  //text("saveB", 700 , 40); 
}

void draw() 
{ 
  if( page_no > 1 )
  { 
    strokeWeight(8);
    stroke(250);
    fill(250);
    if(prev_px != pointX  || prev_py != pointY) 
    {
      point(pointX , pointY);
      if( pointX == 1550 && pointY == ( 660 - 1500 ) ) delay(500); 

      _Serialwrite( pointX - bx ,  600 - ( pointY - by ));

      prev_px = pointX;
      prev_py = pointY;

      if(write_button == true)
      {
        output.println( pointX );
        output.println( pointY );
      }
    }   
    if( penDOWN == 1 ) { 
      penDown(); 
      penDOWN = 0 ; 
    }

    delay(5);
    ///////////////////////////////////////////
    /////////////////////////////////////////

    if(read_button == true)
    {
      for(i=0; i<2 ; i++)
      {
        try {
          line = reader.readLine();
        } 
        catch (IOException e) {
          e.printStackTrace();
          line = null;
        }
        if (line == null) {
          read_button = false;  
        }
        else
        {
          if( i % 2 == 0)
            pointX = (Integer.parseInt(line));  
          else
            pointY = (Integer.parseInt(line));  
        }
      }
      delay(30);
    }
  }  
}

void mousePressed() {
  if( page_no == 1)
  {
    if(_portCount > 0)
    { 
      if( mouseX > 200 && mouseX < 300)
       {     
        for( tempo = 200 ; tempo <= (( _portCount * 50) + 150) ; tempo+=50)
         if( mouseY > tempo && mouseY< (tempo + 30))
          {
              k = ( (tempo - 200 )/ 50) ;
              myPort = new Serial(this, Serial.list()[k], 9600);
              page_no++;
              fill(0);
              stroke(0); 
              rect( bx , by , 900 , 600);
              println("=========================");
              print("Com port selected : ");
              println( Serial.list()[k] );
          }
      }
    }
  } 
  else 
    if( page_no > 1)
  {
    if (mouseX > bx && mouseX < (bx+ 900) && 
      mouseY > by && mouseY < (by+ 600)) 
    { 
      pointX = mouseX; 
      pointY = mouseY; 
      penDOWN = 1; 
      locked = true; 
    }  
    else 
      locked = false;

    if (mouseX > 960 && mouseX < 990 && 
      mouseY > 10 && mouseY < 40) 
    {
      fill(0);
      stroke(0); 
      rect( bx , by , 900 , 600);
    }

    if (mouseX > 500 && mouseX < 580 && 
      mouseY > 10 && mouseY < 40) 
    { 
      reader = createReader("positions.txt"); 
      read_button = true;
    }    
    if (mouseX > 600 && mouseX < 680 && 
      mouseY > 10 && mouseY < 40) 
    {
      output = createWriter("positions.txt");
      write_button = true;
    }
    if (mouseX > 700 && mouseX < 790 && 
      mouseY > 10 && mouseY < 40) 
    {
      write_button = false;
      output.flush(); 
      output.close();
    }
  }
}
void mouseDragged() {
  if (mouseX > bx && mouseX < (bx+ 900) && 
    mouseY > by && mouseY < (by+ 600)) 
    if(locked) {
      pointX = mouseX; 
      pointY = mouseY; 
    }
}

void mouseReleased() {
  locked = false;
if( page_no > 1 )
{
  _Serialwrite(1499, 1499);
  if(write_button == true)
  {
    output.println(1549);
    output.println(660 - 1499);
  }
}
}

void _Serialwrite( int x, int y)
{
  myPort.write(x>>8);
  myPort.write(x);

  myPort.write(y>>8);
  myPort.write(y);
}

void penDown()
{
  //delay(300);
  _Serialwrite(1500,1500);
  if(write_button == true)
  {
    output.println(1550);
    output.println(660 - 1500);
  }
}


void Serial_try_catch()
{
  noFill();
  rect(155,120, 490, 50);
  fill(150);
  textFont(fontA, 20);
  text("Select the Serial Port connected to the SCARA !!!", 170, 150);

  do
  {
    try
    {
      z = Serial.list() [_portCount];
    } 
    catch( Exception e )
    {
      z = "madu";
    }
    if( z != "madu")
    {
      fill(50); 
      rect(200, ra, 100, 30);
      fill(255);
      text(z, 215, ra + 23);
      ra= ra + 40;  
    }
    _portCount++;
  }
  while( z !="madu");
  _portCount--;
  textFont(fontA, 18);
  if( _portCount == 0 ) {
    text(" No com port found :( ", 180, 250);
    textFont(fontA,16);
    text("Make sure you have connected the arduino board to the system and then restart the drawing board ", 180, 300, 300,300);

  }
}


