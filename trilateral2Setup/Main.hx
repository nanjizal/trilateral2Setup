package trilateral2Setup;

// generic js
import js.Browser;
import js.html.Event;
import js.html.KeyboardEvent;
import js.html.MouseEvent;
import js.html.DivElement;
import js.lib.Float32Array;

// WebGL / Canvas setup, basic browser utils
import htmlHelper.webgl.WebGLSetup;
import htmlHelper.tools.CharacterInput;
import htmlHelper.tools.AnimateTimer;
import htmlHelper.tools.DivertTrace;

// SVG path parser
import justPath.*;
import justPath.transform.ScaleContext;
import justPath.transform.ScaleTranslateContext;
import justPath.transform.TranslationContext;

// Maths mostly matrix trasforms
import geom.matrix.Matrix4x3;
import geom.matrix.Matrix4x4;
import geom.matrix.Quaternion;
import geom.matrix.DualQuaternion;
import geom.matrix.Matrix1x4;
import geom.move.Axis3;
import geom.move.Trinary;
import geom.matrix.Projection;
import geom.matrix.Matrix1x2;
import geom.flat.Float32FlatRGBA;
import geom.flat.Float32FlatTriangle;

// Trilateral Contour Drawing Tools
import trilateral2.Algebra;
import trilateral2.Pen;
import trilateral2.DrawType;
import trilateral2.ColorType;
import trilateral2.Shaper;
import trilateral2.Contour;
import trilateral2.EndLineCurve;
import trilateral2.Sketch;
import trilateral2.SketchForm;
import trilateral2.Fill;
import trilateral2.ArrayTriple;


// Color pallettes
import pallette.QuickARGB;

// Shaders
import trilateral2Setup.shaders.Shaders;

// Keyboard control
import trilateral2Setup.helpers.AxisKeys;
// Layout helper
import trilateral2Setup.helpers.LayoutPos;
// SVG paths
import trilateral2Setup.helpers.PathTests;
// Font Letters as SVG paths
import trilateral2Setup.helpers.DroidSans;

// Test shapes
import trilateral2Setup.drawings.GreenSquare;
import trilateral2Setup.drawings.OrangeDavidStar;
import trilateral2Setup.drawings.IndigoCircle;
import trilateral2Setup.drawings.VioletRoundedRectangle;
import trilateral2Setup.drawings.YellowDiamond;
import trilateral2Setup.drawings.MidGreySquareOutline;
import trilateral2Setup.drawings.BlueRectangle;
import trilateral2Setup.drawings.RedRoundedRectangleOutline;
import trilateral2Setup.drawings.FillPoly2Trihx;
import trilateral2Setup.drawings.OutlinePoly2Trihx;
import trilateral2Setup.drawings.QuadCurveTest;
import trilateral2Setup.drawings.CubicCurveTest;
import trilateral2Setup.drawings.OrangeBirdOutline;
import trilateral2Setup.drawings.GoldBirdFill;

using htmlHelper.webgl.WebGLSetup;
class Main extends WebGLSetup {
    var webgl:                  WebGLSetup;
    public var axisModel        = new Axis3();
    var scale:                  Float;
    var model                   =  DualQuaternion.zero();
    var pen:                    Pen;
    var theta:                  Float = 0;
    var toDimensionsGL:         Matrix4x3;
    var layoutPos:              LayoutPos;
    var verts                   = new Float32FlatTriangle(2000000);
    var cols                    = new Float32FlatRGBA(2000000);
    var ind                     = new Array<Int>();
    public static function main(){ new Main(); }
    public inline static var stageRadius: Int = 600;
    public function new(){
        setupSideTrace();
        super( stageRadius, stageRadius );
        keyboardNavigation();
        glSettings();
        setupProgram( Shaders.vertexColor, Shaders.fragmentColor );
        layoutPos = new LayoutPos( stageRadius );
        createPen();
        drawShapes();
        transformVerticesToGL();
        uploadVectors();
        setAnimate();
    }
    function setupSideTrace(){
        new DivertTrace();
        trace('Trilateral2Setup Testing');
    }
    function keyboardNavigation(){
        var axisKeys = new AxisKeys( axisModel );
        axisKeys.reset = resetPosition;
    }
    function resetPosition():Void{
        model =  DualQuaternion.zero();
    }
    function glSettings(){
        DEPTH_TEST = false;
        BACK       = false;
        darkBackground();
    }
    function createPen(){
        pen = new Pen( {  triangle: verts.triangle
                        , next:     verts.next
                        , hasNext:  verts.hasNext
                        , pos:      verts.pos
                        , length:   verts.length }
                      , { cornerColors: cols.cornerColors
                        , colorTriangles: cols.colorTriangles
                        , pos:      verts.pos
                        , length:   verts.length
                        } 
                      );
    }
    function transformVerticesToGL(){
        verts.transformAll( scaleToGL() );
    }
    function scaleToGL(){
        scale = 1/(stageRadius);
        var axisWebGL = Matrix4x3.unit().translateXYZ( 1, -1, 0. );
        var scaleWebGL  = new Matrix1x4( { x: -scale, y: scale, z: 1., w: 1. } );
        return scaleWebGL * axisWebGL;
    }
    function uploadVectors(){
        vertices =  cast verts.getArray();
        colors   =  cast cols.getArray();
        indices  = createIndices();
        clearTriangles();
        gl.uploadDataToBuffers( program, vertices, colors, indices );
    }
    function createIndices(){
        for( i in 0...verts.length ) {
            ind[ i * 3 ]     = i *3;
            ind[ i * 3 + 1 ] = i *3 + 1;
            ind[ i * 3 + 2 ] = i *3 + 2;
        }
        return ind;
    }
    function darkBackground(){
        var dark = 0x18/256;
        bgRed   = dark;
        bgGreen = dark;
        bgBlue  = dark;
    }
    // example of showing flat array data and of the matrix data.
    public function traceFlatData(){
        trace( toDimensionsGL.pretty(5) );
        trace( verts.getArray() );
        trace( cols.hexAll() );
    }
    
    public function drawShapes(){
        var layoutPos     = new LayoutPos( stageRadius );
        new GoldBirdFill(               pen, layoutPos );
        new OrangeBirdOutline(          pen, layoutPos );
        new GreenSquare(                pen, layoutPos );
        new OrangeDavidStar(            pen, layoutPos );
        new IndigoCircle(               pen, layoutPos );
        new VioletRoundedRectangle(     pen, layoutPos );
        new YellowDiamond(              pen, layoutPos );
        new MidGreySquareOutline(       pen, layoutPos );
        new BlueRectangle(              pen, layoutPos );
        new RedRoundedRectangleOutline( pen, layoutPos );
        new FillPoly2Trihx(             pen, layoutPos );
        new OutlinePoly2Trihx(          pen, layoutPos );
        new QuadCurveTest(              pen, layoutPos );
        new CubicCurveTest(             pen, layoutPos );
    }
    inline
    function clearTriangles(){
        verts                   = new Float32FlatTriangle(1000000);
        cols                    = new Float32FlatRGBA(1000000);
    }
    inline
    function render_( i: Int ):Void{        
        //origin = axisOrigin.updateCalculate( origin );
        model  = axisModel.updateCalculate( model );
        var trans: Matrix4x3 = (  offset * model ).normalize();
        var proj4 = ( Projection.perspective() * trans ).updateWebGL( matrix32Array );
        //trace( 'matrix32Array ' + matrix32Array );
        render();
    }
    inline
    function setAnimate(){
        AnimateTimer.create();
        AnimateTimer.onFrame = render_;
    }
    override public 
    function render(){
        super.render();
    }
    inline
    public static 
    function getOffset(): DualQuaternion {
        var qReal = Quaternion.zRotate( Math.PI );
        var qDual = new Matrix1x4( { x: 0., y: 0., z: -1., w: 1. } );
        return DualQuaternion.create( qReal, qDual );
    }
    var offset = getOffset();
}