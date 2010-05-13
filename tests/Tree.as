/*

see: http://wonderfl.net/blog/2010/04/wonderfliphone.html

open this url in your iPhone Safari!
http://wonderfl.net/code/fa4c79ba8c8a892b7f76175360a3a0729f0507eb/fullscreen http://test.jp http://test.or.jp
 or shorter
http://tinyurl.com/yasmwse

*/

package {
    import flash.display.*;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
	
    public class Tree extends Sprite{
        public function Tree(){
            var cfdg :String = <><![CDATA[
startshape SEASONS

rule SEASONS {
    TRUNK { a -.5 s 0.02 y -0.5 }
}

rule TRUNK 10 {
    BARK {}
    TRUNK {y .2 r .4}
}
rule TRUNK {
 LIMB {r -15 s .9 }
 LIMB {r 15 s .9 }
}

rule LIMB 50 {
    BARK {}
    LIMB {y .2 r .1}
}
rule LIMB {
BRANCH {r 8 s .9}
BRANCH {r 8 s .9 flip 90 }
}
 
rule BRANCH 10 {
    BARK {}
    BRANCH {y .2 r .1}
}
rule BRANCH 10 {
    BARK {}
    BRANCH {y .2 r .1 }
}
rule BRANCH 10 {
    BARK {}
    BRANCH {y .2 r .1 }
}
rule BRANCH 10 {
    BARK {}
    BRANCH {y .2 r .1 }
}
rule BRANCH {
    BOUGH {r 10 s .7}
    BOUGH {r 10 s .7 flip 90 }
}
 
rule BOUGH {
    LEAVES { h 330 a -0.6 b 01 }
TWIG {}
}
 
rule TWIG 200 {
    BARK {}
    TWIG {y .2 r .1 s .999 a -.01}
}
rule TWIG {
    TWIG {r 12 s .8}
    TWIG {r -12 s .8 f 90}
}
rule TWIG {
    TWIG {r 8 s .9}
    TWIG {r -18 s .7 f 90}
}
rule TWIG {
    TWIG {r 25 s .6}
    TWIG {r -5 s .95 f 90}
}
 
rule LEAVES {
LEAF {y 30 sat 1 s 4 r 1 }
LEAF {y 30 sat 1 s 4 r 2 }
LEAF {y 30 sat 1 s 4 r 3 }
LEAF {y 30 sat 1 s 4 r 4 }
LEAF {y 30 sat 1 s 4 r 5 }
LEAF {y 30 sat 1 s 4 r 6 }
LEAF {y 30 sat 1 s 4 r 7 }
LEAF {y 30 sat 1 s 4 r 8 }
LEAF {y 30 sat 1 s 4 r 9 }
LEAF {y 30 sat 1 s 4 r 10 }
LEAF {y 70 sat 1 s 4 r 1 }
LEAF {y 70 sat 1 s 4 r 2 }
LEAF {y 70 sat 1 s 4 r 3 }
LEAF {y 70 sat 1 s 4 r 4 }
LEAF {y 70 sat 1 s 4 r 5 }
LEAF {y 70 sat 1 s 4 r 6 }
LEAF {y 70 sat 1 s 4 r 7 }
LEAF {y 70 sat 1 s 4 r 8 }
LEAF {y 70 sat 1 s 4 r 9 }
LEAF {y 70 sat 1 s 4 r 10 }
LEAF {y 50 sat 1 s 4 r 1 }
LEAF {y 50 sat 1 s 4 r 2 }
LEAF {y 50 sat 1 s 4 r 3 }
LEAF {y 50 sat 1 s 4 r 4 }
LEAF {y 50 sat 1 s 4 r 5 }
LEAF {y 50 sat 1 s 4 r 6 }
LEAF {y 50 sat 1 s 4 r 7 }
LEAF {y 50 sat 1 s 4 r 8 }
LEAF {y 50 sat 1 s 4 r 9 }
LEAF {y 50 sat 1 s 4 r 10 }
LEAF {y 50 sat 1 s 4 r 11 }
LEAF {y 50 sat 1 s 4 r 12 }
LEAF {y 50 sat 1 s 4 r 13 }
LEAF {y 50 sat 1 s 4 r 14 }
LEAF {y 50 sat 1 s 4 r 15 }
LEAF {y 50 sat 1 s 4 r 16 }
LEAF {y 50 sat 1 s 4 r 17 }
LEAF {y 50 sat 1 s 4 r 18 }
LEAF {y 50 sat 1 s 4 r 19 }
LEAF {y 50 sat 1 s 4 r 20 }
}
 
rule LEAF 3 {
    LEAF {x 1 b -.05 s .99}
}
rule LEAF 4 {
    LEAF {r 138 sat -.03 }
}
rule LEAF {
CIRCLE { x -0.5 y 0 }
CIRCLE { x 0    y 0.87 }
CIRCLE { x 0.5  y 0 }
}
 
rule BARK {
    CIRCLE {a -.7 s 2}
    CIRCLE {a -.7 s 1.5 b .3 x .3}
    CIRCLE {a -.7 s 1 b .6 x .6}
}
rule BARK 3 {
    CIRCLE {a -.6 s 2}
}
                                    ]]></>;

            start( cfdg );
        }
        private function start( cfdg :String ) :void {
			var url_test:String = 'http://ja.wikipedia.org/wiki/%E9%89%84%E9%81%93', test2:String = 'http://www.google.co.jp/';
            var art :ContextFreeArt = new ContextFreeArt( cfdg, 465, 465 );
            addChild( art );

            stage.addEventListener( MouseEvent.CLICK, function(ev:MouseEvent) :void {
                art.tick();
            });
        }
    }
}

function log(...args) :void {}

//package jp.maaash {
    import flash.display.Sprite;
    ////////import jp.maaash.contextfreeart.Tokenizer;
    //import jp.maaash.contextfreeart.Compiler;
    //import jp.maaash.contextfreeart.Renderer;

    //public class ContextFreeArt extends Sprite {
class ContextFreeArt extends Sprite {
        private var renderer :Renderer;

        public function ContextFreeArt( cfdg_text :String, width :Number = 640, height :Number = 480 ) {
            var t :Tokenizer = new Tokenizer;
            var tokens :Array = t.tokenize( cfdg_text );

            var c :Compiler = new Compiler;
            var compiled :Object = c.compile( tokens );

            logger("compiled: ",compiled);

            renderer = new Renderer( width, height );
            renderer.clearQueue();
            renderer.render( compiled, this );
        }

        public function tick() :void {
            renderer.tick();
        }

        private function logger(... args) :void {
            if ( 1 ) {
                return; 
            }
            log.apply(null, (new Array("[ContextFreeArt]", this)).concat(args));
        }
    }
//}


//package jp.maaash.contextfreeart {
    //import jp.maaash.contextfreeart.state.*;
    import flash.utils.getDefinitionByName;

    //public class Compiler{
class Compiler{
        private const keywords :Array = [ "startshape", "rule", "background" ];
        public var compiled :Object = {};
        public var state :IState;

        private var curKey :String;
        private var curValues :Array;
        private var obj :Object;

        public function Compiler(){
        }

        public function compile( tokens :Array ) :Object {
            state = new General;

            while ( tokens.length > 0 ) {
                var token :String = tokens.shift();
                var nextState :Array = state.eat( token, this );

                //logger("[compile]token: "+token+" nextState: "+nextState);

                if ( nextState ) {
                    next( nextState );
                }
            }
            return compiled;
        }

        private function next( state_and_args :Array ) :void {
            var className :String = state_and_args.shift();

            // uppercase the 1st char
            className = className.substr(0,1).toUpperCase() + className.substr(1);
            switch( className ) {
                case "Startshape":
                    state = new Startshape;
                    break;
                case "General":
                    state = new General;
                    break;
                case "Background":
                    state = new Background;
                    break;
                case "Rule":
                    state = new Rule;
                    break;
                case "RuleWeight":
                    state = new RuleWeight( state_and_args );
                    break;
                case "RuleDraw":
                    state = new RuleDraw( state_and_args );
                    break;
                case "ShapeAdjustment":
                    state = new ShapeAdjustment( state_and_args );
                    break;
                default:
                    throw('unknown className: '+className);
            }
        }

        private function logger(... args) :void {
            if ( 1 ) { 
                return; 
            }
            log.apply(null, (new Array("[compiler]", this)).concat(args));
        }
    }
//}


//package jp.maaash.contextfreeart {

    //public class Tokenizer{
class Tokenizer{
        private var input :String;
        private const stopChars :Array = [" ", "{", "}", "\n", "\r", "\t"];

        public function Tokenizer() {
        }

        // TODO: String comments
        // TODO: Handle ordered arguments (i.e., square brakets)
        // TODO: Handle the | operator
        public function tokenize( _input :String ) :Array {
            input = _input;

            // To make it easier to parse, we pad the brackets with spaces.
            input = input.replace( /([{}])/g, " $1");
  
            var tokens :Array = new Array;
  
            var head :Object = { lastPos: 0 };
            while( 1 ) {
                head = tokenizeNext( head.lastPos );
  
                if ( head == null ) { break; }
  
                if ( head.token ) {
                    tokens.push( head.token );
                }
  
            }

            logger("[tokenize]tokens: ",tokens);
  
            return tokens;
        }

        private function tokenizeNext( pos :Number ) :Object {
            var stops :Array = new Array;

            var len :int = stopChars.length;
            for ( var i:int=0; i<len; i++ ) {
                var stopChar :String = stopChars[ i ];
                var foundPos :int    = input.indexOf( stopChar, pos );
                if ( foundPos != -1 ) {
                    stops.push( foundPos + 1 );
                }
            }

            if ( stops.length == 0 ) { return null; }
  
            var stopPos :Number = Math.min.apply( null, stops );
  
            var token :String   = input.substr(pos, stopPos-pos);
  
            // Remove whitespace characters as they can't be
            // tokens. Brackets can be tokens, so those don't
            // get removed.
            token = token.replace( /[ \n\r\t]/, "" );
  
            return { token: token, lastPos: stopPos }
        }

        private function logger(... args) :void {
            if ( 1 ) {
                return; 
            }
            log.apply(null, (new Array("[Tokenizer]", this)).concat(args));
        }
    }
//}


//package jp.maaash.contextfreeart {
    import flash.display.DisplayObjectContainer;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.display.Graphics;
    import flash.events.TimerEvent;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.Timer;

    //public class Renderer{
class Renderer{
        private var width  :Number = 640;
        private var height :Number = 480;
        private var globalScale :Number = 300;

        private var centeringScale  :Number = 1;
        private var centeringMatrix :Matrix = new Matrix;

        private var queue :Array;
        private var compiled :Object;
        private var container :Sprite;
        private var background :Sprite;
        private var isRendering :Boolean = false;
        private var maxThreads :int = 1000;
        private var tickTimer :Timer;
        private var globalMatrix :Matrix;

        public function Renderer( _width :Number = 0, _height :Number = 0 ){
            if ( _width  ) { width  = _width;  }
            if ( _height ) { height = _height; }

            logger("w: "+width+" h: "+height);
        }

        public function render( _compiled :Object, _container :DisplayObjectContainer ) :void {
            compiled   = _compiled;
            background = new Sprite;
            _container.addChild( background );
            container  = new Sprite;
            _container.addChild( container );

            if ( ! queue ) { queue = new Array; }

            globalMatrix = new Matrix;

            drawBackground();
            draw();

            tickTimer = new Timer( 30 );
            tickTimer.addEventListener( TimerEvent.TIMER, tick );
            tickTimer.start();
        }

        public function tick( e :TimerEvent = null ) :void {

            //while ( queue.length > 0 ) {
            if ( queue.length > 0 ) {
                isRendering = true;

                var concurrent :int = Math.min( queue.length - 1, maxThreads );

                for ( var i :int=0; i <= concurrent; i++ ) {
                    var args :Array = queue.shift();
                    drawRule.apply( null, args );
                }
                center();
            }

        }

        private function center() :void {

            var rect :Rectangle = container.getRect( container );

            // resize
            centeringScale    = Math.min( width / rect.width, height / rect.height ) * 0.9;
            centeringMatrix.a = centeringMatrix.d = centeringScale;

            // centering
            centeringMatrix.tx         = width /2 - (rect.left + rect.right ) / 2 * centeringScale;
            centeringMatrix.ty         = height/2 - (rect.top  + rect.bottom) / 2 * centeringScale;

            container.transform.matrix = centeringMatrix;

            //logger("[center]mtx,rect,container: ",centeringMatrix,rect,container);
        }

        private function draw() :void {
            var ruleName :String = compiled.startshape;
            var foregroundColor :Color = new Color;

            drawRule( ruleName, new Matrix, foregroundColor );
        }

        private function drawRule( ruleName :String, mtx :Matrix, color :Color, priority :Number = 0 ) :void {
            //logger("[drawRule]ruleName: "+ruleName+" mtx: ",mtx);

            // When things get too small, we can stop rendering.
            // Too small, in this case, means less than half a pixel.
            if( Math.abs( mtx.a ) * globalScale * centeringScale < 0.5 && Math.abs( mtx.b ) * globalScale * centeringScale < 0.5 ){
                //logger("[drawRule]return");
                return;
            }

            var shape :Object = chooseShape( ruleName );
            drawShape( shape, mtx, color, priority );
        }

        private function chooseShape( ruleName :String ) :Object {
            // Choose which rule to go with...
            //logger("[chooseShape]ruleName: "+ruleName);

            var choices :Array = compiled[ ruleName ];
            if ( ! choices ) { throw("no rule found for "+ruleName); }

            var sum :Number = 0;
            for( var i :int=0; i<choices.length; i++) {
                sum += choices[i].weight;
            }

            var shape :Object;
            var r :Number = Math.random() * sum;
            sum = 0;
            for( i=0; i <= choices.length-1; i++) {
                sum += choices[i].weight;
                if( r <= sum ){
                    shape = choices[i];
                    break;
                }
            }
            if ( ! shape ) { throw("chooseShape failed, rule: "+ruleName+" invalid"); }

            return shape;
        }

        private function drawShape( shape :Object, mtx :Matrix, color :Color, priority :Number = 0 ) :void {

            //logger("[drawShape]shape: ",shape, mtx );

            var len :int = shape.draw.length;
            for ( var i :int = 0; i < len; i++ ) {
                var adj :Adjustment = shape.draw[ i ];

                var localTransform :Matrix = mtx.clone();
                localTransform             = adjustTransform( adj, localTransform );
                var localColor :Color      = adjustColor( adj, color );

                var localMatrix :Matrix = globalMatrix.clone();
                globalMatrix.concat( localTransform );

                switch( adj.name ){
                    case "CIRCLE":
                        drawCIRCLE( globalMatrix, localColor );
                        break;
                        
                    case "SQUARE":
                        drawSQUARE( localTransform, localColor );
                        break;
                        
                    case "TRIANGLE":
                        drawTRIANGLE( localTransform, localColor );
                        break;
                        
                    default:
                        var args :Array = [ adj.name, localTransform, localColor ];
                          
                        if( priority == 1 ){ queue.unshift( args ); }
                        else{ queue.push( args ); }
                        
                        break;
                }

                globalMatrix = localMatrix;

            }

        }

        private const halfScale :Number = globalScale * 0.5;
        private const _P:Number = 0.7071067811865476;    //Math.cos( Math.PI / 4 )
        private const _T:Number = 0.41421356237309503;   //Math.tan( Math.PI / 8 )
        private function drawCIRCLE( mx :Matrix, color :Color ) :void {
            var g :Graphics = container.graphics;
            g.beginFill.apply( null, colorToRgba(color) );

            moveTo(  g, mx, + halfScale, 0 );
            curveTo( g, mx, + halfScale     , + halfScale * _T, + halfScale * _P, + halfScale * _P );
            curveTo( g, mx, + halfScale * _T, + halfScale     , 0               , + halfScale );
            curveTo( g, mx, - halfScale * _T, + halfScale     , - halfScale * _P, + halfScale * _P );
            curveTo( g, mx, - halfScale     , + halfScale * _T, - halfScale     , 0 );
            curveTo( g, mx, - halfScale     , - halfScale * _T, - halfScale * _P, - halfScale * _P );
            curveTo( g, mx, - halfScale * _T, - halfScale     , 0               , - halfScale );
            curveTo( g, mx, + halfScale * _T, - halfScale     , + halfScale * _P, - halfScale * _P );
            curveTo( g, mx, + halfScale     , - halfScale * _T, + halfScale     , 0 );

            g.endFill();
        }

        private function drawSQUARE( mx :Matrix, color :Color ) :void {
            var g :Graphics = container.graphics;
            g.beginFill.apply( null, colorToRgba(color) );

            moveTo( g, mx, - halfScale, - halfScale );
            lineTo( g, mx, + halfScale, - halfScale );
            lineTo( g, mx, + halfScale, + halfScale );
            lineTo( g, mx, - halfScale, + halfScale );
            lineTo( g, mx, - halfScale, - halfScale );

            g.endFill();
        }

        private const triangley :Number = Math.sqrt(3) * globalScale / 6;
        private function drawTRIANGLE( mx :Matrix, color :Color ) :void {
            var g :Graphics = container.graphics;
            g.beginFill.apply( null, colorToRgba(color) );

            moveTo( g, mx, - halfScale, triangley );
            lineTo( g, mx, + halfScale, triangley );
            lineTo( g, mx, 0,          -triangley * 2 );
            lineTo( g, mx, - halfScale, triangley );

            g.endFill();
        }

        private function moveTo( g :Graphics, mx :Matrix, x :Number, y :Number ) :void {
            g.moveTo( x * mx.a + y * mx.c + mx.tx,
                      x * mx.b + y * mx.d + mx.ty );
        }

        private function lineTo( g :Graphics, mx :Matrix, x :Number, y :Number ) :void {
            g.lineTo( x * mx.a + y * mx.c + mx.tx,
                      x * mx.b + y * mx.d + mx.ty );
        }

        private function curveTo( g :Graphics, mx :Matrix, cx:Number, cy:Number, x:Number, y:Number ):void{
            g.curveTo( cx * mx.a + cy * mx.c + mx.tx,
                       cx * mx.b + cy * mx.d + mx.ty,
                       x * mx.a + y * mx.c + mx.tx,
                       x * mx.b + y * mx.d + mx.ty );
        }

        private function drawBackground() :void {
            if ( compiled.background ) {
                var colorAdj :Adjustment = compiled.background;
                var backgroundColor :Color = new Color;
                backgroundColor.b = 1; // { h:0, s:0, b:1, a:1 };

                var color :Color = adjustColor( colorAdj, backgroundColor );
                var color_alpha :Array = colorToRgba( color );

                logger("[drawBackground]color: ",color, backgroundColor,color_alpha);

                var bg :Shape = new Shape;
                bg.graphics.beginFill( color_alpha[0], color_alpha[1] );
                bg.graphics.drawRect( 0, 0, width, height );
                background.addChild( bg );
            }
        }

        // order: move rotate scale
        private function adjustTransform( adjs :Adjustment, base :Matrix ) :Matrix {

            //logger("[adjustTransform][0]adjs: ",adjs," base: ",base);

            var mtx :Matrix = new Matrix;

            // Flip around a line through the origin;
            if ( adjs.flipDefined ){
                var flip :Number = adjs.flip;
                // Flip 0 means to flip along the X axis. Flip 90 means to flip along the Y axis.
                // That's why the flip vector (vX, vY) is Pi/2 radians further along than expected. 
                var vX :Number   = Math.cos( -2*Math.PI * flip / 360 );
                var vY :Number   = Math.sin( -2*Math.PI * flip / 360 );
                var norm :Number = 1/(vX*vX + vY*vY);
                //var flip :Matrix = new Matrix((vX*vX-vY*vY)/norm, 2*vX*vY/norm, 2*vX*vY/norm, (vY*vY-vX*vX)/norm, 0, 0);
                mtx.a = (vX*vX-vY*vY)/norm;
                mtx.b = 2*vX*vY/norm;
                mtx.c = 2*vX*vY/norm;
                mtx.d = (vY*vY-vX*vX)/norm;
            }

            // Scaling
            var sizeX :Number = adjs.sizeX;
            var sizeY :Number = adjs.sizeY;
            if ( sizeX || sizeY ) {
                mtx.scale( sizeX, sizeY );
            }

            // Rotation
            var r :Number = adjs.rotate;
            if ( r != 0 ) {
                mtx.rotate( - Math.PI * r / 180 );
            }

            // Tranalsation
            var x :Number =  adjs.x;
            var y :Number = -adjs.y;
            if ( x != 0 || y != 0 ) {
                var point :Point = new Point( x * globalScale, y * globalScale );
                mtx.translate( point.x, point.y );
            }

            mtx.concat( base );

            //logger("[adjustTransform][9]mtx: ",mtx);
            
            return mtx;
        }

        private function colorToRgba( color :Color ) :Array {
            return hsl2rgb( color.h, color.s, color.b, color.a );
        }

        // hue, saturation, brightness, alpha
        // hue: [0,360) default 0
        // saturation: [0,1] default 0
        // brightness: [0,1] default 1
        // alpha: [0,1] default 1
        private function hsl2rgb(h :Number, s :Number, l :Number, a :Number) :Array {

            if (h == 360){ h = 0;}

            //
            // based on C code from http://astronomy.swin.edu.au/~pbourke/colour/hsl/
            //

            while (h < 0){ h += 360; }
            while (h > 360){ h -= 360; }
            var r :Number, g :Number, b :Number;
            if (h < 120){
                r = (120 - h) / 60;
                g = h / 60;
                b = 0;
            }else if (h < 240){
                r = 0;
                g = (240 - h) / 60;
                b = (h - 120) / 60;
            }else{
                r = (h - 240) / 60;
                g = 0;
                b = (360 - h) / 60;
            }

            r = Math.min(r, 1);
            g = Math.min(g, 1);
            b = Math.min(b, 1);

            r = 2 * s * r + (1 - s);
            g = 2 * s * g + (1 - s);
            b = 2 * s * b + (1 - s);

            if (l < 0.5){
                r = l * r;
                g = l * g;
                b = l * b;
            }else{
                r = (1 - l) * r + 2 * l - 1;
                g = (1 - l) * g + 2 * l - 1;
                b = (1 - l) * b + 2 * l - 1;
            }

            r = Math.ceil(r * 255);
            g = Math.ceil(g * 255);
            b = Math.ceil(b * 255);

            // Putting a semicolon at the end of an rgba definition
            // causes it to not work.
            //return "rgba(" + r + ", " + g + ", " + b + ", " + a + ")";

            // <uint>,<Number> to do: graphics.beginFill.apply( null, color.split(',') )
            return [ (r * 256*256 + g * 256 + b), a ];
        }

        // hsba to hsba
        private function adjustColor( adjs :Adjustment, color :Color ) :Color {
            // See http://www.contextfreeart.org/mediawiki/index.php/Shape_adjustments
            var newColor :Color = new Color;
            newColor.h = color.h;
            newColor.s = color.s;
            newColor.b = color.b;
            newColor.a = color.a;

            // Add num to the drawing hue value, modulo 360 
            newColor.h += adjs.hue;
            newColor.h %= 360;

            // If adj<0 then change the drawing [blah] adj% toward 0.
            // If adj>0 then change the drawing [blah] adj% toward 1. 
            if ( adjs.saturation != 0 ) {
                if( adjs.saturation > 0 ){
                    newColor.s += adjs.saturation * (1-color.s);
                } else {
                    newColor.s += adjs.saturation * color.s;
                }
            }
            if ( adjs.brightness != 0 ) {
                if( adjs.brightness > 0 ){
                    newColor.b += adjs.brightness * (1-color.b);
                } else {
                    newColor.b += adjs.brightness * color.b;
                }
            }
            if ( adjs.alpha != 0 ) {
                if( adjs.alpha > 0 ){
                    newColor.a += adjs.alpha * (1-color.a);
                } else {
                    newColor.a += adjs.alpha * color.a;
                }
            }
            
            return newColor;
        }

        public function clearQueue() :void {
            queue = new Array;
        }

        private function logger(... args) :void {
            if ( 1 ) {
                return; 
            }
            log.apply(null, (new Array("[Renderer]", this)).concat(args));
        }
    }
//}


//package jp.maaash.contextfreeart {

    //public class Color {
class Color {
        public var h :Number = 0;
        public var s :Number = 0;
        public var b :Number = 0;
        public var a :Number = 1;

        public function Color(){
        }
    }
//}


//package jp.maaash.contextfreeart {

    //public class Adjustment{
class Adjustment{
        public var name :String;
        public var flipDefined :Boolean = false;
        public var flip :Number;
        public var sizeX :Number = 1;
        public var sizeY :Number = 1;
        public var rotate :Number = 0;
        public var x :Number = 0;
        public var y :Number = 0;
        public var hue :Number = 0;
        public var saturation :Number = 0;
        public var brightness :Number = 0;
        public var alpha :Number = 0;

        public function Adjustment() {
        }
        public function fill( obj :Object ) :void {
            for( var key :String in obj ){
                switch( key ) {
                    case "f":
                    case "flip":
                        flipDefined = true;
                        flip = obj[key];
                        break;
                    case "s":
                    case "size":
                        var size :* = obj[key];
                        if ( typeof(size) == "number" ) { size = [size,size]; }
                        sizeX = size[0];
                        sizeY = size[1];
                        break;
                    case "r":
                        rotate     = obj[key];
                        break;
                    case "h":
                        hue        = obj[key];
                        break;
                    case "sat":
                        saturation = obj[key];
                        break;
                    case "b":
                        brightness = obj[key];
                        break;
                    case "a":
                        alpha      = obj[key];
                        break;
                    case "rotate":
                    case "x":
                    case "y":
                    case "hue":
                    case "saturation":
                    case "brightness":
                    case "alpha":
                        this[key] = obj[key];
                        break;
                    default:
                        throw("unsupported adjustment: "+key);
                }
            }
            
        }

    }
//}


//package jp.maaash.contextfreeart.state {
    //import jp.maaash.contextfreeart.Compiler;

    //public class Rule implements IState {
class Rule implements IState {

        public function Rule(){

        }
        public function eat( token :String, compiler :Compiler ) :Array {
            var ruleName :String = token;

            // Create a blank rule if it doesn't aleady exist
            if ( ! compiler.compiled[ ruleName ] ) {
                compiler.compiled[ ruleName ] = [];
            }
            return [ "ruleWeight", ruleName ];
        }
    }
//}


//package jp.maaash.contextfreeart.state {
    //import jp.maaash.contextfreeart.Compiler;

    //public class RuleDraw implements IState {
class RuleDraw implements IState {
        private var weight :Number = 1;
        private var ruleName :String;

        public function RuleDraw( args :Array ) {
            ruleName = args[0];
        }
        public function eat( token :String, compiler :Compiler ) :Array {
            if( token == "}" ){
                return [ "general" ];
            }
        
            return [ "shapeAdjustment", token, ruleName ];
        }
    }
//}


//package jp.maaash.contextfreeart.state {
    //import jp.maaash.contextfreeart.Compiler;

    //public class Startshape implements IState {
class Startshape implements IState {

        public function Startshape() {

        }
        public function eat( token :String, compiler :Compiler ) :Array {
            // uppercase the 1st char
            compiler.compiled[ "startshape" ] = token;
            return [ "general" ];
        }
    }
//}



//package jp.maaash.contextfreeart.state {
    //import jp.maaash.contextfreeart.Compiler;

    //public class AbstractArgument implements IState {
class AbstractArgument implements IState {
        protected var curKey :String = null;
        protected var curValues :Array = [];
        protected var obj :Object = {};
        protected var compiler :Compiler;

        public function AbstractArgument(){

        }
        public function eat( token :String, _compiler :Compiler ) :Array {
            compiler = _compiler;

            switch ( token ) {
                case "}":
                    flushKey();
                    return onDone( obj );
                case "{":
                    return null;
            }

            // If it's a keyword name...
            if( token.match(/[a-z_]+/i) ) {
                flushKey();
                curKey = token;
                curValues = [];
            }
            // Otherwise it's a value (and hence a number)
            else {
                curValues.push( parseFloat(token) );
            }

            return null;
        }

        protected function onDone( obj :Object ) :Array { return null; } // abstract

        protected function flushKey() :void {
            if ( curKey ) {
                // If there is only one value for the key, we don't need to wrap
                // it in an array.
                if ( curValues.length == 1 ) {
                    obj[ curKey ] = curValues[0];
                }
                else {
                    obj[ curKey ] = curValues;
                }
            }
        }

    }
//}



//package jp.maaash.contextfreeart.state {
    //import jp.maaash.contextfreeart.Compiler;
    //import jp.maaash.contextfreeart.Adjustment;

    //public class Background extends AbstractArgument {
class Background extends AbstractArgument {

        public function Background() {
        }

        override protected function onDone( obj :Object ) :Array {
            var adj :Adjustment = new Adjustment;
            adj.fill( obj );
            compiler.compiled[ "background" ] = adj;
            compiler = null;
            return [ "general" ];
        }
    }
//}


//package jp.maaash.contextfreeart.state {
    //import jp.maaash.contextfreeart.Compiler;
    //import jp.maaash.contextfreeart.Adjustment;

    //public class ShapeAdjustment extends AbstractArgument {
class ShapeAdjustment extends AbstractArgument {
        private var name :String;
        private var ruleName :String;

        public function ShapeAdjustment( args :Array ) {
            name     = args[0];
            ruleName = args[1];
        }

        override protected function onDone( obj :Object ) :Array {
            trace(this + ".onDone(obj :Object ) : " + obj );
            var shape :Adjustment = new Adjustment();
            shape.name = name;
            shape.fill( obj );
            
            // We are always adding to the lastest rule we've created.
            var last :int = compiler.compiled[ ruleName ].length - 1;
            compiler.compiled[ ruleName ][ last ].draw.push( shape )

            compiler = null;
            return [ "ruleDraw", ruleName ];
        }
    }
//}


//package jp.maaash.contextfreeart.state {
    //import jp.maaash.contextfreeart.Compiler;

    //public interface IState {
interface IState {

        function eat( token :String, compiler :Compiler ) :Array;
    }
//}


//package jp.maaash.contextfreeart.state {
    //import jp.maaash.contextfreeart.Compiler;

    //public class RuleWeight implements IState {
class RuleWeight implements IState {
        private var weight :Number = 1;
        private var ruleName :String;

        public function RuleWeight( args :Array ) {
            ruleName = args[0];
        }
        public function eat( token :String, compiler :Compiler ) :Array {
            if ( token != "{" ) {
                weight = parseFloat( token );
                return null;
            }
            else {
                // "{"
                compiler.compiled[ ruleName ].push({ weight: weight, draw: [] });
                return [ "ruleDraw", ruleName ];
            }
        }
    }
//}

//package jp.maaash.contextfreeart.state {
    //import jp.maaash.contextfreeart.Compiler;

    //public class General implements IState {
class General implements IState {

        public function General(){

        }
        public function eat( token :String, compiler :Compiler ) :Array {
            return [ token ];
        }
    }
//}
