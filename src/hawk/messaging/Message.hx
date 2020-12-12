package hawk.messaging;

import haxe.io.BytesData;
import haxe.io.Bytes;

abstract Message(BytesData) {
	public function new(b:Bytes) {
		this = b.getData();
	}

	public function body():Bytes {
		return Bytes.ofData(this);
	}

	public static inline function fromString(str:String):Message {
		return new Message(Bytes.ofString(str));
	}

	public function toString():String {
		return body().toString();
	}
}
