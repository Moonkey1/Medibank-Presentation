package med.interaction {
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class Pong extends Sprite {
		
		protected static const M_TIME:Number = 500;
		protected static const M_SPEED_MULTIPLIER:Number = 15;
		protected static const CURVE:Number = 200;
				
		protected var bounds:Rectangle;
		protected var pWidth:Number;
		protected var pHeight:Number;
		protected var ballSize:Number;
		
		protected var left:Number;
		protected var right:Number;
		protected var top:Number;
		protected var bottom:Number;
		protected var midX:Number;
		protected var midY:Number;
		protected var paddleX:Number;
		
		protected var prx:Number;
		protected var pry:Number;
		protected var br:Number;

		protected var p1:Shape;
		protected var p2:Shape;
		protected var ball:Shape;
		
		protected var ballDir:Point;
		
		protected var prev1:Number
		protected var prev2:Number
		protected var m1:Number;
		protected var m2:Number;

		protected var playing:Boolean;
		public var active:Boolean;

		public function Pong(bounds:Rectangle) {
			this.bounds = bounds;
			
			left = bounds.left;
			right = bounds.right;
			top = bounds.top;
			bottom = bounds.bottom;
			midX = left + (right - left) / 2;
			midY = top + (bottom - top) / 2;
			
			pWidth = bounds.width * 0.04;
			pHeight = Math.min(pWidth * 5, bounds.height * 0.3);
			ballSize = pWidth * 2;
			paddleX = bounds.width * 0.08;
			
			prx = pWidth / 2;
			pry = pHeight / 2;
			br = ballSize / 2;

			p1 = new Shape();
			p1.graphics.beginFill(0xFFFFFF);
			p1.graphics.drawRect( -pWidth / 2, -pHeight / 2, pWidth, pHeight);
			p1.graphics.endFill();
			p1.x = left + paddleX;
			p1.y = midY;
			addChild(p1);
			p2 = new Shape();
			p2.graphics.beginFill(0xFFFFFF);
			p2.graphics.drawRect( -pWidth / 2, -pHeight / 2, pWidth, pHeight);
			p2.graphics.endFill();
			p2.x = right - paddleX;
			p2.y = midY;
			addChild(p2);
			ball = new Shape();
			ball.graphics.beginFill(0xFFFFFF);
			ball.graphics.drawRect( -ballSize / 2, -ballSize / 2, ballSize, ballSize);
			ball.graphics.endFill();
			ball.x = midX;
			ball.y = midY;
			addChild(ball);
			
			ballDir = new Point();
			m1 = 0;
			m2 = 0;
			
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
		}
		
		protected function handleAddedToStage(e:Event):void {
			addEventListener(Event.REMOVED_FROM_STAGE, handleRemovedFromStage);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
		}
		
		protected function handleRemovedFromStage(e:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, handleRemovedFromStage);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);			
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseDrag);
			stage.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
		}
		
		protected function handleMouseDown(e:MouseEvent):void {
			if (!active) return;
			if (!bounds.contains(mouseX, mouseY)) return;
			//if (!stage || (!playing && !p1.hitTestPoint(mouseX, mouseY))) return;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseDrag);
			stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			dragToMouse();
			if (!playing && active) beginGame();
		}
		protected function handleMouseDrag(e:MouseEvent):void {
			dragToMouse();
		}
		protected function handleMouseUp(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseDrag);
			stage.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
		}
		
		protected function dragToMouse():void {
			p1.y = Math.max(top + pry, Math.min(bottom - pry, mouseY));			
		}
		
		public function reset(resetPlayer:Boolean):void {
			playing = false;
			ball.x = midX;
			ball.y = midY;
			p2.y = midY;
			if (resetPlayer) p1.y = midY;
		}
		

		protected function beginGame():void {
			playing = true;
			ballDir.x = bounds.width * 1.1;
			ballDir.y = ballDir.x * (Math.random() - 0.5) * 0.5;
			prev1 = p1.y;
			prev2 = p2.y;
			m1 = 0;
			m2 = 0;
		}
		
		protected function endGame(playerWin:Boolean):void {
			reset(false);
			if (playerWin) dispatchEvent(new Event("Win"));
			else dispatchEvent(new Event("Lose"));
		}
		
		protected function getCurveY(f:Number):Number {
			var exp:Number = Math.pow(Math.max(-1, Math.min(1, f)), 3);
			var cut:Number = 0.05;
			if (exp > 0) exp = (Math.max(exp - cut, 0)) * 1 / (1 - cut);
			else exp = (Math.min(exp + cut, 0)) * 1 / (1 - cut);
			return exp * CURVE;
		}
		
		
		public function animate(dTime:Number):void {
			
			if (playing) {
				// AI
				var aiSpeed:Number = 0.65 * bounds.height * (dTime / 1000);
				aiSpeed *= (0.4 + Math.random() * 0.6);
				var target:Number = ball.y;// + (Math.random() - 0.5) * pry * 0.3;
				p2.y = Math.max(p2.y - aiSpeed, Math.min(p2.y + aiSpeed, target));
				p2.y = Math.max(top + pry, Math.min(bottom - pry, p2.y));	
				
				// Paddles' Momentum
				var newF:Number = Math.min(1, dTime / M_TIME);
				var oldF:Number = 1 - newF;
				m1 = m1 * oldF + (p1.y - prev1) * newF;
				m2 = m2 * oldF + (p2.y - prev2) * newF;
				prev1 = p1.y;
				prev2 = p2.y;

				// Move ball
				ball.x += ballDir.x * (dTime / 1000);
				ball.y += ballDir.y * (dTime / 1000);
				if (ball.y < top + br) {
					ball.y = (top + br) * 2 - ball.y;
					ballDir.y *= -1;
				}
				if (ball.y > bottom - br) {
					ball.y = (bottom - br) * 2 - ball.y;
					ballDir.y *= -1;
				}
				
				if (ballDir.x > 0) {
					if (ball.x + br >= p2.x - prx) {
						if (Math.abs(ball.y - p2.y) <= (br + pry)) {
							ball.x = (p2.x - prx) * 2 - (ball.x + br);
							ballDir.x *= -1;
							ballDir.y += m2 * M_SPEED_MULTIPLIER;
							ballDir.y += getCurveY((ball.y - p2.y) / (pHeight / 2));
						} else if (ball.x + br > p2.x/*right*/) {
							endGame(true);
						}
					}
				} else {
					if (ball.x - br <= p1.x + prx) {
						if (Math.abs(ball.y - p1.y) <= (br + pry)) {
							ball.x = (p1.x + prx) * 2 - (ball.x - br);
							ballDir.x *= -1;
							ballDir.y += m1 * M_SPEED_MULTIPLIER;
							ballDir.y += getCurveY((ball.y - p1.y) / (pHeight / 2));
						} else if (ball.x - br < p1.x/*left*/) {
							endGame(false);
						}
					}
				}
			}
			
		}
		
		
	}

}