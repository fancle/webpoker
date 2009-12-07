package Application.utils
{
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	//用具类 一些常用方法
	public class GameUtil
	{	
	
	
		
		public function GameUtil()
		{

		}
		//网页超链接的方法
		public static function webLink(value:String,type:String = "_blank"):void{
				navigateToURL(new URLRequest(value),type);
		}
		//DWORD IP转字符IP
		public static function convertIPToString(dw:uint):String{
			var strIP:String = String(dw&0x000000ff) + "." + String((dw&0x0000ff00)>>>8) + "." + String((dw&0x00ff0000)>>>16) + "." + String((dw&0xff000000)>>>24);
			return strIP;
		}
		//字符串替换的方法
		public static function replaceText(value:String,obj:Object):String{
			var _pat:String;
			var _reg:RegExp;
			var _text:String = value;
			var _txt:String;
			for(_pat in obj){			
				_reg = new RegExp("{"+_pat+"}","g");
				_txt = _text.replace(_reg,obj[_pat]);		
	       
			}			
			return _txt;			
		}
		public static function convertToProperty(userData:*,str:String):*
		{
			var total:int=(userData["lWinCount"] + userData["lLostCount"] + userData["lDrawCount"] + userData["lFleeCount"]); //总局数
			if (total == 0)
				total=-1;
			switch(str)
			{
				case "昵称":
				{
					return userData["szNickName"];
					
				}
				case "U豆":
				{
					return userData["lGameGold"];
					
				}
				case "桌号":
				{
					return userData["wTableID"] + 1;
					
				}
				case "魅力":
				{
					return userData["lLoveliness"];
					
				}
				case "等级":
				{
					return userData["cbHonorLevel"];
					
				}
				case "胜率":
				{
					return (Number(userData["lWinCount"] / total*100).toFixed(2) + "%");
					
				}
				case "逃率":
				{
					return (Number(userData["lLostCount"] / total*100).toFixed(2) + "%");
					
				}
				case "总局":
				{
					return ((total == -1) ? 0 : total);
					
				}
				case "赢局":
				{
					return userData["lWinCount"];
					
				}
				case "输局":
				{
					return userData["lLostCount"];
					
				}
				case "积分":
				{
					return userData["lScore"];
					
				}
				case "游戏级别":
				{
					return userData["cbHonorLevel"];
					
				}
				case "经验值":
				{
					return userData["lExperience"];
					
				}
				case "排名":
				{
					return userData["dwHonorRank"];
					
				}
			}
			return "";
		}
		/**
		 * 积分转换成经验条的比例 
		 * @param value 传入的是积分
		 * 
		 */
		public static  function socreToexp(value:Number):Number{
			var temp:Number = value/200000;		
			if(temp<0){
				return 0;
			}else if(temp>1){
				return 1;
			}else{
				return temp;
			}
		
			
		}
	}
}