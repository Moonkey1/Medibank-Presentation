package med.display {
	import flash.display.Sprite;

	public class Content extends Sprite {

		static public const WIDTH:Number = Main.WIDTH;
		static public const HEIGHT:Number = Main.HEIGHT;

		public var color:uint;

		public var takenAction:Boolean; // When something has happened which should cause the overall idleTime to be reset

		protected var _full:Boolean;
		public function get full():Boolean { return _full; }		
		public function set full(value:Boolean):void { _full = value; }

		protected var paused:Boolean;
		
		public function get isIdle():Boolean { return false; }
		
		public function Content(color:uint) {
			
			this.color = color;
			
		}
		
		public function animate(dTime:Number):void {
			
		}
		
		public function pause():void {
			paused = true;
		}
		
		public function resume():void {
			paused = false;
		}
		
		public function reset():void {
			
		}
		

	}

}