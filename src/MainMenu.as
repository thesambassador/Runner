package  
{
	import mx.core.FlexSprite;
	import org.flixel.FlxBasic;
	import org.flixel.FlxButton;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxObject;
	import org.flixel.FlxSprite;
	import org.flixel.FlxText;
	import org.flixel.plugin.photonstorm.FlxButtonPlus;
	/**
	 * ...
	 * @author ...
	 */
	public class MainMenu extends FlxGroup
	{
		[Embed(source = '../resources/img/menu_logo.png')]public static var imgLogo:Class;
		
		[Embed(source = '../resources/img/menu_play.png')]public static var imgPlay:Class;
		[Embed(source = '../resources/img/menu_play_hover.png')]public static var imgPlayHover:Class;
		
		[Embed(source = '../resources/img/menu_howto.png')]public static var imgHowto:Class;
		[Embed(source = '../resources/img/menu_howto_hover.png')]public static var imgHowtoHover:Class;
		
		[Embed(source = '../resources/img/menu_highscores.png')]public static var imgHighScores:Class;
		[Embed(source = '../resources/img/menu_highscores_hover.png')]public static var imgHighScoresHover:Class;
		
		[Embed(source = '../resources/img/menu_credits.png')]public static var imgCredits:Class;
		[Embed(source = '../resources/img/menu_credits_hover.png')]public static var imgCreditsHover:Class;
		
		[Embed(source = '../resources/img/menu_back.png')]public static var imgBack:Class;
		[Embed(source = '../resources/img/menu_back_hover.png')]public static var imgBackHover:Class;
		[Embed(source = '../resources/img/3.png')]private static var img3:Class;
		
		
		[Embed(source = '../resources/img/missionsTab.png')]private static var missionsTab:Class;
		
		
		
		
		[Embed(source = '../resources/img/howto.png')]private static var imgHowToFull:Class;
		
		
		
		public var logo : FlxSprite;
		public var btnPlay : FlxButtonPlus;
		public var btnHowto : FlxButtonPlus;
		public var btnHighScores : FlxButtonPlus;
		public var btnCredits : FlxButtonPlus;
		public var btnBack : FlxButtonPlus;
		public var btnMissions : FlxButtonPlus;
		
		public var resetButton : FlxButton;
		
		public var menuRoot : FlxGroup;
		public var menuHowto : FlxGroup;
		public var menuHighscores : FlxGroup;
		public var menuCredits : FlxGroup;
		public var menuMissions : MissionView;
		
		public var removing : Boolean = false;
		
		public var hsView : HighScoresView;
		
		public function MainMenu(startGameFunction : Function)
		{
			super();
			
			menuRoot = new FlxGroup();
			menuHowto = new FlxGroup();
			menuHighscores = new FlxGroup();
			menuCredits = new FlxGroup();
			menuMissions = new MissionView();
			
			add(menuRoot);
			add(menuHowto);
			add(menuHighscores);
			add(menuCredits);
			add(menuMissions);
			
			menuHowto.visible = false;
			menuHighscores.visible = false;
			menuCredits.visible = false;
			menuMissions.visible = false;
			
			menuHowto.active = false;
			menuHighscores.active = false;
			menuCredits.active = false;
			menuMissions.active = false;
			
			logo = new FlxSprite();
			logo.loadGraphic(imgLogo);
			logo.scrollFactor.x = 0;
			logo.scrollFactor.y = 0;
			logo.x = CommonFunctions.alignX(logo.width);
			logo.y = 15;
			menuRoot.add(logo);
			
			initButtons(startGameFunction);
			initMenus();
			
		}
		
		public function initMenus() : void {
			if (menuHighscores.members.length == 0) {
				var bgHighScores : FlxSprite = new FlxSprite();
				bgHighScores.loadGraphic(CommonConstants.MENUBG);
				bgHighScores.scrollFactor.x = 0;
				bgHighScores.scrollFactor.y = 0;
				
				menuHighscores.add(bgHighScores);
				
				hsView = new HighScoresView();
				menuHighscores.add(hsView);
			}
			
			var howto : FlxSprite = new FlxSprite();
			howto.loadGraphic(imgHowToFull);
			howto.scrollFactor.x = 0;
			howto.scrollFactor.y = 0;
			menuHowto.add(howto);
			
			initCredits();
		}
		
		public function initCredits() : void {
			//background sprite
			var bgCredits : FlxSprite = new FlxSprite();
			bgCredits.loadGraphic(CommonConstants.MENUBG);
			bgCredits.scrollFactor.x = 0;
			bgCredits.scrollFactor.y = 0;
			menuCredits.add(bgCredits);
			
			//text
			var message : String = ( <![CDATA[
Game Design, Programming, Graphics, Sound Effects
Sam Tregillus

Music
Some guy

Thank you to the creators of:
Flixel and Flixel Power Tools
BFGX
Flash Develop
Graphics Gale and Paint.Net
And special thanks to my wife Katie for all of her ideas and support

			]]> ).toString();

			
			var text : FlxText = new FlxText(0, 0, 400, message);
			text.scrollFactor.x = 0;
			text.scrollFactor.y = 0;
			text.alignment = "center";
			text.antialiasing = false;
			text.size = 8;
			menuCredits.add(text);
			
			
			
		}
		
		public function initButtons(startGameFunction : Function) : void {
			
			btnPlay = CreateButton(imgPlay, imgPlayHover, startGameFunction);
			btnPlay.x = CommonFunctions.alignX(btnPlay.width);
			btnPlay.y = CommonConstants.VISIBLEHEIGHT / 2;
			menuRoot.add(btnPlay);
			
			btnHowto = CreateButton(imgHowto, imgHowtoHover, ShowHowto);
			btnHowto.x = CommonFunctions.alignX(btnHowto.width, "left", 15);
			btnHowto.y = CommonConstants.VISIBLEHEIGHT - btnHowto.height - 15;
			menuRoot.add(btnHowto);
			
			/* removing high scores to use Kongregate's API
			btnHighScores = CreateButton(imgHighScores, imgHighScoresHover, ShowHighscores);
			btnHighScores.x = CommonFunctions.alignX(btnHighScores.width, "center");
			btnHighScores.y = CommonConstants.VISIBLEHEIGHT - btnHighScores.height - 15;
			menuRoot.add(btnHighScores);
			*/
			btnCredits = CreateButton(imgCredits, imgCreditsHover, ShowCredits);
			btnCredits.x = CommonFunctions.alignX(btnCredits.width, "right", 15);
			btnCredits.y = CommonConstants.VISIBLEHEIGHT - btnCredits.height - 15;
			menuRoot.add(btnCredits);
			
			btnMissions = CreateButton(missionsTab, missionsTab, ShowMissions);
			btnMissions.x = CommonFunctions.alignX(btnMissions.width, "left", 0);
			btnMissions.y = CommonConstants.VISIBLEHEIGHT / 2 - btnMissions.height / 2;
			menuRoot.add(btnMissions);
			
			btnBack = CreateButton(imgBack, imgBackHover, BackToRoot);
			btnBack.x = CommonFunctions.alignX(btnBack.width, "right", 5);
			btnBack.y = CommonConstants.VISIBLEHEIGHT - btnBack.height - 5;
			btnBack.visible = false;
			btnBack.active = false;
			this.add(btnBack);
		}
		
		override public function update() : void {
			if (removing) {
				var speed : int = 5;
				logo.y -= speed;
				btnPlay.visible = false;
				//btnHighScores.y += speed;
				btnCredits.y += speed;
				btnHowto.y += speed;
				btnMissions.x -= speed;
			}
			super.update();
		}
		
		public function CreateButton(basicImg : Class, hoverImg : Class, onClick : Function) : FlxButtonPlus{
			var basic : FlxSprite = new FlxSprite();
			var hover : FlxSprite = new FlxSprite();
			
			basic.loadGraphic(basicImg);
			hover.loadGraphic(hoverImg);
			
			var returned : FlxButtonPlus = new FlxButtonPlus(0, 0, onClick);
			returned.loadGraphic(basic, hover);
			return returned;
		}
		

		public function ShowHowto() : void {
			menuRoot.active = false;
			menuRoot.visible = false;
			
			menuHowto.visible = true;
			menuHowto.active = true;
			
			btnBack.visible = true;
			btnBack.active = true;
		}
		
		public function ShowHighscores() : void {
			menuRoot.active = false;
			menuRoot.visible = false;
			
			menuHighscores.visible = true;
			menuHighscores.active = true;
			
			hsView.RefreshScores();
			hsView.ShowEntries();
			
			btnBack.visible = true;
			btnBack.active = true;
		}
		
		public function ShowCredits() : void {
			menuRoot.active = false;
			menuRoot.visible = false;
			
			menuCredits.visible = true;
			menuCredits.active = true;
			
			btnBack.visible = true;
			btnBack.active = true;
			//btnBack._pressed = false;
			//btnBack._status = FlxButtonPlus.NORMAL;
		}
		
		public function ShowMissions() : void {
			menuRoot.active = false;
			menuRoot.visible = false;
			
			menuMissions.active = true;
			menuMissions.visible = true;
			ShowResetMissionButton();
		
			btnBack.visible = true;
			btnBack.active = true;
		}
		
		public function BackToRoot() : void {
			//disable and hide alternative menus
			menuHowto.visible = false;
			menuHighscores.visible = false;
			menuCredits.visible = false;
			menuMissions.visible = false;
			
			menuHowto.active = false;
			menuHighscores.active = false;
			menuCredits.active = false;
			menuMissions.active = false;
			
			//reactivate root menu
			menuRoot.active = true;
			menuRoot.visible = true;
			
			//remove back button
			btnBack.visible = false;
			btnBack.active = false;
			btnBack._status = FlxButtonPlus.NORMAL;
			btnBack._pressed = false;
			
		}
		
		public function AnimateRemoveMenu() : void {
			removing = true;
		}
		
		public function ShowResetMissionButton() : void {
			if(resetButton == null){
				resetButton = new FlxButton(CommonFunctions.alignX(80, "center", 0), 280 , "Reset", ResetMissions);
				resetButton.scrollFactor.x = 0;
				resetButton.scrollFactor.y = 0;
			}
			menuMissions.add(resetButton);
		}
		
		public function ResetMissions() : void {
			
			MissionManager.missionManagerInstance.ResetRank();
			
			menuMissions.SetupView();
			ShowResetMissionButton();
			
		}
		

		
		public function MoveGroup(group : FlxGroup, x : Number, y : Number) : void {
			for each(var member : FlxBasic in group.members) {
				if (member != null) {
					if (member is FlxObject) {
						var obj : FlxObject = member as FlxObject;
						obj.x += x;
						obj.y += y;
					}
					else if (member is FlxButtonPlus) {
						var btn : FlxButtonPlus = member as FlxButtonPlus;
						btn.x += x;
						btn.y += y;
					}
					else if (member is FlxGroup) {
						MoveGroup(member as FlxGroup, x, y);
					}
				}
			}
		}
		
	}

}