package med.display {
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import med.data.BarData;

	public class GraphContent extends Content {

		public var titleField:TextField;
		public var textField:TextField;
		public var graphTextField:TextField;
		
		protected var graphRect:Rectangle;
		
		public function GraphContent(color:uint, title:String, text:String, graphText:String, barDatas:Vector.<BarData>) {
			super(color);
			
			titleField.text = title;
			textField.text = text;
			graphTextField.text = graphText;
			
			graphRect = new Rectangle(900, 200, 1450, 1300);
			
			//graphics.beginFill(0x0);
			//graphics.drawRect(graphRect.x, graphRect.y, graphRect.width, graphRect.height);
			//graphics.endFill();
			
			var len:int = barDatas.length;
			if (len > 0) {
				const GAP:Number = 30;
				const WIDTH:Number = (graphRect.width - (len - 1) * GAP) / len;
				for (var i:int = 0; i < len; i++) {
					var data:BarData = barDatas[i];
					var bar:GraphBar = new GraphBar(data.text, WIDTH, graphRect.height * data.value);
					bar.x = graphRect.x + (i + 0.5) * WIDTH + (i - 1) * GAP;
					bar.y = graphRect.y + graphRect.height * (1 - data.value);
					addChild(bar);
				}				
			}
			
		}

	}

}