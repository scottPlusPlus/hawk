package hawk.weberror;

import tink.core.Promise;
import zenlog.Log;
import hawk.weberror.Data;
import tink.core.Error;

using yaku_core.PromiseX;

@:access(tink.core.TypedError)
class WebErrorX {
	// use cases
	// create new webError
	// take a NON web-error and make it one (wrap)
	// cast an Error as a webError
	// alternative is to recast every Promise as a "web promise";
	public static inline function isWebError(err:Error):Bool {
		return Std.is(err.data, Data);
	}

	public static function asWebErr(err:Error):WebError {
		if (!isWebError(err)) {
			return wrapAsWebErr(err);
		}
		return (cast err : WebError);
	}

	private static inline function wrapAsWebErr(err:Error):WebError {
		var data = new Data();
		err.data = data;
		return (cast err : WebError);
	}

	public static function enhanceErr<T>(p:Promise<T>, ?context:String, ?publicMsgFallback:String, ?publicMsgOverride:String):Promise<T> {
		return p.mapError(function(err:Error) {
			var we = asWebErr(err);
			if (context != null) {
				we.addContext(context);
			}
			if (publicMsgOverride != null) {
				we.publicMsg = publicMsgOverride;
			}
			if (publicMsgFallback != null) {
				if (we.publicMsg == null || we.publicMsg.length == 0) {
					we.publicMsg = publicMsgFallback;
				}
			}
			return we.asErr();
		});
	}

	public static function logWebErr<T>(p:Promise<T>, ?store:WebErrorStore):Promise<T> {
		return p.mapError(function(err:Error) {
			Log.warn(err.message);
			if (!isWebError(err)) {
				Log.warn('attempting to logWebErr, but it is not a webError');
				return err;
			}
			if (store != null) {
				// this is done async
				store.push(asWebErr(err)).mapError(function(err:Error) {
					Log.error('WebErrorStore failure! ${err.message}');
					return err;
				}).eager();
			}
			return err;
		});
	}
}

typedef ErrorEnhanceMent = {
	?context:String,
	?publicMsgOverride:String,
	?publicMsgFallback:String,
}
