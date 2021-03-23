package hawk.testutils;

import haxe.ds.ArraySort;
import zenlog.ILogger;
import haxe.CallStack;

using hawk.util.NullX;

class TestLogger implements  ILogger {

    public function new(l:ILogger, ?config:Config){
		wrappedLogger = l;
		if (config == null){
			config = defaultConfig();
		}
		this.config = config;
    }

    public var wrappedLogger:ILogger;

	public var messageStack:Array<Message>;

	public var activeTestName:String;

	public var activeConfig:Config;
	public var config:Config;


	public static function defaultConfig():Config {
		return {
			debugEnabled: false,
			enableDebugOnCritical: true,
			enableDebugOnWarn: true,
			enableDebugOnError: true,
			indentChar: " . ."
		}
	}


	public function beginTest(testName:String = ""):Void {
		messageStack = [];
		activeConfig = copyConfig(config);
		activeTestName = testName;
		debug("Begin Test: " + activeTestName);
		messageStack[0].stackSize = 0;
	}

    public function enableDebug():Void {
        activeConfig.debugEnabled = true;
    }

	public function debug(?message:Dynamic, ?extra:Array<Dynamic>, ?pos:haxe.PosInfos):Void {
		if (activeConfig == null){
			wrappedLogger.debug(message, extra, pos);
			return;
		}
		storeLog(LogLevel.DEBUG, message, extra, pos);
	}

	public function info(?message:Dynamic, ?extra:Array<Dynamic>, ?pos:haxe.PosInfos):Void {
		if (activeConfig == null){
			wrappedLogger.info(message, extra, pos);
			return;
		}
		storeLog(LogLevel.INFO, message, extra, pos);
	}

	public function warn(?message:Dynamic, ?extra:Array<Dynamic>, ?pos:haxe.PosInfos):Void {
		if (activeConfig == null){
			wrappedLogger.warn(message, extra, pos);
			return;
		}
		if (activeConfig.enableDebugOnWarn){
			activeConfig.debugEnabled = true;
		}
		storeLog(LogLevel.WARN, message, extra, pos);
	}

	public function error(?message:Dynamic, ?extra:Array<Dynamic>, ?pos:haxe.PosInfos):Void {
		if (activeConfig == null){
			wrappedLogger.error(message, extra, pos);
			return;
		}
		if (activeConfig.enableDebugOnError){
			activeConfig.debugEnabled = true;
		}
		storeLog(LogLevel.ERROR, message, extra, pos);
	}

	public function critical(?message:Dynamic, ?extra:Array<Dynamic>, ?pos:haxe.PosInfos):Void {
		if (activeConfig == null){
			wrappedLogger.critical(message, extra, pos);
			return;
		}
		if (activeConfig.enableDebugOnCritical){
			activeConfig.debugEnabled = true;
		}
		storeLog(LogLevel.CRITICAL, message, extra, pos);
	}

	public function finishTest(){
		debug("Finish Test: " + activeTestName);
		messageStack[messageStack.length-1].stackSize = 0;

		var messages = messageStack;
		if (!activeConfig.debugEnabled){
			messages = messages.filter(function(msg){
				return msg.level != DEBUG;
			});
		}
		if (messages.length == 0){
			return;
		}

		var messages = crunchIndentationLevels(messageStack);
		messages.map(function(msg){
			return prefixMessage(msg);
		});

		for (msg in messageStack){
			switch (msg.level) {
				case DEBUG:
					wrappedLogger.debug(msg.message, msg.extra, msg.pos);
				case INFO:
					wrappedLogger.info(msg.message, msg.extra, msg.pos);
				case WARN:
					wrappedLogger.warn(msg.message, msg.extra, msg.pos);
				case ERROR:
					wrappedLogger.error(msg.message, msg.extra, msg.pos);
				case CRITICAL:
					wrappedLogger.critical(msg.message, msg.extra, msg.pos);
			}
		}
	}

	private function prefixMessage(msg:Message):Message {
		if (msg.message == null){
			return msg;
		}
		var prefix = indentationPrefix(msg.stackSize);
		if (prefix.length > 0){
			msg.message = prefix + msg.message;
		}
		return msg;
	}

	private function indentationPrefix(size:Int):String {
		var res = "";
		for (_ in 0...size){
			res += activeConfig.indentChar;
		}
		if (res.length > 0){
			res += " ";
		}
		return res;
	}

	private static function crunchIndentationLevels(messages:Array<Message>):Array<Message>{
		if (messages.length == 0){
			return messages;
		}

		var stackSizes = messages.map(function(msg){
			return msg.stackSize;
		});
		stackSizes.sort(function(a,b){
			return a-b;
		});

		var stackSizesUnique = new Array<Int>();
		for (item in stackSizes){
			if (!stackSizesUnique.contains(item)){
				stackSizesUnique.push(item);
			}
		}

		var stackSizeMap = new Map<Int,Int>();
		for (i in 0...stackSizesUnique.length){
			stackSizeMap.set(stackSizesUnique[i], i);
		}
		
		return messages.map(function(msg){
			msg.stackSize = stackSizeMap.get(msg.stackSize).valOr(0);
			return msg;
		});
	}



	private inline function storeLog(level:LogLevel, ?message:Dynamic,  ?extra:Array<Dynamic>, ?pos:haxe.PosInfos):Void {
		var size = callStackSize();
		var msg = {
			level: level,
			stackSize: size,
			message: message,
			extra: extra,
			pos: pos
		}
		messageStack.push(msg);
	}

	private inline function callStackSize():Int {
		var res = 0;
		try {
			res = CallStack.callStack().length;
		} catch (e:Dynamic){

		}
		return res;
	}

	private static function copyConfig(c:Config):Config {
		return {
			debugEnabled: c.debugEnabled,
			enableDebugOnCritical: c.enableDebugOnCritical,
			enableDebugOnWarn: c.enableDebugOnWarn,
			enableDebugOnError: c.enableDebugOnError,
			indentChar: c.indentChar
		}
	}
}


typedef Config = {
	debugEnabled:Bool,
	enableDebugOnError:Bool,
	enableDebugOnWarn:Bool,
	enableDebugOnCritical:Bool,
	indentChar:String
}


typedef Message = {
	?level:LogLevel,
	stackSize:Int,
	?message:Dynamic,
	?extra:Array<Dynamic>,
	?pos:haxe.PosInfos
}