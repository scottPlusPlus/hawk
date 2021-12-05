package hawk.datatypes;

import hawk.general_tools.adapters.TStringAdapter;

abstract Url(String) to String {

	private function new(str:String) {
		this = str;
	}

	@:from
	static public function fromString(s:String) {
        var tu:tink.Url = s;
		return new Url(tu.toString());
	}

	@:to
	public function toString():String {
		return this;
	}

	public static function stringAdapter(): TStringAdapter<Url>{
        return new TStringAdapter(Std.string, fromString);
	}
}