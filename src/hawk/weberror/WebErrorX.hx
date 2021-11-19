package hawk.weberror;

import tink.core.Promise;
import zenlog.Log;
import hawk.weberror.Data;
import tink.core.Error;

using yaku_core.PromiseX;

@:access(tink.core.TypedError)
class WebErrorX {

    //use cases
    //create new webError
    //take a NON web-error and make it one (wrap)

    //cast an Error as a webError
    //alternative is to recast every Promise as a "web promise";

    public static inline function isWebError(err:Error):Bool {
        return Std.is(err.data, Data);
    }


    public static function asWebErr(err:Error):WebError {
        if (!isWebError(err)){
            throw('Error is not a WebError');
        }
        return (cast err:WebError);
    }

    private static inline function wrapAsWebErr(err:Error,  code:ErrorCode, publicMsg:String = "An error occurred"):WebError {
        var data = new Data();
        data.publicMsg = publicMsg;
        err.code = code;
        err.data = data;
        return (cast err:WebError);
    }

    public static function ensureWebErr<T>(p:Promise<T>, code:ErrorCode, publicMsg:String):Promise<T> {
        return p.mapError(function(err:Error) {
            if (isWebError(err)){
                return err;
            }
            var we = wrapAsWebErr(err, code, publicMsg);
            return we.asErr();
		});
    }

    public static function errContext<T>(p:Promise<T>, msg:String):Promise<T> {
		return p.mapError(function(err:Error) {
            if (!isWebError(err)){
                Log.warn('attempting to add context to an Error, but it is not a webError. Context:  $msg');
                return err;
            }
            var w = asWebErr(err);
            w.addContext(msg);
            return err;
		});
    }

    public static function logWebErr<T>(p:Promise<T>, ?store:WebErrorStore):Promise<T> {
        return p.mapError(function(err:Error){
            Log.warn(err.message);
            if (!isWebError(err)){
                Log.warn('attempting to logWebErr, but it is not a webError');
                return err;
            }
            if (store != null){
                //this is done async
                store.push(asWebErr(err)).mapError(function(err:Error){
                    Log.error('WebErrorStore failure! ${err.message}');
                    return err;
                }).eager();
            }
            return err;
        });
    }

}