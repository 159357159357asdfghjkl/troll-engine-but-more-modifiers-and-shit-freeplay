package modchart.modifiers;

import playfields.NoteField;
import flixel.math.FlxMath;
class ZoomModifier extends Modifier {
    override public function getName()return 'mini';

    override public function affectsField()return true; // tells the mod system to call this for playfield zooms

	override public function getFieldZoom(zoom:Float, beat:Float, songPos:Float, player:Int, field:NoteField, diff:Float)
	{
        if(getValue(player)!=0)
            zoom -= (0.5 * getValue(player));
		if (getSubmodValue("pulseInner",player) != 0 || getSubmodValue("pulseOuter",player) != 0)
		{
			var sine:Float = FlxMath.fastSin(((diff + (100.0 * (getSubmodValue("pulseOffset",
				player)))) / (0.4 * (Note.swagWidth + (getSubmodValue("pulsePeriod", player) * Note.swagWidth)))));

			zoom *= (sine * (getSubmodValue("pulseOuter", player) * 0.5)) + getPulseInner(player);
		}
		if (getSubmodValue("shrinkMult",player) != 0 && diff >= 0)
			zoom *= 1 / (1 + (diff * (getSubmodValue("shrinkMult", player) / 100.0)));

		if (getSubmodValue("shrinkLinear", player) != 0 && diff >= 0)
			zoom += diff * (0.5 * getSubmodValue("shrinkLinear", player) / Note.swagWidth);

        return zoom;
	}
	function getPulseInner(player:Int)
	{
		var p:Float = 1.0;
		if (getSubmodValue("pulseInner", player) != 0 || getSubmodValue("pulseOuter",player) != 0)
		{
			p = ((getSubmodValue("pulseInner", player) * 0.5) + 1);
			if (p == 0)
			{
				p = 0.01;
			}
		}
		return p;
	}
    override function getSubmods()
{
	return ["pulseInner","pulseOuter", "shrinkMult", "shrinkLinear", "pulseOffset", "pulsePeriod"];
}
}

