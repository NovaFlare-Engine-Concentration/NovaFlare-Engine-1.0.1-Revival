package options;

#if desktop
import Discord.DiscordClient;
#end
#if !macro
import flash.text.TextField;
#end
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;
import openfl.Lib;
import lime.app.Application;
import lime.system.DisplayMode;
using StringTools;

class GraphicsSettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Graphics';
		rpcTitle = 'Graphics Settings Menu';

		var option:Option = new Option('Low Quality',
			'If checked, disables some background details,\ndecreases loading times and improves performance.',
			'lowQuality',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Anti-Aliasing',
			'If unchecked, disables anti-aliasing, increases performance\nat the cost of sharper visuals.',
			'globalAntialiasing',
			'bool',
			true);
		option.showBoyfriend = true;
		option.onChange = onChangeAntiAliasing;
		addOption(option);

		var option:Option = new Option('Shaders',
			'If unchecked, disables shaders.\nIt\'s used for some visual effects, and also CPU intensive for weaker PCs.',
			'shaders',
			'bool',
			true);
		addOption(option);

		#if !html5
		var option:Option = new Option('Framerate',
			"Pretty self explanatory, isn't it?",
			'framerate',
			'int',
			60);
		addOption(option);
		option.minValue = 60;
		option.maxValue = 360;
		option.displayFormat = '%v FPS';
		option.onChange = onChangeFramerate;
		#end

		var option:Option = new Option('Draw Framerate',
			'Maximum rendering framerate.\nSet this to match your monitor refresh rate for smoother visuals.',
			'drawFramerate',
			'int',
			120);
		addOption(option);
		option.minValue = 30;
		option.maxValue = 360;
		option.displayFormat = '%v FPS';
		option.onChange = onChangeDrawFramerate;
	
		var option:Option = new Option('Lock Render',
			'If checked, limits rendering to Draw Framerate.\nTurn OFF for maximum FPS (may cause screen tearing).',
			'lockRender',
			'bool',
			false);
		option.onChange = onChangeLockRender;
		addOption(option);

		#if sys
		var option:Option = new Option('Render Thread',
			'If checked, enables multithreaded rendering.\nCan improve performance on multi-core CPUs.',
			'renderThread',
			'bool',
			true);
		option.onChange = onChangeRenderThread;
		addOption(option);
		#end

		super();
	}

	function onChangeAntiAliasing()
	{
		for (sprite in members)
		{
			var sprite:Dynamic = sprite;
			var sprite:FlxSprite = sprite;
			if(sprite != null && (sprite is FlxSprite) && !(sprite is FlxText)) {
				sprite.antialiasing = ClientPrefs.globalAntialiasing;
			}
		}
	}

	function onChangeFramerate()
	{
		FlxG.updateFramerate = ClientPrefs.framerate;
		if (FlxG.updateFramerate < FlxG.drawFramerate) {
			FlxG.updateFramerate = FlxG.drawFramerate;
		}
	}

	function onChangeDrawFramerate()
	{
		FlxG.drawFramerate = ClientPrefs.drawFramerate;
		#if sys
		FlxG.stage.application.window.lockRender = ClientPrefs.lockRender;
		#end

		if (FlxG.drawFramerate > FlxG.updateFramerate) {
			FlxG.updateFramerate = FlxG.drawFramerate;
		}
	}

	function onChangeLockRender()
	{
		#if sys
		FlxG.stage.application.window.lockRender = ClientPrefs.lockRender;
		#end
	}

	function onChangeRenderThread()
	{
		#if sys
		lime.graphics.opengl.GL.setMultiThreaded(ClientPrefs.renderThread);
		#end
	}
}