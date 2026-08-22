package openfl.display;

import haxe.Timer;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;

import openfl.utils.Assets;

#if gl_stats
import openfl.display._internal.stats.Context3DStats;
import openfl.display._internal.stats.DrawCallContext;
#end
#if flash
import openfl.Lib;
#end

#if openfl
import openfl.system.System;
#end

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end

class FPS extends TextField
{
	public var currentFPS(default, null):Float;
	public var currentTPS(default, null):Float;
	public var DisplayFPS(default, null):Float;
	public var DisplayTPS(default, null):Float;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		currentTPS = 0;
		DisplayFPS = 0;
		DisplayTPS = 0;

		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat(Assets.getFont("assets/fonts/montserrat.ttf").fontName, 12, color);
		autoSize = LEFT;
		multiline = true;
		text = "FPS: ";
		textColor = 0xFFFFFFFF;

		addEventListener(Event.ENTER_FRAME, draw);
		addEventListener(Event.ENTER_UPDATE, update);
	}

	public static var currentColor = 0;
	private var skippedFrames = 0;

	private var ColorArray:Array<Int> = [
		0xFF9400D3,
		0xFF4B0082,
		0xFF0000FF,
		0xFF00FF00,
		0xFFFFFF00,
		0xFFFF7F00,
		0xFFFF0000
	];

	private function update(e:Event):Void
	{
		DataCalc.update();
	}

	private function draw(e:Event):Void
	{
		DataCalc.draw();

		currentTPS = DataCalc.updateFPS;
		currentFPS = DataCalc.drawFPS;

		if (DisplayFPS > currentFPS)
			DisplayFPS = DisplayFPS - 1;
		else if (DisplayFPS < currentFPS)
			DisplayFPS = DisplayFPS + 1;

		if (DisplayTPS > currentTPS)
			DisplayTPS = DisplayTPS - 1;
		else if (DisplayTPS < currentTPS)
			DisplayTPS = DisplayTPS + 1;

		if (ClientPrefs.rainbowFPS)
		{
			if (skippedFrames >= 6)
			{
				if (currentColor >= ColorArray.length) currentColor = 0;
				textColor = ColorArray[currentColor];
				currentColor++;
				skippedFrames = 0;
			}
			else
			{
				skippedFrames++;
			}
		}
		else
		{
			textColor = 0xFFFFFFFF;
		}

		var memoryMegas:Float = Math.abs(FlxMath.roundDecimal(System.totalMemory / 1000000, 1));

		text = "FPS: " + Math.floor(DisplayFPS) + "/" + ClientPrefs.drawFramerate;
		text += "\nTPS: " + Math.floor(DisplayTPS) + "/" + ClientPrefs.framerate;
		text += "\nMemory: " + memoryMegas + " MB";

		if (memoryMegas > 1000)
		{
			var newmemoryMegas:Float = Math.ceil(Math.abs(System.totalMemory) / 10000000 / 1.024) / 100;
			text = "FPS: " + Math.floor(DisplayFPS) + "/" + ClientPrefs.drawFramerate;
			text += "\nTPS: " + Math.floor(DisplayTPS) + "/" + ClientPrefs.framerate;
			text += "\nMemory: " + newmemoryMegas + " GB";
		}

		text += "\nNF Engine V1.0.1\n" + Math.floor(1 / DisplayFPS * 10000 + 0.5) / 10 + "ms";
		text += "\n";
	}
}