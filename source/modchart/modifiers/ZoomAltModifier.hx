package modchart.modifiers;

import modchart.modifiers.PathModifier;
import playfields.NoteField;

class ZoomModifier extends Modifier
{
	override public function getName()
		return 'pulseInner';

	override public function affectsField()
		return true;
    function getPulseInner(){
		var p:Float=1.0;
		if (getValue(player) != 0 || getSubmodValue("pulseOuter") != 0){
			p = ((getValue(player) * 0.5) + 1);
			if (p == 0)
			{
				p=0.01;
			}
		}
		return p;
    }
	override public function getFieldZoom(zoom:Float, beat:Float, songPos:Float, player:Int, field:NoteField)
	{
		var fYOffset:Float = Modifier.offsetY;
		if (getValue(player) != 0 || getSubmodValue("pulseOuter") != 0)
		{
			var sine:Float = FlxMath.fastSin(((fYOffset+ (100.0* (getSubmodValue("pulseOffset",player)))) / (0.4 * (Note.swagWidth + (getSubmodValue("pulsePeriod",player) * Note.swagWidth)))));

			zoom *= (sine * (getSubmodValue("pulseOuter",player) * 0.5)) + getPulseInner();
		}
		if (getSubmodValue("shrinkMult") != 0 && fYOffset >= 0)
			zoom *= 1 / (1 + (fYOffset * (getSubmodValue("shinkMult",player) / 100.0)));

		if (getSubmodValue("shinkLinear", player) != 0 && fYOffset >= 0)
			zoom += fYOffset * (0.5 * getSubmodValue("shinkLinear", player) / Note.swagWidth);

		return zoom;
	}
    override function getSubmods(){
        return ["pulseOuter","shrinkMult","shrinkLinear","pulseOffset","pulsePeriod"];
    }
}