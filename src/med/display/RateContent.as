package med.display {
	import flash.display.BlendMode;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;

	public class RateContent extends Content {

		// Bar from 192.4 - 2289.3, width = 2096.9
		//y = 576.8, height = 349.85
		
		protected static const BAR_X:Number = 2.5;// 192.4;
		protected static const BAR_WIDTH:Number = 2096.9;
		
		public var titleField:TextField;
		public var label0:TextField;
		public var label50:TextField;
		public var label100:TextField;
		
		public var submitButton:SimpleButton;
		
		public var hit:Sprite;
		protected var bar:Sprite;
		protected var grab:Sprite;
		protected var circle:Sprite;
		protected var graph:Sprite;
		
		protected var currentX:Number;
		protected var startX:Number;
		protected var targetX:Number;
		protected var timeToTarget:Number;
		protected var totalMoveTime:Number;
		
		public function RateContent(color:uint, title:String, labels:Vector.<String>) {
			super(color);

			var assets:MovieClip = new _RateContentAssets();
			addChild(assets);
			
			assets.titleField.text = title.replace(/\n/ig, "");
			assets.label0.text = labels[0];
			assets.label50.text = labels[1];
			assets.label100.text = labels[2];

			graph = assets.graph as Sprite;
			bar = graph.getChildByName("bar") as Sprite;
			grab = graph.getChildByName("grab") as Sprite;
			circle = graph.getChildByName("circle") as Sprite;
			
			grab.blendMode = BlendMode.ERASE;
			graph.blendMode = BlendMode.LAYER;
			
			grab.hitArea = hit;
			assets.hit.visible = false;
			grab.buttonMode = true;
			grab.mouseChildren = false;
			
			graph.scrollRect = new Rectangle(0, 0, Math.ceil(graph.width) + 100, Math.ceil(graph.height));

			startX = currentX = targetX = grab.x;
			timeToTarget = 0;
			
			grab.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);			
		}
		
		protected function handleMouseDown(event:MouseEvent):void {
			stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, handleUp);
			moveToMouse();
		}
		
		protected function handleUp(event:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, handleUp);
		}
		
		protected function handleMove(event:MouseEvent):void {
			moveToMouse();
		}
		
		protected function moveToMouse():void {
			startX = currentX;
			targetX = Math.max(BAR_X, Math.min(BAR_X + BAR_WIDTH, graph.mouseX));
			totalMoveTime = Math.abs(startX - targetX) * 0.1;
			timeToTarget = totalMoveTime;
		}
		
		protected function moveToX(x:Number):void {
			currentX = x;
			bar.width = x - BAR_X;
			grab.x = x;
			circle.x = x;
		}
		
		override public function animate(dTime:Number):void {
			super.animate(dTime);
			
			if (timeToTarget > 0) {
				timeToTarget = Math.max(0, timeToTarget - dTime);
				var f:Number = 1 - (timeToTarget / totalMoveTime);
				var eased:Number = Utils.easeOut(f);
				var x:Number = startX + (targetX - startX) * eased;
				moveToX(x);
			}
		}

	}

}