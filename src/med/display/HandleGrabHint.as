package med.display {
	import flash.display.BlendMode;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Rectangle;

	public class HandleGrabHint extends _HandleGrabHint {

		protected static const ANIMATE_ON_TIME:Number = 300;
		protected static const ANIMATE_OFF_TIME:Number = 300;
		protected static const SETTLED_TIME:Number = 3000;
		protected static const BOUNCE_TIME:Number = 300;
		protected static const BOUNCES:int = 3;
		protected static const BOUNCE_HEIGHT:Number = 30;
		protected static const BOUNCE_MULTIPLIER:Number = 0.5;
		
		public var finished:Boolean;
		
		protected var time:Number;
		protected var bouncesRemaining:int;
		protected var bounceTime:Number;
		protected var bounceHeight:Number;
		protected var settled:Boolean;
		
		protected var animatingOn:Boolean;
		protected var animatingOff:Boolean;
		
		protected var forcedOff:Boolean;
		
		protected var body:Sprite;
		protected var bodyWidth:Number;
		protected var bodyHeight:Number;
		protected var bodyMask:Shape;

		public function HandleGrabHint() {
			blendMode = BlendMode.LAYER;
			
			body = _body;			
			var bodyBounds:Rectangle = body.getBounds(this);
			bodyHeight = -bodyBounds.top;
			bodyWidth = -bodyBounds.width;
			
			bodyMask = new Shape();
			var g:Graphics = bodyMask.graphics;
			g.beginFill(0x0);
			g.drawRect( -bodyWidth * 0.5, -bodyHeight, bodyWidth, bodyBounds.height);
			g.endFill();
			addChild(bodyMask);
			bodyMask.visible = false;
			
			time = 0;
			bouncesRemaining = BOUNCES;
			bounceTime = BOUNCE_TIME;
			bounceHeight = BOUNCE_HEIGHT;
			
			animatingOn = true;
			body.mask = bodyMask;
		}
		
		public function animate(dTime:Number):void {
			if (finished) return;
			time += dTime;
			var f:Number, eased:Number;
			if (animatingOn) {
				if (time >= ANIMATE_ON_TIME) {
					body.y = 0;
					body.mask = null;
					animatingOn = false;
					time -= ANIMATE_ON_TIME;
				} else {
					f = time / ANIMATE_ON_TIME;
					eased = Utils.easeIn(f);
					body.y = (1 - eased) * bodyHeight;
				}
			} else if (animatingOff) {
				if (time >= ANIMATE_OFF_TIME) {
					body.y = bodyHeight;
					body.mask = null;
					animatingOn = false;
					finished = true;
				} else {
					f = time / ANIMATE_OFF_TIME;
					eased = Utils.easeIn(f);
					body.y = eased * bodyHeight;
				}
			} else if (settled) {
				if (forcedOff || (time >= SETTLED_TIME)) {
					animatingOff = true;
					body.mask = bodyMask;
					time -= SETTLED_TIME;
				}
			} else {
				if (time > BOUNCE_TIME) {
					time -= BOUNCE_TIME;
					bouncesRemaining--;
					bounceHeight *= BOUNCE_MULTIPLIER;
					bounceTime *= BOUNCE_MULTIPLIER;
					if (bouncesRemaining <= 0) {
						body.y = 0;
						settled = true;
						return;
					}
				}
				body.y = -Math.sin(time / BOUNCE_TIME * Math.PI) * bounceHeight;
			}
		}
		
		public function forceOff():void {
			bouncesRemaining = 0;
			forcedOff = true;
		}

	}

}