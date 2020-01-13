package trilateral2Setup.drawings;
import trilateral2Setup.drawings.DrawingLayout;
// Shaper for drawing shapes
import trilateral2.Shaper;
// Color pallettes
import pallette.QuickARGB;
class RedRoundedRectangleOutline extends DrawingLayout{
    override public function draw(){
        var len = Shaper.roundedRectangleOutline( pen.drawType
                                    , topLeft.x - size
                                    ,( topLeft.y + bottomLeft.y )/2 - size/2
                                    , size*2, size,  6, 30 );
        pen.colorTriangles( Red, len );
    }
}