package;

import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types;
import sys.thread.Thread;

#if LUA_ALLOWED
import llua.Lua;
import llua.State;
#end

using StringTools;

class DiscordClient
{
	public static var isInitialized:Bool = false;
	
	public function new()
	{
		trace("Discord Client starting...");
		
		final handlers:DiscordEventHandlers = new DiscordEventHandlers();
		handlers.ready = cpp.Function.fromStaticFunction(onReady);
		handlers.disconnected = cpp.Function.fromStaticFunction(onDisconnected);
		handlers.errored = cpp.Function.fromStaticFunction(onError);
		Discord.Initialize("863222024192262205", cpp.RawPointer.addressOf(handlers), false, null);
		
		trace("Discord Client started.");

		while (true)
		{
			#if DISCORD_DISABLE_IO_THREAD
			Discord.UpdateConnection();
			#end
			
			Discord.RunCallbacks();
			Sys.sleep(2);
			//trace("Discord Client Update");
		}

		Discord.Shutdown();
	}
	
	public static function shutdown()
	{
		Discord.Shutdown();
	}
	
	static function onReady(request:cpp.RawConstPointer<DiscordUser>):Void
	{
		final username:String = request[0].username;
		final globalName:String = request[0].username;
		final discriminator:Int = Std.parseInt(request[0].discriminator);

		if (discriminator != 0)
			trace('Discord: Connected to user ${username}#${discriminator} ($globalName)');
		else
			trace('Discord: Connected to user @${username} ($globalName)');

		final discordPresence:DiscordRichPresence = new DiscordRichPresence();
		discordPresence.state = null;
		discordPresence.details = "In the Menus";
		discordPresence.largeImageKey = "icon";
		discordPresence.largeImageText = "Psych Engine";
		discordPresence.startTimestamp = 0;
		discordPresence.endTimestamp = 0;

		Discord.UpdatePresence(cpp.RawConstPointer.addressOf(discordPresence));
	}

	static function onError(errorCode:Int, message:cpp.ConstCharStar):Void
	{
		trace('Discord: Error ($errorCode:$message)');
	}

	static function onDisconnected(errorCode:Int, message:cpp.ConstCharStar):Void
	{
		trace('Discord: Disconnected ($errorCode:$message)');
	}

	public static function initialize()
	{
		var DiscordDaemon = Thread.create(() ->
		{
			new DiscordClient();
		});
		trace("Discord Client initialized");
		isInitialized = true;
	}

	public static function changePresence(details:String, state:Null<String>, ?smallImageKey : String, ?hasStartTimestamp : Bool, ?endTimestamp: Float)
	{
		var startTimestamp:Float = if(hasStartTimestamp) Date.now().getTime() else 0;

		if (endTimestamp > 0)
		{
			endTimestamp = startTimestamp + endTimestamp;
		}

		final discordPresence:DiscordRichPresence = new DiscordRichPresence();
		discordPresence.state = state;
		discordPresence.details = details;
		discordPresence.largeImageKey = "icon";
		discordPresence.largeImageText = "Engine Version: " + MainMenuState.psychEngineVersion;
		discordPresence.smallImageKey = smallImageKey;
		discordPresence.startTimestamp = Std.int(startTimestamp / 1000);
		discordPresence.endTimestamp = Std.int(endTimestamp / 1000);

		Discord.UpdatePresence(cpp.RawConstPointer.addressOf(discordPresence));

		//trace('Discord RPC Updated. Arguments: $details, $state, $smallImageKey, $hasStartTimestamp, $endTimestamp');
	}

	#if LUA_ALLOWED
	public static function addLuaCallbacks(lua:State) {
		Lua_helper.add_callback(lua, "changePresence", function(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float) {
			changePresence(details, state, smallImageKey, hasStartTimestamp, endTimestamp);
		});
	}
	#end
}