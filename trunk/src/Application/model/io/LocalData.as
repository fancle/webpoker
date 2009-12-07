package Application.model.io
{ 
   import flash.net.SharedObject;
   import flash.net.SharedObjectFlushStatus;
   public class LocalData 
	{
		private var localDataName:String;
        private static var instance:LocalData;
		public function LocalData(param1:String = "game") 
		{
			if (instance == null)
            {
                localDataName = param1;
            }
            else
            {
                throw new Error("实例化单例类出错-LocalData");
            }// end else if
            return;
		}
		public function setObject(param1:String, param2:Object, param3:Number = 0) : void
        {
            var so:SharedObject;
            var flushResult:String;
            var name:* = param1;
            var value:* = param2;
            var time:* = param3;
            so = SharedObject.getLocal(localDataName);
            if (time == 0)
            {
                time = new Date(2030, 1, 1).getTime();
            }// end if
            so.data[name] = {value:value, time:time};
            try
            {
                flushResult = so.flush();
                if (flushResult == SharedObjectFlushStatus.PENDING)
                {
                    trace("PENDING -- 数据超出限制");
                }
                else if (flushResult == SharedObjectFlushStatus.FLUSHED)
                {
                    trace("FlUSHED -- 成功写入");
                }// end else if
            }// end try
            catch (e:Error)
            {
                delete so.data[name];
            }// end catch
            return;
        }// end function
		public function getObject(param1:String) : Object
        {
            var returnValue:Object;
            var dif:Number;
            var name:* = param1;
            var so:* = SharedObject.getLocal(localDataName);
            var now:* = new Date().time;
            try
            {
                if (so.data.hasOwnProperty(name))
                {
                    dif = so.data[name].time - now;
                    if (dif > 0)
                    {
                        returnValue = so.data[name].value;
                    }// end if
                }// end if
            }// end try
            catch (e:Error)
            {
                return returnValue;
            }// end catch
            return returnValue;
        }// end function
		public function hasObject(param1:String) : Boolean
        {
            var _hasobj:Boolean;
            var dif:int;
            var name:* = param1;
            var so:* = SharedObject.getLocal(localDataName);
            var now:* = new Date().time;
            try
            {
                if (so.data.hasOwnProperty(name))
                {
                    dif = so.data[name].time - now;
                    if (dif > 0)
                    {   
                        _hasobj = true; //这里进行了更改
                    }// end if
                }// end if
            }// end try
            catch (e:Error)
            {
            }// end catch
            return _hasobj;
        }// end function
		public function clearObject(param1:String) : void
        {
            var _loc_2:* = SharedObject.getLocal(localDataName);
            delete _loc_2.data[param1];
            return;
        }
	    public static function getInstance(param1:String = "game") : LocalData
        {
            if (!instance)
            {
                instance = new LocalData(param1);
            }// end if
            return instance;
        }// end function
	}
}