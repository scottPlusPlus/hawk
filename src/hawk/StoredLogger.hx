package hawk;

import zenlog.ILogger;


class StoredLogger implements ILogger {

    public var wrappedLogger:ILogger;

    public var logs:Array<String> = [];

    public function new(logger:ILogger){
        wrappedLogger = logger;
    }

    public function debug (?message :Dynamic, ?extra :Array<Dynamic>, ?pos :haxe.PosInfos):Void{
        push(message);
        wrappedLogger.debug(message, extra, pos);
    }
    public function info (?message :Dynamic, ?extra :Array<Dynamic>, ?pos :haxe.PosInfos):Void{
        push(message);
        wrappedLogger.info(message, extra, pos);
    }
    public function warn (?message :Dynamic, ?extra :Array<Dynamic>, ?pos :haxe.PosInfos):Void{
        push(message);
        wrappedLogger.warn(message, extra, pos);
    }
    public function error (?message :Dynamic, ?extra :Array<Dynamic>, ?pos :haxe.PosInfos):Void{
        push(message);
        wrappedLogger.error(message, extra, pos);
    }
    public function critical (?message :Dynamic, ?extra :Array<Dynamic>, ?pos :haxe.PosInfos):Void{
        push(message);
        wrappedLogger.critical(message, extra, pos);
    }

    private function push(?message :Dynamic) {
        var str = Std.string(message);
        logs.push(str);
    }

}