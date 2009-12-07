package B_Land.common
{
	import Application.utils.Memory;
	
	import flash.utils.ByteArray;

	public class GameLogic
	{
		//扑克数据
		public static var m_bCardListData:ByteArray;
		public static var _nCardMaxCount:int=54;

		public function GameLogic()
		{
			if (m_bCardListData == null)
			{
				m_bCardListData=Memory.newLitteEndianByteArray();
				m_bCardListData.writeByte(0x01);
				m_bCardListData.writeByte(0x02);
				m_bCardListData.writeByte(0x03);
				m_bCardListData.writeByte(0x04);
				m_bCardListData.writeByte(0x05);
				m_bCardListData.writeByte(0x06);
				m_bCardListData.writeByte(0x07);
				m_bCardListData.writeByte(0x08);
				m_bCardListData.writeByte(0x09);
				m_bCardListData.writeByte(0x0A);
				m_bCardListData.writeByte(0x0B);
				m_bCardListData.writeByte(0x0C);
				m_bCardListData.writeByte(0x0D); //方块 A - K

				m_bCardListData.writeByte(0x11);
				m_bCardListData.writeByte(0x12);
				m_bCardListData.writeByte(0x13);
				m_bCardListData.writeByte(0x14);
				m_bCardListData.writeByte(0x15);
				m_bCardListData.writeByte(0x16);
				m_bCardListData.writeByte(0x17);
				m_bCardListData.writeByte(0x18);
				m_bCardListData.writeByte(0x19);
				m_bCardListData.writeByte(0x1A);
				m_bCardListData.writeByte(0x1B);
				m_bCardListData.writeByte(0x1C);
				m_bCardListData.writeByte(0x1D); //梅花 A - K

				m_bCardListData.writeByte(0x21);
				m_bCardListData.writeByte(0x22);
				m_bCardListData.writeByte(0x23);
				m_bCardListData.writeByte(0x24);
				m_bCardListData.writeByte(0x25);
				m_bCardListData.writeByte(0x26);
				m_bCardListData.writeByte(0x27);
				m_bCardListData.writeByte(0x28);
				m_bCardListData.writeByte(0x29);
				m_bCardListData.writeByte(0x2A);
				m_bCardListData.writeByte(0x2B);
				m_bCardListData.writeByte(0x2C);
				m_bCardListData.writeByte(0x2D); //红桃 A - K

				m_bCardListData.writeByte(0x31);
				m_bCardListData.writeByte(0x32);
				m_bCardListData.writeByte(0x33);
				m_bCardListData.writeByte(0x34);
				m_bCardListData.writeByte(0x35);
				m_bCardListData.writeByte(0x36);
				m_bCardListData.writeByte(0x37);
				m_bCardListData.writeByte(0x38);
				m_bCardListData.writeByte(0x39);
				m_bCardListData.writeByte(0x3A);
				m_bCardListData.writeByte(0x3B);
				m_bCardListData.writeByte(0x3C);
				m_bCardListData.writeByte(0x3D); //黑桃 A - K

				m_bCardListData.writeByte(0x4E);
				m_bCardListData.writeByte(0x4F);
			}
		}

		public function RemoveCard(bRemoveCard:Array, bRemoveCount:uint, bCardData:Array, bCardCount:uint):Boolean
		{
			//检验数据
			if (bRemoveCount > bCardCount)
			{
				return false;
			}

			//定义变量
			var bDeleteCount:uint=0;
			var bTempCardData:Array=new Array(20);
			if (bCardCount > bTempCardData.length)
			{
				return false;
			}
			Memory.CopyArray(bTempCardData, bCardData, bCardCount);

			//置零扑克
			for (var i:uint=0; i < bRemoveCount; i++)
			{
				for (var j:uint=0; j < bCardCount; j++)
				{
					if (bRemoveCard[i] == bTempCardData[j])
					{
						bDeleteCount++;
						bTempCardData[j]=0;
						break;
					}
				}
			}
			if (bDeleteCount != bRemoveCount)
			{
				return false;
			}

			//清理扑克
			var bCardPos:uint=0;
			for (var k:uint=0; k < bCardCount; k++)
			{
				if (bTempCardData[k] != 0)
				{
					bCardData[bCardPos++]=bTempCardData[k];
				}
			}

			return true;
		}

		//获取花色
		public function GetCardColor(bCardData:uint):uint
		{

			return bCardData & GameLogicDef.LOGIC_MASK_COLOR;
		}

		//获取数值
		public function GetCardValue(bCardData:uint):uint
		{
			return bCardData & GameLogicDef.LOGIC_MASK_VALUE;
		}

		//逻辑函数
		//逻辑数值
		public function GetCardLogicValue(bCardData:uint):uint
		{
			//扑克属性
			var bCardColor:uint=GetCardColor(bCardData);
			var bCardValue:uint=GetCardValue(bCardData);

			//转换数值
			if (bCardColor == 0x40)
			{
				return bCardValue + 15;
			}
			return bCardValue <= 2 ? bCardValue + 13 : bCardValue;
		}

 		//分析扑克1
		public function AnalysebCardData(bCardData:Array, bCardCount:uint, AnalyseResult:tagAnalyseResult):void
		{
			//变量定义
			var bSameCount:uint=1;
			var bCardValueTemp:uint=0;
			var bLogicValue:uint=GetCardLogicValue(bCardData[0]);



			//设置结果
			AnalyseResult.init();
			//扑克分析


			for (var i:uint=1; i < bCardCount; i++)
			{
				//获取扑克
				bCardValueTemp=GetCardLogicValue(bCardData[i]);
				if (bCardValueTemp == bLogicValue)
				{
					bSameCount++;
				}

				//保存结果
				if (bCardValueTemp != bLogicValue || i == bCardCount - 1)
				{
					switch (bSameCount)
					{
						case 2: //两张
						{
							var dst_offset:uint=AnalyseResult.bDoubleCount * 2;
							var src_offset:uint=i - 2 + ((i == bCardCount - 1 && bCardValueTemp == bLogicValue) ? 1 : 0);
							Memory.CopyArray(AnalyseResult.m_bDCardData, bCardData, 2, dst_offset, src_offset);
							AnalyseResult.bDoubleLogicVolue[AnalyseResult.bDoubleCount++]=bLogicValue;
							break;

						}
							;
						case 3: //三张
						{
							var dst_offset:uint=AnalyseResult.bThreeCount * 3;
							var src_offset:uint=i - 3 + ((i == bCardCount - 1 && bCardValueTemp == bLogicValue) ? 1 : 0);

							Memory.CopyArray(AnalyseResult.m_bTCardData, bCardData, 3, dst_offset, src_offset);
							AnalyseResult.bThreeLogicVolue[AnalyseResult.bThreeCount++]=bLogicValue;
							break;

						}
							;
						case 4: //四张
						{
							var dst_offset:uint=AnalyseResult.bFourCount * 4;
							var src_offset:uint=i - 4 + ((i == bCardCount - 1 && bCardValueTemp == bLogicValue) ? 1 : 0);

							Memory.CopyArray(AnalyseResult.m_bFCardData, bCardData, 4, dst_offset, src_offset);
							AnalyseResult.bFourLogicVolue[AnalyseResult.bFourCount++]=bLogicValue;
							break;

						}
					}
				}
				;

				//设置变量
				if (bCardValueTemp != bLogicValue)
				{
					if (bSameCount == 1)
					{
						if (i != bCardCount - 1)
						{
							AnalyseResult.m_bSCardData[AnalyseResult.bSignedCount++]=bCardData[i - 1];
						}
						else
						{
							AnalyseResult.m_bSCardData[AnalyseResult.bSignedCount++]=bCardData[i - 1];
							AnalyseResult.m_bSCardData[AnalyseResult.bSignedCount++]=bCardData[i];
						}
					}
					else
					{
						if (i == bCardCount - 1)
						{
							AnalyseResult.m_bSCardData[AnalyseResult.bSignedCount++]=bCardData[i];
						}
					}
					bSameCount=1;
					bLogicValue=bCardValueTemp;

				}
			}

			//单牌数目
			var bOtherCount:uint=AnalyseResult.bDoubleCount * 2 + AnalyseResult.bThreeCount * 3 + AnalyseResult.bFourCount * 4;
			return;
		} 

/*  		//分析扑克2
		public function AnalysebCardData(cbCardData:Array, cbCardCount:int,  AnalyseResult:tagAnalyseResult):Boolean
		{
			//设置结果
			AnalyseResult.init();
		
			//扑克分析
			for (var i:int=0;i<cbCardCount;i++)
			{
				//变量定义
				var cbSameCount:int=1;
				var cbLogicValue:int=GetCardLogicValue(cbCardData[i]);
				if(cbLogicValue<=0) 
					return false;
		
				//搜索同牌
				for (var j:int=i+1;j<cbCardCount;j++)
				{
					//获取扑克
					if (GetCardLogicValue(cbCardData[j])!=cbLogicValue) break;
		
					//设置变量
					cbSameCount++;
				}
				var cbIndex:int = 0;
				//设置结果
				switch (cbSameCount)
				{
				case 1:		//单张
					{
						cbIndex=AnalyseResult.bSignedCount++;
						AnalyseResult.m_bSCardData[cbIndex*cbSameCount]=cbCardData[i];
						break;
					}
				case 2:		//两张
					{
						cbIndex=AnalyseResult.bDoubleCount++;
						AnalyseResult.m_bDCardData[cbIndex*cbSameCount]=cbCardData[i];
						AnalyseResult.m_bDCardData[cbIndex*cbSameCount+1]=cbCardData[i+1];
						
						AnalyseResult.bDoubleLogicVolue[cbIndex]=cbLogicValue;
					
						break;
					}
				case 3:		//三张
					{
						cbIndex=AnalyseResult.bThreeCount++;
						AnalyseResult.m_bTCardData[cbIndex*cbSameCount]=cbCardData[i];
						AnalyseResult.m_bTCardData[cbIndex*cbSameCount+1]=cbCardData[i+1];
						AnalyseResult.m_bTCardData[cbIndex*cbSameCount+2]=cbCardData[i+2];
						
						AnalyseResult.bThreeLogicVolue[cbIndex]=cbLogicValue;
						break;
					}
				case 4:		//四张
					{
						cbIndex=AnalyseResult.bFourCount++;
						AnalyseResult.m_bFCardData[cbIndex*cbSameCount]=cbCardData[i];
						AnalyseResult.m_bFCardData[cbIndex*cbSameCount+1]=cbCardData[i+1];
						AnalyseResult.m_bFCardData[cbIndex*cbSameCount+2]=cbCardData[i+2];
						AnalyseResult.m_bFCardData[cbIndex*cbSameCount+3]=cbCardData[i+3];
						
						AnalyseResult.bFourLogicVolue[cbIndex]=cbLogicValue;
						break;
					}
				}
		
				//设置索引
				i+=cbSameCount-1;
			}
			AnalyseResult.bDoubleLogicVolue.sort(Array.DESCENDING,Array.NUMERIC);
			AnalyseResult.bThreeLogicVolue.sort(Array.DESCENDING,Array.NUMERIC);
			AnalyseResult.bFourLogicVolue.sort(Array.DESCENDING,Array.NUMERIC);
			return true;
		} */
 
		//获取类型
		public function GetCardType(bCardData:Array, bCardCount:uint):uint
		{

			//开始分析
			switch (bCardCount)
			{
				case 1: //单牌
				{
					return GameLogicDef.CT_SINGLE;
				}

				case 2: //对牌和火箭
				{
					if (bCardData[0] == 0x4F && bCardData[1] == 0x4E)
					{
						return GameLogicDef.CT_MISSILE_CARD;
					}
					return GetCardLogicValue(bCardData[0]) == GetCardLogicValue(bCardData[1]) ? GameLogicDef.CT_DOUBLE : GameLogicDef.CT_INVALID;







				}

				case 3:
				case 4: //连牌和炸弹
				{
					var bLogicValue:uint=GetCardLogicValue(bCardData[0]);
					for (var i:uint=1; i < bCardCount; i++)
					{
						if (bLogicValue != GetCardLogicValue(bCardData[i]))
						{
							break;
						}
					}
					if (i == bCardCount)
					{
						return bCardCount == 3 ? GameLogicDef.CT_THREE : GameLogicDef.CT_BOMB_CARD;
					}
					if (bCardCount == 3)
					{
						return GameLogicDef.CT_INVALID;
					}
					break;

				}
			}
			//其他牌型
			if (bCardCount >= 4)
			{
				//分析扑克
				var AnalyseResult:tagAnalyseResult=new tagAnalyseResult;
				AnalysebCardData(bCardData, bCardCount, AnalyseResult);
			
				//四牌判断
				if (AnalyseResult.bFourCount > 0)
				{
					if (AnalyseResult.bFourCount == 1 && bCardCount == 5)
					{
						return GameLogicDef.CT_FOUR_LINE_TAKE_ONE;
					}
					if (AnalyseResult.bFourCount == 1 && AnalyseResult.bDoubleCount == 1 && bCardCount == 6)
					{
						return GameLogicDef.CT_FOUR_LINE_TAKE_ONE;
					}
					if (AnalyseResult.bFourCount == 1 && AnalyseResult.bDoubleCount == 2 && bCardCount == 8)
					{
						return GameLogicDef.CT_FOUR_LINE_TAKE_DOUBLE;
					}
					if (AnalyseResult.bFourCount == 1 && bCardCount == 6)
					{
						return GameLogicDef.CT_FOUR_LINE_TAKE_DOUBLE;
					}

					return GameLogicDef.CT_INVALID;
				}

				//三牌判断
				if (AnalyseResult.bThreeCount > 0)
				{
					//连牌判断
					if (AnalyseResult.bThreeCount > 1)
					{
						if (AnalyseResult.bThreeLogicVolue[0] == 15)
						{
							return GameLogicDef.CT_INVALID;
						}
						for (var i:uint=1; i < AnalyseResult.bThreeCount; i++)
						{
							if (AnalyseResult.bThreeLogicVolue[i] != AnalyseResult.bThreeLogicVolue[0] - i)
							{
								return GameLogicDef.CT_INVALID;
							}
						}
					}

					//牌形判断
					if (AnalyseResult.bThreeCount * 3 == bCardCount)
					{
						return GameLogicDef.CT_THREE_LINE;
					}
					if (AnalyseResult.bThreeCount == bCardCount - AnalyseResult.bThreeCount * 3)
					{
						return GameLogicDef.CT_THREE_LINE_TAKE_ONE;
					}
					if (AnalyseResult.bDoubleCount == AnalyseResult.bThreeCount && bCardCount == AnalyseResult.bThreeCount * 3 + AnalyseResult.bDoubleCount * 2)
					{
						return GameLogicDef.CT_THREE_LINE_TAKE_DOUBLE;
					}

					return GameLogicDef.CT_INVALID;
				}

				//两张类型
				if (AnalyseResult.bDoubleCount >= 3)
				{
					//二连判断
					if (AnalyseResult.bDoubleLogicVolue[0] != 15)
					{
						for (var i:uint=1; i < AnalyseResult.bDoubleCount; i++)
						{   
							
							if (AnalyseResult.bDoubleLogicVolue[i] != AnalyseResult.bDoubleLogicVolue[0] - i)
							{
								return GameLogicDef.CT_INVALID;
							}
						}
						if (AnalyseResult.bDoubleCount * 2 == bCardCount)
						{
							return GameLogicDef.CT_DOUBLE_LINE;
						}
					}

					return GameLogicDef.CT_INVALID;
				}
				//单张判断
				if (AnalyseResult.bSignedCount >= 5 && AnalyseResult.bSignedCount == bCardCount)
				{
					//bCardData.sort(sortOnValue);					
					var bLogicValue:uint=GetCardLogicValue(bCardData[0]);
					if (bLogicValue >= 15)
					{
						return GameLogicDef.CT_INVALID;
					}
					for (var i:uint=1; i < AnalyseResult.bSignedCount; i++)
					{	
						
						if (GetCardLogicValue(bCardData[i]) != bLogicValue - i)
						{
							return GameLogicDef.CT_INVALID;
						}
					}

					return GameLogicDef.CT_ONE_LINE;
				}
				return GameLogicDef.CT_INVALID;
			}

			return GameLogicDef.CT_INVALID;
		}
		//按值排序分析
		private function sortOnValue(a:uint,b:uint):Number{
			var aValue:int = GetCardLogicValue(a);
			var bValue:int = GetCardLogicValue(b);
			if(aValue>bValue){
				return -1;
			}else if(aValue<bValue){
				return 1;
			}else{
				return 0;
			}
		}
		//混乱扑克
		public function RandCardList(bCardBuffer:Array, bBufferCount:uint):void
		{
			//混乱准备
			var bCardData:Array=new Array(_nCardMaxCount);

			for (var i:uint=0; i < _nCardMaxCount; i++)
			{
				bCardData=m_bCardListData[i];
			}

			//混乱扑克
			var bRandCount:uint=0;
			var bPosition:uint=0;
			do
			{
				bPosition=(uint(Math.random() * int.MAX_VALUE)) % bBufferCount - bRandCount;
				bCardBuffer[bRandCount++]=bCardData[bPosition];
				bCardData[bPosition]=bCardData[bBufferCount - bRandCount];
			} while (bRandCount < bBufferCount);

			return;
		}

		//对比扑克
		public function CompareCard(bFirstList:Array, bNextList:Array, bFirstCount:uint, bNextCount:uint):Boolean
		{
			//获取类型
			var bNextType:uint=GetCardType(bNextList, bNextCount);
			var bFirstType:uint=GetCardType(bFirstList, bFirstCount);

			//类型判断
			if (bFirstType == GameLogicDef.CT_INVALID)
			{
				return false;
			}
			if (bFirstType == GameLogicDef.CT_MISSILE_CARD)
			{
				return true;
			}

			//炸弹判断
			if (bFirstType == GameLogicDef.CT_BOMB_CARD && bNextType != GameLogicDef.CT_BOMB_CARD)
			{
				return true;
			}
			if (bFirstType != GameLogicDef.CT_BOMB_CARD && bNextType == GameLogicDef.CT_BOMB_CARD)
			{
				return false;
			}

			//规则判断
			if (bFirstType != bNextType || bFirstCount != bNextCount)
			{
				return false;
			}

			//开始对比
			switch (bNextType)
			{
				case GameLogicDef.CT_SINGLE:
				case GameLogicDef.CT_DOUBLE:
				case GameLogicDef.CT_THREE:
				case GameLogicDef.CT_ONE_LINE:
				case GameLogicDef.CT_DOUBLE_LINE:
				case GameLogicDef.CT_THREE_LINE:
				case GameLogicDef.CT_BOMB_CARD:
				{
					var bFirstLogicValue:uint=GetCardLogicValue(bFirstList[0]);
					var bNextLogicValue:uint=GetCardLogicValue(bNextList[0]);
					return bFirstLogicValue > bNextLogicValue;


				}
					;
				case GameLogicDef.CT_THREE_LINE_TAKE_ONE:
				case GameLogicDef.CT_THREE_LINE_TAKE_DOUBLE:
				{
					var NextResult:tagAnalyseResult=new tagAnalyseResult;
					var FirstResult:tagAnalyseResult=new tagAnalyseResult;
					AnalysebCardData(bNextList, bNextCount, NextResult);
					AnalysebCardData(bFirstList, bFirstCount, FirstResult);
					return FirstResult.bThreeLogicVolue[0] > NextResult.bThreeLogicVolue[0];


				}
					;
				case GameLogicDef.CT_FOUR_LINE_TAKE_ONE:
				case GameLogicDef.CT_FOUR_LINE_TAKE_DOUBLE:
				{
					var NextResult:tagAnalyseResult=new tagAnalyseResult;
					var FirstResult:tagAnalyseResult=new tagAnalyseResult;
					AnalysebCardData(bNextList, bNextCount, NextResult);
					AnalysebCardData(bFirstList, bFirstCount, FirstResult);
					return FirstResult.bFourLogicVolue[0] > NextResult.bFourLogicVolue[0];


				}
			}
			;

			return false;
		}

		//控制函数
		//排列扑克
		public function SortCardList(bCardData:Array, bCardCount:uint, type:Boolean=false):void
		{
			//转换数值
			var bLogicVolue:Array=new Array(20);
			for (var i:uint=0; i < bCardCount; i++)
			{
				bLogicVolue[i]=GetCardLogicValue(bCardData[i]);
			}

			//排序操作
			var bSorted:Boolean=true;
			var bTempData:uint;
			var bLast:uint=bCardCount - 1;
			do
			{
				bSorted=true;
				for (var i:uint=0; i < bLast; i++)
				{
					if (bLogicVolue[i] < bLogicVolue[i + 1] || bLogicVolue[i] == bLogicVolue[i + 1] && bCardData[i] < bCardData[i + 1])
					{
						//交换位置
						bTempData=bCardData[i];
						bCardData[i]=bCardData[i + 1];
						bCardData[i + 1]=bTempData;
						bTempData=bLogicVolue[i];
						bLogicVolue[i]=bLogicVolue[i + 1];
						bLogicVolue[i + 1]=bTempData;
						bSorted=false;
					}
				}
				bLast--;
			} while (bSorted == false);
			if (type == true)
			{
				//按类型排序
				var cbIndex:int=0;
				var AnalyseResult:tagAnalyseResult=new tagAnalyseResult;
				AnalysebCardData(bCardData, bCardCount, AnalyseResult);
				//拷贝四牌	

				Memory.CopyArray(bCardData, AnalyseResult.m_bFCardData, AnalyseResult.bFourCount * 4, cbIndex);
				cbIndex+=AnalyseResult.bFourCount * 4;
				//拷贝三牌

				Memory.CopyArray(bCardData, AnalyseResult.m_bTCardData, AnalyseResult.bThreeCount * 3, cbIndex);
				cbIndex+=AnalyseResult.bThreeCount * 3;
				//拷贝对牌		

				Memory.CopyArray(bCardData, AnalyseResult.m_bDCardData, (AnalyseResult.bDoubleCount * 2), cbIndex);
				cbIndex+=AnalyseResult.bDoubleCount * 2;
				//拷贝单牌

				Memory.CopyArray(bCardData, AnalyseResult.m_bSCardData, AnalyseResult.bSignedCount, cbIndex);
				//cbIndex+=AnalyseResult.bSignedCount;
			}

			return;
		}

		public function SortCardListType(bCardData:Array, bCardCount:uint):void
		{
			//转换数值
			var bLogicVolue:Array=new Array(20);
			for (var i:uint=0; i < bCardCount; i++)
			{
				bLogicVolue[i]=GetCardLogicValue(bCardData[i]);
			}

			//排序操作
			var bSorted:Boolean=true;
			var bTempData:uint;
			var bLast:uint=bCardCount - 1;
			do
			{
				bSorted=true;
				for (var i:uint=0; i < bLast; i++)
				{
					if (bLogicVolue[i] < bLogicVolue[i + 1] || bLogicVolue[i] == bLogicVolue[i + 1] && bCardData[i] < bCardData[i + 1])
					{
						//交换位置
						bTempData=bCardData[i];
						bCardData[i]=bCardData[i + 1];
						bCardData[i + 1]=bTempData;
						bTempData=bLogicVolue[i];
						bLogicVolue[i]=bLogicVolue[i + 1];
						bLogicVolue[i + 1]=bTempData;
						bSorted=false;
					}
				}
				bLast--;
			} while (bSorted == false);
			var cbIndex:int=0;
			var AnalyseResult:tagAnalyseResult=new tagAnalyseResult;

			AnalysebCardData(bCardData, bCardCount, AnalyseResult);
			//拷贝四牌	

			Memory.CopyArray(bCardData, AnalyseResult.m_bFCardData, AnalyseResult.bFourCount * 4, cbIndex);
			cbIndex+=AnalyseResult.bFourCount * 4;
			//拷贝三牌

			Memory.CopyArray(bCardData, AnalyseResult.m_bTCardData, AnalyseResult.bThreeCount * 3, cbIndex);
			cbIndex+=AnalyseResult.bThreeCount * 3;
			//拷贝对牌		

			Memory.CopyArray(bCardData, AnalyseResult.m_bDCardData, (AnalyseResult.bDoubleCount * 2), cbIndex);
			cbIndex+=AnalyseResult.bDoubleCount * 2;
			//拷贝单牌

			Memory.CopyArray(bCardData, AnalyseResult.m_bSCardData, AnalyseResult.bSignedCount, cbIndex);
			cbIndex+=AnalyseResult.bSignedCount;
			return;
		}

		//提示出牌
		public function searchOutCard(WhichOnsKindCard:uint, m_bTurnOutType:uint, m_bTurnCardData:Array, m_bTurnCardCount:uint, m_bHandCardData:Array, m_bHandCardCount:uint, m_bTempGetCardData:Array, bWhichKindSel:uint):uint
		{
			var i:int=0;
			var j:int=0;
			var n:int=0;
			var s:int=0;
			var m_bTempSCardCount:uint=0; //扑克数目
			var m_bTempSCardData:Array=new Array(20); //手上单牌扑克
			var m_bTempDCardCount:int=0; //扑克数目
			var m_bTempDCardData:Array=new Array(20); //手上对牌扑克
			var m_bTempTCardCount:uint=0; //扑克数目
			var m_bTempTCardData:Array=new Array(20); //手上三张牌扑克
			var m_bTempFCardCount:uint=0; //扑克数目
			var m_bTempFCardData:Array=new Array(20); //手上四张牌扑克
			var m_bTempMissileCount:uint = 0;//扑克数目
			var m_bTempMissileData:Array = new Array;//手上王炸的数量
			var m_bTempGetCardCount:uint=0; //扑克数目
			var m_TempCard:uint=0;
			//如果没有人出牌，不提示
			if (m_bTurnCardCount == 0)
				return 0;
			//获取单牌列表
			for (i=0; i < m_bHandCardCount; i++)
			{
				var m_GetCard:uint=GetCardLogicValue(m_bHandCardData[i]);
				if (m_TempCard != m_GetCard)
				{
					m_bTempSCardData[m_bTempSCardCount++]=m_bHandCardData[i];
					m_TempCard=m_GetCard;
				}
				//判断王炸
				if(m_GetCard>15){
					m_bTempMissileData.push(m_bHandCardData[i]);
					if(m_bTempMissileData.length>1){
						m_bTempMissileCount = 1;
					}
				}
			}
			//获取对牌列表
			m_TempCard=0;
			for (i=0; i < m_bHandCardCount - 1; i++)
			{
				var m_GetCard1:uint=GetCardLogicValue(m_bHandCardData[i]);
				var m_GetCard2:uint=GetCardLogicValue(m_bHandCardData[i + 1]);
				if (m_TempCard != m_GetCard1 && m_GetCard1 == m_GetCard2 && m_GetCard1 < 16)
				{
					m_bTempDCardData[m_bTempDCardCount++]=m_bHandCardData[i];
					m_bTempDCardData[m_bTempDCardCount++]=m_bHandCardData[i + 1];
					m_TempCard=m_GetCard1;
				}
			}
			//获取三张牌列表
			m_TempCard=0;
			for (i=0; i < m_bHandCardCount - 2; i++)
			{
				var m_GetCard1:uint=GetCardLogicValue(m_bHandCardData[i]);
				var m_GetCard2:uint=GetCardLogicValue(m_bHandCardData[i + 1]);
				var m_GetCard3:uint=GetCardLogicValue(m_bHandCardData[i + 2]);
				if (m_TempCard != m_GetCard1 && m_GetCard1 == m_GetCard2 && m_GetCard1 == m_GetCard3)
				{
					m_bTempTCardData[m_bTempTCardCount++]=m_bHandCardData[i];
					m_bTempTCardData[m_bTempTCardCount++]=m_bHandCardData[i + 1];
					m_bTempTCardData[m_bTempTCardCount++]=m_bHandCardData[i + 2];
					m_TempCard=m_GetCard1;
				}
			}
			//获取四张牌列表
			m_TempCard=0;
			for (i=0; i < m_bHandCardCount - 3; i++)
			{
				var m_GetCard1:uint=GetCardLogicValue(m_bHandCardData[i]);
				var m_GetCard2:uint=GetCardLogicValue(m_bHandCardData[i + 1]);
				var m_GetCard3:uint=GetCardLogicValue(m_bHandCardData[i + 2]);
				var m_GetCard4:uint=GetCardLogicValue(m_bHandCardData[i + 3]);
				if (m_TempCard != m_GetCard1 && m_GetCard1 == m_GetCard2 && m_GetCard1 == m_GetCard3 && m_GetCard1 == m_GetCard4)
				{
					m_bTempFCardData[m_bTempFCardCount++]=m_bHandCardData[i];
					m_bTempFCardData[m_bTempFCardCount++]=m_bHandCardData[i + 1];
					m_bTempFCardData[m_bTempFCardCount++]=m_bHandCardData[i + 2];
					m_bTempFCardData[m_bTempFCardCount++]=m_bHandCardData[i + 3];
					m_TempCard=m_GetCard1;
				}
			}
			//根据所出牌类型判断
			i=0;
			switch (m_bTurnOutType)
			{
				case GameLogicDef.CT_SINGLE: //单牌类型
				case GameLogicDef.CT_ONE_LINE: //单连类型
				{
					if (WhichOnsKindCard == 1) //判断是不是具有唯一性
					{
						for (i=m_bTempSCardCount; i > 0; i--)
						{
							if (i - m_bTurnCardCount >= 0 && CompareCard(Memory.CloneArray(m_bTempSCardData, i - m_bTurnCardCount), m_bTurnCardData, m_bTurnCardCount, m_bTurnCardCount))
							{
								if ((bWhichKindSel++) > 1)
									i=0;
							}
						}
					}
					for (i=m_bTempSCardCount; i > 0; i--)
					{
						if (i - m_bTurnCardCount >= 0 && CompareCard(Memory.CloneArray(m_bTempSCardData, i - m_bTurnCardCount), m_bTurnCardData, m_bTurnCardCount, m_bTurnCardCount))
						{
							//判断是不是最合理的
							var m_bIsHaveCard:Boolean=false;
							for (j=0; j < m_bTempDCardCount; j++)
							{
								for (n=0; n < m_bTurnCardCount; n++)
								{
									if (GetCardLogicValue(m_bTempSCardData[i - m_bTurnCardCount + n]) == GetCardLogicValue(m_bTempDCardData[j]))
										m_bIsHaveCard=true;
								}
							}
							//把最合理的情况保存起来
							if (m_bTempGetCardCount == 0 || !m_bIsHaveCard)
							{
								Memory.CopyArray(m_bTempGetCardData, Memory.CloneArray(m_bTempSCardData, i - m_bTurnCardCount), m_bTurnCardCount);
								m_bTempGetCardCount=m_bTurnCardCount;
							}
							if (!m_bIsHaveCard)
								break;
						}
					}
					break;
				}
				case GameLogicDef.CT_DOUBLE: //对牌类型
				case GameLogicDef.CT_DOUBLE_LINE: //对连类型
				{
					if (WhichOnsKindCard == 1) //判断是不是具有唯一性
					{
						for (i=m_bTempDCardCount; i > 0; i--)
						{
							if (i - m_bTurnCardCount >= 0 && CompareCard(Memory.CloneArray(m_bTempDCardData, i - m_bTurnCardCount), m_bTurnCardData, m_bTurnCardCount, m_bTurnCardCount))
							{
								if ((bWhichKindSel++) > 1)
									i=0;
							}
						}
					}
					for (i=m_bTempDCardCount; i > 0; i--)
					{
						if (i - m_bTurnCardCount >= 0 && CompareCard(Memory.CloneArray(m_bTempDCardData, i - m_bTurnCardCount), m_bTurnCardData, m_bTurnCardCount, m_bTurnCardCount))
						{
							//判断是不是最合理的
							var m_bIsHaveCard:Boolean=false;
							for (j=0; j < m_bTempTCardCount; j++)
							{
								for (n=0; n < m_bTurnCardCount; n++)
								{
									if (GetCardLogicValue(m_bTempDCardData[i - m_bTurnCardCount + n]) == GetCardLogicValue(m_bTempTCardData[j]))
										m_bIsHaveCard=true;
								}
							}
							if (m_bTempGetCardCount == 0 || !m_bIsHaveCard)
							{
								Memory.CopyArray(m_bTempGetCardData, Memory.CloneArray(m_bTempDCardData, i - m_bTurnCardCount), m_bTurnCardCount);
								m_bTempGetCardCount=m_bTurnCardCount;
							}
							if (!m_bIsHaveCard)
								break;
						}
					}
					break;
				}
				case GameLogicDef.CT_THREE: //三条类型
				case GameLogicDef.CT_THREE_LINE: //三连类型
				{
					if (WhichOnsKindCard == 1) //判断是不是具有唯一性
					{
						for (i=m_bTempTCardCount; i > 0; i--)
						{
							if (i - m_bTurnCardCount >= 0 && CompareCard(Memory.CloneArray(m_bTempTCardData, i - m_bTurnCardCount), m_bTurnCardData, m_bTurnCardCount, m_bTurnCardCount))
							{
								if ((bWhichKindSel++) > 1)
									i=0;
							}
						}
					}
					for (i=m_bTempTCardCount; i > 0; i--)
					{
						if (i - m_bTurnCardCount >= 0 && CompareCard(Memory.CloneArray(m_bTempTCardData, i - m_bTurnCardCount), m_bTurnCardData, m_bTurnCardCount, m_bTurnCardCount))
						{
							//判断是不是最合理的
							var m_bIsHaveCard:Boolean=false;
							for (j=0; j < m_bTempFCardCount; j++)
							{
								for (n=0; n < m_bTurnCardCount; n++)
								{
									if (GetCardLogicValue(m_bTempTCardData[i - m_bTurnCardCount + n]) == GetCardLogicValue(m_bTempFCardData[j]))
										m_bIsHaveCard=true;
								}
							}
							if (m_bTempGetCardCount == 0 || !m_bIsHaveCard)
							{
								Memory.CopyArray(m_bTempGetCardData, Memory.CloneArray(m_bTempTCardData, i - m_bTurnCardCount), m_bTurnCardCount);
								m_bTempGetCardCount=m_bTurnCardCount;
							}
							if (!m_bIsHaveCard && m_bTempGetCardCount != 0)
								break;
						}
					}
					break;
				}
				case GameLogicDef.CT_THREE_LINE_TAKE_ONE: //三带一单
				case GameLogicDef.CT_THREE_LINE_TAKE_DOUBLE: //三带一对
				{
					//分析扑克
					var AnalyseResult:tagAnalyseResult=new tagAnalyseResult;
					AnalysebCardData(m_bTurnCardData, m_bTurnCardCount, AnalyseResult);
					if (WhichOnsKindCard == 1) //判断是不是具有唯一性
					{
						for (i=m_bTempTCardCount; i > 0; i--)
						{
							if (i - AnalyseResult.bThreeCount * 3 >= 0 && CompareCard(Memory.CloneArray(m_bTempTCardData, i - AnalyseResult.bThreeCount * 3), m_bTurnCardData, AnalyseResult.bThreeCount * 3, AnalyseResult.bThreeCount * 3))
							{
								if ((bWhichKindSel++) > 1)
									i=0;
							}
						}
					}
					for (i=m_bTempTCardCount; i > 0; i--)
					{
						if (i - AnalyseResult.bThreeCount * 3 >= 0 && CompareCard(Memory.CloneArray(m_bTempTCardData, i - AnalyseResult.bThreeCount * 3), AnalyseResult.m_bTCardData, AnalyseResult.bThreeCount * 3, AnalyseResult.bThreeCount * 3))
						{
							//判断是不是最合理的
							var m_bIsHaveCard:Boolean=false;
							for (j=0; j < m_bTempFCardCount; j++)
							{
								for (n=0; n < AnalyseResult.bThreeCount * 3; n++)
								{
									if (GetCardLogicValue(m_bTempTCardData[i - AnalyseResult.bThreeCount * 3 + n]) == GetCardLogicValue(m_bTempFCardData[j]))
										m_bIsHaveCard=true;
								}
							}
							if (m_bTempGetCardCount == 0 || !m_bIsHaveCard)
							{
								Memory.CopyArray(m_bTempGetCardData, Memory.CloneArray(m_bTempTCardData, i - AnalyseResult.bThreeCount * 3), AnalyseResult.bThreeCount * 3);
								m_bTempGetCardCount=AnalyseResult.bThreeCount * 3;
							}
							if (!m_bIsHaveCard && m_bTempGetCardCount != 0)
								i=0;
						}
					}
					if (m_bTempGetCardCount > 0)
					{
						var m_bIsHaveSame:Boolean;
						for (var m:int=0; m < AnalyseResult.bDoubleCount; m++)
						{
							for (j=0; j < m_bTempDCardCount / 2; j++)
							{
								//判断是不是最合理的
								m_bIsHaveSame=false;
								for (n=0; n < m_bTempGetCardCount; n++)
								{
									if (GetCardLogicValue(m_bTempDCardData[m_bTempDCardCount - j * 2 - 1]) == GetCardLogicValue(m_bTempGetCardData[n]))
									{
										m_bIsHaveSame=true;
									}
								}
								if (!m_bIsHaveSame)
								{
									var m_bIsHaveCard:Boolean=false;
									for (s=0; s < m_bTempTCardCount; s++)
									{
										for (n=0; n < m_bTempGetCardCount; n++)
										{
											if (GetCardLogicValue(m_bTempDCardData[m_bTempDCardCount - j * 2 - 1]) == GetCardLogicValue(m_bTempTCardData[s]))
												m_bIsHaveCard=true;
										}
									}
									if (m_bTempGetCardCount == AnalyseResult.bThreeCount * 3 || !m_bIsHaveCard)
									{
										m_bTempGetCardData[AnalyseResult.bThreeCount * 3 + m * 2]=m_bTempDCardData[m_bTempDCardCount - j * 2 - 1];
										m_bTempGetCardData[AnalyseResult.bThreeCount * 3 + m * 2 + 1]=m_bTempDCardData[m_bTempDCardCount - j * 2 - 2];
										m_bTempGetCardCount=AnalyseResult.bThreeCount * 3 + (m + 1) * 2;
									}
									if (!m_bIsHaveCard)
									{
										n=m_bTempGetCardCount;
										j=m_bTempDCardCount / 2;
									}
								}
							}
						}
						for (var m:int=0; m < AnalyseResult.bSignedCount; m++)
						{
							for (j=0; j < m_bTempSCardCount; j++)
							{
								//判断是不是最合理的
								m_bIsHaveSame=false;
								for (n=0; n < m_bTempGetCardCount; n++)
								{
									if (GetCardLogicValue(m_bTempSCardData[m_bTempSCardCount - j - 1]) == GetCardLogicValue(m_bTempGetCardData[n]))
									{
										m_bIsHaveSame=true;
									}
								}
								if (!m_bIsHaveSame)
								{
									var m_bIsHaveCard:Boolean=false;
									for (s=0; s < m_bTempDCardCount; s++)
									{
										for (n=0; n < m_bTempGetCardCount; n++)
										{
											if (GetCardLogicValue(m_bTempSCardData[m_bTempSCardCount - j - 1]) == GetCardLogicValue(m_bTempDCardData[s]))
												m_bIsHaveCard=true;
										}
									}
									if (m_bTempGetCardCount == AnalyseResult.bThreeCount * 3 || !m_bIsHaveCard)
									{
										m_bTempGetCardData[AnalyseResult.bThreeCount * 3 + m]=m_bTempSCardData[m_bTempSCardCount - j - 1];
										m_bTempGetCardCount=AnalyseResult.bThreeCount * 3 + m + 1;
									}
									if (!m_bIsHaveCard)
									{
										n=m_bTempGetCardCount;
										j=m_bTempSCardCount;
									}
								}
							}
						}
					}
					break;
				}
				case GameLogicDef.CT_FOUR_LINE_TAKE_ONE: //四带两单
				case GameLogicDef.CT_FOUR_LINE_TAKE_DOUBLE: //四带两对
				{
					//分析扑克
					var AnalyseResult:tagAnalyseResult=new tagAnalyseResult;
					AnalysebCardData(m_bTurnCardData, m_bTurnCardCount, AnalyseResult);
					if (WhichOnsKindCard == 1) //判断是不是具有唯一性
					{
						for (i=m_bTempFCardCount; i > 0; i--)
						{
							if (i - AnalyseResult.bFourCount * 4 >= 0 && CompareCard(Memory.CloneArray(m_bTempFCardData, i - AnalyseResult.bFourCount * 4), m_bTurnCardData, AnalyseResult.bFourCount * 4, AnalyseResult.bFourCount * 4))
							{
								if ((bWhichKindSel++) > 1)
									i=0;
							}
						}
					}
					for (i=m_bTempFCardCount; i > 0; i--)
					{
						if (i - AnalyseResult.bFourCount * 4 >= 0 && CompareCard(Memory.CloneArray(m_bTempFCardData, i - AnalyseResult.bFourCount * 4), m_bTurnCardData, AnalyseResult.bFourCount * 4, AnalyseResult.bFourCount * 4))
						{
							Memory.CopyArray(m_bTempGetCardData, Memory.CloneArray(m_bTempFCardData, i - AnalyseResult.bFourCount * 4), AnalyseResult.bFourCount * 4);
							m_bTempGetCardCount=AnalyseResult.bFourCount * 4;
							i=0;
						}
					}
					if (m_bTempGetCardCount > 0)
					{
						var m_bIsHaveSame:Boolean;
						for (m=0; m < AnalyseResult.bDoubleCount; m++)
						{
							for (j=0; j < m_bTempDCardCount / 2; j++)
							{
								//判断是不是最合理的
								m_bIsHaveSame=false;
								for (n=0; n < m_bTempGetCardCount; n++)
								{
									if (GetCardLogicValue(m_bTempDCardData[m_bTempDCardCount - j * 2 - 1]) == GetCardLogicValue(m_bTempGetCardData[n]))
									{
										m_bIsHaveSame=true;
									}
								}
								if (!m_bIsHaveSame)
								{
									var m_bIsHaveCard:Boolean=false;
									for (s=0; s < m_bTempTCardCount; s++)
									{
										for (n=0; n < m_bTempGetCardCount; n++)
										{
											if (GetCardLogicValue(m_bTempDCardData[m_bTempDCardCount - j * 2 - 1]) == GetCardLogicValue(m_bTempTCardData[s]))
												m_bIsHaveCard=true;
										}
									}
									if (m_bTempGetCardCount == AnalyseResult.bFourCount * 4 || !m_bIsHaveCard)
									{
										m_bTempGetCardData[AnalyseResult.bFourCount * 4 + m * 2]=m_bTempDCardData[m_bTempDCardCount - j * 2 - 1];
										m_bTempGetCardData[AnalyseResult.bFourCount * 4 + m * 2 + 1]=m_bTempDCardData[m_bTempDCardCount - j * 2 - 2];
										m_bTempGetCardCount=AnalyseResult.bFourCount * 4 + (m + 1) * 2;
									}
									if (!m_bIsHaveCard)
									{
										n=m_bTempGetCardCount;
										j=m_bTempDCardCount / 2;
									}
								}
							}
						}
						for (var m:int=0; m < AnalyseResult.bSignedCount; m++)
						{
							for (j=0; j < m_bTempSCardCount; j++)
							{
								//判断是不是最合理的
								m_bIsHaveSame=false;
								for (n=0; n < m_bTempGetCardCount; n++)
								{
									if (GetCardLogicValue(m_bTempSCardData[m_bTempSCardCount - j - 1]) == GetCardLogicValue(m_bTempGetCardData[n]))
									{
										m_bIsHaveSame=true;
									}
								}
								if (!m_bIsHaveSame)
								{
									var m_bIsHaveCard:Boolean=false;
									for (s=0; s < m_bTempDCardCount; s++)
									{
										for (n=0; n < m_bTempGetCardCount; n++)
										{
											if (GetCardLogicValue(m_bTempSCardData[m_bTempSCardCount - j - 1]) == GetCardLogicValue(m_bTempDCardData[j]))
												m_bIsHaveCard=true;
										}
									}
									if (m_bTempGetCardCount == AnalyseResult.bFourCount * 4 || !m_bIsHaveCard)
									{
										m_bTempGetCardData[AnalyseResult.bFourCount * 4 + m]=m_bTempSCardData[m_bTempSCardCount - j - 1];
										m_bTempGetCardCount=AnalyseResult.bFourCount * 4 + m + 1;
									}
									if (!m_bIsHaveCard)
									{
										n=m_bTempGetCardCount;
										j=m_bTempSCardCount;
									}
								}
							}
						}
					}
					break;
				}

			}
			if (m_bTempGetCardCount == 0)
			{
				bWhichKindSel=0;
				//判断炸弹的可能性
				if (m_bTempFCardCount > 3)
				{
					for (i=m_bTempFCardCount - 4; i >= 0; i--)
					{
						if (CompareCard(Memory.CloneArray(m_bTempFCardData, i), m_bTurnCardData, 4, m_bTurnCardCount))
						{
							if ((bWhichKindSel++) == 0)
							{
								Memory.CopyArray(m_bTempGetCardData, Memory.CloneArray(m_bTempFCardData, i), 4);
								m_bTempGetCardCount=4;
							}
						}
					}
				}
				if (m_bTempGetCardCount == 0)
				{
					if (m_bHandCardCount > 1)
					{
						if (m_bTempMissileCount>0)
						{
							Memory.CopyArray(m_bTempGetCardData, m_bTempMissileData, 2);
							m_bTempGetCardCount=2;
							if (WhichOnsKindCard == 1)
								bWhichKindSel=1;
						}
					}
				}
			}
			return m_bTempGetCardCount;
		}
	}
}