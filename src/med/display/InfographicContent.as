package med.display {
	import med.infographic.Infographic;
	import med.infographic.InfographicData;

	public class InfographicContent extends Content {
		
		protected var infographicData:InfographicData;

		protected var background:Background;
		protected var infographic:Infographic;
		
		override public function get isIdle():Boolean { return infographic.isOnLastFrame; }
		
		protected var showingSlideIndex:int;
		
		/*
		 * Default Infographic size is 1024 x 576
		 * 
		 * Window size for Content is 2857 - 399 x 1607 (2458 x 1607)
		 * 
		 * Infographic scaling to map default size to the window (with letterboxing) = 2.400390625
		 * Unscaled height including letterboxing = 669.4743694060212
		 * 
		 * scale of a 1080 video = 0.6198836753759455
		 * scale of a 1088 video = 0.6153257071746518
		 */
				
		
		public function InfographicContent(color:uint, infographicData:InfographicData) {
			Infographic.HEIGHT = 670;

			super(color);
			this.infographicData = infographicData;
			
			background = new Background(WIDTH, HEIGHT);
			background.showColor(color);
			addChild(background);
			
			var infographicColors:Vector.<uint> = new Vector.<uint>();
			
			if (infographicData.xml.hasOwnProperty("InfographicColors")) {
				// get the colors from a tag at the infographic level (rather than at Chapter level in Medibank-Core)
				infographicColors.push(uint(infographicData.xml.InfographicColors.@color1.toString().replace("#", "0x")));
				infographicColors.push(uint(infographicData.xml.InfographicColors.@color2.toString().replace("#", "0x")));
				infographicColors.push(uint(infographicData.xml.InfographicColors.@color3.toString().replace("#", "0x")));			
				infographicColors.push(uint(infographicData.xml.InfographicColors.@color4.toString().replace("#", "0x")));			
				infographicColors.push(uint(infographicData.xml.InfographicColors.@color5.toString().replace("#", "0x")));			
				infographicColors.push(uint(infographicData.xml.InfographicColors.@color6.toString().replace("#", "0x")));			
			} else {
				Infographic.DEFAULT_COLORS;
			}
						
			infographic = new Infographic(infographicData, background, infographicColors);
			addChild(infographic);
			infographic.x = WIDTH / 2;
			infographic.y = HEIGHT / 2;
			var scale:Number = Math.min(WIDTH / 1024, HEIGHT / 576);
			infographic.scaleX = infographic.scaleY = scale;
			
		}
		
		override public function animate(dTime:Number):void {
			super.animate(dTime);
			
			if (showingSlideIndex != infographic.currentSlideIndex) {
				showingSlideIndex = infographic.currentSlideIndex;
				takenAction = true;
			}
			
			infographic.animate(dTime);
		}
		
		
		
		override public function pause():void {
			if (paused) return;
			paused = true;
			
			infographic.pauseMedia();
		}
		
		override public function resume():void {
			if (!paused) return;
			paused = false;

			infographic.resumeMedia();
		}
		
		override public function reset():void {
			super.reset();
			
			infographic.reset();
		}

	}

}