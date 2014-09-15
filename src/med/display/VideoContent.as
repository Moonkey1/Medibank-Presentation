package med.display {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import med.data.VideoSet;
	import med.data.VideoSlide;

	public class VideoContent extends Content {
		/*
		protected function createTextFormats():void {
			var format:TextFormat;			
			chapterHeaderFormat = format = new TextFormat("DINCond-Black", 15);
			format.leading = -5;
			format.letterSpacing = -0.35;
			storyHeaderFormat = format = new TextFormat("DIN Bold", 13);
			format.leading = -1;
			format.letterSpacing = -0.35;
			quoteFormat = format = new TextFormat("DIN Bold", 11);
			format.leading = -2;
			format.letterSpacing = -0.35;
			contentFormat = format = new TextFormat("DIN", 11);
			format.leading = 0;//-2;
			format.letterSpacing = -0.1;
			contentBoldFormat = format = new TextFormat("DIN Bold", 11);
			format.leading = 0;//-2;
			format.letterSpacing = -0.1;
			contentNewlineFormat = format = new TextFormat("DIN", 0);
			format.leading = 0;
			labelFormat = format = new TextFormat("DIN Bold", 27);
			format.leading = -2;
			format.letterSpacing = -0.35;
			format.align = TextFormatAlign.CENTER;
		}
		*/

		protected var sets:Vector.<VideoSet>;
		protected var currentSet:VideoSet;
		protected var setIndex:int;
		
		protected var players:Vector.<VideoSetPlayer>;
		protected var currentPlayer:VideoSetPlayer;
		

		public function VideoContent(color:uint, sets:Vector.<VideoSet>) {
			super(color);

			this.sets = sets;

			players = new Vector.<VideoSetPlayer>();
			for each(var videoSet:VideoSet in sets) {
				players.push(new VideoSetPlayer(videoSet));
			}
			
			setIndex = 0;
			currentSet = sets[setIndex];
			currentPlayer = players[setIndex];
			
			addChild(currentPlayer);
		
			//addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false, 0, true);
		}
		
		override public function animate(dTime:Number):void {
			super.animate(dTime);
			
			if (full) {
				currentPlayer.resume();
			} else {
				currentPlayer.pause();
			}
		}
		
		
		
	}


}