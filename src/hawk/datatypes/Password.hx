package hawk.datatypes;

import tink.CoreApi;

abstract Password(String) {
	public function new(str:String) {
		this = str;
	}

	@:from
	static public function fromString(s:String) {
		return new Password(s);
	}

	@:to
	public function toString() {
		return this;
	}

	public function isValid():Outcome<Noise, Error> {
		if (this != StringTools.trim(this)) {
			var err = new Error('password should be trim');
			return Failure(err);
		}
		if (this.length < 8) {
			var err = new Error('password should be at least 8 characters');
			return Failure(err);
		}
		if (this.length > 128) {
			var err = new Error('password must be less than 128 chars');
			return Failure(err);
		}
		return Success(Noise);
	}

	public static function createValid(str:String):Outcome<Password, Error> {
		str = StringTools.trim(str);
		if (str.length < 8) {
			return Failure(new Error('password must be at least 8 characters'));
		}
		if (str.length > 128) {
			return Failure(new Error('password must be less than 128 chars'));
		}
		return Success(new Password(str));
	}
}
