package chair
{
	public class MahjongTableCreator extends TableCreator
	{
		override protected function factoryMethod():ITableView
		{
			//trace("Creating product 1");	
			//return new Product2();	// returns concrete product
			//return null;
			
			return new MahjongTableView();
		}
	}
}