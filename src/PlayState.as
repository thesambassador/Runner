package
{
	import org.flixel.*;
	import org.flixel.system.FlxDebugger;
	
	/**
	 * Very basic game state class, sets framerate, background color, sets up a pause menu, and instantiates the game world.
	 */
	
	public class PlayState extends FlxState
	{
		[Embed(source = '../resources/sound/SurgeRamizHaddad.MP3')]private static var music:Class;
		public var world : World; //game world, contains everything for the actual gameplay
		public var pauseMenu : FlxGroup; //menu to show when paused
		public var debugDiag : FlxDebugger; //debugger
		public var mainMenu : MainMenu;
		
		public static var playImmediately : Boolean = false;
		
		public var missionManager : MissionManager;
		
		override public function create():void
		{
			CommonConstants.SAVE = new FlxSave();
			CommonConstants.SAVE.bind("AlienRunner");
			//CommonConstants.SAVE.erase();
			//CommonConstants.SAVE.bind("AlienRunner");
			
			missionManager = new MissionManager();
			//missionManager.ResetRank();
			
			//FlxG.visualDebug = true;
			//basic initialization
			FlxG.mouse.show();
			FlxG.bgColor = 0xff000000;
			FlxG.framerate = 60;
			FlxG.flashFramerate = 60;
			
			//create a new world object and add it to the state
			world = new World();
			add(world);
			
			mainMenu = new MainMenu(startGame);
			
			if (playImmediately) {
				startGame();
				playImmediately = false;
			}
			else{
				//add the main menu
				
				add(mainMenu);
			}
			//create the pause menu
			pauseMenu = new FlxGroup();
		}
		
		override public function update():void {
			//Pause/Unpause the game if you hit P
			//if (FlxG.keys.justPressed("P")) {
			//	FlxG.paused = !FlxG.paused;
			//}
			
			//If we're paused, 
			
			if (FlxG.paused) {
				pauseMenu.update();
				return;
			}
			super.update();
		}
		
		override public function draw():void {
			if (FlxG.paused) {
				pauseMenu.draw();
			}
			super.draw();
		}
		
		public function startGame() : void {

			mainMenu.AnimateRemoveMenu();
			
			
			//remove the main menu after the animation of it moving off the screen is done
			DelayManager.AddDelay(1, RemoveMainMenu);
			
			//set up the countdown object to show itself
			var countdown : Countdown = new Countdown();
			countdown.x = CommonFunctions.alignX(countdown.width);
			countdown.y = (CommonConstants.VISIBLEWIDTH / 2) - (countdown.height);
			add(countdown);
			
			//set up music to play
			FlxG.playMusic(music);
			FlxG.volume = .25;
			
			//start the game after the countdown is over (3 seconds)
			
			DelayManager.AddDelay(3, world.startGame);
		}
		
		public function RemoveMainMenu() : void {
			remove(mainMenu);
			mainMenu.destroy();
		}
	}
}