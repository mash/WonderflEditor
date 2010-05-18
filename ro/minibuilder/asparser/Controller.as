/* license section

Flash MiniBuilder is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Flash MiniBuilder is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Flash MiniBuilder.  If not, see <http://www.gnu.org/licenses/>.


Author: Victor Dramba
2009
*/

/*
 * @Author Dramba Victor
 * 2009
 * 
 * You may use this code any way you like, but please keep this notice in
 * The code is provided "as is" without warranty of any kind.
 */

package ro.minibuilder.asparser
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.FileReference;
	import flash.net.SharedObject;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import ro.minibuilder.main.editor.ScriptAreaComponent;
	import ro.minibuilder.swcparser.SWFParser;
	import ro.victordramba.thread.ThreadEvent;
	import ro.victordramba.thread.ThreadsController;

	[Event(type="flash.events.Event", name="change")]
	



	public class Controller extends EventDispatcher
	{
		/*[Embed(source="/assets/globals.amf", mimeType="application/octet-stream")]
		private static var GlobalTypesAsset:Class;
		
		[Embed(source="/assets/playerglobals.amf", mimeType="application/octet-stream")]
		private static var PlayerglobalAsset:Class;*/
		
		//[Embed(source="aswing.amf", mimeType="application/octet-stream")]
		//private static var ASwingAsset:Class;
		
		
		private var parser:Parser;
		private var t0:Number;		
		static private var tc:ThreadsController;
		
		public var status:String;
		public var percentReady:Number = 0;
		//public var tokenInfo:String;
		//public var scopeInfo:Array/*of String*/
		//public var typeInfo:Array/*of String*/
		
		private var fld:ScriptAreaComponent;
		
		function Controller(stage:Stage, textField:ScriptAreaComponent)
		{
			fld = textField;
			//TODO refactor, Controller should probably be a singleton
			if (!tc)
			{
				tc = new ThreadsController(stage);
				//TypeDB.setDB('global', TypeDB.formByteArray(new GlobalTypesAsset));
				//TypeDB.setDB('playerglobal', TypeDB.formByteArray(new PlayerglobalAsset));
			}
			parser = new Parser;
			
			//parser.addTypeData(TypeDB.formByteArray(new GlobalTypesAsset), 'global');
			//parser.addTypeData(TypeDB.formByteArray(new PlayerglobalAsset), 'player');
			//parser.addTypeData(TypeDB.formByteArray(new ASwingAsset), 'aswing');
			
			
			
			tc.addEventListener(ThreadEvent.THREAD_READY, function(e:ThreadEvent):void
			{
				if (e.thread != parser) return;
				parser.applyFormats(fld);
				//cursorMoved(textField.caretIndex);
				status = 'Parse time: '+ (getTimer()-t0) + 'ms '+parser.tokenCount+' tokens';
				dispatchEvent(new Event('status'));
			});
			
			tc.addEventListener(ThreadEvent.PROGRESS, function(e:ThreadEvent):void
			{
				if (e.thread != parser) return;
				status = '';
				percentReady = parser.percentReady;
				dispatchEvent(new Event('status'));
			});
		}		

		public function saveTypeDB():void
		{
			/*var so:SharedObject = SharedObject.getLocal('ascc-type');
			so.data.typeDB = parser.getTypeData();
			so.flush();*/
			
			var file:FileReference = new FileReference;
			var ret:ByteArray = parser.getTypeData();
			file.save(ret, 'globals.amf');
			
		}
		
		public function restoreTypeDB():void
		{
			throw new Error('restoreTypeDB not supported');
			var so:SharedObject = SharedObject.getLocal('ascc-type');
			TypeDB.setDB('restored', so.data.typeDB);
		}
		
		/*public function addTypeDB(typeDB:TypeDB, name:String):void
		{
			parser.addTypeData(typeDB, name);
		}*/
		
		public function loadSWFLib(swfData:ByteArray, fileName:String):void
		{
			TypeDB.setDB(fileName, SWFParser.parse(swfData));
		}
		
		public function sourceChanged(source:String, fileName:String):void
		{
			t0 = getTimer();
			parser.load(source, fileName);
			if (tc.isRunning(parser))
				tc.kill(parser);
			tc.run(parser);
			status = 'Processing ...';
		}
		
		public function getMemberList(index:int):Vector.<String>
		{
			return parser.newResolver().getMemberList(fld.text, index);
		}
		
		public function getFunctionDetails(index:int):String
		{
			return parser.newResolver().getFunctionDetails(fld.text, index);
		}
		
		public function getTypeOptions():Vector.<String>
		{
			return parser.newResolver().getAllTypes();
		}
		
		public function getAllOptions(index:int):Vector.<String>
		{
			return parser.newResolver().getAllOptions(index);
		}
		
		public function getMissingImports(name:String, pos:int):Vector.<String>
		{
			return parser.newResolver().getMissingImports(name, pos);
		}
		
		public function isInScope(name:String, pos:int):Boolean
		{
			return parser.newResolver().isInScope(name, pos);
		}
	}
}