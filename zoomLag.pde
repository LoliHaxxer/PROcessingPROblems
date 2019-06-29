

ScaImage<Image> i;

PImage badi;

void setup()
{
  frameRate( 60 );
  fullScreen();
  badi = super.loadImage( "ddos.png" );
  i = new ScaImage( loadImage( "ddos.png" ) );
}


void draw()
{
  background( 0 );
  
  //Image ii = i.get( zoom );
  
  //g.image( ii, 0, 0 );
  
  g.image( badi, 0, 0, badi.width * zoom, badi.height * zoom );
  
  fps();
}

float azoom;
int frames;
int last = millis() ;

void fps()
{
  int now = millis();
  
  azoom += zoom;
  frames += 1;
  
  if( ( now - last ) * .001 >= 1 )
  {
    println( frames + " fps" );
    
    final float az = (float)azoom / frames;
    println( "average zoom: " + az );
    println( "image w: " + badi.width * az + " , h: " + badi.height * az );
    println();
    
    azoom = frames = 0;
    last = now;
  }
}

float zoom = 1;

void mouseWheel( MouseEvent e )
{
  float count = e.getCount();
  
  zoom *= 1 - count * .1;
}
