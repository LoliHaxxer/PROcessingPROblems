

PImage i;

void setup()
{
  size( 1200, 675 );
  i = loadImage( "ddos.png" );
}


void draw()
{
  background( 0 );
  
  g.image( i, 0, 0, i.width * zoom, i.height * zoom );
  
  fps();
}

int frames;
int last = millis() ;

void fps()
{
  int now = millis();
  
  frames += 1;
  
  if( ( now - last ) * .001 >= 1 )
  {
    println( frames + " fps" );
    frames = 0;
    last = now;
  }
}

float zoom = 1;

void mouseWheel( MouseEvent e )
{
  float count = e.getCount();
  
  zoom *= 1 - count * .1;
}
