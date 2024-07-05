package modchart.modifiers;

import ui.*;
import modchart.*;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.FlxG;
import math.Vector3;
import math.*;
import playfields.NoteField;

class AccelModifier extends NoteModifier
{ // this'll be boost in ModManager
	inline function lerp(a:Float, b:Float, c:Float)
	{
		return a + (b - a) * c;
	}
	//var player:Int;
	override function getName()
		return 'boost';
	var expandSeconds:Float;
	/*override function shouldUpdate()return true;
	override function update(elapsed:Float, beat:Float){
    var lastTime:Float = 0;
    var time:Float = Conductor.instance.songPosition / 1000 * 4294.967296 / 1000000; // fast time math
    expandSeconds += time - lastTime;
    expandSeconds %= ((Math.PI * 2) / (getSubmodValue('expandPeriod',player) + 1));
	}*/
	override function getPos(visualDiff:Float, timeDiff:Float, beat:Float, pos:Vector3, data:Int, player:Int, obj:FlxSprite, field:NoteField)
	{
		//this.player = player;
		if (getOtherValue("movePastReceptors", player) == 0 && visualDiff<=0)
            return pos;
        
		var wave = getSubmodValue("wave", player);
		var brake = getSubmodValue("brake", player);
		var boost = getValue(player);
		var parabolaY = getSubmodValue("parabolaY",player);
		var effectHeight = 720;

		var yAdjust:Float = 0;
		var scrollSpeeds:Float = 0;
		var reverse:Dynamic = modMgr.register.get("reverse");
		var reversePercent = reverse.getReverseValue(data, player);
		var mult = CoolUtil.scale(reversePercent, 0, 1, 1, -1);

		if (brake != 0)
		{
			var scale = CoolUtil.scale(visualDiff, 0, effectHeight, 0, 1);
			var off = visualDiff * scale;
			yAdjust += CoolUtil.clamp(brake * (off - visualDiff), -600, 600);
		}

		if (boost != 0)
		{
			var off = visualDiff * 1.5 / ((visualDiff + effectHeight / 1.2) / effectHeight);
			yAdjust += CoolUtil.clamp(boost * (off - visualDiff), -600, 600);
		}

		if (getSubmodValue("wavePeriod", player) != -1 /**< no division by 0**/ && wave != 0) 
		    yAdjust += wave * 40 * FlxMath.fastSin(visualDiff / ((114 * getSubmodValue("wavePeriod", player)) + 114));
		if (getSubmodValue("boomerang",player) != 0)
		{
			var oldpos = 50 + Note.swagWidth/2;
			pos.y = oldpos + getSubmodValue("boomerang", player)*((-1 * visualDiff * visualDiff / effectHeight) + 1.5 * visualDiff);
		}
		if (getSubmodValue("parabolaY", player)!=0)
			yAdjust += getSubmodValue("parabolaY", player) * (visualDiff / Note.swagWidth) * (visualDiff / Note.swagWidth);

		pos.y += yAdjust * mult;


		/*if(getSubmodValue("expand",player)!=0){
			var expandMultiplier = CoolUtil.scale(FlxMath.fastCos(expandSeconds * 1.2 * (getSubmodValue("expandPeriod", player) + 1)),-1,1,0.75,1.75);
			fScrollSpeed *= CoolUtil.scale(getSubmodValue("expand", player), 0, 1, 1,expandMultiplier);
		}*/
		//speed is in yoffset, i don't want to change it anymore, waiting for my vslice modchart system,it will has many mods
		return pos;
	}

	override function getSubmods()
	{
		var subMods:Array<String> = ["brake", "wave", "wavePeriod","boomerang",/*"expand","expandPeriod",*/"parabolaY"];
		return subMods;
	}
}
