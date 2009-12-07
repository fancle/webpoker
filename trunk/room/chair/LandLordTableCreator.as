package chair
{
	public class LandLordTableCreator extends TableCreator
	{
		override protected function factoryMethod():ITableView
		{
			trace("Create Product 1");
			//return new Product1();	// returns concrete product
			//return null;
			
			return new LandLordTableView();
		}
	}
}