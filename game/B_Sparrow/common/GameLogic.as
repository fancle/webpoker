package B_Sparrow.common
{
	import Application.utils.Memory;
	
	//	游戏逻辑类
	public class GameLogic
	{
		public static var m_cbSparrowDataArray:Array;
		public function GameLogic()
		{
			if(m_cbSparrowDataArray)
			{
				m_cbSparrowDataArray = new Array(
				0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,	//万子
				0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,	//万子
				0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,	//万子
				0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,	//万子
				0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,	//索子
				0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,	//索子
				0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,	//索子
				0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,	//索子
				0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,	//同子
				0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,	//同子
				0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,	//同子
				0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,	//同子
				0x31,0x32,0x33,0x34,0x35,0x36,0x37,				//番子
				0x31,0x32,0x33,0x34,0x35,0x36,0x37,				//番子
				0x31,0x32,0x33,0x34,0x35,0x36,0x37,				//番子
				0x31,0x32,0x33,0x34,0x35,0x36,0x37				//番子
				);
			}
		}
		
		//删除麻将
		public function RemoveSparrow2(cbSparrowIndex:Array/*[MAX_INDEX]*/, cbRemoveSparrow:uint):Boolean
		{
			//效验麻将
		
			//删除麻将
			var cbRemoveIndex:uint=SwitchToSparrowIndex1(cbRemoveSparrow);
			if (cbSparrowIndex[cbRemoveIndex]>0)
			{
				cbSparrowIndex[cbRemoveIndex]--;
				return true;
			}
			//失败效验
			return false;
		}
		/**
		 * 删除麻将--从cbSparrowIndex中移除麻将
		 * @param cbSparrowIndex
		 * @param cbRemoveSparrow
		 * @param cbRemoveCount
		 * @return 
		 * 
		 */
		public function RemoveSparrow3(cbSparrowIndex:Array/*[MAX_INDEX]*/,cbRemoveSparrow:Array, cbRemoveCount:uint):Boolean
		{
			//删除麻将
			for (var i:uint=0;i<cbRemoveCount;i++)
			{
				//效验麻将
				Memory.ASSERT(IsValidSparrow(cbRemoveSparrow[i]));
				Memory.ASSERT(cbSparrowIndex[SwitchToSparrowIndex1(cbRemoveSparrow[i])]>0);
		
				//删除麻将
				var cbRemoveIndex:uint=SwitchToSparrowIndex1(cbRemoveSparrow[i]);
				if (cbSparrowIndex[cbRemoveIndex]==0)
				{
					//错误断言
					Memory.ASSERT(false);
		
					//还原删除
					for (var j:uint=0;j<i;j++) 
					{
						Memory.ASSERT(IsValidSparrow(cbRemoveSparrow[j]));
						cbSparrowIndex[SwitchToSparrowIndex1(cbRemoveSparrow[j])]++;
					}
		
					return false;
				}
				else 
				{
					//删除麻将
					--cbSparrowIndex[cbRemoveIndex];
				}
			}
		
			return true;
		}
		/**
		 * 删除麻将---如：手中有1万2万，自己有个吃3万的操作，则返回一个1万2万的数组在下步的时候从手牌中删除
		 * @param cbSparrowData
		 * @param cbSparrowCount
		 * @param cbRemoveSparrow
		 * @param cbRemoveCount
		 * @return 
		 * 
		 */
		public function RemoveSparrow4(cbSparrowData:Array, cbSparrowCount:uint, cbRemoveSparrow:Array, cbRemoveCount:uint):Boolean
		{
			//检验数据
			Memory.ASSERT(cbSparrowCount<=14);
			Memory.ASSERT(cbRemoveCount<=cbSparrowCount);
		
			//定义变量
			var cbDeleteCount:uint=0;
			var cbTempSparrowData:Array = new Array(14);
			if (cbSparrowCount>Memory.CountArray(cbTempSparrowData)) return false;
			Memory.CopyArray(cbTempSparrowData,cbSparrowData,cbSparrowCount);
		
			//置零麻将
			for (var i:uint=0;i<cbRemoveCount;i++)
			{
				for (var j:uint=0;j<cbSparrowCount;j++)
				{
					if (cbRemoveSparrow[i]==cbTempSparrowData[j])
					{
						cbDeleteCount++;
						cbTempSparrowData[j]=0;
						break;
					}
				}
			}
		
			//成功判断
			if (cbDeleteCount!=cbRemoveCount) 
			{
				Memory.ASSERT(false);
				return false;
			}
		
			//清理麻将
			var cbSparrowPos:uint=0;
			for (var i:uint=0;i<cbSparrowCount;i++)
			{
				if (cbTempSparrowData[i]!=0) cbSparrowData[cbSparrowPos++]=cbTempSparrowData[i];
			}
		
			return true;
		}
		
		//麻将转换
		public function SwitchToSparrowData1(cbSparrowIndex:uint):uint
		{
			Memory.ASSERT(cbSparrowIndex < 34 );
			return ((cbSparrowIndex/9)<<4)|(cbSparrowIndex%9+1);
		}
		
		//麻将转换
		public function SwitchToSparrowIndex1(cbSparrowData:uint):uint
		{
			Memory.ASSERT(IsValidSparrow(cbSparrowData));
			return ((cbSparrowData&GameLogicDef.MASK_COLOR)>>4)*9+(cbSparrowData&GameLogicDef.MASK_VALUE)-1;
		}
		
		//麻将转换
		public function SwitchToSparrowData2( cbSparrowIndex:Array/*[MAX_INDEX]*/,  cbSparrowData:Array/*[MAX_COUNT]*/):uint
		{
			//转换麻将
			var cbPosition:uint=0;
			for (var i:uint=0;i<GameLogicDef.MAX_INDEX;i++)
			{
				if (cbSparrowIndex[i]!=0)
				{
					for (var j:uint=0;j<cbSparrowIndex[i];j++)
					{
						Memory.ASSERT(cbPosition<GameLogicDef.MAX_COUNT);
						cbSparrowData[cbPosition++]=SwitchToSparrowData1(i);
					}
				}
			}
		
			return cbPosition;
		}
		
		//麻将转换
		public function SwitchToSparrowIndex3(cbSparrowData:Array,cbSparrowCount:uint, cbSparrowIndex:Array/*[MAX_INDEX]*/):uint
		{
			//设置变量
			Memory.ZeroArray(cbSparrowIndex);
			
			//转换麻将
			for(var i:uint = 0; i < cbSparrowCount; i++)
			{
				Memory.ASSERT(IsValidSparrow(cbSparrowData[i]));
				cbSparrowIndex[SwitchToSparrowIndex1(cbSparrowData[i])]++;
			}
			return cbSparrowCount;
		}
		
		//分析麻将
		public function AnalyseSparrow( cbSparrowIndex:Array,  WeaveItem:Array,  cbWeaveCount:uint, AnalyseItemArray:Array):Boolean
		{
			//计算数目
			var cbSparrowCount:uint=0;
			for (var i:uint=0;i<GameLogicDef.MAX_INDEX;i++) cbSparrowCount+=cbSparrowIndex[i];
			
			//效验数目
			Memory.ASSERT((cbSparrowCount>=2)&&(cbSparrowCount<=GameLogicDef.MAX_COUNT)&&((cbSparrowCount-2)%3==0));
			if ((cbSparrowCount<2)||(cbSparrowCount>GameLogicDef.MAX_COUNT)||((cbSparrowCount-2)%3!=0)) return false;
			
			//变量定义
			var cbKindItemCount:uint=0;
			var KindItem:Array = Memory.NewArray(GameLogicDef.MAX_COUNT-2,tagKindItem);
			
			//需求判断
			var cbLessKindItem:uint = (cbSparrowCount-2)/3;
			Memory.ASSERT((cbLessKindItem+cbWeaveCount)==4);
			
			//单吊判断
			if(cbLessKindItem==0)
			{
				//效验参数
				Memory.ASSERT((cbSparrowCount==2)&&(cbWeaveCount==4));
				
				//牌眼判断
				for(var i:uint = 0; i < GameLogicDef.MAX_INDEX; i++)
				{
					if(cbSparrowIndex[i]==2)
					{
						//变量定义
						var AnalyseItem:tagAnalyseItem = new tagAnalyseItem;
						
						//设置结果
						for(var j:uint = 0; j < cbWeaveCount; j++)
						{
							AnalyseItem.cbWeaveKind[j]=WeaveItem[j].cbWeaveKind;
							AnalyseItem.cbCenterCard[j]=(WeaveItem[i] as tagWeaveItem).cbCenterSparrow//WeaveItem[j].cbCenterSparrow;
						}
						
						AnalyseItem.cbCardEye = SwitchToSparrowData1(1);
						
						//插入结果
						AnalyseItemArray.push(AnalyseItem);
						
						return true;
					}	
				}
				return false;
			}
			
			//拆分分析
			if(cbSparrowCount >= 3)
			{
				for(var i:uint = 0; i < GameLogicDef.MAX_INDEX; i++)
				{
					//同牌判断
					if (cbSparrowIndex[i]>=3)
					{
						KindItem[cbKindItemCount].cbCenterSparrow=i;
						KindItem[cbKindItemCount].cbSparrowIndex[0]=i;
						KindItem[cbKindItemCount].cbSparrowIndex[1]=i;
						KindItem[cbKindItemCount].cbSparrowIndex[2]=i;
						KindItem[cbKindItemCount++].cbWeaveKind=GameLogicDef.WIK_PENG;
					}
					
					//连牌判断
					if((i<(GameLogicDef.MAX_INDEX-2))&&(cbSparrowIndex[i]>0)&&((i%9)<7))
					{
						for(var j:uint=1;j<=cbSparrowIndex[i];j++)
						{
							if ((cbSparrowIndex[i+1]>=j)&&(cbSparrowIndex[i+2]>=j))
							{
								KindItem[cbKindItemCount].cbCenterSparrow=i;
								KindItem[cbKindItemCount].cbSparrowIndex[0]=i;
								KindItem[cbKindItemCount].cbSparrowIndex[1]=i+1;
								KindItem[cbKindItemCount].cbSparrowIndex[2]=i+2;
								KindItem[cbKindItemCount++].cbWeaveKind=GameLogicDef.WIK_LEFT;	
							}
						}
					}
				}	
			}
				
				
			//组合分析
			if (cbKindItemCount>=cbLessKindItem)
			{
				var i:uint = 0;
				//变量定义
				var cbSparrowIndexTemp:Array = new Array(GameLogicDef.MAX_INDEX);
				Memory.ZeroArray(cbSparrowIndexTemp);
		
				//变量定义
				var cbIndex:Array=new Array(0,1,2,3);
				var pKindItem:Array = new Array(4);
				Memory.ZeroArray(pKindItem,null);
		
				//开始组合
				do
				{
					//设置变量
					Memory.CopyArray(cbSparrowIndexTemp,cbSparrowIndex,cbSparrowIndexTemp.length);
					for (i=0;i<cbLessKindItem;i++) pKindItem[i]=KindItem[cbIndex[i]];
		
					//数量判断
					var bEnoughSparrow:Boolean=true;
					for (i=0;i<cbLessKindItem*3;i++)
					{
						//存在判断
						cbSparrowIndex=pKindItem[i/3].cbSparrowIndex[i%3];
						if (cbSparrowIndexTemp[cbSparrowIndex]==0)
						{
							bEnoughSparrow=false;
							break;
						}
						else cbSparrowIndexTemp[cbSparrowIndex]--;
					}
		
					//胡牌判断
					if (bEnoughSparrow==true)
					{
						//牌眼判断
						var cbSparrowEye:uint=0;
						for (i=0;i<GameLogicDef.MAX_INDEX;i++)
						{
							if (cbSparrowIndexTemp[i]==2)
							{
								cbSparrowEye=SwitchToSparrowData1(i);
								break;
							}
						}
		
						//组合类型
						if (cbSparrowEye!=0)
						{
							//变量定义
							var AnalyseItem:tagAnalyseItem = new tagAnalyseItem;
						
							//设置组合
							for (i=0;i<cbWeaveCount;i++)
							{
								AnalyseItem.cbWeaveKind[i]=WeaveItem[i].cbWeaveKind;
								AnalyseItem.cbCenterCard[i]=WeaveItem[i].cbCenterCard;
							}
		
							//设置牌型
							for (i=0;i<cbLessKindItem;i++) 
							{
								AnalyseItem.cbWeaveKind[i+cbWeaveCount]=pKindItem[i].cbWeaveKind;
								AnalyseItem.cbCenterCard[i+cbWeaveCount]=pKindItem[i].cbCenterCard;
							}
		
							//设置牌眼
							AnalyseItem.cbCardEye=cbSparrowEye;
		
							//插入结果
							AnalyseItemArray.push(AnalyseItem);
						}
					}
		
					//设置索引
					if (cbIndex[cbLessKindItem-1]==(cbKindItemCount-1))
					{
						for (i=cbLessKindItem-1;i>0;i--)
						{
							if ((cbIndex[i-1]+1)!=cbIndex[i])
							{
								var cbNewIndex:uint=cbIndex[i-1];
								for (var j:uint=(i-1);j<cbLessKindItem;j++) cbIndex[j]=cbNewIndex+j-i+2;
								break;
							}
						}
						if (i==0) break;
					}
					else cbIndex[cbLessKindItem-1]++;
					
				} while (true);
			}
			return (AnalyseItemArray.length()>0);
		}

		//有效判断
		public function IsValidSparrow( cbSparrowData:uint):Boolean
		{
			var cbValue:uint = (cbSparrowData&GameLogicDef.MASK_VALUE);
			var cbColor:uint = (cbSparrowData&GameLogicDef.MASK_COLOR)>>4;
			return (((cbValue>=1)&&(cbValue<=9)&&(cbColor<=2))||((cbValue>=1)&&(cbValue<=7)&&(cbColor==3)));
		}
		
		//麻将数目
		public function GetSparrowCount(cbSparrowIndex:Array/*[MAX_INDEX]*/):uint
		{
			//统计数目
			var cbSparrowCount:uint = 0;
			for(var i:uint=0;i<GameLogicDef.MAX_INDEX;i++) cbSparrowCount+=cbSparrowIndex[i];
			
			return cbSparrowCount;
		}
		
		//获取组合
		public function GetWeaveSparrow( cbWeaveKind:uint, cbCenterSparrow:uint, cbSparrowBuffer:Array/*[4]*/):uint
		{
			//组合麻将
			switch(cbWeaveKind)
			{
				case GameLogicDef.WIK_LEFT:			//上牌操作
				{
					//设置变量
					cbSparrowBuffer[0]=cbCenterSparrow;
					cbSparrowBuffer[1]=cbCenterSparrow+1;
					cbSparrowBuffer[2]=cbCenterSparrow+2;					
					
					return 3;
				}
				case GameLogicDef.WIK_RIGHT:		//上牌操作
				{
					//设置变量
					cbSparrowBuffer[0]=cbCenterSparrow-2;
					cbSparrowBuffer[1]=cbCenterSparrow-1;
					cbSparrowBuffer[2]=cbCenterSparrow;
		
					return 3;
				}
				case GameLogicDef.WIK_CENTER:		//上牌操作
				{
					//设置变量
					cbSparrowBuffer[0]=cbCenterSparrow-1;
					cbSparrowBuffer[1]=cbCenterSparrow;
					cbSparrowBuffer[2]=cbCenterSparrow+1;
		
					return 3;
				}
				case GameLogicDef.WIK_PENG:			//碰牌操作
				{
					//设置变量
					cbSparrowBuffer[0]=cbCenterSparrow;
					cbSparrowBuffer[1]=cbCenterSparrow;
					cbSparrowBuffer[2]=cbCenterSparrow;
					
					return 3;
				}
				case GameLogicDef.WIK_FILL:			//补牌操作
				{
					//设置变量
					cbSparrowBuffer[0]=cbCenterSparrow;
					cbSparrowBuffer[1]=cbCenterSparrow;
					cbSparrowBuffer[2]=cbCenterSparrow;
					cbSparrowBuffer[3]=cbCenterSparrow;
					
					return 4;	
				}
				case GameLogicDef.WIK_GANG:			//杠牌操作
				{
					//设置变量
					cbSparrowBuffer[0]=cbCenterSparrow;
					cbSparrowBuffer[1]=cbCenterSparrow;
					cbSparrowBuffer[2]=cbCenterSparrow;
					cbSparrowBuffer[3]=cbCenterSparrow;
					
					return 4;
				}
				default:
				{
					Memory.ASSERT(false);
				}
			}
			
			return 0;
		}
		
		//动作等级
		public function GetUserActionRank(cbUserAction:uint):uint
		{
			//胡牌等级
			if (cbUserAction&GameLogicDef.WIK_CHI_HU) { return 4; }
			
			//杠牌等级
			if (cbUserAction&(GameLogicDef.WIK_FILL|GameLogicDef.WIK_GANG)) { return 3; }
		
			//碰牌等级
			if (cbUserAction&GameLogicDef.WIK_PENG) { return 2; }
		
			//上牌等级
			if (cbUserAction&(GameLogicDef.WIK_RIGHT|GameLogicDef.WIK_CENTER|GameLogicDef.WIK_LEFT)) { return 1; }
			
			return 0;
		}
		
		//胡牌等级
		public function GetChiHuActionRank(ChiHuResult:tagChiHuResult):uint
		{
			//变量定义
			var cbChiHuOrder:uint=0;
			var wChiHuRight:uint=ChiHuResult.dwChiHuRight;
			var wChiHuKind:uint=(ChiHuResult.dwChiHuKind&0xFF00)>>4;
		
			//大胡升级
			for (var i:uint=0;i<8;i++)
			{
				wChiHuKind>>=1;
				if ((wChiHuKind&0x0001)!=0) cbChiHuOrder++;
			}
		
			//权位升级
			for ( i=0;i<16;i++)
			{
				wChiHuRight>>=1;
				if ((wChiHuRight&0x0001)!=0) cbChiHuOrder++;
			}
		
			return cbChiHuOrder;
		}
		///////////////////////////////////////////////////////////////////////////////////////////////////////////
		public function EstimateOperate(cbSparrowIndex:Array,cbCurrentSparrow:uint):uint
		{
			var operateCode:uint = GameLogicDef.WIK_NULL;
			
			//判断吃
			operateCode |= EstimateEatSparrow(cbSparrowIndex,cbCurrentSparrow);
			//判断杠
			operateCode |= EstimateGangSparrow(cbSparrowIndex,cbCurrentSparrow);
			//判断碰
			operateCode |= EstimatePengSparrow(cbSparrowIndex,cbCurrentSparrow);
			//判断胡
			operateCode |= EstimateChiHu(cbSparrowIndex,cbCurrentSparrow);
			
			return operateCode;
		}
		/**
		 * 普通胡牌----排过序的牌
		 * @param cbSparrowData
		 * @param isJiang
		 * @return 
		 * 
		 */
		public function normalChiHu (cbSparrowData:Array,isJiang:Boolean):uint
		{ 
			if(cbSparrowData.length==0)return GameLogicDef.WIK_CHI_HU;
			
			for(var i:int=0;i<cbSparrowData.length-1;i++)
			{
			   //如果是顺子
			   if((cbSparrowData[i]<0x30)&&(i==1)&&(cbSparrowData[i]==(cbSparrowData[i-1]+1))&&(cbSparrowData[i]==(cbSparrowData[i+1]-1))) 
			   {
			    if(this.normalChiHu(cbSparrowData.slice(i+2),isJiang))
			    {
			     return GameLogicDef.WIK_CHI_HU;
			    }
			    
			    break;
			   }
			   //比如：1万2万2万3万---这种情况然后从中提取一个顺子继续递归
			   if((cbSparrowData[i]<0x30)&&(i==1)&&(cbSparrowData[i]==(cbSparrowData[i-1]+1))&&(cbSparrowData[i]==cbSparrowData[i+1])&&(cbSparrowData[i]==(cbSparrowData[i+2]-1))) 
			   {
			    var arr1:Array =cbSparrowData.slice(i+3);
			    arr1.unshift(cbSparrowData[i]);
			    if(this.normalChiHu(arr1,isJiang))
			    {
			     return GameLogicDef.WIK_CHI_HU;
			    }
			    break;
			   }
			   //比如：1万2万2万2万3万---提一个顺子后继续
			   if((cbSparrowData[i]<0x30)&&(i==1)&&(cbSparrowData[i]==(cbSparrowData[i-1]+1))&&(cbSparrowData[i]==cbSparrowData[i+1])&&(cbSparrowData[i]==cbSparrowData[i+2])&&(cbSparrowData[i]==(cbSparrowData[i+3]-1))) 
			   {
			    var arr2:Array = cbSparrowData.slice(i+4);
			    arr2.unshift(cbSparrowData[i],cbSparrowData[i]);
			   
			    if(this.normalChiHu(arr2,isJiang))
			    {
			     return GameLogicDef.WIK_CHI_HU;
			    }
			    break;
			   }
			   //比如：1万2万2万2万2万3万---提一个顺子后继续
			   if((cbSparrowData[i]<0x30)&&(i==1)&&(cbSparrowData[i]==(cbSparrowData[i-1]+1))&&(cbSparrowData[i]==cbSparrowData[i+1])&&(cbSparrowData[i]==cbSparrowData[i+2])&&(cbSparrowData[i]==cbSparrowData[i+3])&&(cbSparrowData[i]==(cbSparrowData[i+4]-1))) 
			   {
			    var arr3:Array = cbSparrowData.slice(i+5);
			    arr3.unshift(cbSparrowData[i],cbSparrowData[i],cbSparrowData[i]);
			    if(this.normalChiHu(arr3,isJiang))
			    {
			     return GameLogicDef.WIK_CHI_HU;
			    }
			    break;
			   }
			   
				//如果是刻子
			   if((i==0)&&(cbSparrowData[i]==cbSparrowData[i+1])&&(cbSparrowData[i]==cbSparrowData[i+2]))
			   {
			    if(this.normalChiHu(cbSparrowData.slice(i+3),isJiang))
			    {
			     return GameLogicDef.WIK_CHI_HU;
			    }
			   }
			   //判断将
			   if((i==0)&&(cbSparrowData[i]==cbSparrowData[i+1])&&(isJiang==false))
			   {
			    if(this.normalChiHu(cbSparrowData.slice(i+2),true))
			    {
			     return GameLogicDef.WIK_CHI_HU;
			    }
			   }
			   //比如：1万1万2万2万3万3万
			   if((i==0)&&(cbSparrowData[0]==cbSparrowData[1])&&(cbSparrowData[2]==cbSparrowData[1]+1)&&(cbSparrowData[2]==cbSparrowData[3])&&(cbSparrowData[4]==cbSparrowData[3]+1)&&(cbSparrowData[4]==cbSparrowData[5]))
			   {
			    if(this.normalChiHu(cbSparrowData.slice(6),isJiang))
			    {
			     return GameLogicDef.WIK_CHI_HU;
			    }
			   }
			
			   if(i>1)break;
			}
			return GameLogicDef.WIK_NULL;
		}
		/**
		 * 判断是否七小对胡牌
		 * @param cbSparrowData
		 * @return WORD
		 * 
		 */
		public function EstimateQiXiaoDuiHu(cbSparrowData:Array):uint
		{
			if(cbSparrowData.length==0)return GameLogicDef.WIK_CHI_HU;
			
			if((cbSparrowData[0]==cbSparrowData[1])){
				if(this.EstimateQiXiaoDuiHu(cbSparrowData.slice(2)))
			    {
			     return GameLogicDef.WIK_CHI_HU;
			    }
			}
			
			return GameLogicDef.WIK_NULL;
		}
		/**
		 * 判断是否十三幺胡牌
		 * @param cbSparrowData
		 * @param jiang
		 * @return WORD
		 * 
		 */
		public function EstimateShiSanYaoHu(cbSparrowData:Array,jiang:Boolean):uint
		{
			if(cbSparrowData.length==0)return GameLogicDef.WIK_CHI_HU;
			
			var isValidData:Boolean = cbSparrowData[0]>0x30||(cbSparrowData[0]&GameLogicDef.MASK_VALUE)==9||(cbSparrowData[0]&GameLogicDef.MASK_VALUE)==1;
			
			if(isValidData&&cbSparrowData[0]==cbSparrowData[1]&&jiang == false){
				if(this.EstimateShiSanYaoHu(cbSparrowData.slice(1),true))
			    {
			     return GameLogicDef.WIK_CHI_HU;
			    }
			}
			
			if(isValidData&&cbSparrowData[0]!=cbSparrowData[1]){
				if(this.EstimateShiSanYaoHu(cbSparrowData.slice(1),jiang))
			    {
			     return GameLogicDef.WIK_CHI_HU;
			    }
			}						
			
			return GameLogicDef.WIK_NULL;
		}
		public function EstimateChiHu(cbSparrowIndex:Array,cbCurrentSparrow:uint = 0):uint
		{
			var cbSparrowData:Array = new Array;
			var cbSparrowIndex1:Array = Memory.CloneArray(cbSparrowIndex,0);
			if(cbCurrentSparrow!=0){
				++cbSparrowIndex1[SwitchToSparrowIndex1(cbCurrentSparrow)];
			}			
			SwitchToSparrowData2(cbSparrowIndex1,cbSparrowData);
			
			var operateCode:uint = GameLogicDef.WIK_NULL;
			
			if(cbSparrowData.length==14){
				operateCode |= EstimateQiXiaoDuiHu(cbSparrowData);
				operateCode |= EstimateShiSanYaoHu(cbSparrowData,false);
			}			
			if((cbSparrowData.length-2)%3!=0)
				return operateCode;
			operateCode |= normalChiHu(cbSparrowData,false);
			
			
			return operateCode;
		}
		//吃胡判断2
		public function EstimateChiHu2(cbSparrowData:Array):uint
		{
			var operateCode:uint = GameLogicDef.WIK_NULL;
			
			if(cbSparrowData.length==14){
				operateCode |= EstimateQiXiaoDuiHu(cbSparrowData);
				operateCode |= EstimateShiSanYaoHu(cbSparrowData,false);
			}			
			if((cbSparrowData.length-2)%3!=0)
				return operateCode;
			operateCode |= normalChiHu(cbSparrowData,false);
			
			
			return operateCode;
		}	 
		//吃胡判断
		public function EstimateChiHu1( cbSparrowIndex:Array/*[MAX_INDEX])*/):uint
		{
			//变量定义
			var cbActionMask:uint = GameLogicDef.WIK_NULL; 	
			
			//特殊胡牌
			if (IsSiXi(cbSparrowIndex)==true) cbActionMask|=GameLogicDef.WIK_CHI_HU;
			else if (IsBanBanHu(cbSparrowIndex)==true) cbActionMask|=GameLogicDef.WIK_CHI_HU;
			else if (IsLiuLiuShun(cbSparrowIndex)==true) cbActionMask|=GameLogicDef.WIK_CHI_HU;
			
			return cbActionMask;
		}	 
		
		//吃牌判断
		public function EstimateEatSparrow(cbSparrowIndex:Array,cbCurrentSparrow:uint):uint
		{
			//参数效验
			Memory.ASSERT(IsValidSparrow(cbCurrentSparrow));
			
			//过滤判断
			if (cbCurrentSparrow>=0x30) return GameLogicDef.WIK_NULL;
			
			//变量定义
			var cbExcursion:Array=new Array(0,1,2);
			var cbItemKind:Array=new Array(GameLogicDef.WIK_LEFT,GameLogicDef.WIK_CENTER,GameLogicDef.WIK_RIGHT);
			
			//吃牌判断
			var cbEatKind:uint=0;
			var cbFirstIndex:uint=0;
			var cbCurrentIndex:uint=SwitchToSparrowIndex1(cbCurrentSparrow);
			var cbValueIndex:uint=cbCurrentIndex%9;
			
			for (var i:uint=0;i<Memory.CountArray(cbItemKind);i++)
			{
				if ((cbValueIndex>=cbExcursion[i])&&((cbValueIndex-cbExcursion[i])<=6))
				{
					//吃牌判断
					cbFirstIndex=cbCurrentIndex-cbExcursion[i];
					if ((cbCurrentIndex!=cbFirstIndex)&&(cbSparrowIndex[cbFirstIndex]==0)) continue;
					if ((cbCurrentIndex!=(cbFirstIndex+1))&&(cbSparrowIndex[cbFirstIndex+1]==0)) continue;
					if ((cbCurrentIndex!=(cbFirstIndex+2))&&(cbSparrowIndex[cbFirstIndex+2]==0)) continue;
		
					//设置类型
					cbEatKind|=cbItemKind[i];
				}
			}
			return cbEatKind;
		}
		
		
		//碰牌判断
		public function EstimatePengSparrow( cbSparrowIndex:Array/*[MAX_INDEX]*/, cbCurrentSparrow:uint):uint
		{
			//参数效验
			Memory.ASSERT(IsValidSparrow(cbCurrentSparrow));
		
			//碰牌判断
			return (cbSparrowIndex[SwitchToSparrowIndex1(cbCurrentSparrow)]>=2)?GameLogicDef.WIK_PENG:GameLogicDef.WIK_NULL;
		}
		
		//杠牌判断
		/**
		 * 手中牌中有一个刻子
		 * @param cbSparrowIndex
		 * @param cbCurrentSparrow
		 * @return 
		 * 
		 */
		public function EstimateGangSparrow(cbSparrowIndex:Array/*[MAX_INDEX]*/, cbCurrentSparrow:uint):uint
		{
			//参数效验
			Memory.ASSERT(IsValidSparrow(cbCurrentSparrow));
		
			//杠牌判断
			return (cbSparrowIndex[SwitchToSparrowIndex1(cbCurrentSparrow)]==3)?(GameLogicDef.WIK_GANG|GameLogicDef.WIK_FILL):GameLogicDef.WIK_NULL;
		}
		/**
		 * 组合牌中已经有一个刻子
		 * @param WeaveItem
		 * @param cbWeaveCount
		 * @param cbCurrentSparrow
		 * @return 
		 * 
		 */
		public function EstimateGangSparrow2(WeaveItem:Array, cbWeaveCount:uint,cbCurrentSparrow:uint):uint
		{
			var weaveItm:tagWeaveItem;
			
			for(var i:int = 0; i<cbWeaveCount; i++){
				weaveItm = WeaveItem[i] as tagWeaveItem
				if((weaveItm.cbWeaveKind&GameLogicDef.WIK_PENG)!=0&&weaveItm.cbCenterSparrow == cbCurrentSparrow){
					return GameLogicDef.WIK_GANG;
				}
			}
			
			return GameLogicDef.WIK_NULL;
		} 
		
		//听牌判断
		public function EstimateListenSparrow(cbSparrowIndex:Array,cbCurrentSparrow:uint,arrResult:Array):uint
		{
			var cbSparrowData:Array = new Array;
			var cbSparrowIndex1:Array = Memory.CloneArray(cbSparrowIndex,0);
			if(cbCurrentSparrow!=0){
				++cbSparrowIndex1[SwitchToSparrowIndex1(cbCurrentSparrow)];
			}			
						
			for(var i:int = 0; i<GameLogicDef.MAX_INDEX; i++){
				if(cbSparrowIndex1[i]==0) continue;
				
				--cbSparrowIndex1[i];
				
				for(var j:int = 0; j<GameLogicDef.MAX_INDEX; j++){
					if(cbSparrowIndex1[j]==4) continue;
					
					++cbSparrowIndex1[j];
					if(EstimateChiHu(cbSparrowIndex1)==GameLogicDef.WIK_CHI_HU){
						if(arrResult.indexOf(i)==-1) 
							arrResult.push(SwitchToSparrowData1(i));						
					}
					--cbSparrowIndex1[j];
				}	
				
				++cbSparrowIndex1[i];
			}
						
			if(arrResult.length>0)
				return GameLogicDef.WIK_LISTEN;
			return GameLogicDef.WIK_NULL;
		}
		///////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		//杠牌分析
		/**
		 * 暗杠分析
		 * @param cbSparrowIndex
		 * @param WeaveItem
		 * @param cbWeaveCount
		 * @param GangSparrowResult
		 * @return 
		 * 
		 */
		public function AnalyseGangSparrow(cbSparrowIndex:Array/*[MAX_INDEX]*/, 
		 WeaveItem:Array, cbWeaveCount:uint, 
		 GangSparrowResult:tagGangCardResult):uint
		 {
		 	//设置变量
		 	var cbActionMask:uint=GameLogicDef.WIK_NULL;
		 	
		 	//手上杠牌
		 	for(var i:uint = 0;i < GameLogicDef.MAX_INDEX;i++)
		 	{
		 		if(cbSparrowIndex[i]==4)
		 		{
		 			cbActionMask|=(GameLogicDef.WIK_GANG|GameLogicDef.WIK_FILL);
					GangSparrowResult.cbGangType[GangSparrowResult.cbCardCount]=cbActionMask;
					GangSparrowResult.cbCardData[GangSparrowResult.cbCardCount++]=SwitchToSparrowData1(i);
					cbActionMask = GameLogicDef.WIK_NULL;
		 		}	
		 	}
		 	return 0;
		 }
		
		/* =====================================以下暂不用===================================================== */
		//吃胡分析
		public function AnalyseChiHuSparrow(cbSparrowIndex:Array/*[MAX_INDEX]*/,
		  WeaveItem:Array, cbWeaveCount:uint, cbCurrentSparrow:uint, wChiHuRight:uint,
		 ChiHuResult:tagChiHuResult):uint
		{
			//变量定义
			var wChiHuKind:uint=GameLogicDef.CHK_NULL;
			var AnalyseItemArray:Array = new Array;
			
			//构造函数
			var cbSparrowIndexTemp:Array = new Array(GameLogicDef.MAX_INDEX);
			Memory.CopyArray(cbSparrowIndexTemp,cbSparrowIndex,cbSparrowIndexTemp.length);
			
			//插入麻将
			if (cbCurrentSparrow!=0) cbSparrowIndexTemp[SwitchToSparrowIndex1(cbCurrentSparrow)]++;
			
			//权位处理
			if ((cbCurrentSparrow!=0)&&(cbWeaveCount==4)) wChiHuRight|=GameLogicDef.CHR_QUAN_QIU_REN;
			if (IsQingYiSe(cbSparrowIndexTemp,WeaveItem,cbWeaveCount)==true) wChiHuRight|=GameLogicDef.CHR_QING_YI_SE;
			
			//牌型判断
			if (IsQiXiaoDui(cbSparrowIndexTemp,WeaveItem,cbWeaveCount)==true) wChiHuKind|=GameLogicDef.CHK_QI_XIAO_DUI;
//			if (IsHaoHuaDui(cbSparrowIndexTemp,WeaveItem,cbWeaveCount)==true) wChiHuKind|=GameLogicDef.CHK_HAO_HUA_DUI;
//			if (IsJiangJiangHu(cbSparrowIndexTemp,WeaveItem,cbWeaveCount)==true) wChiHuKind|=GameLogicDef.CHK_JIANG_JIANG;
			
			//分析麻将
			AnalyseSparrow(cbSparrowIndexTemp,WeaveItem,cbWeaveCount,AnalyseItemArray);
		
			//胡牌分析
			if (AnalyseItemArray.GetCount()>0)
			{
				//眼牌需求
				var bNeedSymbol:Boolean=((wChiHuRight&0xFF00)==0);
		
				//牌型分析
				for (var i:uint=0;i<AnalyseItemArray.length;i++)
				{
					//变量定义
					var bLianSparrow:Boolean=false;
					var bPengSparrow:Boolean=false;
					var pAnalyseItem:tagAnalyseItem=AnalyseItemArray[i];
		
					//牌眼类型
					var cbEyeValue:uint=pAnalyseItem.cbCardEye&GameLogicDef.MASK_VALUE;
					var bSymbolEye:Boolean=true;//((cbEyeValue==2)||(cbEyeValue==5)||(cbEyeValue==8));
		
					//牌型分析
					for (var j:uint=0;j<Memory.CountArray(pAnalyseItem.cbWeaveKind);j++)
					{
						var cbWeaveKind:uint=pAnalyseItem.cbWeaveKind[j];
						bPengSparrow=((cbWeaveKind&(GameLogicDef.WIK_GANG|GameLogicDef.WIK_FILL|GameLogicDef.WIK_PENG))!=0)?true:bPengSparrow;
						bLianSparrow=((cbWeaveKind&(GameLogicDef.WIK_LEFT|GameLogicDef.WIK_CENTER|GameLogicDef.WIK_RIGHT))!=0)?true:bLianSparrow;
					}
		
					//牌型判断
					Memory.ASSERT((bLianSparrow==true)||(bPengSparrow==true));
		
					//碰碰牌型
					if ((bLianSparrow==false)&&(bPengSparrow==true)) wChiHuKind|=GameLogicDef.CHK_PENG_PENG;
					if ((bLianSparrow==true)&&(bPengSparrow==true)&&((bSymbolEye==true)||(bNeedSymbol==false))) wChiHuKind|=GameLogicDef.CHK_JI_HU;
					if ((bLianSparrow==true)&&(bPengSparrow==false)&&((bSymbolEye==true)||(bNeedSymbol==false))) wChiHuKind|=GameLogicDef.CHK_PING_HU;
				}
			}
		
			//结果判断
			if (wChiHuKind!=GameLogicDef.CHK_NULL)
			{
				//设置结果
				ChiHuResult.dwChiHuKind=wChiHuKind;
				ChiHuResult.dwChiHuRight=wChiHuRight;
		
				return GameLogicDef.WIK_CHI_HU;
			}
		
			return GameLogicDef.WIK_NULL;
		}
		
		//四喜胡牌
		public function IsSiXi(cbSparrowIndex:Array/*[MAX_INDEX]*/):Boolean
		{
			//胡牌判断
			for (var i:uint=0;i<GameLogicDef.MAX_INDEX;i++)
			{
				if (cbSparrowIndex[i]==4) return true;
			}
		
			return false;
		}
		
		//缺一色牌
		public function IsQueYiSe(cbSparrowIndex:Array/*[MAX_INDEX]*/):Boolean
		{
			//胡牌判断
			var cbIndex:Array=new Array(0,9,18);
			var i:uint = 0;
			var j:uint = 0;
			for (i=0;i<Memory.CountArray(cbIndex);i++)
			{
				for (j=cbIndex[i];j<(cbIndex[i]+9);j++)
				{
					if (cbSparrowIndex[j]!=0) break;
				}
				if (j==(cbIndex[i]+9)) return true;
			}
		
			return false;
		}
		
		//板板胡牌
		public function IsBanBanHu(cbSparrowIndex:Array/*[MAX_INDEX]*/):Boolean
		{
			//胡牌判断
			for (var i:uint=1;i<GameLogicDef.MAX_INDEX;i+=3) if (cbSparrowIndex[i]!=0) return false;
		
			return true;
		}
		
		//六六顺牌
		public function IsLiuLiuShun(cbSparrowIndex:Array/*[MAX_INDEX]*/):Boolean
		{
			//胡牌判断
			var cbPengCount:uint=0;
			for (var i:uint=0;i<GameLogicDef.MAX_INDEX;i++)
			{
				if ((cbSparrowIndex[i]>=3)&&(++cbPengCount>=2)) return true;
			}
		
			return false;
		}
		
		//清一色牌
		public function IsQingYiSe(cbSparrowIndex:Array/*[MAX_INDEX]*/,  WeaveItem:Array,  cbItemCount:uint):Boolean
		{
			//胡牌判断
			var cbSparrowColor:uint = 0xFF;
			for(var i:uint = 0; i <GameLogicDef.MAX_INDEX; i++)
			{
				if (cbSparrowIndex[i]!=0)
				{
					//花色判断
					if (cbSparrowColor!=0xFF) return false;
		
					//设置花色
					cbSparrowColor=(SwitchToSparrowData1(i)&GameLogicDef.MASK_COLOR);
		
					//设置索引
					i=(i/9+1)*9;
				}
			}
			
			//组合判断
			for(i = 0; i < cbItemCount;i++)
			{
				var cbCenterSparrow:uint = WeaveItem[i].cbCenterSparrow;
				if((cbCenterSparrow&GameLogicDef.MASK_COLOR)!=cbSparrowColor) return false;
			}
			return true;
		}
		
		//七小对牌
		public function IsQiXiaoDui( cbSparrowIndex:Array/*[MAX_INDEX]*/,  WeaveItem:Array,  cbWeaveCount:uint):Boolean
		{
			//组合判断
			if (cbWeaveCount!=0) return false;
			
			//麻将判断
			for (var i:uint=0;i<GameLogicDef.MAX_INDEX;i++)
			{
				var cbSparrowCount:uint=cbSparrowIndex[i];
				if ((cbSparrowCount!=0)&&(cbSparrowCount!=2)&&(cbSparrowCount!=4)) return false;
			}
		
			return true;
		}
		
		//豪华对牌
		public function IsHaoHuaDui( cbSparrowIndex:Array/*[MAX_INDEX]*/,  WeaveItem:Array,  cbItemCount:uint):Boolean
		{
			//变量定义
			var bFourSparrow:Boolean=false;
		
			//组合判断
			for (var i:uint=0;i<cbItemCount;i++)
			{
				//杆补判断
				//if (WeaveItem[i].cbWeaveKind!=WIK_FILL) return false;
				if((WeaveItem[i] as tagWeaveItem).cbWeaveKind != GameLogicDef.WIK_FILL)	return false;
				if((WeaveItem[i] as tagWeaveItem).cbWeaveKind != GameLogicDef.WIK_GANG)	return false;
				//if (WeaveItem[i].cbWeaveKind!=WIK_GANG) return false;
		
				//设置变量
				bFourSparrow=true;
			}
		
			//麻将判断
			for (var i:uint=0;i<GameLogicDef.MAX_INDEX;i++)
			{
				//四牌判断
				if (cbSparrowIndex[i]==4)
				{
					bFourSparrow=true;
					continue;
				}
		
				//对牌判断
				if ((cbSparrowIndex[i]!=0)&&(cbSparrowIndex[i]!=2)) return false;
			}
		
			//结果判断
			if (bFourSparrow==false) return false;
		
			return true;
		}
		
		
		//将将胡牌
		public function IsJiangJiangHu( cbSparrowIndex:Array/*[MAX_INDEX]*/,  WeaveItem:Array,  cbWeaveCount:uint):Boolean
		{
			//组合判断
			for (var i:uint=0;i<cbWeaveCount;i++)
			{
				//类型判断
				var cbWeaveKind:uint=(WeaveItem[i] as tagWeaveItem).cbWeaveKind;
				if ((cbWeaveKind!=GameLogicDef.WIK_PENG)&&(cbWeaveKind!=GameLogicDef.WIK_GANG)&&(cbWeaveKind!=GameLogicDef.WIK_FILL)) return false;
		
				//数值判断
				var cbCenterValue:uint=(WeaveItem[i].cbCenterSparrow&GameLogicDef.MASK_VALUE);
				if ((cbCenterValue!=2)&&(cbCenterValue!=5)&&(cbCenterValue!=8)) return false;
			}
		
			//麻将判断
			for ( i=0;i<GameLogicDef.MAX_INDEX;i++)
			{
				if ((i%3!=1)&&(cbSparrowIndex[i]!=0)) return false;
			}
		
			return true;
		}
		
		//计算番数
		public function GetHuCardScore(_cbHuTypeFlag:Array):int
		{
			var cbHuTypeFlag:Array = Memory.CloneArray(_cbHuTypeFlag,0);
			
			var iScoreReturn:int=0;
			for(var i:int=0;i<81;i++)
			{
				if(cbHuTypeFlag[i] >0 && cbHuTypeFlag[i]<81)
				{
					switch(i)
					{
					case 0:
					case 1:
					case 2:
					case 3:
					case 4:
					case 5:
					case 6:
					case 7:
					case 8:
					case 9:
					case 10:
					case 11:
					case 12:
						iScoreReturn=20;
						break;
					case 13:
					case 14:
					case 15:
						iScoreReturn+=0;
						break;
					case 16:
						iScoreReturn+=3;
						break;
					case 17:
					case 18:
						iScoreReturn+=2;
						break;
					case 19:
					case 20:
						iScoreReturn+=0;
						break;
					case 21:
						iScoreReturn+=7;
						break;
					case 22:
						iScoreReturn+=3;
						break;
					case 23:
					case 24:
					case 25:
					case 26:
						iScoreReturn+=0;
						break;
					case 27:
						iScoreReturn+=2;
						break;
					case 28:
					case 29:
					case 30:
						iScoreReturn+=0;
						break;
					case 31:
					case 32:
						iScoreReturn=+3;
						break;
					case 33:
					case 34:
					case 35:
					case 36:
						iScoreReturn+=0;
						break;
					case 37:
						iScoreReturn+=7;
						break;
					case 38:
					case 39:
						iScoreReturn+=0;
						break;
					case 40:
						iScoreReturn+=2;
						break;
					case 41:
					case 42:
						iScoreReturn+=0;
						break;
					case 43:
					case 44:
					case 45:
					case 46:
						iScoreReturn+=1;
						break;
					case 47:
					case 48:
						iScoreReturn+=2;
						break;
					case 49:
					case 50:
					case 51:
					case 52:
						iScoreReturn+=0;
						break;
					case 53:
						iScoreReturn+=2;
						break;
					case 54:
						iScoreReturn+=3;
						break;
					case 55:
					case 56:
					case 57:
						iScoreReturn+=0;
						break;
					case 58:
						iScoreReturn+=1;
						break;
					case 59:
					case 60:
						iScoreReturn+=0;
						break;
					case 61:
					case 62:
						iScoreReturn+=1;
						break;
					case 63:
					case 64:
					case 65:
					case 66:
						iScoreReturn+=0;
						break;
					case 67:
						iScoreReturn+=1;
						break;
					case 68:
					case 69:
					case 70:
					case 71:
					case 72:
					case 73:
					case 74:
					case 75:
					case 76:
					case 77:
					case 78:
						iScoreReturn+=0;
						break;
					case 79:
					case 80:
						iScoreReturn+=1;
						break;
					default:
						break;
					}
				}
		
			}
			if( iScoreReturn > 20 )
			{
				iScoreReturn = 20;
			}
			if( iScoreReturn == 0 )
			{
				iScoreReturn = 1;
			} 
			return iScoreReturn;
		}


	}
}