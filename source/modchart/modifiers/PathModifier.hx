package modchart.modifiers;

import playfields.NoteField;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import math.Vector3;
import playfields.NoteField;

class PathModifier extends NoteModifier
{
	override function getName()
		return 'tornado';

	inline function square(angle:Float)
	{
		var fAngle = angle % (Math.PI * 2);

		return fAngle >= Math.PI ? -1.0 : 1.0;
	}

	inline function triangle(angle:Float)
	{
		var fAngle:Float = angle % (Math.PI * 2.0);
		if (fAngle < 0.0)
		{
			fAngle += Math.PI * 2.0;
		}
		var result:Float = fAngle * (1 / Math.PI);
		if (result < .5)
		{
			return result * 2.0;
		}
		else if (result < 1.5)
		{
			return 1.0 - ((result - .5) * 2.0);
		}
		else
		{
			return -4.0 + (result * 2.0);
		}
	}

	override function getPos(diff:Float, tDiff:Float, beat:Float, pos:Vector3, data:Int, player:Int, obj:FlxSprite, field:NoteField)
	{
        if(getSubmodValue("zigzag", player) != 0){
			var offset = getSubmodValue("zigzagOffset", player);
			var period = getSubmodValue("zigzagPeriod", player);
			var perc = getSubmodValue("zigzag", player);

			var result:Float = triangle((Math.PI * (1 / (period + 1)) * ((diff + (100 * (offset))) / Note.swagWidth)));

			pos.x += (perc * Note.swagWidth * 0.5) * result;
        }
        
        if(getSubmodValue("sawtooth", player) != 0){
			var percent = getSubmodValue('sawtooth', player);
			var period = (getSubmodValue("sawtoothPeriod", player)) + 1;
			pos.x += (percent * Note.swagWidth) * ((0.5 / period * diff) / Note.swagWidth - Math.floor((0.5 / period * diff) / Note.swagWidth));
        }

		if (getSubmodValue("square", player) != 0)
		{
			var offset = getSubmodValue("squareOffset", player);
			var period = getSubmodValue("squarePeriod", player);
			var cum:Float = (Math.PI * (diff + offset) / (Note.swagWidth + (period * Note.swagWidth)));
			var fResult = square(cum);

			pos.x += getSubmodValue('square', player) * Note.swagWidth * 0.5 * fResult;
		}

        if(getSubmodValue("bounce", player)!=0){
			var offset = getSubmodValue("bounceOffset", player);
			var period = getSubmodValue("bouncePeriod", player);
			var bounce:Float = Math.abs(FlxMath.fastSin(((diff + offset) / (90
				+ (period * 90)))));
            //Math.abs(FlxMath.fastSin(((diff + (1 * (offset))) / (90 + 90 * period))));

			pos.x += getSubmodValue('bounce', player) * Note.swagWidth * 0.5 * bounce;
        }


        if(getSubmodValue("xmode", player) != 0){
			var mod = (player + 1) * 2 - 3;
			pos.x += getSubmodValue('xmode', player) * (diff * mod);
        }

		if(getSubmodValue("parabola",player)!=0)
			pos.x += getSubmodValue("parabola", player) * (diff / Note.swagWidth) * (diff / Note.swagWidth);

		if (getSubmodValue("digital", player) != 0){
			var daShits:Float = Math.PI * (diff + (1.0 * getSubmodValue("digitalOffset",
				player))) / (Note.swagWidth + (getSubmodValue("digitalPeriod", player) * Note.swagWidth));
			pos.x += (getSubmodValue("digital",player) * Note.swagWidth * 0.5) * Math.round((getSubmodValue("digitalSteps",player) + 1) * FlxMath.fastSin(daShits)) / (getSubmodValue("digitalSteps",player) + 1);

		}
		if (getSubmodValue("zigzagZ", player) != 0)
		{
			var offset = getSubmodValue("zigzagZOffset", player);
			var period = getSubmodValue("zigzagZPeriod", player);
			var perc = getSubmodValue("zigzagZ", player);

			var result:Float = triangle((Math.PI * (1 / (period + 1)) * ((diff + (100 * (offset))) / Note.swagWidth)));

			pos.z += (perc * Note.swagWidth * 0.5) * result;
		}

		if (getSubmodValue("sawtoothZ", player) != 0)
		{
			var percent = getSubmodValue('sawtoothZ', player);
			var period = (getSubmodValue("sawtoothZPeriod", player)) + 1;
			pos.z += (percent * Note.swagWidth) * ((0.5 / period * diff) / Note.swagWidth - Math.floor((0.5 / period * diff) / Note.swagWidth));
		}

		if (getSubmodValue("squareZ", player) != 0)
		{
			var offset = getSubmodValue("squareZOffset", player);
			var period = getSubmodValue("squareZPeriod", player);
			var cum:Float = (Math.PI * (diff + offset) / (Note.swagWidth + (period * Note.swagWidth)));
			var fResult = square(cum);

			pos.z += getSubmodValue('squareZ', player) * Note.swagWidth * 0.5 * fResult;
		}

		if (getSubmodValue("bounceZ", player) != 0)
		{
			var offset = getSubmodValue("bounceZOffset", player);
			var period = getSubmodValue("bounceZPeriod", player);
			var bounce:Float = Math.abs(FlxMath.fastSin(((diff + offset) / (90 + (period * 90)))));
			// Math.abs(FlxMath.fastSin(((diff + (1 * (offset))) / (90 + 90 * period))));

			pos.z += getSubmodValue('bounceZ', player) * Note.swagWidth * 0.5 * bounce;
		}

		if (getSubmodValue("parabolaZ", player) != 0)
			pos.z += getSubmodValue("parabolaZ", player) * (diff / Note.swagWidth) * (diff / Note.swagWidth);

		if (getSubmodValue("digitalZ", player) != 0)
		{
			var daShits:Float = Math.PI * (diff + (1.0 * getSubmodValue("digitalZOffset",
				player))) / (Note.swagWidth + (getSubmodValue("digitalZPeriod", player) * Note.swagWidth));
			pos.z += (getSubmodValue("digitalZ",
				player) * Note.swagWidth * 0.5) * Math.round((getSubmodValue("digitalZSteps",
					player) + 1) * FlxMath.fastSin(daShits)) / (getSubmodValue("digitalZSteps", player) + 1);
		}
		if (getValue(player) != 0)
		{
			// from schmovin!!
			var playerColumn = data % 4;
			var columnPhaseShift = playerColumn * Math.PI / 3;
			var phaseShift = diff / 135;
			var returnReceptorToZeroOffsetX = (-Math.cos(-columnPhaseShift) + 1) * 0.5 * Note.swagWidth * 3;
			var offsetX = (-Math.cos(phaseShift - columnPhaseShift) + 1) * 0.5 * Note.swagWidth * 3 - returnReceptorToZeroOffsetX;
			pos.x += offsetX * getValue(player);
		}
		if (getSubmodValue("tornadoZ",player) != 0)
		{
			var playerColumn = data % 4;
			var columnPhaseShift = playerColumn * Math.PI / 3;
			var phaseShift = diff / 135;
			var returnReceptorToZeroOffsetX = (-Math.cos(-columnPhaseShift) + 1) * 0.5 * Note.swagWidth * 3;
			var offsetX = (-Math.cos(phaseShift - columnPhaseShift) + 1) * 0.5 * Note.swagWidth * 3 - returnReceptorToZeroOffsetX;
			pos.z += offsetX * getSubmodValue("tornadoZ", player);
		}
		return pos;
	}

	override function getSubmods()
	{
		return [
            'xmode',

            'zigzag',
            'zigzagPeriod',
            'zigzagOffset',

            'sawtooth',
            'sawtoothPeriod',

            'square',
            'squareOffset',
            'squarePeriod',

            'bounce',
            'bounceOffset',
            'bouncePeriod',

			'parabola',

			'digital',
			'digitalSteps',
			'digitalOffset',
			'digitalPeriod',

			'zigzagZ',
			'zigzagZPeriod',
			'zigzagZOffset',

			'sawtoothZ',
			'sawtoothZPeriod',

			'squareZ',
			'squareZOffset',
			'squareZPeriod',

			'bounceZ',
			'bounceZOffset',
			'bounceZPeriod',

			'parabolaZ',

			'digitalZ',
			'digitalZSteps',
			'digitalZOffset',
			'digitalZPeriod',

			'tornadoZ'
            // TODO: maybe some sorta scrollDirectionX/Y/Z which'll make it so the note moves towards the receptor in that direction
        ];
	}
}