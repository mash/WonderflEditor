package jp.psyark.psycode.controls 
{
import flash.display.DisplayObject;
import flash.display.GradientType;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Matrix;

public class List extends UIControl {
	private var _itemRenderer:Class = ListItemRenderer;
	private var _rowHeight:Number = 20;
	private var _dataProvider:Array;
	private var _selectedIndex:int = -1;
	private var _labelField:String = "label";
	
	private var selectionRect:Shape;
	private var rendererLayer:Sprite;
	private var scrollBar:ScrollBar;
	
	private var renderers:Array;
	private var scrollPosition:int = 0;
	
	
	/**
	 * Listクラスのインスタンスを作成します。
	 */
	public function List() {
		renderers = [];
		
		selectionRect = new Shape();
		rendererLayer = new Sprite();
		scrollBar = new ScrollBar();
		scrollBar.addEventListener(Event.CHANGE, scrollBarChangeHandler);
		
		tabChildren = false;
		tabEnabled = false;

		focusRect = null;
		
		addChild(selectionRect);
		addChild(rendererLayer);
		addChild(scrollBar);
		
		updateSize();
	}
	
	/**
	 * リストのアイテムレンダラークラスを取得または設定します。
	 */
	public function get itemRenderer():Class {
		return _itemRenderer;
	}
	
	/**
	 * @private
	 */
	public function set itemRenderer(value:Class):void {
		if (_itemRenderer != value) {
			_itemRenderer = value;
			updateRenderers();
		}
	}
	
	/**
	 * リストの各行の高さを取得または設定します。
	 */
	public function get rowHeight():Number {
		return _rowHeight;
	}
	
	/**
	 * @private
	 */
	public function set rowHeight(value:Number):void {
		if (_rowHeight != value) {
			_rowHeight = value;
			updateRenderers();
		}
	}
	
	/**
	 * データプロバイダを取得または設定します。
	 */
	public function get dataProvider():Array {
		return _dataProvider;
	}
	
	/**
	 * @private
	 */
	public function set dataProvider(value:Array):void {
		if (_dataProvider != value) {
			_dataProvider = value;
			updateData();
		}
	}
	
	/**
	 * 選択されているアイテムのインデックスを取得または設定します。
	 */
	public function get selectedIndex():int {
		return _selectedIndex;
	}
	
	/**
	 * @private
	 */
	public function set selectedIndex(value:int):void {
		if (_selectedIndex != value) {
			_selectedIndex = value;
			
			if (dataProvider) {
				if (value >= 0 && value < dataProvider.length) {
					if (scrollPosition > value) {
						scrollPosition = value;
						scrollBar.value = scrollPosition;
						updateData();
					} else if (scrollPosition < value - renderers.length + 1) {
						scrollPosition = value - renderers.length + 1;
						scrollBar.value = scrollPosition;
						updateData();
					}
				}
			}
			updateData();
		}
	}
	
	/**
	 * ラベルとして使うプロパティ名を取得または設定します。
	 */
	public function get labelField():String {
		return _labelField;
	}
	
	/**
	 * @private
	 */
	public function set labelField(value:String):void {
		if (_labelField != value) {
			_labelField = value;
			updateData();
		}
	}
	
	/**
	 * 
	 */
	public function get selectedItem():Object {
		return _dataProvider ? _dataProvider[selectedIndex] : null
	}
	public function set selectedItem(value:Object):void {
		selectedIndex = _dataProvider ? _dataProvider.indexOf(value) : -1;
	}
	
	
	/**
	 * アイテムレンダラーに与えるデータを更新します。
	 */
	protected function updateData():void {
		scrollBar.maxValue = dataProvider ? Math.max(0, dataProvider.length - renderers.length) : 0;
		
		for (var i:int=0; i<renderers.length; i++) {
			var renderer:ListItemRenderer = renderers[(i + scrollPosition) % renderers.length];
			renderer.labelField = labelField;
			if (_dataProvider) {
				renderer.data = _dataProvider[i + scrollPosition];
			} else {
				renderer.data = null;
			}
			renderer.height = rowHeight;
			renderer.y = i * rowHeight;
		}
		
		if (_dataProvider && selectedIndex >= scrollPosition && selectedIndex < (scrollPosition + renderers.length)) {
			selectionRect.visible = true;
			selectionRect.y = (selectedIndex - scrollPosition) * rowHeight;
		} else {
			selectionRect.visible = false;
		}
	}
	
	/**
	 * アイテムレンダラーを作成します。
	 */
	protected function updateRenderers():void {
		var itemCount:int = Math.floor(height / rowHeight);
		
		while (renderers.length > itemCount) {
			rendererLayer.removeChild(renderers.pop() as DisplayObject);
		}
		while (renderers.length < itemCount) {
			var renderer:ListItemRenderer = new itemRenderer();
			renderer.addEventListener(MouseEvent.CLICK, rendererClickHandler, false, 0, true);
			renderers.push(renderer);
			rendererLayer.addChild(renderer);
		}
		
		var mtx:Matrix = new Matrix();
		mtx.createGradientBox(10, rowHeight, Math.PI / 2);
		
		selectionRect.graphics.clear();
		selectionRect.graphics.beginFill(0x222222);
		selectionRect.graphics.drawRoundRect(0, 0, width - scrollBar.width, rowHeight, 8);
		selectionRect.graphics.beginFill(0x333333);
		selectionRect.graphics.drawRoundRect(1, 1, width - scrollBar.width - 2, rowHeight - 2, 6);
		selectionRect.graphics.beginFill(0x694543);
		//selectionRect.graphics.beginGradientFill(GradientType.LINEAR, [0x333333, 0x444444, 0x222222], [1, 1, 1], [0x00, 0x40, 0xFF], mtx);
		selectionRect.graphics.drawRoundRect(2, 2, width - scrollBar.width - 4, rowHeight - 4, 4);
		
		scrollBar.viewSize = renderers.length;
		updateData();
	}
	
	private function rendererClickHandler(event:Event):void {
		var renderer:ListItemRenderer = ListItemRenderer(event.currentTarget);
		if (renderer.data) {
			selectedItem = renderer.data;
			dispatchEvent(new Event(Event.CHANGE));
		}
	}
	
	protected override function updateSize():void {
		updateRenderers();
		for each (var renderer:ListItemRenderer in renderers) {
			renderer.width = width - scrollBar.width;
		}
		scrollBar.x = width - scrollBar.width;
		scrollBar.height = height;
		
		graphics.clear();
		graphics.beginFill(0x222222);
		graphics.drawRect(0, 0, width, height);
	}
	
	private function scrollBarChangeHandler(event:Event):void {
		scrollPosition = Math.round(scrollBar.value);
		updateData();
	}
}
}