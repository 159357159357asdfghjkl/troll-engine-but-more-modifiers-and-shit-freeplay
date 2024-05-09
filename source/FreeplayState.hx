package;

#if discord_rpc
import Discord.DiscordClient;
#end
import sys.io.File;
import sys.FileSystem;
import flixel.text.FlxText;
import Song;
import flixel.util.FlxColor;
import flixel.addons.display.FlxBackdrop;
import flixel.math.FlxMath;
using StringTools;

//Update time:2024/5/4
//the real song list
class FreeplayState extends MusicBeatState
{	
	var songMeta:Array<SongMetadata> = [];
	var songText:Array<FlxText> = [];
	var curSel(default, set):Int;
	var camFollow:FlxObject;

	function set_curSel(sowy){
		if (songMeta.length == 0)
			return curSel = 0;

		if (sowy < 0 || sowy >= songMeta.length)
			sowy = sowy % songMeta.length;
		if (sowy < 0)
			sowy = songMeta.length + sowy;
		
		////
		var prevText = songText[curSel];
		if (prevText != null)
			prevText.color = 0xFFFFFFFF;

		var selText = songText[sowy];
		if (selText != null)
			selText.color = 0xFFFFFF00;

		////
		curSel = sowy;
		return curSel;
	}
	

	var verticalLimit:Int;
	var bg:FlxBackdrop;
	override public function create() 
	{
		StartupState.load();

		#if discord_rpc
		DiscordClient.changePresence("In the Menus", null);
		#end
		FlxG.camera.bgColor = 0xFF000000;
		////
		curSel = 0;

		bg = new FlxBackdrop(Paths.image("menuDesat"));
		bg.velocity.set(50, 50);
		bg.screenCenter();
		bg.blend = INVERT;
		//bg.setColorTransform(-1.75, -1.75, -1.75, 0.4, Std.int(255 + bg.color.red / 3), Std.int(255 + bg.color.green / 3), Std.int(255 + bg.color.blue / 3), 0);
		bg.screenCenter();
		bg.alpha = 0.6;
		add(bg);
		

		////
		if (FlxG.sound.music == null){
			MusicBeatState.playMenuMusic(1);
		}else{
			FlxG.sound.music.fadeIn(1.0, FlxG.sound.music.volume);
		}

		var folder = 'assets/songs/';
		Paths.iterateDirectory(folder, function(name:String){
			if (FileSystem.isDirectory(folder + name))
				songMeta.push(new SongMetadata(name));
		});

		#if MODS_ALLOWED
		for (modDir in Paths.getModDirectories()){
			var folder = Paths.mods('$modDir/songs/');
			Paths.iterateDirectory(folder, function(name:String){
				if (FileSystem.isDirectory(folder + name))
					songMeta.push(new SongMetadata(name, modDir));
			});
		}
		#end
		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		var hPadding = 14;
		var vPadding = 24;
		var spacing = 3;
		var textSize = 30;
		var width = 16*textSize;

		var ySpace = (textSize+spacing);

		verticalLimit = Math.floor((FlxG.height - vPadding*2)/ySpace);

		for (id in 0...songMeta.length)
		{
			var text = new FlxText(
				hPadding + (Math.floor(id/verticalLimit) * width), 
				vPadding + (ySpace*(id%verticalLimit)), 
				width, 
				songMeta[id].songName,
				textSize
			);
			text.wordWrap = false;
			text.antialiasing = false;
			songText.push(text);
			text.font = Paths.font("vcr.ttf");
			add(text);
		}


		var select:FlxText = new FlxText(0,-100,0,"Select a Song",50);
		select.font = Paths.font("consola.ttf");
		select.color = 0xffff0000;
		add(select);

		var tutorial:FlxText = new FlxText(0,-50,0,"Tips: Press Ctrl to Open Gameplay Change Menu, Press 6 to Open Options Menu" #if debug + ", Press 7 to Open Master Editor Menu" #end,16);
		tutorial.color = 0xffff00ff;
		tutorial.font = Paths.font("consola.ttf");
		add(tutorial);

		var versionTxt = new FlxText(0, 0, 0, Main.displayedVersion, 12);
		versionTxt.setPosition(FlxG.width - 2 - versionTxt.width, FlxG.height - 2 - versionTxt.height);
		versionTxt.alpha = 0.6;
		versionTxt.antialiasing = false;
		add(versionTxt);
		FlxG.camera.follow(camFollow, null, 0.06);
		super.create();
	}

	var xSecsHolding = 0.0;
	var ySecsHolding = 0.0; 

	override public function update(e)
	{
		var speed = 1;

		camFollow.setPosition(songText[curSel].getGraphicMidpoint().x, songText[curSel].getGraphicMidpoint().y);
		if (controls.UI_UP || controls.UI_DOWN){
			if (controls.UI_DOWN_P){
				curSel += speed;
				FlxG.sound.play(Paths.sound("scrollMenu"),1,false);
				ySecsHolding = 0;
			}
			if (controls.UI_UP_P){
				curSel -= speed;
				FlxG.sound.play(Paths.sound("scrollMenu"), 1, false);
				ySecsHolding = 0;
			}

			var checkLastHold:Int = Math.floor((ySecsHolding - 0.5) * 10);
			ySecsHolding += e;
			var checkNewHold:Int = Math.floor((ySecsHolding - 0.5) * 10);

			if(ySecsHolding > 0.35 && checkNewHold - checkLastHold > 0)
				curSel += (checkNewHold - checkLastHold) * (controls.UI_UP ? -1 : 1) * speed;
		}

		if (controls.UI_LEFT || controls.UI_RIGHT){
			if (controls.UI_RIGHT_P){
				curSel += verticalLimit;
				FlxG.sound.play(Paths.sound("scrollMenu"), 1, false);
				ySecsHolding = 0;
			}
			if (controls.UI_LEFT_P){
				curSel -= verticalLimit;
				FlxG.sound.play(Paths.sound("scrollMenu"), 1, false);
				ySecsHolding = 0;
			}

			var checkLastHold:Int = Math.floor((ySecsHolding - 0.5) * 10);
			ySecsHolding += e;
			var checkNewHold:Int = Math.floor((ySecsHolding - 0.5) * 10);

			if(ySecsHolding > 0.35 && checkNewHold - checkLastHold > 0)
				curSel += (checkNewHold - checkLastHold) * (controls.UI_LEFT_P ? -1 : 1) * verticalLimit;
		}

		if (FlxG.keys.pressed.CONTROL)
		{
			openSubState(new GameplayChangersSubstate());
		}

		if (controls.ACCEPT){
			FlxG.sound.play(Paths.sound('confirmMenu'));
			var charts = DifficultyState.getCharts(songMeta[curSel]);

			trace(charts);
			
			if (charts.length > 1)
				MusicBeatState.switchState(new DifficultyState(songMeta[curSel], charts));
			else if (charts.length > 0)
				Song.playSong(songMeta[curSel], charts[0], 0);
			else{
				trace("no charts!");
				songText[curSel].alpha = 0.6;
			}
		}
        else if (controls.BACK){
			FlxG.sound.play(Paths.sound('cancelMenu'));
            MusicBeatState.switchState(new MainMenuState());
		}
		else if (FlxG.keys.justPressed.SEVEN)
			MusicBeatState.switchState(new editors.MasterEditorMenu());
		else if (FlxG.keys.justPressed.SIX)
			MusicBeatState.switchState(new options.OptionsState());

		super.update(e);
	}
}

class DifficultyState extends MusicBeatState
{
	var songMeta:SongMetadata;
	var alts:Array<String>;

	var texts:Array<FlxText> = [];
	var curSel = 0;

	function changeSel(diff:Int = 0)
	{
		texts[curSel].color = 0xFFFFFFFF;

		curSel += diff;
		
		if (curSel < 0)
			curSel += alts.length;
		else if (curSel >= alts.length)
			curSel -= alts.length;

		texts[curSel].color = 0xFFFFFF00;
	}
	var bg:FlxSprite;
	var b:FlxSprite;
	override function create()
	{
		var white:FlxSprite = new FlxSprite().makeGraphic(1280,720,0xffffffff);
		add(white);
		var diff:FlxSprite = new FlxSprite(290, 190).loadGraphic(Paths.image('impstuff'));
		add(diff);
		diff.scale.set(1.5,1.5);
		for (id in 0...alts.length){
			var alt = alts[id];
			var text = new FlxText(550, 240 + id * 80, (FlxG.width-20) / 2, alt, 50);
			text.borderSize = 1.25;
			text.font = Paths.font("pixel.otf");
			texts[id] = text;
			add(text);
		}
		
		changeSel();
b=new FlxSprite().makeGraphic(1500,800,0xff000000);
add(b);
	}

	override public function update(e){
		if (controls.UI_DOWN_P){
			changeSel(1);
		FlxG.sound.play(Paths.sound("scrollMenu"),1,false);
		}
		if (controls.UI_UP_P){
			changeSel(-1);
		FlxG.sound.play(Paths.sound("scrollMenu"),1,false);
		}
		if (controls.BACK){
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new FreeplayState());
		}
		else if (controls.ACCEPT){
			FlxG.sound.play(Paths.sound('confirmMenu'));
			var daDiff = alts[curSel];
			Song.playSong(songMeta, (daDiff=="normal") ? null : daDiff, curSel);
		}
b.alpha = FlxMath.lerp(b.alpha,0,0.1);
		super.update(e);
	} 

	public function new(WHO:SongMetadata, alts) 
	{
		super();
		
		songMeta = WHO;
		this.alts = alts;
	}

	public static function getCharts(metadata:SongMetadata):Array<String>
	{
		Paths.currentModDirectory = metadata.folder;
		final songName = Paths.formatToSongPath(metadata.songName);
		
		trace(songName, metadata.folder);

		final charts = new haxe.ds.StringMap();
		function processFileName(fileName:String)
		{			
			if (fileName == '$songName.json'){
				charts.set("normal", true);
				return;
			}
			else if (!fileName.startsWith('$songName-') || !fileName.endsWith('.json')){
				return;
			}

			final extension_dot = songName.length + 1;
			charts.set(fileName.substr(extension_dot, fileName.length - extension_dot - 5), true);
		}

		#if PE_MOD_COMPATIBILITY
		final folder = (metadata.folder == "") ? Paths.getPath('data/$songName/') : Paths.mods('${metadata.folder}/data/$songName/');
		Paths.iterateDirectory(folder, processFileName);
		#end

		final folder = (metadata.folder == "") ? Paths.getPath('songs/$songName/') : Paths.mods('${metadata.folder}/songs/$songName/');
		Paths.iterateDirectory(folder, processFileName);

		return [for (name in charts.keys()) name];
	} 
}