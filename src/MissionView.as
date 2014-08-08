package  
{
	import mx.core.FlexSprite;
	import org.flixel.FlxButton;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	import org.flixel.FlxText;
	import org.flixel.FlxPoint;
	import org.flixel.FlxU;
	/**
	 * ...
	 * @author ...
	 */
	public class MissionView extends FlxGroup
	{
		[Embed(source = '../resources/img/missionViewOutline.png')]private static var missionViewOutline:Class;
		[Embed(source = '../resources/img/missionViewBackground.png')]private static var missionViewBackground:Class;
		
		public var missionManager : MissionManager;
		
		public var missionGroup : FlxGroup;
		public var activeStarGroup : FlxGroup; //group for the stars on the rank display
		public var inactiveStarGroup : FlxGroup;
		public var starQueue : FlxGroup; //group for the stars waiting to be sent from completed missions
		
		public var rankText : FlxText;
		public var displayRank : int;
		
		public var currentAnimationFunction : Function;
		public var animationsCompleted : Boolean = true;
		public var animationCallback : Function;
		
		public var needInit : Boolean = false;
		public var index : int;
		
		public var slideSpeed : int = 25;
		
		public var delay : int = 0;
		public var continueFunction : Function;
		
		public var missionPanelX : int = 80;
		public var missionPanelYStart : int = 115;
		public var missionPanelYBuffer : int = 30;
		
		public var starStartY : int = 207;
		public var starBufferX : int = 5;
		public var starBufferY : int = 20;
		public var starWidth : int = 20;
		
		public var explodeStarDirs : Array;
		
		public var starIndex : int = 0;
		public var starPositions : Array;
		
		public var currentStar : FlxSprite;
		public var currentStarTargetPoint : FlxPoint;
		public var starSpeed : Number = 10;
		
		public var currentMission : MissionDisplay;
		
		public var resetButton : FlxButton;
		
		public function MissionView() 
		{
			super();
			
			SetupView();
		}
		
		public function SetupView() : void {
			this.clear();
			var background : FlxSprite = new FlxSprite(0, 0, missionViewBackground);
			add(background);
			
			var outline : FlxSprite = new FlxSprite(0, 0, missionViewOutline);
			add(outline);
			
			missionGroup = new FlxGroup();
			add(missionGroup);

			missionManager = MissionManager.missionManagerInstance;

			AddCurrentMissions();
			
			starQueue = new FlxGroup();
			add(starQueue);
			
			rankText = new FlxText(135, 255, 130);
			rankText.size = 10;
			rankText.alignment = "center";
			rankText.shadow = 0xFF000000;
			add(rankText);
			
			SetupStars(missionManager.currentRank, missionManager.currentStars);

			this.setAll("scrollFactor", new FlxPoint(0, 0));
		}
		
		public function AddCurrentMissions() : void {
			displayRank = missionManager.currentRank;
			var addY = missionPanelYStart;
			
			for each(var mission : Mission in missionManager.activeMissions) {
				var display : MissionDisplay = new MissionDisplay(mission);
				display.x = missionPanelX;
				display.y = addY;
				
				//display.completed = true;
				
				missionGroup.add(display);
				
				addY += missionPanelYBuffer;
			}
		}
		
		public function SetupStars(rank : int, filledStars : int) : void {
			if (activeStarGroup != null) {
				remove(activeStarGroup);
				activeStarGroup.destroy();
			}
			if (inactiveStarGroup != null) {
				remove(inactiveStarGroup);
				activeStarGroup.destroy();
			}

			activeStarGroup = new FlxGroup();
			inactiveStarGroup = new FlxGroup();
			add(inactiveStarGroup);
			add(activeStarGroup);
			starPositions = new Array();
			
			rankText.text =  rank.toString() + ": " + missionManager.GetRankName(rank);

			var numStars : int = missionManager.GetNextStars(rank-1);
			//top row will only ever have 3, 4, or 5
			//if(numStars <= 5)
			
			var numTopRow : int;
			if (numStars > 5) numTopRow = numStars / 2 + 1;
			else numTopRow = numStars;
			
			var starStartX : int = CommonConstants.VISIBLEWIDTH / 2 - (numTopRow * starWidth + (numTopRow - 1) * starBufferX) / 2;
			var placeX : int = starStartX;
			var placeY : int = starStartY;
			
			for (var i:int = 0; i < numStars; i++) {

				if(numStars > 5){
					if (i == numTopRow) {
						placeY += starBufferY;
						placeX = starStartX + starWidth / 2 + starBufferX / 2;
					}
				}
				
				if (i < filledStars) {
					var greystar : FlxSprite = new FlxSprite(placeX, placeY, CommonConstants.STAREMPTY);
					greystar.scrollFactor.x = 0;
					greystar.scrollFactor.y = 0;
					inactiveStarGroup.add(greystar);
					
					var filledstar : FlxSprite= new FlxSprite(placeX, placeY, CommonConstants.STARFULL);
					filledstar.scrollFactor.x = 0;
					filledstar.scrollFactor.y = 0;
					activeStarGroup.add(filledstar);
				}
				else {
					var greystar : FlxSprite = new FlxSprite(placeX, placeY, CommonConstants.STAREMPTY);
					greystar.scrollFactor.x = 0;
					greystar.scrollFactor.y = 0;
					inactiveStarGroup.add(greystar);
				}

				starPositions.push(new FlxPoint(placeX, placeY));
				
				placeX += starWidth + starBufferX;

			}
		}
		
		override public function update():void 
		{
			super.update();
			if (currentAnimationFunction) {
				currentAnimationFunction();
			}
			
			if (animationsCompleted == true && animationCallback) {
				animationCallback();
				animationCallback = null;
			}
			
		}
		
		public function StartMissionAnimation(callback : Function = null) : void {
			animationsCompleted = false;
			SwitchAnimation(AnimateSlideInMissions);
			animationCallback = callback;
		}
		
		//slide in the existing missions, included ones that have been completed
		public function AnimateSlideInMissions() : void {
			if (needInit) {
				for each(var mission : MissionDisplay in missionGroup.members) {
					mission.x = -500;
				}
				needInit = false;
				
			}
			
			var completed : Boolean = false;
			
			for each(var mission : MissionDisplay in missionGroup.members) {
				if (mission.x == missionPanelX) {
					completed = true;
				}
				else if(mission.x + slideSpeed < missionPanelX){
					mission.x += slideSpeed;
					completed = false;
				}
				else if (mission.x + slideSpeed > missionPanelX) {
					mission.x = missionPanelX;
					completed = false;
				}
			}
			
			if (completed)
				DelayAnimation(AnimateMissionCompleted, 15);
			
		}
		
		//show the animation on the mission display of the mission being "completed"
		public function AnimateMissionCompleted() : void {
			
			if (needInit) {
				index = 0;
				currentMission = missionGroup.members[index] as MissionDisplay;
				needInit = false;
			}
			//currentMission.completed = true;
			if (currentMission.completed && !currentMission.animatedCompleted) {
				currentMission.AnimateCompleted();
			}
			
			if (currentMission.doneAnimating) {
				index += 1;
			}
			
			if(!currentMission || index >= missionGroup.length){
				DelayAnimation(AnimateStars, 15);
			}
			else {
				currentMission = missionGroup.members[index];
			}
		}
		
		//animate the stars flying into position on the rank display
		public function AnimateStars() : void {
			if (needInit) {
				//save the current index of the last star in the rank area as a starting point
				starIndex = missionManager.currentStars;
			
				//add the stars that are on the completed missions to our star queue, removing them from the missiondisplay
				for each(var mission : MissionDisplay in missionGroup.members) {
					if (mission.completed) {
						for each(var star : FlxSprite in mission.stars) {
							mission.remove(star, true);
							this.starQueue.add(star);
						}
						mission.stars = new Array();
					}
				}
				needInit = false;
			}
			
			//keep going until we've sent all the stars
			if (starQueue.length > 0) {
				if(currentStar == null){
					currentStar = starQueue.members[0] as FlxSprite;
					currentStarTargetPoint = starPositions[starIndex];
				}
				
				
				//move our star, and if the star has reached its destination, add it to the star group and set it to null to go to the next one
				if (CommonFunctions.moveTowards(currentStar, currentStarTargetPoint, starSpeed)){
					starQueue.remove(currentStar, true);
					activeStarGroup.add(currentStar);
					currentStar = null;
					starIndex += 1;
					
					//check to see if we have filled our current rank
					if (starIndex >= starPositions.length) {
						starIndex = 0;
						SwitchAnimation(AnimateRankUp);
					}
				}
			}
			else {
				SwitchAnimation(AnimateCompletedSlideOff);
			}
			

			
		}
		
		public function AnimateRankUp() : void {
			if (needInit) {
				delay = 60;
				//FlxG.shake(.01, .25);
				needInit = false;
			}
			
			delay --;
			
			if (delay == 45) {
				FlxG.shake(.03, .1);
				displayRank += 1;
				SetupStars(displayRank, 0);
			}
			
			if (delay < 45) {
				
				ExplodeStars();
			}
			
			if(delay <= 0){
				SwitchAnimation(AnimateStars, false);
			}
		}
		
		//animate the completed missions sliding off to the right
		public function AnimateCompletedSlideOff() : void {
			var anyCompleted : Boolean = false;
			for each(var mission : MissionDisplay in missionGroup.members) {
				if (mission.completed) {
					anyCompleted = true;
					mission.x += slideSpeed;
					if (mission.x > CommonConstants.VISIBLEWIDTH) {
						SwitchAnimation(AnimateNewSlideOn);
					}
				}
			}
			if (!anyCompleted) {
				SwitchAnimation(AnimateNewSlideOn);
			}
		}
		
		//animate the newly added missions 
		public function AnimateNewSlideOn() : void {
			if (needInit) {
				RemoveAndReplaceCompleted();
				needInit = false;
			}
			
			var completedCount : int = 0;
			
			for each(var mission : MissionDisplay in missionGroup.members) {
				if (mission.x == missionPanelX) {
					completedCount += 1;
				}
				else if(mission.x + slideSpeed < missionPanelX){
					mission.x += slideSpeed;
				}
				else if (mission.x + slideSpeed > missionPanelX) {
					mission.x = missionPanelX;
				}
			}
			
			if(completedCount == 3){
				SwitchAnimation(null);
			}
		}
		
		public function DelayAnimation(nextAnimation : Function, delayFrames : int = 30, init : Boolean = true) {
			continueFunction = nextAnimation;
			delay = delayFrames;
			SwitchAnimation(AnimateDelay);
		}
		
		public function AnimateDelay() {
			delay --;
			if (delay <= 0) {
				SwitchAnimation(continueFunction, true);
			}
		}

		public function SwitchAnimation(nextAnimation : Function, init : Boolean = true) {
			needInit = init;
			currentAnimationFunction = nextAnimation;
			if (nextAnimation == null){
				needInit = false;
				animationsCompleted = true;
			}
		}
		
		public function ExplodeStars() : void {
			if (explodeStarDirs == null) {
				explodeStarDirs = new Array();
				for (var i:int = 0; i < activeStarGroup.length; i++ ) {
					var x:Number;
					var y:Number;
					
					if (FlxG.random() >= .5) {
						x = CommonFunctions.getRandom( -200, -50);
					}
					else {
						x = CommonFunctions.getRandom(CommonConstants.VISIBLEWIDTH, CommonConstants.VISIBLEWIDTH + 200);
					}
					
					y = CommonFunctions.getRandom(0, CommonConstants.VISIBLEHEIGHT);

					explodeStarDirs.push(new FlxPoint(x, y));
				}
			}
			
			for (var j : int = 0; j < activeStarGroup.length; j++){
				var star : FlxSprite = activeStarGroup.members[j] as FlxSprite;
				var point : FlxPoint = explodeStarDirs[j];
				if (star && point) {
					CommonFunctions.moveTowards(star, point, 25);
				}
			}
		}
		
		//remove the completed missions
		public function RemoveAndReplaceCompleted() : void {
			//first, tell our MissionManager to remove old missions and generate new ones
			missionManager.UpdateMissionQueue();
			
			//next, remove our completed MissionDisplays and replace them with new ones from the MissionManager
			for (var i:int = 0; i < missionGroup.length; i++) {
				var missionDisp : MissionDisplay = missionGroup.members[i] as MissionDisplay;
				
				if (missionDisp.completed) {
					
					var newMission : Mission = missionManager.activeMissions[i];
					var display : MissionDisplay = new MissionDisplay(newMission);
					display.x = -500;
					display.y = missionPanelYStart + missionPanelYBuffer * i;
					missionGroup.members[i] = display;
					
					
					missionDisp.destroy();
				}
			}
		}
		
	
		
		
	}

}