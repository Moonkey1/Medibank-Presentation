package med.display {
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import med.data.TextData;

	public class TextSection extends _TextSection {
		
		public static const MARGIN:Number = 50;
		static public const TEXT_SCALE:Number = 1;

		static public const TYPE_HEADER:String = "Header";
		public static const TYPE_QUOTE:String = "Quote";
		public static const TYPE_CONTENT:String = "Content";
		public static const TYPE_SPLASH:String = "Splash";
		
		protected static var headerFormat:TextFormat;
		protected static var quoteFormat:TextFormat;
		protected static var contentFormat:TextFormat;
		protected static var contentBoldFormat:TextFormat;
		protected static var contentNewlineFormat:TextFormat;
		protected static var splashFormat:TextFormat;
		
		protected function createTextFormats():void {
			var format:TextFormat;			
			headerFormat = format = new TextFormat("DIN Bold", 130);
			format.leading = -1;
			format.letterSpacing = -0.35;
			quoteFormat = format = new TextFormat("DIN Bold", 80);
			format.leading = -2;
			format.letterSpacing = -0.35;
			contentFormat = format = new TextFormat("DIN", 40);
			format.leading = 0;//-2;
			format.letterSpacing = -0.1;
			contentBoldFormat = format = new TextFormat("DIN Bold", 40);
			format.leading = 0;//-2;
			format.letterSpacing = -0.1;
			contentNewlineFormat = format = new TextFormat("DIN", 0);
			format.leading = 0;
			splashFormat = format = new TextFormat("DIN Bold", 60);
			format.leading = -2;
			format.letterSpacing = -0.35;
			format.align = TextFormatAlign.CENTER;
		}

		
		
		protected static const MOMENTUM_FALLOFF:Number = 0.4;
		protected static const INITIAL_WAIT:Number = 5000;
		protected static const TOUCH_WAIT:Number = 2000;
		protected static const END_WAIT:Number = 3000;
		protected static const AUTO_SCROLL:Number = 3;
		
		public var subtextField:TextField;
		public var textMask:Sprite;
		
		protected var min:Number;
		protected var max:Number;
		protected var dragY:Number;
		protected var mouseInteractor:DisplayObjectContainer;
		protected var momentum:Number;
		protected var dragging:Boolean;
		protected var autoWait:Number;
		protected var autoIncrease:Boolean;
		protected var scrollY:Number;
		
		protected var scrollBar:Shape;
		
		public function get isScroller():Boolean { return (scrollBar != null); }

		public function getHeight():Number { return textField.y + textField.height + 2; }

		
		public function TextSection(data:TextData) {
			
			if (!quoteFormat) createTextFormats();
			
			var width:Number = Content.WIDTH - MARGIN * 2;
			var height:Number = Content.HEIGHT * 0.5;
			
			var textType:String = data.type;
			var text:String = data.text;
			var textScale:Number = 1;

			text = text.replace(/\n\r/ig, '\n');
			text = text.replace(/\r\n/ig, '\n');
			text = text.replace(/\r/ig, '\n');

			switch(textType) {
				case TYPE_SPLASH:
					textField.autoSize = TextFieldAutoSize.CENTER;
					break;
				default:
					textField.autoSize = TextFieldAutoSize.LEFT;
					break;					
			}
			
			
			if (textType == TYPE_CONTENT) {
		
				fillText(text, contentFormat, contentBoldFormat);
				
				textField.width = width;
				textField.height = height;
				textField.x = MARGIN;
				textField.y = 0;

				setupScrolling(width, height);
				
			} else {
				switch(textType) {
					case TYPE_HEADER: textField.defaultTextFormat = headerFormat; break;
					case TYPE_QUOTE: textField.defaultTextFormat = quoteFormat; break;
					case TYPE_SPLASH: textField.defaultTextFormat = splashFormat; break;
				}
								
				textField.text = text;
				textField.width = width;
				//textField.height = height;
				
				switch(textType) {
					case TYPE_SPLASH:
						textField.x = width / 2 - textField.width / 2;
						textField.y = 0;
						break;
					default:
						textField.x = MARGIN;
						textField.y = 0;
						break;
				}
				
			}			
			
		}
		
		
		
		protected function setupScrolling(width:Number, height:Number):void {
			if (textField.height > height) {
				
				const BAR_WIDTH:Number = 10;
				textField.width -= (BAR_WIDTH + 20);
				
				scrollY = textField.y;
				min = textField.y - (textField.height - height);
				max = textField.y;
				momentum = 0;
				autoIncrease = false;
				
				textMask = new Sprite();
				textMask.graphics.beginFill(0xFFFFFF);
				textMask.graphics.drawRect(0, 0, width, height);
				textMask.graphics.endFill();
				textMask.visible = false;
				textMask.x = textField.x;
				textField.mask = textMask;
				addChild(textMask);
				
				autoWait = INITIAL_WAIT;
				
				scrollBar = new Shape();
				scrollBar.graphics.beginFill(0xFFFFFF, 0.3);
				scrollBar.graphics.drawRect(0, 0, BAR_WIDTH, height * (height / textField.height));
				scrollBar.graphics.endFill();
				addChild(scrollBar);
				scrollBar.x = textField.x + width - BAR_WIDTH;
				
				scrollTo(0);
				
				addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage, false, 0, true);
			}
		}
		
		
		protected function handleAddedToStage(event:Event):void {
			for (mouseInteractor = this; mouseInteractor != null; mouseInteractor = mouseInteractor.parent) {
				if (!mouseInteractor.mouseChildren) {
					break;
				} else if (mouseInteractor == stage) {
					mouseInteractor = this;
					break;
				}
			}
			if (!mouseInteractor) return;
			
			addEventListener(Event.REMOVED_FROM_STAGE, handleRemovedFromStage, false, 0, true);
			mouseInteractor.addEventListener(MouseEvent.MOUSE_DOWN, handleBeginDrag, false, 0, true);			
		}
		protected function handleRemovedFromStage(event:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, handleRemovedFromStage);
			mouseInteractor.removeEventListener(MouseEvent.MOUSE_DOWN, handleBeginDrag, false);			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMove, false);
			stage.removeEventListener(MouseEvent.MOUSE_UP, handleUp, false);
			dragging = false;
		}

		
		protected function handleBeginDrag(event:MouseEvent):void {
			stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMove, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, handleUp, false, 0, true);
			dragY = scrollY - mouseInteractor.mouseY;
			dragging = true;
		}
		protected function handleUp(event:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMove, false);
			stage.removeEventListener(MouseEvent.MOUSE_UP, handleUp, false);
			dragging = false;
		}
		protected function handleMove(event:MouseEvent):void {
			var target:Number = mouseInteractor.mouseY + dragY;
			var current:Number = scrollY;
			scrollTo(target);
			momentum += (target - current);
			autoWait = TOUCH_WAIT;
			if (target > current) autoIncrease = true;
			if (target < current) autoIncrease = false;
		}
		
		public function animate(dTime:Number):void {
			if (max == 0) return;
			momentum *= (1 - MOMENTUM_FALLOFF);
			if (!dragging) {
				if (momentum < 0) {
					scrollTo(scrollY + momentum);
					if (momentum > -1) momentum = 0;				
					if (scrollY == min) {
						momentum = 0;
						autoIncrease = true;
						autoWait = Math.max(autoWait, END_WAIT);
					}
				} else if (momentum > 0) {
					scrollTo(scrollY + momentum);
					if (momentum < 1) momentum = 0;				
					if (scrollY == max) {
						momentum = 0;
						autoIncrease = false;
						autoWait = Math.max(autoWait, END_WAIT);
					}
				} else {
					if (autoWait > 0) {
						autoWait = Math.max(0, autoWait - dTime);
					} else {
						var scroll:Number = dTime / 1000 * AUTO_SCROLL;
						if (autoIncrease) {
							if (scrollY + scroll >= max) {
								scrollTo(max);
								autoIncrease = false;
								autoWait = END_WAIT;
							} else {
								scrollTo(scrollY + scroll);
							}
						} else {
							if (scrollY - scroll <= min) {
								scrollTo(min);
								autoIncrease = true;
								autoWait = END_WAIT;
							} else {
								scrollTo(scrollY - scroll);
							}
						}
					}
				}
			}
		}
		
		protected function scrollTo(y:Number):void {
			textField.y = scrollY = Math.max(min, Math.min(max, y));
			scrollBar.y = textMask.y + (textMask.height - scrollBar.height) * ((scrollY - max) / (min - max));
		}
		
		protected function fillText(text:String, regularFormat:TextFormat, boldFormat:TextFormat):void {
			textField.text = "";
			var carat:int = 0
			var len:int;
			var i:int = 0;
			var boldStart:int;
			var boldEnd:int;
			while(true) {
				boldStart = text.indexOf("[b]", i);
				boldEnd = text.indexOf("[/b]", boldStart);
				if ((boldStart >= 0) && (boldEnd >= 0)) {
					len = boldStart - i;
					if (len > 0) {
						textField.appendText(text.substr(i, len));
						textField.setTextFormat(regularFormat, carat, carat + len);
						carat += len;
					}
					len = boldEnd - boldStart - 3;
					if (len > 0) {
						textField.appendText(text.substr(boldStart + 3, len));
						textField.setTextFormat(boldFormat, carat, carat + len);
						carat += len;
					}
				} else {
					len = text.length - i;
					if (len > 0) {
						textField.appendText(text.substr(i, len));
						textField.setTextFormat(regularFormat, carat, carat + len);
						carat += len;
					}
					break;
				}
				i = boldEnd + 4;
			};
			var tft:String = textField.text;
			for (i = tft.lastIndexOf('\r'); i >= 0; i = tft.lastIndexOf('\r', i - 1)) {
				textField.replaceText(i, i, '\n');
				textField.setTextFormat(contentNewlineFormat, i, i + 1);					
			}
		}
	}

}