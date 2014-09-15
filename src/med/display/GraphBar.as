package med.display {
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.text.TextField;

	public class GraphBar extends _GraphBar {
		
		public function GraphBar(text:String, width:Number, height:Number) {
			field.text = text || "";
			
			bg.width = width;
			bg.height = height;
			
			blendMode = BlendMode.LAYER;
			field.blendMode = BlendMode.ERASE;
		}

	}

}