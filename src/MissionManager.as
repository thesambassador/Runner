package  
{
	import flash.utils.Dictionary;
	import org.flixel.FlxG;
	/**
	 * Class that manages and keeps track of missions, including saving/loading them into browser cache. 
	 * @author Sam Tregillus
	 * 
	 */
	public class MissionManager 
	{
		//[Embed(source = '../resources/missions_test.xml',  mimeType="application/octet-stream")]public static var missionXML:Class;
		[Embed(source = '../resources/missions.xml',  mimeType="application/octet-stream")]public static var missionXML:Class;
		[Embed(source = '../resources/ranks.xml',  mimeType="application/octet-stream")]public static var rankXML:Class;
		
		//dictionary of values that we want to track
		public static var trackingVariables : Dictionary;
		public static var missionManagerInstance : MissionManager;
		
		//array of all the potential missions, loaded when the game loads
		public var missionList : Array;
		
		//array of the 3 current active missions
		public var activeMissions : Array;
		
		//array of mission IDs that have been completed
		public var completedMissionIDs : Array;
		
		//Current rank of the player
		public var currentRank : int = 1;
		
		//Number of stars earned right now
		public var currentStars : int = 0;
		
		//nubmer of stars to next rank
		public var starsForNextRank : int = 3;
		
		public var rankNames : Array;
		public var rankStars : Array;
		
		public function MissionManager() 
		{
			trackingVariables = new Dictionary();
			LoadMissionList();
			LoadRankList();
			
			activeMissions = new Array();
			completedMissionIDs = new Array();
			LoadPlayerSave();
			
			missionManagerInstance = this;
		}
		
		/**
		 * Loads the full mission list (of all potential missions) from the embedded XML
		 */
		public function LoadMissionList() : void {
			missionList = new Array();
			var xml : XML = new XML(new missionXML);

			for (var pname : String in xml.MISSION) {
				var mission : Mission = new Mission();
				
				mission.missionID = xml.MISSION.ID[pname];
				mission.missionDescription = xml.MISSION.DESCRIPTION[pname];
				mission.starValue = xml.MISSION.STARVALUE[pname];
				mission.trackingVariable = xml.MISSION.TRACKVAR[pname];
				var persist : int = xml.MISSION.PERSIST[pname];
				mission.persist = persist == 1;
				mission.goal = xml.MISSION.GOAL[pname];
				mission.prereq = xml.MISSION.PREREQ[pname];
				mission.minRank = xml.MISSION.MINRANK[pname];
				
				missionList.push(mission);
			}
		}
		
		public function LoadRankList() : void {
			rankNames = new Array();
			rankStars = new Array();
			
			var xml : XML = new XML(new rankXML);
			
			for (var pname : String in xml.RANK) {
				rankNames.push(xml.RANK.NAME[pname]);
				rankStars.push(xml.RANK.STARS[pname]);
			}
		}
		
		/**
		 * Loads the player's saved settings.  If no settings exist, it initializes the player's missions, rank, and stats
		 */
		public function LoadPlayerSave() : void {
			var currentMissionIDs : Array = CommonConstants.SAVE.data.currentMissions;
			var currentProgress : Array = CommonConstants.SAVE.data.currentProgress;
			completedMissionIDs = CommonConstants.SAVE.data.completedMissions; //this should load the completed mission list in.
			currentRank = CommonConstants.SAVE.data.rank;
			currentStars = CommonConstants.SAVE.data.stars;
			starsForNextRank = rankStars[currentRank - 1];
			
			//currentMissionIDs will be null if no save has been set
			if (currentMissionIDs != null) {
				//first load the active missions.  Unless they player is almost done with all the missions, this should be length 3.  
				for (var i:int = 0; i < currentMissionIDs.length; i++) {
					var progress : int = currentProgress[i];
					var loadedMission : Mission = GetMissionByID(currentMissionIDs[i], progress);
					activeMissions.push(loadedMission);
				}
			}
			//if no missions from save, initialize with 3 random ones
			else {
				//if we're here, completedMissionIDs also will be null again, so initialize it
				completedMissionIDs = new Array();
				currentRank = 1;
				currentStars = 0;
				
				while(activeMissions.length < 3) {
					activeMissions.push(GetRandomMission());
				}
				
				
				
				//save the missions now
				SaveMissionStatus();
			}
			
		}
		
		/**
		 * 
		 * @param	id			ID of the mission
		 * @param	progress	Progress to initialize the mission, if progress is valid
		 */
		public function GetMissionByID(id : int, progress : int = 0) : Mission {
			var mission : Mission = new Mission();
			var missionTemplate : Mission = missionList[id];

			mission.missionID = missionTemplate.missionID;
			mission.persist = missionTemplate.persist;
			mission.starValue = missionTemplate.starValue;
			mission.missionDescription = missionTemplate.missionDescription;
			mission.trackingVariable = missionTemplate.trackingVariable;
			mission.goal = missionTemplate.goal;
			mission.prereq = missionTemplate.prereq;
			mission.minRank = missionTemplate.prereq;
			
			//only add progress if this is a persistant mission.  shouldn't really happen that this function is misused... but i guess just in case?
			if(mission.persist)
				mission.progress = progress;
				
			return mission;
		}
		
		//adds a tracking variable and value to the dictionary. if the key exists already, it adds the existing value and the input value
		public static function AddValue(key : String, value : int) : void{
			if (trackingVariables != null) {
				if (trackingVariables[key]) {
					trackingVariables[key] += value;
				}
				else {
					trackingVariables[key] = value;
				}
			}
		}
		
		public static function SetValue(key : String, value : int) : void{
			if (trackingVariables != null) {	
				trackingVariables[key] = value;
			}
		}
		
		public static function SetValueIfMax(key : String, value : int) : void {
			if (trackingVariables != null) {
				if (trackingVariables[key] < value) {
					trackingVariables[key] = value;
				}
			}
		}
		
		
		//check to see if the active missions are complete, based on the current values in trackingVariables
		public static function CheckIfMissionsComplete() : void {
			
			for each(var mission : Mission in missionManagerInstance.activeMissions) {
				if (mission.completed) continue;
				var varName : String = mission.trackingVariable;
				var varValue : int = trackingVariables[varName];

				//for persistent missions, we want to add to the progress and see if we've completed
				if (mission.persist) {
					mission.progress += varValue;
					if (mission.progress >= mission.goal) {
						mission.completed = true;
					}
				}
				//otherwise, we just check the variable and see if it matches the goal:
				else {
					if (varValue >= mission.goal) {
						mission.completed = true;
					}
				}
			}
			missionManagerInstance.SaveMissionStatus();
		}
		
		//gets a random mission from the mission list that hasn't been completed already.  
		//TODO: attempts to avoid 2 missions that track the same variable, and tries to only have 1 3-star mission at a time.
		public function GetRandomMission() : Mission {
			
			var validMissions : Array = GetValidMissions();
			var potentialMission : Mission = FlxG.getRandom(validMissions) as Mission;
			return potentialMission;
		}
		
		public function GetRankName(rankNum : int) : String {
			if (rankNum <= 0) return "Error?";
			if (rankNum > 20)
				return "Addicted";
			if (rankNum > 15)
				return "Obsessed";
			if (rankNum > 10)
				return "Enthusiast";
			
			return rankNames[rankNum - 1];
		}
		
		public function GetNextStars(rankNum : int) : int {
			if (rankNum < 10) {
				return rankStars[rankNum];
			}
			return 9;
		}
		
		/**
		 * gets an array of missions from the missions list that have not been completed
		 * @return	The list of valid missions that have not been completed
		 */
		public function GetValidMissions() : Array {
			var validMissions : Array = new Array();
			
			var hasThree : Boolean = AlreadyHasThreeStar();
			
			for each(var mission : Mission in missionList) {
				if (!HasCompletedMission(mission.missionID) && HasPrereq(mission.prereq) && currentRank >= mission.minRank) {
					if (hasThree && mission.starValue == 3) {
						continue
					}
					if (AlreadyHasMissionType(mission.trackingVariable)) {
						continue;
					}
					
					validMissions.push(mission);
				}
			}
			
			if (validMissions.length == 0) {
				completedMissionIDs = new Array();
				return GetValidMissions();
			}
			
			return validMissions;
		}
		
		/**
		 * Checks to see if we already have an active mission tracking a variable
		 * @param	trackingVar - the variable to see if we are already tracking
		 * @return	boolean value indicating whether one of the active missions already contains trackingVar
		 */
		public function AlreadyHasMissionType(trackingVar : String) : Boolean {
			for each(var mission:Mission in activeMissions) {
				if (mission == null) continue;
				if (mission.trackingVariable == trackingVar) {
					return true;
				}
			}
			return false;
		}
		
		/**
		 * Checks to see if we already have a three star mission in our active missions
		 * @return	boolean value indicating whether one of the active missions already is a 3-star mission
		 */
		public function AlreadyHasThreeStar() : Boolean {
			for each(var mission:Mission in activeMissions) {
				if (mission == null) continue;
				
				if (mission.starValue == 3) {
					return true;
				}
			}
			return false;
		}
		
		public function HasPrereq(checkID : int) : Boolean {
			if (currentRank >= 10) return true; //if you've gotten to rank 10, all missions are open
			else return HasCompletedMission(checkID);
		}
		
		public function HasCompletedMission(checkID : int) : Boolean {
			if (checkID == -1) return true;
			for each(var id : int in completedMissionIDs) {
				if (id == checkID) {
					return true;
				}
			}
			return false;
		}
		
		//this will remove completed missions, add their star value to rank, and generate a new mission to replace it
		public function UpdateMissionQueue() : void {
			for (var i:int = 0; i < activeMissions.length; i++){
				var mission : Mission = activeMissions[i] as Mission;
				
				if (mission.completed) {
					//add the star value for the mission, let UpdateRank figure out overflow
					currentStars += mission.starValue;
					UpdateRank();
					
					//add the ID to completed missions
					completedMissionIDs.push(mission.missionID);
					
					//replace the mission
					activeMissions[i] = GetRandomMission();
				}
			}
			
			//save the finished mission status
			SaveMissionStatus();
		}
		
		
		/**
		 * We're going to save:
			 * Current mission IDs
			 * progress on each mission
			 * Completed mission IDs
			 * Current rank
			 * Current stars
		 */
		public function SaveMissionStatus() : void {
			var currentMissions : Array = new Array();
			var currentProgress : Array = new Array();
			var completedMissions : Array = completedMissionIDs.slice();
			
			for each(var mission : Mission in activeMissions) {
				currentMissions.push(mission.missionID);
				currentProgress.push(mission.progress);	
			}
			
			CommonConstants.SAVE.data.currentMissions = currentMissions;
			CommonConstants.SAVE.data.currentProgress = currentProgress;
			CommonConstants.SAVE.data.completedMissions = completedMissions;
			CommonConstants.SAVE.data.rank = currentRank;
			CommonConstants.SAVE.data.stars = currentStars;
			var x : Boolean = CommonConstants.SAVE.close();
			CommonConstants.SAVE.bind("AlienRunner");
		}
		
		public function UpdateRank() : void{
			if (currentStars >= starsForNextRank && starsForNextRank != -1) {
				currentRank += 1;
				currentStars -= starsForNextRank;
				if(currentRank < 10)
					starsForNextRank = GetNextStars(currentRank - 1);
				
			}
		}
		
		public function ResetRank() : void {
			CommonConstants.SAVE.erase();
			//CommonConstants.SAVE.
			CommonConstants.SAVE.bind("AlienRunner");
			currentRank = 1;
			currentStars = 0;
			completedMissionIDs = new Array();
			activeMissions = new Array();
			
			while(activeMissions.length < 3) {
				activeMissions.push(GetRandomMission());
			}
			//save the missions now
			SaveMissionStatus();
		}
		
	}

}