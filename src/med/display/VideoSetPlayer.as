package med.display {
	import flash.display.Sprite;
	import flash.events.AsyncErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.geom.Rectangle;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import med.data.VideoSet;
	import med.data.VideoSlide;

	public class VideoSetPlayer extends _VideoSetPlayer {
		
		public var videoSet:VideoSet;
		protected var slideIndex:int;
		
		protected var titleField:TextField;
		protected var textField:TextField;
		
		protected var video1:Video;
		protected var video2:Video;
		protected var stream1:NetStream;
		protected var stream2:NetStream;
		protected var currentStream:NetStream;
		protected var offStream:NetStream;
		
		protected var playing:Boolean;
		
		
		public function VideoSetPlayer(videoSet:VideoSet) {
			this.videoSet = videoSet;

			titleField = overlay.getChildByName("titleField") as TextField;
			textField = overlay.getChildByName("textField") as TextField;
			titleField.autoSize = TextFieldAutoSize.LEFT;
			textField.autoSize = TextFieldAutoSize.LEFT;
			
			initVideos();
			
			continueSequence();
						
		}

		protected function initVideos():void {
			
			var nc:NetConnection = new NetConnection();
			nc.connect(null);

			//Create a NetStream object, passing the NetConnection object as an argument to the constructor. The following snippet connects a NetStream object to the NetConnection instance and sets up the event handlers for the stream:
			stream1 = new NetStream(nc);
			stream1.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			stream1.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			stream1.client = { onMetaData:function(obj:Object):void { } }
			stream2 = new NetStream(nc);
			stream2.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			stream2.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			stream2.client = { onMetaData:function(obj:Object):void { } }
			
			
			video1 = new Video();
			video1.smoothing = true;
			video1.attachNetStream(stream1);
			video2 = new Video();
			video2.smoothing = true;
			video2.attachNetStream(stream2);
			
		}
		
		protected function continueSequence():void {
			var currentSlide:VideoSlide = videoSet.slides[slideIndex];
			var offSlide:VideoSlide = videoSet.slides[(slideIndex + 1) % videoSet.slides.length];
			var currentVideo:Video;
			
			if (video1.parent) video1.parent.removeChild(video1);
			if (video2.parent) video2.parent.removeChild(video2);
			if (currentStream == stream1) {
				currentVideo = video2;
				currentStream = stream2;
				offStream = stream1;
			} else {
				currentVideo = video1;
				currentStream = stream1;
				offStream = stream2;
			}
			addChildAt(currentVideo, 0);
			
			//1920, 1088
			//2458 1607 1.2802083333333334 1.4770220588235294
			var scale:Number = Math.max(Content.WIDTH / currentSlide.width, Content.HEIGHT / currentSlide.height);
			var scaledWidth:Number = currentSlide.width * scale;
			var scaledHeight:Number = currentSlide.height * scale;
			currentVideo.width = scaledWidth;
			currentVideo.height = scaledHeight;
			currentVideo.scrollRect = new Rectangle(int((scaledWidth - Content.WIDTH) / 2 / currentVideo.scaleX), int((scaledHeight - Content.HEIGHT) / 2 / currentVideo.scaleY), scaledWidth, scaledHeight);
			//trace(currentVideo.scrollRect, currentVideo.scaleX, currentVideo.scaleY);
			
			if (currentSlide.stream) {
				currentStream.resume();
			} else {
				currentStream.play(currentSlide.url);
			}
			playing = true;
			
			offSlide.stream = offStream;
			offStream.play(offSlide.url);
			offStream.pause();
			
			//if (slideIndex == 0) currentStream.seek(40);
			//else currentStream.seek(30);

			showOverlay(currentSlide);
			
		}
		
		private function netStatusHandler(event:NetStatusEvent):void {
			if (event.info.code == "NetStream.Play.Stop") {
				slideIndex = (slideIndex + 1) % videoSet.slides.length;
				continueSequence();
			}
		}

		private function asyncErrorHandler(event:AsyncErrorEvent):void {
		}
		
		public function pause():void {
			if (currentStream) currentStream.pause();
			playing = false;
		}
		public function resume():void {
			if (currentStream) currentStream.resume();
			playing = true;
		}
		
		protected function showOverlay(slide:VideoSlide):void {
			const GAP:Number = 30;
			if (slide.title || slide.text) {
				overlay.visible = true;
				if (slide.title) {
					titleField.visible = true;
					titleField.text = slide.title;
					textField.y = int(titleField.y + titleField.height + GAP);
				} else {
					titleField.visible = false;
					textField.y = titleField.y;
				}
				if (slide.text) {
					textField.visible = true;
					
					var text:String = slide.text;
					text = text.replace(/\n\r/ig, '\n');
					text = text.replace(/\r\n/ig, '\n');
					text = text.replace(/\r/ig, '\n');

					//1200					
					textField.text = text;
					textField.autoSize = TextFieldAutoSize.LEFT;
					var format:TextFormat = textField.getTextFormat(0, 1);
					
					//format = new TextFormat("DIN", 11);
					format = new TextFormat("DIN", 50);
					format.leading = 0;//-2;
					format.letterSpacing = -0.1;

					//trace(format.size);
					while (textField.y + textField.height > 1180) {
						format.size = int(format.size) - 1;
						textField.setTextFormat(format, 0, text.length);
						//break;
					}
					
				} else {
					textField.visible = false;
				}				
			} else {
				overlay.visible = false;
			}
		}
		
	}

}