package med.display {
	import com.greensock.easing.Quad;
	import com.greensock.TweenMax;
	import flash.display.Sprite;

	public class Screen extends Sprite {
		
		static public const CONTENT_FADE_TIME:Number = 0.5;

		protected var background:Background;
		
		public var content:Content;
		public var screenSaver:ScreenSaver;
				
		protected var screenSaverFinishedCallback:Function;

		protected var _full:Boolean;
		public function get full():Boolean { return _full; }		
		public function set full(value:Boolean):void { _full = value; content.full = value; }
		public var closed:Boolean;
		
		public var color:uint;
		
		
		public function Screen(title:String, color:uint, content:Content, screenSaverContent:Content, screenSaverText:String, screenSaverFinishedCallback:Function) {
			this.screenSaverFinishedCallback = screenSaverFinishedCallback;
			this.color = color;
			this.content = content;			
			screenSaver = new ScreenSaver(screenSaverText, screenSaverContent, onScreenSaverFinished);

			var background:Background;
			background = new Background(Content.WIDTH + 1, Content.HEIGHT);
			background.showColor(color);			
			addChild(background);
			
			addChild(content);
		}
		
		protected function onScreenSaverFinished():void {
			if (screenSaverFinishedCallback != null) screenSaverFinishedCallback();
		}
		
		public function resetContent():void {
			content.reset();
		}
		
		public function pauseContent():void {
			content.pause();
		}

		public function resumeContent():void {
			content.resume();
		}
		
		public function resetScreenSaver():void {
			screenSaver.content.reset();
		}
		
		public function pauseScreenSaver():void {
			screenSaver.content.pause();
		}

		public function resumeScreenSaver():void {
			screenSaver.content.resume();
		}
		
		
		public function animateContent(dTime:Number):void {
			if (content.parent) {
				content.animate(dTime);
			}
		}
		public function animateScreenSaver(dTime:Number):void {
			if (screenSaver.parent) {
				screenSaver.animate(dTime);
			}
		}
		
		public function fadeToScreenSaver(instant:Boolean):void {
			if (instant) {
				if (content.parent) content.parent.removeChild(content);
				resetContent();
				addChild(screenSaver);
				screenSaver.animateOn(true);
			} else {
				TweenMax.to(content, CONTENT_FADE_TIME, { alpha:0, ease:Quad.easeOut, onComplete:onContentFadedOut } );
			}
		}		
		protected function onContentFadedOut():void {
			if (content.parent) content.parent.removeChild(content);
			resetContent();
			addChild(screenSaver);
			screenSaver.animateOn(false);
		}
		
		public function fadeToContent(instant:Boolean):void {
			if (instant) {
				screenSaver.animateOff(true, null);
				if (screenSaver.parent) screenSaver.parent.removeChild(screenSaver);
				resetScreenSaver();
				addChild(content);
				content.alpha = 1;
			} else {
				screenSaver.animateOff(false, onScreenSaverAnimatefOff);
			}
		}
		
		protected function onScreenSaverAnimatefOff():void {
			if (screenSaver.parent) screenSaver.parent.removeChild(screenSaver);
			resetScreenSaver();
			addChild(content);
			content.alpha = 0;
			TweenMax.to(content, CONTENT_FADE_TIME, { alpha:1, ease:Quad.easeIn } );
		}
		
	}

}