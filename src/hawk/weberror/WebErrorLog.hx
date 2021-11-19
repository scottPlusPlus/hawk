package hawk.weberror;

import hawk.datatypes.UUID;
import hawk.datatypes.Timestamp;
import tink.core.Error.ErrorCode;

@:access(tink.core.TypedError)
class WebErrorLog {
	public var uid:UUID;
	public var code:ErrorCode;
	public var message:String;
	public var publicMsg:String;
	public var pos:String;
	public var time:Timestamp;
	public var context:String;

	public function new() {}

	public static function fromWebError(err:WebError):WebErrorLog {
		var x = new WebErrorLog();
		x.code = err.code;
		x.context = err.context.join(" - ");
		x.message = err.message;
		x.pos = err.printPos();
		x.publicMsg = err.data.publicMsg;
		x.uid = err.data.uid;
		return x;
	}

	public static function testExample():WebErrorLog {
		var err = new WebError(ErrorCode.I_am_a_Teapot, "Something bad happened with private detals...", "Something bad happeend");
		return WebErrorLog.fromWebError(err);
	}
}
