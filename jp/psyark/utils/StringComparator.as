package jp.psyark.utils 
{
public class StringComparator {
	/**
	 * @private
	 */
	internal static function test():void {
		var sc:StringComparator = new StringComparator();
		var test:Function = function (a:String, b:String, l:int, r:int):void {
			sc.compare(a, b);
			if (sc.commonPrefixLength != l || sc.commonSuffixLength != r) {
				throw new Error();
			}
		};
		test("Hello World", "Hello World", 11, 0);
		test("Hello World", "Hello! World", 5, 6);
		test("Hello World", "HelPIYOrld", 3, 3);
		test("a", "aB", 1, 0);
		test("aBC", "aBCD", 3, 0);
		test("Ba", "a", 0, 1);
		test("aBC", "DaBC", 0, 3);
		test("aXbXc", "aXc", 2, 1);
		test("aaaXccc", "aaaXbbbXccc", 4, 3);
	}
	
	/**
	 * 左側の共通文字列長
	 */
	public var commonPrefixLength:int;
	
	/**
	 * 右側の共通文字列長
	 */
	public var commonSuffixLength:int;
	
	/**
	 * 2つの文字列を比較し、commonPrefixLengthとcommonSuffixLengthをセットする
	 * 
	 * @param str1 比較する文字列の一方
	 * @param str2 比較する文字列の他方
	 */
	public function compare(str1:String, str2:String):void {
		var minLength:int = Math.min(str1.length, str2.length);
		var step:int, l:int, r:int;
		
		step = Math.pow(2, Math.floor(Math.log(minLength) / Math.log(2)));
		for (l=0; l<minLength; ) {
			if (str1.substr(0, l + step) != str2.substr(0, l + step)) {
				if (step == 1) { break; }
				step >>= 1;
			} else {
				l += step;
			}
		}
		l = Math.min(l, minLength);
		
		minLength -= l;
		
		step = Math.pow(2, Math.floor(Math.log(minLength) / Math.log(2)));
		for (r=0; r<minLength; ) {
			if (str1.substr(-r - step) != str2.substr(-r - step)) {
				if (step == 1) { break; }
				step >>= 1;
			} else {
				r += step;
			}
		}
		r = Math.min(r, minLength);
		
		commonPrefixLength = l;
		commonSuffixLength = r;
	}
}

}