package trilateral2Setup.drawings;
import trilateral2Setup.drawings.DrawingLayout;
// Shaper for drawing shapes
import trilateral2.Shaper;
// Color pallettes
import pallette.QuickARGB;
class VioletRoundedRectangle extends DrawingLayout{
    override public function draw(){
        var len = Shaper.roundedRectangle( pen.drawType
                                         , topLeft.x - size
                                         ,( topLeft.y + bottomLeft.y )/2 - size/2, size*2
                                         , size, 30 );
        pen.colorTriangles( Violet, len );
    }
}
