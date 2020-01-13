package trilateral2Setup.drawings;
import trilateral2Setup.drawings.DrawingLayout;
// Shaper for drawing shapes
import trilateral2.Shaper;
// Color pallettes
import pallette.QuickARGB;
class IndigoCircle extends DrawingLayout{
    override public function draw(){
        var len = Shaper.circle( pen.drawType
                   , ( topRight.x + centre.x )/2, ( topRight.y + centre.y )/2
                   ,  size);
        pen.colorTriangles( Indigo, len );
    }
}

