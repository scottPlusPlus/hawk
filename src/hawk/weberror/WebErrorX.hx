package hawk.weberror;

import zenlog.Log;
import hawk.weberror.Data;
import tink.core.Error;

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


    public static function asWebErr(err:Error):Null<WebError> {
        if (!isWebError(err)){
            throw('Error is not a WebError');
        }
        return (cast err:WebError);
    }

    public static function wrapAsWebErr(err:Error,  code:ErrorCode, publicMsg:String = "An error occurred"):WebError {
        var data = new Data();
        data.publicMsg = publicMsg;
        err.code = code;
        err.data = data;
        return (cast err:WebError);
    }

}