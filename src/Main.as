package {
	import com.greensock.easing.Quad;
	import com.greensock.TweenMax;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.SoundTransform;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.ui.Mouse;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import med.data.BarData;
	import med.data.TextData;
	import med.data.VideoSet;
	import med.data.VideoSlide;
	import med.display.Background;
	import med.display.Content;
	import med.display.GameContent;
	import med.display.GraphContent;
	import med.display.Handle;
	import med.display.InfographicContent;
	import med.display.RateContent;
	import med.display.Screen;
	import med.display.ScreenSaver;
	import med.display.ScreenSaverOverlay;
	import med.display.StoryContent;
	import med.display.VideoContent;
	import med.infographic.InfographicData;

	public class Main extends Sprite {
		
		static public const SET_INDEX:int = 0;

		public static const WIDTH:Number = 1920;
		public static const HEIGHT:Number = 1080;
		public static const SCALE:Number = 0.5;
		// 0.7060167387913802
		// 40% = 1143, 643

		protected var xmlLoader:URLLoader;
		protected var loadedXML:XML;
		
		protected var screenSets:Vector.<Vector.<String>>;
		protected var screenData:Dictionary;
		
		
		protected var lastFrameTime:Number;
		
		private var contentLayer:Sprite;
		
		public var currentScreen:Screen;
		

		public function Main() {
			scaleX = scaleY = SCALE;
			
			TextUtils.createTextFormats();
			new _FontDump();
			
			//soundTransform = new SoundTransform(0);
			
			contentLayer = new Sprite();
			addChild(contentLayer);
			
			xmlLoader = new URLLoader();
			xmlLoader.addEventListener(Event.COMPLETE, handleXMLLoaded);
			xmlLoader.load(new URLRequest("PresentationData.XML"));
			
			CONFIG::release {
				Mouse.hide();
				addEventListener(MouseEvent.CLICK, handleFullScreenClick);
			}
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, handleFullScreenChange);
		}

		protected function handleXMLLoaded(event:Event):void {
			loadedXML = new XML(xmlLoader.data);

			xmlLoader.removeEventListener(Event.COMPLETE, handleXMLLoaded);
			xmlLoader = null;

			preloadImages(loadedXML);

			addEventListener(Event.ENTER_FRAME, handleCheckImagesLoaded);
		}
		
		protected function handleCheckImagesLoaded(event:Event):void {
			if (AssetManager.isLoading) return;
			removeEventListener(Event.ENTER_FRAME, handleCheckImagesLoaded);			

			readSets(loadedXML);
			readScreens(screenSets[SET_INDEX]);
			
			lastFrameTime = getTimer();
			
			addEventListener(Event.ENTER_FRAME, handleEnterFrame);
			//addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
		}
		
		
		protected function handleEnterFrame(event:Event):void {
			var time:Number = getTimer();
			var dTime:Number = time - lastFrameTime;
			
			lastFrameTime = time;
			
			animate(dTime);
			
		}
		
		protected function animate(dTime:Number):void {
			//background.animate(dTime);
			
			if (currentScreen) currentScreen.animateContent(dTime);

		}
		
		
		
		
		
		
		
		
		static public function preloadImages(loadedXML:XML):void {
			//<Image url="assets/Test Image.png" />
			var xmlString:String = loadedXML.toString();
			for (var index:int = xmlString.lastIndexOf("<Image"); index >= 0; index = xmlString.lastIndexOf("<Image", index - 1)) {
				var startIndex:int = xmlString.indexOf("\"", index);
				var endIndex:int = xmlString.indexOf("\"", startIndex + 1);
				var url:String = xmlString.substr(startIndex + 1, (endIndex - startIndex) - 1);
				AssetManager.loadImage(url);
			}			
		}
				
		protected function readSets(loadedXML:XML):void {
			screenSets = new Vector.<Vector.<String>>();
			var id:String;
			for each(var setXML:XML in loadedXML.ScreenSet) {
				var screenSet:Vector.<String> = new Vector.<String>();
				var s:String = setXML.toString();
				s = s.replace(/ /ig, "");
				var ids:Array = s.split(",");
				for each(id in ids) screenSet.push(id);
				screenSets.push(screenSet);
			}
			screenData = new Dictionary();
			for each(var screenXML:XML in loadedXML.Screen) {
				id = screenXML.@id.toString();
				screenData[id] = screenXML;
			}
		}
		
		protected function readScreens(screenSet:Vector.<String>):void {
			Handle.WIDTH = Handle.TOTAL_WIDTH / screenSet.length;
			for each(var id:String in screenSet) {
				var screenXML:XML = screenData[id];
				
				// Color
				var color:uint;
				if (screenXML.hasOwnProperty("Colour")) {
					var colorString:String = screenXML.Colour[0].toString();
					if (colorString.charAt(0) == "#") colorString = colorString.substr(1);
					color = uint("0x" + colorString);
				}
				
				// Handle Text
				var handleText:String = "";
				if (screenXML.hasOwnProperty("Handle")) handleText = screenXML.Handle[0].toString();				
				var screenSaverText:String = handleText;
				
				var content:Content = null;
				if (screenXML.hasOwnProperty("Content")) content = createContent(screenXML.Content[0], color);
				if (!content) content = new Content(color);				
				var screenSaverContent:Content = null;
				if (screenXML.hasOwnProperty("ScreenSaverContent")) {
					screenSaverContent = createContent(screenXML.ScreenSaverContent[0], color);
					var screenSaverXML:XML = screenXML.ScreenSaverContent[0];
					if (screenSaverXML.hasOwnProperty("@alpha")) {
						if (screenSaverContent) screenSaverContent.alpha = parseFloat(screenSaverXML.@alpha);
					}
					if (screenSaverXML.hasOwnProperty("ScreenSaverText")) screenSaverText = TextUtils.safeText(screenSaverXML.ScreenSaverText[0].toString());
				}
				if (!screenSaverContent) screenSaverContent = new Content(color);
				
				
				currentScreen = new Screen(handleText, color, content, screenSaverContent, screenSaverText, onScreenSaverFinished);
				contentLayer.addChild(currentScreen);
			}
				
		}
		
		protected function onScreenSaverFinished():void {
			
		}
		
		
		protected static function createContent(xml:XML, color:uint):Content {
			var title:String;
			var title1:String;
			var title2:String;
			var text:String;
			var graphText:String;
			
			var content:Content;
			switch(xml.@type.toString().toLowerCase()) {
				case "pong":
					title1 = "";
					title2 = "";
					if (xml.hasOwnProperty("Title1")) title1 = xml.Title1.toString();
					if (xml.hasOwnProperty("Title2")) title2 = xml.Title2.toString();
					content = new GameContent(color, title1, title2);
					break;
					
				case "graph":
					title = "";
					text = "";
					graphText = "";
					var bars:Vector.<BarData> = new Vector.<BarData>();
					if (xml.hasOwnProperty("Title")) title = xml.Title.toString();
					if (xml.hasOwnProperty("Text")) text = xml.Text.toString();
					if (xml.hasOwnProperty("Graph")) {
						var graphXML:XML = xml.Graph[0];
						if (graphXML.hasOwnProperty("Text")) graphText = graphXML.Text.toString();
						for each(var barXML:XML in graphXML.Bar) {
							bars.push(new BarData(parseFloat(barXML.@value) || 1, barXML.@text.toString() || ""));
						}
					}
					content = new GraphContent(color, title, text, graphText, bars);
					break;
					
				case "rate":
					title = "";
					if (xml.hasOwnProperty("Title")) title = xml.Title.toString();
					var labels:Vector.<String> = new Vector.<String>();
					if (xml.hasOwnProperty("Label0")) labels.push(xml.Label0.toString());
					else labels.push("");
					if (xml.hasOwnProperty("Label50")) labels.push(xml.Label50.toString());
					else labels.push("");
					if (xml.hasOwnProperty("Label100")) labels.push(xml.Label100.toString());
					else labels.push("");
					content = new RateContent(color, title, labels);
					break;
					
				case "video":
					var sets:Vector.<VideoSet> = new Vector.<VideoSet>();
					for each(var setXML:XML in xml.Set) {
						var videoSet:VideoSet = new VideoSet();
						for each(var slideXML:XML in setXML.Video) {
							var slide:VideoSlide = new VideoSlide();
							if (slideXML.hasOwnProperty("@url")) slide.url = slideXML.@url.toString();
							else continue;
							if (slideXML.hasOwnProperty("@width")) slide.width = parseFloat(slideXML.@width);
							else slide.width = 1920;
							if (slideXML.hasOwnProperty("@height")) slide.height = parseFloat(slideXML.@height);
							else slide.height = 1088;
							if (slideXML.hasOwnProperty("Title")) slide.title = slideXML.Title[0].toString();
							if (slideXML.hasOwnProperty("Text")) slide.text = slideXML.Text[0].toString();
							videoSet.slides.push(slide);
						}
						sets.push(videoSet);
					}
					content = new VideoContent(color, sets);
					break;
					
				case "story":
					var datas:Vector.<TextData> = new Vector.<TextData>();
					for each(var textXML:XML in xml.Text) {
						datas.push(new TextData(textXML.@type.toString(), textXML.toString()));
					}
					var bgImage:BitmapData;
					if (xml.hasOwnProperty("Background")) {
						var backgroundXML:XML = xml.Background[0];
						if (backgroundXML.hasOwnProperty("Image")) {
							var imageXML:XML = backgroundXML.Image[0];
							bgImage = AssetManager.getImage(imageXML.@url.toString());
						}
					}
					content = new StoryContent(color, datas, bgImage);
					break;
					
				case "infographic":
					var infographicXML:XML = xml.Infographic[0];
					content = new InfographicContent(color, new InfographicData(infographicXML));
					break;
			}
			return content;
		}
		
		
		protected function handleFullScreenClick(event:MouseEvent):void {
			stage.displayState = StageDisplayState.FULL_SCREEN;
			removeEventListener(MouseEvent.CLICK, handleFullScreenClick);
		}
		protected function handleFullScreenChange(event:FullScreenEvent):void {
			if (stage.displayState == StageDisplayState.NORMAL) {
				addEventListener(MouseEvent.CLICK, handleFullScreenClick);
			}
		}
	}

}