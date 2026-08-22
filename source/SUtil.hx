package;

import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
import openfl.utils.Assets as OpenFlAssets;
import openfl.Lib;
import haxe.CallStack.StackItem;
import haxe.CallStack;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import lime.system.System as LimeSystem;

#if android
import android.jni.JNICache;
import android.os.Build.VERSION as AndroidVersion;
import android.os.Build.VERSION_CODES as AndroidVersionCode;
import android.os.Environment as AndroidEnvironment;
import android.Permissions as AndroidPermissions;
import android.Settings as AndroidSettings;
#end

/**
 * A storage class for mobile.
 * @author Mihai Alexandru (M.A. Jigsaw) and Lily (mcagabe19)
 */
class SUtil
{
	#if sys
	public static function getPath():String
	{
		return getStorageDirectory();
	}

	public static function getStorageDirectory(type:StorageType = EXTERNAL, ?folderOverride:String = null):String
	{
		var daPath:String = '';
		#if android
		var folderName:String = (folderOverride != null) ? folderOverride : lime.app.Application.current.meta.get("file");
		switch (type)
		{
			case EXTERNAL:
				daPath = AndroidEnvironment.getExternalStorageDirectory() + '/.' + folderName;
		}
		#elseif ios
		daPath = LimeSystem.documentsDirectory;
		#else
		daPath = Sys.getCwd();
		#end
		daPath = haxe.io.Path.addTrailingSlash(daPath);
		return daPath;
	}

	public static function mkDirs(directory:String):Void
	{
		var total:String = '';
		if (directory.substr(0, 1) == '/')
			total = '/';

		var parts:Array<String> = directory.split('/');
		if (parts.length > 0 && parts[0].indexOf(':') > -1)
			parts.shift();

		for (part in parts)
		{
			if (part != '.' && part != '')
			{
				if (total != '' && total != '/')
					total += '/';

				total += part;

				try
				{
					if (!FileSystem.exists(total))
						FileSystem.createDirectory(total);
				}
				catch (e:haxe.Exception)
					trace('Error while creating folder. (${e.message}');
			}
		}
	}

	public static function doTheCheck():Void
	{
		#if android
		// 检查权限
		if (!hasPermissions())
		{
			requestPermissions();
			return;
		}
		
		createRequiredDirectories();
		#else
		createRequiredDirectories();
		#end
	}

	#if android
	public static function hasPermissions():Bool
	{
		if (AndroidVersion.SDK_INT >= AndroidVersionCode.R)
		{
			var result = AndroidEnvironment.isExternalStorageManager();
			return result;
		}
		else
		{
			var readPerm = AndroidPermissions.getGrantedPermissions().contains('android.permission.READ_EXTERNAL_STORAGE');
			var writePerm = AndroidPermissions.getGrantedPermissions().contains('android.permission.WRITE_EXTERNAL_STORAGE');
			return readPerm && writePerm;
		}
	}

	public static function requestPermissions():Void
	{
		if (AndroidVersion.SDK_INT >= AndroidVersionCode.R)
		{
			// 自动跳转到系统设置
			AndroidSettings.requestSetting('MANAGE_APP_ALL_FILES_ACCESS_PERMISSION');
		}
		else // Android 10 and below
		{
			AndroidPermissions.requestPermissions(['READ_EXTERNAL_STORAGE', 'WRITE_EXTERNAL_STORAGE']);
		}
	}
	#end

	private static function createRequiredDirectories():Void
	{
		try
		{
			mkDirs(SUtil.getPath());

			mkDirs(SUtil.getPath() + 'assets');
			mkDirs(SUtil.getPath() + 'mods');
			mkDirs(SUtil.getPath() + 'crash');
			mkDirs(SUtil.getPath() + 'saves');
			mkDirs(SUtil.getPath() + 'logs');
		}
		catch (e:haxe.Exception)
		{
			trace('Error creating directories: ${e.message}');
		}
	}

	public static function gameCrashCheck():Void
	{
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
	}

	public static function onCrash(e:UncaughtErrorEvent):Void
	{
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();
		dateNow = StringTools.replace(dateNow, " ", "_");
		dateNow = StringTools.replace(dateNow, ":", "'");

		var path:String = "crash/" + "crash_" + dateNow + ".txt";
		var errMsg:String = "";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += e.error;

		try
		{
			mkDirs(SUtil.getPath() + "crash");
			File.saveContent(SUtil.getPath() + path, errMsg + "\n");
			Sys.println("Crash dump saved in " + Path.normalize(path));
		}
		catch (ex:haxe.Exception)
		{
			trace('Could not save crash dump: ${ex.message}');
		}

		Sys.println(errMsg);
		Sys.println("Making a simple alert ...");

		SUtil.showPopUp(errMsg, "Uncaught Error :(!");
		LimeSystem.exit(0);
	}

	public static function saveContent(fileName:String = 'file', fileExtension:String = '.json',
			fileData:String = 'You forgot to add something in your code'):Void
	{
		try
		{
			mkDirs(SUtil.getPath() + 'saves');
			File.saveContent(SUtil.getPath() + 'saves/' + fileName + fileExtension, fileData);
			showPopUp(fileName + " file has been saved.", "Success!");
		}
		catch (e:haxe.Exception)
			trace('File couldn\'t be saved. (${e.message})');
	}

	public static function AutosaveContent(fileName:String = 'file', fileExtension:String = '.json',
			fileData:String = 'You forgot to add something in your code'):Void
	{
		try
		{
			mkDirs(SUtil.getPath() + 'saves');
			File.saveContent(SUtil.getPath() + 'saves/' + fileName + fileExtension, fileData);
		}
		catch (e:haxe.Exception)
			trace('File couldn\'t be saved. (${e.message})');
	}

	public static function saveClipboard(fileData:String = 'You forgot to add something in your code'):Void
	{
		try
		{
			openfl.system.System.setClipboard(fileData);
			showPopUp('Data Saved to Clipboard Successfully!', 'Done :)!');
		}
		catch (e:haxe.Exception)
			trace('Could not save to clipboard. (${e.message})');
	}

	public static function copyContent(copyPath:String, savePath:String):Void
	{
		try
		{
			if (!FileSystem.exists(savePath))
			{
				mkDirs(haxe.io.Path.directory(savePath));
				File.saveBytes(savePath, OpenFlAssets.getBytes(copyPath));
			}
		}
		catch (e:haxe.Exception)
			trace('Could not copy content. (${e.message})');
	}

	public static function showPopUp(message:String, title:String):Void
	{
		#if android
		JNICache.createStaticMethod('org/haxe/extension/Tools', 'showAlertDialog',
			'(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Lorg/haxe/lime/HaxeObject;Ljava/lang/String;Lorg/haxe/lime/HaxeObject;)V')(title,
				message, 'OK', null, null, null);
		#else
		var application = lime.app.Application.current;
		if (application != null && application.window != null)
			application.window.alert(message, title);
		else
			Sys.println('$title\n$message');
		#end
	}
	#end
}

enum StorageType
{
	EXTERNAL;
}