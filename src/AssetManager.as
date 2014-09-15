package  {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;

	public class AssetManager {

		private static var loadCount:int = 0;
		public static function get isLoading():Boolean { return (loadCount > 0); }

		private static const images:Dictionary = new Dictionary();
		
		
		static public function getImage(imageURL:String):BitmapData {
			return images[imageURL];
		}
		static public function loadImage(imageURL:String):void {
			var loader:Loader = new Loader();
			loadCount++;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleImageLoaded);
			loader.load(new URLRequest(imageURL));
		}		
		static protected function handleImageLoaded(event:Event):void {
			var info:LoaderInfo = event.target as LoaderInfo;
			info.removeEventListener(Event.COMPLETE, handleImageLoaded);
			var path:String = info.loaderURL.substr(0, info.loaderURL.lastIndexOf("/")) + "/";
			var imageURL:String = info.url.substr(path.length);
			var image:BitmapData = (info.content as Bitmap).bitmapData;
			images[imageURL] = image;
			loadCount--;
		}


	}

}