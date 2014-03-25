package  
{
	/**
	 * ...
	 * @author ...
	 */
	public class Mission 
	{
		
		//public static var missionDefinition;
		
		//The mission ID
		public var missionID : int;
		
		//Description shown to the user on the mission screen
		public var missionDescription : String;
		
		//How many stars this mission is worth
		public var starValue : int;
		
		//Over what period the player has to complete the missiong
		//0 = complete in a single game
		//1 = complete in a single level
		//2 = complete over several games
		public var persist : Boolean = false;
		
		//Which variable we are tracking (ie numDeaths, etc)
		public var trackingVariable : String;
		
		//For missions that last over multiple games, the progress so far for this mission
		public var progress : int = 0;
		
		//The goal value to complete this mission
		public var goal : int;
		
		//have to have completed the mission with ID of prereq in order to get htis mission
		public var prereq : int = -1;
		
		public var minRank : int = 1;
		
		public var completed : Boolean = false;
		
		public function Mission() 
		{
			
		}
		

	}

}