package med.display {
	import com.greensock.easing.Quad;
	import com.greensock.TweenMax;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.text.TextField;

	public class Handle extends _Handle {

		//133, 1607
		static public const TOTAL_WIDTH:Number = 399;
		static public var WIDTH:Number;
		static public const HEIGHT:Number = Main.HEIGHT;
		
		public var title:String;
		public var screen:Screen;
		
		private var bg:Sprite;
		
		public var idleFlasher:Shape;
		
		public var homeColor:uint;
		protected var sourceColor:uint;
		protected var targetColor:uint;
		protected var currentColor:uint;
		protected var colorAnimateTime:Number;
		protected var totalColorAnimateTime:Number;
		protected var animatingCT:ColorTransform;

		public var prev:Handle;
		public var next:Handle;
		public var prevCount:int;
		public var nextCount:int;
		public var homeX:Number;
		
		public var left:Boolean;
		public var willBeLeft:Boolean;
		public var screenLeft:Boolean;
		
		protected var grabHint:HandleGrabHint;

		protected var _draggable:Boolean;
		public function get draggable():Boolean { return _draggable; }
		public function set draggable(value:Boolean):void {
			_draggable = value;
			grab.visible = _draggable;
			buttonMode = _draggable;
		}
		
		
		public function Handle(title:String, screen:Screen) {
			this.title = title;
			this.screen = screen;
			homeColor = screen.color;
			currentColor = homeColor;
			animatingCT = new ColorTransform(0, 0, 0, 1);

			bg = new Sprite();
			bg.graphics.beginFill(0xFFFFFF);
			bg.graphics.drawRect(0, 0, WIDTH + 0.5, HEIGHT);
			bg.graphics.endFill();
			addChildAt(bg, 0);
			animateColorTo(homeColor, 0);
						
			prevCount = 0;
			nextCount = 0;
			
			titleField.text = title;
			titleField.x = (WIDTH - titleField.width) / 2;
			
			grab.x = WIDTH / 2;
			grab.gotoAndStop(1);
			
			idleFlasher = new Shape();
			idleFlasher.graphics.beginFill(0xFFFFFF);
			idleFlasher.graphics.drawRect(0, 0, WIDTH + 0.5, HEIGHT);
			idleFlasher.graphics.endFill();
			addChild(idleFlasher);
			idleFlasher.alpha = 0;
			
			hitArea = bg;
			
			buttonMode = true;
			mouseChildren = false;

			draggable = true;
			
		}
		
		public function showDragDirection():void {
			grab.gotoAndStop(2);
			if (willBeLeft) grab.scaleX = 1;
			else grab.scaleX = -1;
		}
		public function clearDragDirection():void {
			grab.gotoAndStop(1);
			grab.scaleX = 1;
		}
		public function showGrabHint():void {
			if (grabHint) return;
			grabHint = new HandleGrabHint();
			grabHint.x = grab.x;
			grabHint.y = grab.y;
			addChild(grabHint);
		}
		public function hideGrabHint():void {
			if (grabHint) grabHint.forceOff();
		}
		
		
		public function animateColorTo(color:uint, time:Number):void {
			if (color == targetColor) return;
			targetColor = color;
			sourceColor = currentColor;
			
			if (time > 0) {
				colorAnimateTime = totalColorAnimateTime = time;
				//TweenMax.to(bg, time / 1000, { colorTransform:{ tint:color, tintAmount:1 }, ease:Quad.easeOut } ) 
			} else {
				setColor(color);
			}
		}		
		protected function setColor(color:uint):void {
			currentColor = color;
			animatingCT.color = color;
			bg.transform.colorTransform = animatingCT;
		}
		
		public function animateAlphaTo(alpha:Number, time:Number):void {
			if (time > 0) {
				TweenMax.to(titleField, time / 1000, { alpha:alpha, ease:Quad.easeOut } ) 
			} else {
				titleField.alpha = alpha;
			}
		}
		
		public function animate(dTime:Number):void {
			if (colorAnimateTime > 0) {
				colorAnimateTime = Math.max(0, colorAnimateTime - dTime);
				if (colorAnimateTime == 0) {
					setColor(targetColor);
				} else {
					var f:Number = (1 - colorAnimateTime / totalColorAnimateTime);
					var eased:Number = Utils.easeOut(f);
					var sourceR:uint = (sourceColor & 0xFF0000) >> 16;
					var sourceG:uint = (sourceColor & 0xFF00) >> 8;
					var sourceB:uint = (sourceColor & 0xFF);
					var targetR:uint = (targetColor & 0xFF0000) >> 16;
					var targetG:uint = (targetColor & 0xFF00) >> 8;
					var targetB:uint = (targetColor & 0xFF);
					var currentR:uint = uint(sourceR + (targetR - sourceR) * eased) << 16;
					var currentG:uint = uint(sourceG + (targetG - sourceG) * eased) << 8;
					var currentB:uint = uint(sourceB + (targetB - sourceB) * eased);
					
					setColor(currentR + currentG + currentB);
				}
			}
			
			if (grabHint) {
				grabHint.animate(dTime);
				if (grabHint.finished) {
					if (grabHint.parent) grabHint.parent.removeChild(grabHint);
					grabHint = null;
				}
			}
		}
		
		

	}

}