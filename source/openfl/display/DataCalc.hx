package openfl.display;

import flixel.math.FlxMath;
import openfl.Lib;
import ClientPrefs;

class DataCalc
{
	static public var updateFPS:Float = 0;
	static public var drawFPS:Float = 0;

	static private var updateTimeSave:Float = 0;
	static private var updateCount:Int = 0;
	static private var updateInitialized:Bool = false;

	static private var drawTimeSave:Float = 0;
	static private var drawCount:Int = 0;
	static private var drawInitialized:Bool = false;

	static public function update()
	{
		updateCount++;
		var time = Lib.getTimer();

		if (!updateInitialized)
		{
			updateInitialized = true;
			updateTimeSave = time;
			updateCount = 0;
			return;
		}

		if (time - updateTimeSave < 100) return;

		var elapsed:Float = time - updateTimeSave;
		var frameTime:Float = elapsed / updateCount;
		updateFPS = Math.floor(1000 / frameTime + 0.5);

		// TPS 限制在 framerate（更新帧率）
		if (updateFPS > ClientPrefs.framerate)
			updateFPS = ClientPrefs.framerate;

		updateTimeSave = time;
		updateCount = 0;
	}

	static public function draw()
	{
		drawCount++;
		var time = Lib.getTimer();

		if (!drawInitialized)
		{
			drawInitialized = true;
			drawTimeSave = time;
			drawCount = 0;
			return;
		}

		if (time - drawTimeSave < 100) return;

		var elapsed:Float = time - drawTimeSave;
		var frameTime:Float = elapsed / drawCount;
		drawFPS = Math.floor(1000 / frameTime + 0.5);

		if (drawFPS > ClientPrefs.drawFramerate)
			drawFPS = ClientPrefs.drawFramerate;

		drawTimeSave = time;
		drawCount = 0;
	}
}