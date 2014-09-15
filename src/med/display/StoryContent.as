package med.display {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import med.data.TextData;

	public class StoryContent extends Content {
		
		protected var panelA:Sprite;
		protected var panelB:Sprite;
		

		public function StoryContent(color:uint, textDatas:Vector.<TextData>, bgImage:BitmapData) {
			super(color);
			
			if (bgImage) {
				var bitmap:Bitmap = new Bitmap(bgImage, "auto", true);
				var bgScale:Number = Math.max(WIDTH / bgImage.width, HEIGHT / bgImage.height);
				bitmap.scaleX = bitmap.scaleY = bgScale;
				bitmap.x = -(bitmap.width - WIDTH) / 2;
				bitmap.y = -(bitmap.height - HEIGHT) / 2;
				addChild(bitmap);
				trace(bgScale, bitmap.x, bitmap.y);
			}
			
			panelA = new Sprite();
			panelB = new Sprite();
			var panels:Array = [panelA, panelB];
			
			const SPACING:Number = 100;
			
			for each(var panel:Sprite in panels) {
				var y:Number = 30;
				for each(var data:TextData in textDatas) {
					var section:TextSection = new TextSection(data);
					panel.addChild(section);
					section.y = y;
					panel.addChild(section);
					y += section.getHeight() + SPACING;
				}
			}
			
			addChild(panelA);
		}
		

	}

}