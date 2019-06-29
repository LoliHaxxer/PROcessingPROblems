import java.util.*;


Image loadImage( String s )
{
  return new Image( super.loadImage( s ) );
}

static int[] corners( PImage i, float xDivY )
{
  try{
  return corners( i.width, i.height, xDivY );
  }
  catch(Exception e)
  {
    e.printStackTrace();
    return null;
  }
}
//i rectangular
static int[] corners( int w, int h, float xDivY )
{
  if( xDivY >= 1 )
  {
    final int hrh = round( h / xDivY * .5 );
    return new int[]{ 0, hrh, w, h - hrh };
  }
  else
  {
    final int hrw = round( w * ( 1 - xDivY ) * .5 );
    return new int[]{ hrw, 0, w - hrw, h };
  }
}

static void imageVFlip( PGraphics g, PImage i, float x, float y, float w, float h, int... sc )
{
  image( g, i, x, y, w, h, sc[ 2 ], sc[ 1 ], sc[ 0 ], sc[ 3 ] );
}
static void image( PGraphics g, PImage i, float x, float y, float w, float h, int... sc )
{
  g.image( i, x, y, w, h, sc[ 0 ], sc[ 1 ], sc[ 2 ], sc[ 3 ] );
}


//Scalable Image
static class ScaImage<T extends Image>
{
  T base;
  float factor;
  T scaled;
  
  ScaImage( T base )
  {
    this( base, 1 );
  }
  ScaImage( T base, float factor )
  {
    this.base = base;
    this.factor = factor;
    this.scaled = (T)base.sca( factor );
  }
  T get( float factor )
  {
    if( factor == this.factor )
    {
      return scaled;
    }
    return this.scaled = (T)base.sca( this.factor = factor );
  }
  
}

class Image extends PImage
{
  Image()
  {
    
  }
  Image( PImage i )
  {
    super( i.width, i.height, i.format );
    this.pixels = i.pixels;
  }
  Image( int w, int h, int t )
  {
    super( w, h, ARGB );
  }
  <A extends Image> A sca( A i, int rw, int rh )
  {
    i.copy( this, 0, 0, this.width, this.height, 0, 0, rw, rh );
    return i;
  }
  Image sca( float v )
  {
    final int rw = (int)( this.width * v ), rh = (int)( this.height * v );
    return sca( rw, rh );
  }
  Image sca( int rw, int rh )
  {
    Image r = new Image( rw, rh, this.format );
    return sca( r, rw, rh );
  }
}


class Animu extends Image
{
  
  String path;
  float w, h;
  
   int frames;
  int frame;
  
  Animu( int w, int h, int f )
  {
    super( w, h, f );
  }
  Animu( String name )
  {
    this( name, ".png", ".txt" );
  }
  Animu( String path, String exI, String exInfo )
  {
    super( loadImage( path + exI ) ) ;
    
    this.path = path;
    
    Scanner s = null;
    try
    {
      s = new Scanner( new File( dataPath( path + exInfo ) ) );
      
      this.w = Integer.parseInt( s.nextLine() );
      this.h = Integer.parseInt( s.nextLine() );
      this.frames = Integer.parseInt( s.nextLine() );
    }
    catch( Throwable t )
    {
      t.printStackTrace();
    }
    if( s != null )
    {
      s.close();
    }
    
  }
  int[] get( int i )
  {
    final int off = (int)( i * h );
    return new int[]{ 0, off, (int)w, (int)( off + h ) };
  }
  int[] poll()
  {
    final int[] r = peek();
    frame = frame == frames - 1 ? 0 : frame + 1;
    return r;
  }
  int[] peek()
  {
    return get( frame );
  }
  <A extends Image> A sca( A i, int rw, int rh )
  {
    super.sca( i, rw, rh );
    Animu ii = (Animu)i;
    ii.w = rw;
    ii.h = (float)rh / frames;
    ii.frames = frames;
    return i;
  }
  Animu sca( int rw, int rh )
  {
    Animu r = new Animu( rw, rh, this.format );
    return sca( r, rw, rh );
  }
}

//Animu Directional
//for walking animations etc.
class AnimuD extends Animu
{
  
  // f == forward, b == backward, l == libtard
  // M = Movement, NM = No Movement
  int fNM, bNM, lNM, fM, bM, lM1, lM2;
  
  AnimuD( int w, int h, int f )
  {
    super( w, h, f );
  }
  
  AnimuD( String name, int fNM, int bNM, int lNM, int fM, int bM, int lM1, int lM2 )
  {
    super( name );
    
    this.fNM = fNM;
    this.bNM = bNM;
    this.lNM = lNM;
    this.fM = fM;
    this.bM = bM;
    this.lM1 = lM1;
    this.lM2 = lM2;
  }
  
  int[] get( final int dir, final boolean moving, final int atWalk )
  {
    if( dir == LEFT || dir == RIGHT )
    {
       int[] ltbr =
       moving
       ?
         atWalk == 0
         ?
           get( lM1 )
           :
           get( lM2 )
         :
         get( lNM )
       ;
      
       return dir == LEFT ? ltbr : new int[]{ ltbr[ 2 ], ltbr[ 1 ], ltbr[ 0 ], ltbr[ 3 ] };
    }
    else if( dir == UP )
    {
      if( ! moving )
      {
        return get( bNM );
      }
      else
      {
        int[] ltbr = get( bM );
        return atWalk == 0 ? ltbr : new int[]{ ltbr[ 2 ], ltbr[ 1 ], ltbr[ 0 ], ltbr[ 3 ] };
      }
    }
    else
    {
      if( ! moving )
      {
        return get( fNM );
      }
      else
      {
        int[] ltbr = get( fM );
        return atWalk == 0 ? ltbr : new int[]{ ltbr[ 2 ], ltbr[ 1 ], ltbr[ 0 ], ltbr[ 3 ] };
      }
    }
  }
    
  <A extends Image> A sca( A i, int rw, int rh )
  {
    super.sca( i, rw, rh );
    AnimuD c = (AnimuD)i;
    c.fNM = this.fNM;
    c.bNM = this.bNM;
    c.lNM = this.lNM;
    c.fM = this.fM;
    c.bM = this.bM;
    c.lM1 = this.lM1;
    c.lM2 = this.lM2;
    
    return i;
  }
  AnimuD sca( int rw, int rh )
  {
    AnimuD r = new AnimuD( rw, rh, this.format );
    return sca( r, rw, rh );
  }
  
}
