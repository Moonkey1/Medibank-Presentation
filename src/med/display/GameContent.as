package med.display {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import med.interaction.Pong;

	public class GameContent extends Content {
		
		override public function set full(value:Boolean):void { super.full = value; pong.active = value; }

		public var line1:Sprite;
		public var line2:Sprite;
		protected var field1:TextField;
		protected var field2:TextField;
		
		public var playerScoreField:TextField;
		public var computerScoreField:TextField;
		
		protected var playerScore:int;
		protected var computerScore:int;
		
		protected var pong:Pong;
		
		public function GameContent(color:uint, text1:String, text2:String) {
			super(color);
		
			var assets:MovieClip = new _GameContentAssets();
			addChild(assets);
			
			field1 = assets.line1.getChildByName("field") as TextField;
			field2 = assets.line2.getChildByName("field") as TextField;
			field1.text = text1 || "";
			field2.text = text2 || "";
			
			playerScoreField = assets.playerScoreField;
			computerScoreField = assets.computerScoreField;
			
			playerScore = 0;
			computerScore = 0;			
			updateScores();
			
			pong = new Pong(new Rectangle(110, 400, 2238, 1100));
			addChild(pong);
			
			pong.addEventListener("Win", handleWin);
			pong.addEventListener("Lose", handleLose);
		}
		
		override public function animate(dTime:Number):void {
			super.animate(dTime);

			pong.animate(dTime);
		}
		
		override public function reset():void {
			super.reset();

			playerScore = 0;
			computerScore = 0;			
			updateScores();
			
			pong.reset(true);
		}
		
		protected function updateScores():void {
			playerScoreField.text = "" + playerScore;
			computerScoreField.text = "" + computerScore;
		}
		
		protected function handleLose(event:Event):void {
			computerScore++;
			updateScores();
		}
		
		protected function handleWin(event:Event):void {
			playerScore++;
			updateScores();
		}

	}

}