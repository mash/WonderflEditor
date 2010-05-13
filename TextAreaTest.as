package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextLineMetrics;
	import flash.text.engine.TextBlock;
	import flash.utils.getTimer;
	
	import net.hires.debug.Stats;
	
	[SWF(backgroundColor="#000000")]
	public class TextAreaTest extends Sprite
	{
		private var _textField:TextField;
		private var _traceField:TextField;
		private const LOOP:int = 1 << 14;
		private var _lines:Vector.<TextField>;
		
		public function TextAreaTest()
		{
			XML.prettyPrinting = false;
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			_textField = new TextField;
			_textField.defaultTextFormat = new TextFormat('_typewriter', null, 0xffffff);
			_traceField = new TextField;
			_traceField.x = 500;
			_traceField.textColor = 0xffffff;
			//addChild(_textField);
			addChild(_traceField);
			
			code_str = code_str.replace(/\n/g, "");
			_textField.text = code_str.replace(/\n/g, "");
			//_textField.width = _textField.textWidth + 4;
			//_textField.height = _textField.textHeight + 4;
			
			var rect:Rectangle = _textField.getCharBoundaries(0);
			var lines:int = Math.ceil(stage.stageHeight / rect.height);
			var off:int = _textField.getLineOffset(lines);
			
			_lines = new Vector.<TextField>(lines, true);
			
			var o:Object;
			var len:int = format_runs.length;
			var j:int;
			var i:int;
			var t:int;
			var tf:TextField;
			
			
			t = getTimer();
			
			var line_formats:Array = [];
			var line_format:Array;
			var pos:int = 0;
			var index:int = 0;
			j = 0;
			
			for (i = 0; i < lines; ++i) {
				tf = new TextField;
				tf.y = i * (rect.height);
				tf.mouseEnabled = false;
				tf.textColor = 0xffffff;
				addChild(tf);
				index = code_str.indexOf("\r", pos);
				if (index >= 0) {
					tf.text = code_str.substring(pos, index);
					
					o = format_runs[j];
					while (o && o.begin < index) {
						tf.setTextFormat(new TextFormat('_typewriter', null, parseInt("0x" + o.color), o.bold, o.italic), Math.max(0, o.begin - pos), Math.min(index - pos, o.end - pos));
						
						o = format_runs[j];
						if (o.end < index)
							++j;
						else
							break;
					}
					
					tf.width = tf.textWidth + 4;
				}
				pos = index + 1;
				_lines[i] = tf;
			}
			
			
			trace((getTimer() - t) + " ms");
		}
		
		private function trace(...args):void {
			_traceField.appendText(args + "\n");
			_traceField.width = _traceField.textWidth + 4;
			_traceField.height= _traceField.textHeight + 4;
		}
	}
}

var format_runs:Array = [{"italic":false,"bold":true,"begin":0,"color":"f39c64","end":7},{"italic":false,"bold":true,"begin":13,"color":"d54c02","end":19},{"italic":false,"bold":true,"begin":43,"color":"d54c02","end":49},{"italic":false,"bold":true,"begin":73,"color":"d54c02","end":79},{"italic":false,"bold":true,"begin":107,"color":"d54c02","end":113},{"italic":false,"bold":true,"begin":145,"color":"d54c02","end":151},{"italic":false,"bold":true,"begin":173,"color":"d54c02","end":179},{"italic":false,"bold":true,"begin":209,"color":"d54c02","end":215},{"italic":true,"bold":false,"begin":242,"color":"8c8c8c","end":284},{"italic":false,"bold":true,"begin":286,"color":"d54c02","end":292},{"italic":false,"bold":true,"begin":316,"color":"d54c02","end":322},{"italic":false,"bold":true,"begin":349,"color":"d54c02","end":355},{"italic":false,"bold":true,"begin":384,"color":"d54c02","end":390},{"italic":false,"bold":true,"begin":415,"color":"d54c02","end":421},{"italic":false,"bold":true,"begin":446,"color":"d54c02","end":452},{"italic":false,"bold":true,"begin":476,"color":"d54c02","end":482},{"italic":false,"bold":true,"begin":508,"color":"d54c02","end":514},{"italic":false,"bold":true,"begin":543,"color":"d54c02","end":549},{"italic":false,"bold":true,"begin":589,"color":"d54c02","end":595},{"italic":false,"bold":true,"begin":623,"color":"d54c02","end":629},{"italic":false,"bold":true,"begin":665,"color":"d54c02","end":671},{"italic":false,"bold":true,"begin":713,"color":"d54c02","end":719},{"italic":false,"bold":true,"begin":764,"color":"d54c02","end":770},{"italic":false,"bold":true,"begin":820,"color":"d54c02","end":826},{"italic":false,"bold":true,"begin":879,"color":"d54c02","end":885},{"italic":false,"bold":true,"begin":937,"color":"d54c02","end":943},{"italic":false,"bold":true,"begin":986,"color":"d54c02","end":992},{"italic":false,"bold":true,"begin":1042,"color":"d54c02","end":1048},{"italic":true,"bold":false,"begin":1076,"color":"8c8c8c","end":1119},{"italic":false,"bold":true,"begin":1121,"color":"d54c02","end":1127},{"italic":false,"bold":true,"begin":1128,"color":"f39c64","end":1133},{"italic":false,"bold":true,"begin":1145,"color":"d54c02","end":1152},{"italic":false,"bold":true,"begin":1168,"color":"d54c02","end":1175},{"italic":false,"bold":true,"begin":1176,"color":"d54c02","end":1182},{"italic":false,"bold":true,"begin":1183,"color":"f39c64","end":1188},{"italic":false,"bold":true,"begin":1194,"color":"455fac","end":1197},{"italic":false,"bold":true,"begin":1206,"color":"d54c02","end":1212},{"italic":false,"bold":true,"begin":1213,"color":"f39c64","end":1216},{"italic":false,"bold":true,"begin":1246,"color":"d54c02","end":1251},{"italic":false,"bold":false,"begin":1261,"color":"c28ebd","end":1292},{"italic":false,"bold":true,"begin":1297,"color":"d54c02","end":1304},{"italic":false,"bold":true,"begin":1305,"color":"f39c64","end":1308},{"italic":false,"bold":true,"begin":1321,"color":"455fac","end":1326},{"italic":false,"bold":true,"begin":1334,"color":"d54c02","end":1339},{"italic":false,"bold":false,"begin":1349,"color":"c28ebd","end":1382},{"italic":false,"bold":true,"begin":1387,"color":"d54c02","end":1394},{"italic":false,"bold":true,"begin":1395,"color":"f39c64","end":1398},{"italic":false,"bold":true,"begin":1412,"color":"455fac","end":1417},{"italic":false,"bold":true,"begin":1424,"color":"d54c02","end":1431},{"italic":false,"bold":true,"begin":1432,"color":"f39c64","end":1435},{"italic":false,"bold":true,"begin":1456,"color":"d54c02","end":1463},{"italic":false,"bold":true,"begin":1464,"color":"f39c64","end":1467},{"italic":false,"bold":true,"begin":1496,"color":"d54c02","end":1503},{"italic":false,"bold":true,"begin":1504,"color":"f39c64","end":1507},{"italic":false,"bold":true,"begin":1535,"color":"d54c02","end":1542},{"italic":false,"bold":true,"begin":1543,"color":"f39c64","end":1546},{"italic":false,"bold":true,"begin":1579,"color":"d54c02","end":1582},{"italic":false,"bold":true,"begin":1604,"color":"d54c02","end":1611},{"italic":false,"bold":true,"begin":1612,"color":"f39c64","end":1615},{"italic":false,"bold":true,"begin":1624,"color":"455fac","end":1630},{"italic":false,"bold":false,"begin":1632,"color":"c28ebd","end":1634},{"italic":false,"bold":true,"begin":1638,"color":"d54c02","end":1645},{"italic":false,"bold":true,"begin":1646,"color":"f39c64","end":1649},{"italic":false,"bold":true,"begin":1663,"color":"455fac","end":1668},{"italic":false,"bold":true,"begin":1677,"color":"d54c02","end":1684},{"italic":false,"bold":true,"begin":1685,"color":"f39c64","end":1688},{"italic":false,"bold":true,"begin":1708,"color":"d54c02","end":1711},{"italic":false,"bold":true,"begin":1722,"color":"d54c02","end":1729},{"italic":false,"bold":true,"begin":1730,"color":"f39c64","end":1733},{"italic":false,"bold":true,"begin":1745,"color":"455fac","end":1748},{"italic":false,"bold":true,"begin":1752,"color":"d54c02","end":1759},{"italic":false,"bold":true,"begin":1760,"color":"f39c64","end":1763},{"italic":false,"bold":true,"begin":1793,"color":"455fac","end":1800},{"italic":false,"bold":true,"begin":1803,"color":"d54c02","end":1808},{"italic":false,"bold":true,"begin":1812,"color":"d54c02","end":1819},{"italic":false,"bold":true,"begin":1820,"color":"f39c64","end":1823},{"italic":false,"bold":true,"begin":1832,"color":"455fac","end":1839},{"italic":false,"bold":true,"begin":1842,"color":"d54c02","end":1847},{"italic":false,"bold":true,"begin":1851,"color":"d54c02","end":1858},{"italic":false,"bold":true,"begin":1859,"color":"f39c64","end":1862},{"italic":false,"bold":true,"begin":1893,"color":"d54c02","end":1900},{"italic":false,"bold":true,"begin":1901,"color":"f39c64","end":1904},{"italic":false,"bold":true,"begin":1922,"color":"455fac","end":1929},{"italic":false,"bold":true,"begin":1933,"color":"d54c02","end":1940},{"italic":false,"bold":true,"begin":1941,"color":"f39c64","end":1944},{"italic":false,"bold":true,"begin":1955,"color":"455fac","end":1961},{"italic":false,"bold":true,"begin":1965,"color":"d54c02","end":1972},{"italic":false,"bold":true,"begin":1973,"color":"f39c64","end":1976},{"italic":false,"bold":true,"begin":2009,"color":"d54c02","end":2016},{"italic":false,"bold":true,"begin":2017,"color":"f39c64","end":2020},{"italic":false,"bold":true,"begin":2038,"color":"455fac","end":2044},{"italic":false,"bold":true,"begin":2051,"color":"d54c02","end":2057},{"italic":false,"bold":true,"begin":2058,"color":"f39c64","end":2066},{"italic":false,"bold":false,"begin":2094,"color":"c28ebd","end":2117},{"italic":false,"bold":true,"begin":2340,"color":"d54c02","end":2343},{"italic":false,"bold":true,"begin":2381,"color":"d54c02","end":2384},{"italic":false,"bold":true,"begin":2402,"color":"f39c64","end":2405},{"italic":false,"bold":true,"begin":2418,"color":"d54c02","end":2421},{"italic":false,"bold":true,"begin":2452,"color":"d54c02","end":2457},{"italic":false,"bold":true,"begin":2474,"color":"d54c02","end":2478},{"italic":false,"bold":true,"begin":2551,"color":"d54c02","end":2555},{"italic":false,"bold":true,"begin":2590,"color":"d54c02","end":2595},{"italic":false,"bold":true,"begin":2627,"color":"d54c02","end":2632},{"italic":false,"bold":true,"begin":2689,"color":"f39c64","end":2697},{"italic":false,"bold":true,"begin":2701,"color":"455fac","end":2705},{"italic":true,"bold":false,"begin":2712,"color":"8c8c8c","end":2802},{"italic":false,"bold":true,"begin":2870,"color":"f39c64","end":2878},{"italic":false,"bold":true,"begin":2882,"color":"455fac","end":2886},{"italic":false,"bold":true,"begin":2906,"color":"d54c02","end":2910},{"italic":false,"bold":true,"begin":2978,"color":"f39c64","end":2986},{"italic":false,"bold":true,"begin":2990,"color":"455fac","end":2994},{"italic":false,"bold":true,"begin":3014,"color":"d54c02","end":3019},{"italic":false,"bold":true,"begin":3045,"color":"d54c02","end":3048},{"italic":false,"bold":true,"begin":3192,"color":"d54c02","end":3195},{"italic":false,"bold":true,"begin":3293,"color":"d54c02","end":3295},{"italic":false,"bold":true,"begin":3434,"color":"f39c64","end":3442},{"italic":false,"bold":true,"begin":3446,"color":"455fac","end":3450},{"italic":false,"bold":true,"begin":3683,"color":"d54c02","end":3685},{"italic":false,"bold":true,"begin":3855,"color":"d54c02","end":3859},{"italic":false,"bold":true,"begin":3879,"color":"d54c02","end":3882},{"italic":true,"bold":false,"begin":3913,"color":"8c8c8c","end":3949},{"italic":true,"bold":false,"begin":3954,"color":"8c8c8c","end":4035},{"italic":true,"bold":false,"begin":4040,"color":"8c8c8c","end":4057},{"italic":true,"bold":false,"begin":4062,"color":"8c8c8c","end":4098},{"italic":true,"bold":false,"begin":4103,"color":"8c8c8c","end":4125},{"italic":true,"bold":false,"begin":4130,"color":"8c8c8c","end":4168},{"italic":true,"bold":false,"begin":4174,"color":"8c8c8c","end":4191},{"italic":true,"bold":false,"begin":4196,"color":"8c8c8c","end":4199},{"italic":true,"bold":false,"begin":4204,"color":"8c8c8c","end":4207},{"italic":false,"bold":true,"begin":4215,"color":"d54c02","end":4217},{"italic":false,"bold":true,"begin":4345,"color":"d54c02","end":4350},{"italic":false,"bold":true,"begin":4418,"color":"d54c02","end":4422},{"italic":false,"bold":true,"begin":4452,"color":"d54c02","end":4455},{"italic":false,"bold":true,"begin":4554,"color":"d54c02","end":4561},{"italic":false,"bold":true,"begin":4562,"color":"f39c64","end":4570},{"italic":false,"bold":true,"begin":4599,"color":"455fac","end":4603},{"italic":false,"bold":true,"begin":4612,"color":"d54c02","end":4614},{"italic":false,"bold":true,"begin":4729,"color":"d54c02","end":4733},{"italic":false,"bold":true,"begin":4744,"color":"d54c02","end":4751},{"italic":false,"bold":true,"begin":4752,"color":"f39c64","end":4760},{"italic":false,"bold":true,"begin":4793,"color":"455fac","end":4797},{"italic":false,"bold":true,"begin":4806,"color":"d54c02","end":4808},{"italic":false,"bold":true,"begin":4827,"color":"d54c02","end":4829},{"italic":true,"bold":false,"begin":4850,"color":"8c8c8c","end":4861},{"italic":false,"bold":true,"begin":4895,"color":"d54c02","end":4901},{"italic":false,"bold":true,"begin":4902,"color":"f39c64","end":4910},{"italic":false,"bold":true,"begin":4918,"color":"455fac","end":4922},{"italic":false,"bold":true,"begin":4928,"color":"f39c64","end":4931},{"italic":false,"bold":true,"begin":4937,"color":"455fac","end":4943},{"italic":false,"bold":false,"begin":4971,"color":"c28ebd","end":4980},{"italic":false,"bold":false,"begin":5012,"color":"e6e65c","end":5017},{"italic":false,"bold":false,"begin":5019,"color":"c28ebd","end":5025},{"italic":false,"bold":true,"begin":5046,"color":"f39c64","end":5049},{"italic":false,"bold":true,"begin":5060,"color":"455fac","end":5066},{"italic":false,"bold":false,"begin":5125,"color":"c28ebd","end":5135},{"italic":false,"bold":true,"begin":5150,"color":"d54c02","end":5153},{"italic":false,"bold":false,"begin":5205,"color":"c28ebd","end":5210},{"italic":false,"bold":true,"begin":5222,"color":"d54c02","end":5229},{"italic":false,"bold":true,"begin":5230,"color":"f39c64","end":5238},{"italic":false,"bold":true,"begin":5265,"color":"455fac","end":5269},{"italic":false,"bold":true,"begin":5278,"color":"d54c02","end":5280},{"italic":false,"bold":true,"begin":5309,"color":"f39c64","end":5312},{"italic":false,"bold":true,"begin":5315,"color":"455fac","end":5318},{"italic":false,"bold":true,"begin":5337,"color":"f39c64","end":5340},{"italic":false,"bold":true,"begin":5349,"color":"455fac","end":5355},{"italic":false,"bold":true,"begin":5366,"color":"d54c02","end":5371},{"italic":false,"bold":true,"begin":5403,"color":"d54c02","end":5405},{"italic":false,"bold":true,"begin":5433,"color":"d54c02","end":5438},{"italic":false,"bold":true,"begin":5488,"color":"d54c02","end":5490},{"italic":false,"bold":true,"begin":5612,"color":"d54c02","end":5616},{"italic":false,"bold":true,"begin":5644,"color":"d54c02","end":5648},{"italic":false,"bold":true,"begin":5655,"color":"d54c02","end":5657},{"italic":false,"bold":true,"begin":5829,"color":"d54c02","end":5833},{"italic":false,"bold":true,"begin":5856,"color":"d54c02","end":5863},{"italic":false,"bold":true,"begin":5864,"color":"f39c64","end":5872},{"italic":false,"bold":true,"begin":5891,"color":"455fac","end":5895},{"italic":false,"bold":true,"begin":5904,"color":"f39c64","end":5907},{"italic":false,"bold":true,"begin":5910,"color":"455fac","end":5913},{"italic":false,"bold":true,"begin":5937,"color":"f39c64","end":5940},{"italic":false,"bold":true,"begin":5943,"color":"455fac","end":5946},{"italic":false,"bold":true,"begin":5971,"color":"f39c64","end":5974},{"italic":false,"bold":true,"begin":5980,"color":"455fac","end":5985},{"italic":true,"bold":false,"begin":5990,"color":"8c8c8c","end":6026},{"italic":true,"bold":false,"begin":6031,"color":"8c8c8c","end":6099},{"italic":true,"bold":false,"begin":6104,"color":"8c8c8c","end":6117},{"italic":true,"bold":false,"begin":6123,"color":"8c8c8c","end":6137},{"italic":true,"bold":false,"begin":6143,"color":"8c8c8c","end":6157},{"italic":true,"bold":false,"begin":6162,"color":"8c8c8c","end":6165},{"italic":true,"bold":false,"begin":6169,"color":"8c8c8c","end":6172},{"italic":false,"bold":true,"begin":6238,"color":"d54c02","end":6246},{"italic":false,"bold":true,"begin":6247,"color":"d54c02","end":6256},{"italic":false,"bold":true,"begin":6257,"color":"f39c64","end":6265},{"italic":false,"bold":true,"begin":6279,"color":"455fac","end":6283},{"italic":false,"bold":true,"begin":6435,"color":"d54c02","end":6437},{"italic":false,"bold":true,"begin":6623,"color":"d54c02","end":6627},{"italic":false,"bold":true,"begin":6692,"color":"d54c02","end":6699},{"italic":false,"bold":true,"begin":6700,"color":"f39c64","end":6708},{"italic":false,"bold":true,"begin":6738,"color":"455fac","end":6742},{"italic":false,"bold":true,"begin":6751,"color":"d54c02","end":6753},{"italic":false,"bold":true,"begin":6794,"color":"f39c64","end":6797},{"italic":false,"bold":true,"begin":6805,"color":"455fac","end":6813},{"italic":false,"bold":true,"begin":6818,"color":"d54c02","end":6824},{"italic":false,"bold":true,"begin":6847,"color":"d54c02","end":6851},{"italic":false,"bold":true,"begin":6909,"color":"d54c02","end":6914},{"italic":false,"bold":true,"begin":6919,"color":"d54c02","end":6923},{"italic":false,"bold":true,"begin":6983,"color":"d54c02","end":6988},{"italic":false,"bold":true,"begin":6993,"color":"d54c02","end":6997},{"italic":false,"bold":true,"begin":7064,"color":"d54c02","end":7069},{"italic":false,"bold":true,"begin":7074,"color":"d54c02","end":7078},{"italic":false,"bold":true,"begin":7136,"color":"d54c02","end":7141},{"italic":false,"bold":true,"begin":7146,"color":"d54c02","end":7150},{"italic":false,"bold":true,"begin":7197,"color":"d54c02","end":7202},{"italic":false,"bold":true,"begin":7207,"color":"d54c02","end":7211},{"italic":false,"bold":true,"begin":7261,"color":"d54c02","end":7266},{"italic":false,"bold":true,"begin":7271,"color":"d54c02","end":7275},{"italic":false,"bold":true,"begin":7325,"color":"d54c02","end":7330},{"italic":false,"bold":true,"begin":7344,"color":"d54c02","end":7346},{"italic":false,"bold":true,"begin":7358,"color":"d54c02","end":7362},{"italic":false,"bold":true,"begin":7370,"color":"f39c64","end":7373},{"italic":false,"bold":true,"begin":7379,"color":"455fac","end":7384},{"italic":false,"bold":true,"begin":7501,"color":"d54c02","end":7508},{"italic":false,"bold":true,"begin":7509,"color":"f39c64","end":7517},{"italic":false,"bold":true,"begin":7537,"color":"455fac","end":7540},{"italic":false,"bold":true,"begin":7542,"color":"455fac","end":7546},{"italic":false,"bold":true,"begin":7554,"color":"d54c02","end":7556},{"italic":false,"bold":true,"begin":7614,"color":"d54c02","end":7621},{"italic":false,"bold":true,"begin":7622,"color":"f39c64","end":7630},{"italic":false,"bold":true,"begin":7650,"color":"455fac","end":7653},{"italic":false,"bold":true,"begin":7655,"color":"455fac","end":7659},{"italic":false,"bold":true,"begin":7667,"color":"d54c02","end":7669},{"italic":false,"bold":true,"begin":7727,"color":"d54c02","end":7734},{"italic":false,"bold":true,"begin":7735,"color":"f39c64","end":7743},{"italic":false,"bold":true,"begin":7755,"color":"455fac","end":7759},{"italic":false,"bold":false,"begin":7773,"color":"c28ebd","end":7784},{"italic":false,"bold":true,"begin":7836,"color":"d54c02","end":7838},{"italic":false,"bold":true,"begin":7915,"color":"d54c02","end":7920},{"italic":false,"bold":true,"begin":7948,"color":"d54c02","end":7955},{"italic":false,"bold":true,"begin":7956,"color":"f39c64","end":7964},{"italic":false,"bold":true,"begin":7975,"color":"455fac","end":7979},{"italic":false,"bold":false,"begin":7991,"color":"c28ebd","end":8000},{"italic":false,"bold":true,"begin":8066,"color":"d54c02","end":8070},{"italic":false,"bold":true,"begin":8098,"color":"d54c02","end":8105},{"italic":false,"bold":true,"begin":8106,"color":"f39c64","end":8114},{"italic":false,"bold":true,"begin":8131,"color":"455fac","end":8135},{"italic":true,"bold":false,"begin":8143,"color":"8c8c8c","end":8177},{"italic":true,"bold":false,"begin":8182,"color":"8c8c8c","end":8239},{"italic":false,"bold":true,"begin":8249,"color":"d54c02","end":8256},{"italic":false,"bold":true,"begin":8257,"color":"f39c64","end":8265},{"italic":false,"bold":true,"begin":8300,"color":"455fac","end":8304},{"italic":false,"bold":true,"begin":8323,"color":"d54c02","end":8327},{"italic":false,"bold":true,"begin":8358,"color":"d54c02","end":8361},{"italic":false,"bold":true,"begin":8571,"color":"f39c64","end":8579},{"italic":false,"bold":true,"begin":8583,"color":"455fac","end":8587},{"italic":false,"bold":true,"begin":8625,"color":"d54c02","end":8629},{"italic":false,"bold":true,"begin":8653,"color":"d54c02","end":8660},{"italic":false,"bold":true,"begin":8661,"color":"f39c64","end":8669},{"italic":false,"bold":true,"begin":8687,"color":"455fac","end":8691},{"italic":false,"bold":true,"begin":8700,"color":"d54c02","end":8702},{"italic":false,"bold":true,"begin":8731,"color":"f39c64","end":8734},{"italic":false,"bold":true,"begin":8737,"color":"455fac","end":8740},{"italic":false,"bold":true,"begin":8759,"color":"f39c64","end":8762},{"italic":false,"bold":true,"begin":8771,"color":"455fac","end":8777},{"italic":false,"bold":true,"begin":8788,"color":"d54c02","end":8793},{"italic":false,"bold":true,"begin":8825,"color":"d54c02","end":8827},{"italic":false,"bold":true,"begin":8855,"color":"d54c02","end":8860},{"italic":false,"bold":true,"begin":8931,"color":"d54c02","end":8935},{"italic":false,"bold":true,"begin":8972,"color":"d54c02","end":8979},{"italic":false,"bold":true,"begin":8980,"color":"f39c64","end":8988},{"italic":false,"bold":true,"begin":9007,"color":"455fac","end":9011},{"italic":false,"bold":true,"begin":9020,"color":"f39c64","end":9023},{"italic":false,"bold":true,"begin":9038,"color":"455fac","end":9045},{"italic":false,"bold":false,"begin":9077,"color":"c28ebd","end":9079},{"italic":false,"bold":true,"begin":9089,"color":"d54c02","end":9091},{"italic":false,"bold":true,"begin":9148,"color":"d54c02","end":9155},{"italic":false,"bold":true,"begin":9156,"color":"f39c64","end":9164},{"italic":false,"bold":true,"begin":9182,"color":"455fac","end":9185},{"italic":false,"bold":true,"begin":9192,"color":"455fac","end":9195},{"italic":false,"bold":true,"begin":9210,"color":"455fac","end":9216},{"italic":false,"bold":true,"begin":9222,"color":"f39c64","end":9225},{"italic":false,"bold":true,"begin":9230,"color":"455fac","end":9236},{"italic":false,"bold":true,"begin":9279,"color":"d54c02","end":9285},{"italic":false,"bold":false,"begin":9300,"color":"c28ebd","end":9302},{"italic":false,"bold":true,"begin":9316,"color":"d54c02","end":9323},{"italic":false,"bold":true,"begin":9324,"color":"f39c64","end":9332},{"italic":false,"bold":true,"begin":9359,"color":"455fac","end":9362},{"italic":false,"bold":true,"begin":9374,"color":"455fac","end":9377},{"italic":false,"bold":true,"begin":9388,"color":"455fac","end":9394},{"italic":false,"bold":true,"begin":9396,"color":"455fac","end":9400},{"italic":true,"bold":false,"begin":9409,"color":"8c8c8c","end":9496},{"italic":false,"bold":true,"begin":9688,"color":"d54c02","end":9695},{"italic":false,"bold":true,"begin":9696,"color":"f39c64","end":9704},{"italic":false,"bold":true,"begin":9741,"color":"455fac","end":9744},{"italic":false,"bold":true,"begin":9765,"color":"455fac","end":9768},{"italic":false,"bold":true,"begin":9770,"color":"455fac","end":9774},{"italic":true,"bold":false,"begin":9782,"color":"8c8c8c","end":9871},{"italic":false,"bold":true,"begin":9894,"color":"d54c02","end":9899},{"italic":true,"bold":false,"begin":9904,"color":"8c8c8c","end":9982},{"italic":false,"bold":true,"begin":10120,"color":"d54c02","end":10127},{"italic":false,"bold":true,"begin":10128,"color":"f39c64","end":10136},{"italic":false,"bold":true,"begin":10161,"color":"455fac","end":10167},{"italic":false,"bold":true,"begin":10169,"color":"455fac","end":10173},{"italic":true,"bold":false,"begin":10182,"color":"8c8c8c","end":10240}];

class Format {
	public var color:int;
	public var bold:Boolean;
	public var italic:Boolean;
	public var url:String;
	public var begin:int;
	public var end:int;
}


var code_str:String = <><![CDATA[package  
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	//import flash.external.ExternalInterface;
	import flash.geom.Transform;
	import flash.net.FileReference;
	import flash.system.Capabilities;
	import flash.system.Security;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import jp.psyark.utils.callLater;
	import jp.psyark.psycode.controls.UIControl;
	import jp.psyark.utils.CodeUtil;
	import jp.psyark.utils.StringComparator;
	import net.wonderfl.editor.ASParserController;
	import net.wonderfl.editor.livecoding.LiveCoding;
	import net.wonderfl.editor.livecoding.LiveCodingEvent;
	import net.wonderfl.editor.livecoding.LiveCodingSettings;
	import net.wonderfl.editor.livecoding.SocketBroadCaster;
	import net.wonderfl.editor.livecoding.TextArea;
	import net.wonderfl.editor.livecoding.ViewerInfoPanel;
	import org.libspark.ui.SWFWheel;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class TestViewer extends UIControl
	{
		private static const TICK:int = 80;
		public var fileRef:FileReference;
		
		[Embed(source = '../assets/btn_smallscreen.jpg')]
		private var _image_out_:Class;
		
		[Embed(source = '../assets/btn_smallscreen_o.jpg')]
		private var _image_over_:Class;
		
		private var _viewer:TextArea;
		private var _ctrl:ASParserController;
		private var _scaleDownButton:Sprite;
		private var broadcaster:SocketBroadCaster = new SocketBroadCaster;
		private var _source:String ='';
		private var _commandList:Array = [];
		private var _executer:Sprite = new Sprite;
		private var _parseTime:int;
		private var _setInitialCodeForLiveCoding:Boolean = false;
		private var _isLive:Boolean = false;
		private var _infoPanel:ViewerInfoPanel;
		private var _ignoreSelection:Boolean;
		private var _prevText:String;
		private var _comparetor:StringComparator;
		private var _selectionObject:Object;
		
		public function TestViewer() 
		{
			trace("TestViewer.TestViewer");
			_parseTime = getTimer();
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, onResize);
			SWFWheel.initialize(stage);
			
			_scaleDownButton = new Sprite;
			_scaleDownButton.addChild(new _image_out_);
			var bm:Bitmap = new _image_over_;
			bm.visible = false;
			focusRect = null;
			
			_scaleDownButton.addChild(bm);
			_scaleDownButton.buttonMode = true;
			_scaleDownButton.tabEnabled = false;
			_scaleDownButton.visible = false;
			_scaleDownButton.addEventListener(MouseEvent.CLICK, function ():void {
				//if (ExternalInterface.available) ExternalInterface.call("Wonderfl.Codepage.scale_down");
			});
			_scaleDownButton.addEventListener(MouseEvent.MOUSE_OVER, function ():void {
				bm.visible = true;
			});
			_scaleDownButton.addEventListener(MouseEvent.MOUSE_OUT, function ():void {
				bm.visible = false;
			});
			
			_viewer = new TextArea;
			_viewer.addEventListener(Event.COMPLETE, onColoringComplete);
			addChild(_viewer);
			addChild(_scaleDownButton);
			
			_ctrl = new ASParserController(stage, _viewer);
			
			_viewer.addEventListener(Event.CHANGE, onChange);

			if (loaderInfo.parameters)
				LiveCodingSettings.setUpParameters(loaderInfo.parameters);
			
			broadcaster.addEventListener(Event.CONNECT, function ():void {
				broadcaster.join(LiveCodingSettings.room, LiveCodingSettings.ticket);
			});
			broadcaster.addEventListener(LiveCodingEvent.JOINED, startListening);
			broadcaster.addEventListener(LiveCodingEvent.RELAYED, onRelayed);
			
			if (LiveCodingSettings.server && LiveCodingSettings.port) {
				broadcaster.connect(LiveCodingSettings.server, LiveCodingSettings.port);
				_setInitialCodeForLiveCoding = true;
				_comparetor = new StringComparator;
			}
			
			//if (ExternalInterface.available) {
				//var code:String = ExternalInterface.call("Wonderfl.Codepage.get_initial_code");
				//_source = code;
				//_viewer.text = (code) ? code : "";
				//trace('init', code);
				//if (!_setInitialCodeForLiveCoding) {
					//onChange(null);
				//}
			//}
			
			if (_setInitialCodeForLiveCoding) {
				addEventListener(Event.ENTER_FRAME, setupInitialCode);
				_setInitialCodeForLiveCoding = false;
			}
			
			_viewer.text = _source = <>{code_str}</>;
			onChange(null);
			
			stage.dispatchEvent(new Event(Event.RESIZE));
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		}
		
		private function onColoringComplete(e:Event):void 
		{
			if (_selectionObject)
				onSetSelection(_selectionObject.index, _selectionObject.index);
				
			_selectionObject = null;
		}
		
		private function keyDownHandler(e:KeyboardEvent):void 
		{
			if (e.ctrlKey) {
				if (e.keyCode == 83) { // Ctrl + S
					save();
				}
			}
		}
		
		public function save():void {
			var text:String = (Capabilities.os.indexOf('Windows') != -1) ? _viewer.text.replace(/\r/g, '\r\n') : _viewer.text;
			var localName:String = CodeUtil.getDefinitionLocalName(text);
			localName ||= "untitled";
			fileRef = new FileReference();
			fileRef.save(text, localName + ".as");
		}
		
		private function setupInitialCode(e:Event):void 
		{
			if (_commandList.length) {
				var t:int = getTimer();
				var command:Object;
				
				while (getTimer() - t < TICK) {
					if (_commandList.length == 0) break;
					
					command = _commandList.shift();
					if (command.method == LiveCoding.SEND_CURRENT_TEXT || command.method == LiveCoding.REPLACE_TEXT)
						command.method.apply(null, command.args);
				}
			} else {
				if (_setInitialCodeForLiveCoding) {
					removeEventListener(Event.ENTER_FRAME, setupInitialCode);
					_executer.addEventListener(Event.ENTER_FRAME, execute);
					onChange(null);
				}
			}
		}
		
		private function onResize(e:Event):void 
		{
			var w:int = stage.stageWidth;
			var h:int = stage.stageHeight;
			var size:Array;
			//if (ExternalInterface.available) {
				//size = ExternalInterface.call("Wonderfl.Codepage.get_stage_size");
				//if (size) {
					//w = size[0];
					//h = size[1];
				//}
			//}
			
			width = (w > 465) ? w - 465 : w;;
			height = h;
		}
		
		override protected function updateSize():void 
		{
			_viewer.width = width;
			_scaleDownButton.x = width - _scaleDownButton.width;
			_scaleDownButton.visible = (width > 464 || height > 466);
			if (_isLive) {
				_infoPanel.width = _scaleDownButton.visible ? _scaleDownButton.x  : width - 15;
				_viewer.y = _infoPanel.height;
				_viewer.height = height - _infoPanel.height;
			} else {
				_viewer.y = 0;
				_viewer.height = height;
			}
		}
		
		private function onRelayed(e:LiveCodingEvent):void 
		{
			if (!_isLive) {
				restart();
			}
			
			var method:Function;
			switch (e.data.command) {
			case LiveCoding.REPLACE_TEXT:
				method = onReplaceText;
				break;
			case LiveCoding.SET_SELECTION:
				method = onSetSelection;
				break;
			case LiveCoding.SEND_CURRENT_TEXT:
				method = onSendCurrentText;
				break;
			case LiveCoding.SWF_RELOADED:
				method = onSWFReloaded;
				break;
			case LiveCoding.CLOSED:
				method = onClosed;
				break;
			case LiveCoding.SCROLL_V:
				method = onScrollV;
				break;
			case LiveCoding.SCROLL_H:
				method = onScrollH;
				break;
			}
			
			if (method != null) {
				var args:Array = e.data.args;
				_commandList[_commandList.length] = {
					method : method,
					args : args
				}
			}
		}
		
		private function onScrollH($scrollH:int):void
		{
			if (_infoPanel.isSync) _viewer.scrollH = $scrollH;
		}
		
		private function onScrollV($scrollV:int):void
		{
			if (_infoPanel.isSync) _viewer.scrollV = $scrollV;
		}
		
		private function onClosed():void
		{
			trace('on closed');
			_viewer.hideCaret();
			_infoPanel.stop();
			if (_infoPanel.parent) _infoPanel.parent.removeChild(_infoPanel);
			_isLive = false;
			updateSize();
		}
		
		private function restart():void {
			trace('restart');
			addChild(_infoPanel);
			_infoPanel.restart();
			_isLive = true;
			updateSize();
		}
		
		private function onSWFReloaded():void
		{
			//if (ExternalInterface.available)
				//ExternalInterface.call('Wonderfl.Codepage.reload_swf');
		}
		
		private function startListening(e:LiveCodingEvent):void 
		{
			_isLive = true;
			
			addChild(_infoPanel = new ViewerInfoPanel);
			_infoPanel.elapsed_time = e.data ? e.data.elapsed_time : 0;
			broadcaster.addEventListener(LiveCodingEvent.MEMBERS_UPDATED, _infoPanel.onMemberUpdate);
			updateSize();
			
			setTimeout(function ():void {
				_setInitialCodeForLiveCoding = true;
			}, 1000);
		}
		
		private function execute(e:Event):void 
		{
			if (_commandList.length) {
				var t:int = getTimer();
				var command:Object;
				
				while (getTimer() - t < TICK) {
					if (_commandList.length == 0) break;
					
					command = _commandList.shift();
					command.method.apply(null, command.args);
				}
			}
		}
		
		private function onChange(e:Event):void 
		{
			var parserRunning:Boolean = _ctrl.sourceChanged(_source, '');
			
			if (!parserRunning)
				_viewer.setText(_source);
		}
		
		private function substring($begin:int, $end:int = 0x7fffffff):String {
			var str:String = _source.substring($begin, $end);
			
			return (str) ? str : '';
		}
		
		
		private function onReplaceText($beginIndex:int, $endIndex:int, $newText:String):void 
		{
			//JSLog.logToConsole('viewer: onReplaceText', $beginIndex, $endIndex, $newText.length);
			_source = _source.substring(0, $beginIndex) + $newText + substring($endIndex);
			_viewer.text = _source;
			_selectionObject = {
				index : $endIndex + $newText.length
			}				
		}
		
		private function onSetSelection($selectionBeginIndex:int, $selectionEndIndex:int):void
		{
			//JSLog.logToConsole('viewer: onSetSelection', $selectionBeginIndex, $selectionEndIndex);
			_ignoreSelection = false;
			//callLater(_viewer.setSelection, [$selectionBeginIndex, $selectionEndIndex]);
			_viewer.setSelection($selectionBeginIndex, $selectionEndIndex);
			_selectionObject = {
				index : $selectionEndIndex
			};
		}
		
		private function onSendCurrentText($text:String):void 
		{
			//JSLog.logToConsole('viewer: onSendCurrentText ', $text);
			_viewer.text = _source = $text;
		}		
	}
}
]]></>;