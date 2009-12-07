package common.data
{
	import Application.utils.GameUtil;
	
	import common.assets.ModuleLib;
	
	import flash.display.InteractiveObject;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuBuiltInItems;
	import flash.ui.ContextMenuItem;
	
	public class ContextConfig
	{
		private static var _instance:ContextConfig;
		private var myContextMenu:ContextMenu;
		private var itemArr:Array = new Array();
		public function ContextConfig()
		{
			if(_instance!=null)
			{
				throw new Error("右击菜单");	
			}
		}
		public static function getInstance():ContextConfig
		{
			if(_instance==null)
			{
				_instance = new ContextConfig();	
			}	
			return _instance;
		}
		public function showContext():void{
			myContextMenu = new ContextMenu();
			myContextMenu.hideBuiltInItems();
			var defaultItems:ContextMenuBuiltInItems = myContextMenu.builtInItems;
            defaultItems.print = false;
			defaultItems.rewind = false;
			initItem();
            myContextMenu.customItems = itemArr
            ModuleLib.getInstance().gameStage.contextMenu = myContextMenu;       

		}
		private function initItem():void
		{
			var item:ContextMenuItem = new ContextMenuItem(null,false,false);
			item.caption = GameUtil.replaceText(StringDef.VERSION,{num:HallConfig.getInstance().version});		
			itemArr.push(item);
		}
		public function setRightClick(value:InteractiveObject):void{
			value.contextMenu = myContextMenu;
		}
	}
}