package hawk.util;

import zenlog.Log;
import tink.core.Error;

class ErrorX {

    public static inline function wrap(err:Error, ?code:ErrorCode = InternalError, message:String, ?pos:Pos):Error {
        message += '\n${err.message}';
        return Error.withData(code, message, err, pos);
    }

    public static inline function logOut(err:Error){
        Log.error(err.message);
    }

    public static inline function domainErr(message:String, ?pos):Error {
        return new Error(ErrorCode.Forbidden, message, pos);
    }

    public static inline function notYetImplemented():Error {
        return new Error(ErrorCode.Forbidden, "Not yet implemented");
    }

}