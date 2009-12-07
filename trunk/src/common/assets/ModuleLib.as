package common.assets
{
	import Application.model.SingleGameProxy;
	import Application.model.load.LoaderProxy;
	import Application.view.mediator.GameMediator;
	
	import common.data.GlobalDef;
	
	import de.polygonal.ds.HashMap;
	import de.polygonal.ds.Iterator;
	
	import flash.display.LoaderInfo;
	
	import org.puremvc.as3.multicore.patterns.facade.Facade;
	
	public class ModuleLib
	{   
		private static var instance:ModuleLib;
		private var libIterator:Iterator;
		public function ModuleLib()
		{
			if(instance!=null){
				 throw new Error("单例实例化出错--ModuleLib");
			}
		}
		//得到loaderProxy中的moduleLib元素库
		public function get lib():HashMap{
			 return (Facade.getInstance(GlobalDef.GAME_FACADE).retrieveProxy("LoaderProxy") as LoaderProxy).Lib;
		}
		//获取舞台主场景
        public function get gameStage():game{
        	return (Facade.getInstance(GlobalDef.GAME_FACADE).retrieveMediator("GameMediator") as GameMediator).getGameComponent;
        }
        //得到SingleGameProxy中的gameModuleLibde的元素
        public function get gameLib():HashMap{       
        	return (Facade.getInstance(GlobalDef.GAME_FACADE).retrieveProxy("SingleGameProxy") as SingleGameProxy).lib;
        }
        private  function searchClass(value:String):Class{   
        	libIterator = lib.getIterator();
            while(libIterator.hasNext()){
            	if(((libIterator.next() as LoaderInfo).applicationDomain.hasDefinition(value))){
             		return (((libIterator.next() as LoaderInfo).applicationDomain.getDefinition(value)) as Class);    
            	}
            	
            }
        	return null;   
        }
        //获取Class
        public function getClass(value:String):Class{
        	return searchClass(value);
        }
        //获取实例
        public function getMaterial(value:String):Object{
        	var tempLib:Class= searchClass(value);
        	if(tempLib!=null){
        		return  new tempLib;
        	}
        	return null;
        }
		public static function getInstance():ModuleLib{
			if(instance==null){
				instance= new ModuleLib();				
			}
			return instance;
		}

	}
}