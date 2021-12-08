package hawk.datatypes;

import hawk.general_tools.adapters.TStringAdapter;

abstract Url(String) to String {

	private function new(str:String) {
		this = str;
	}

	@:from
	static public function fromString(s:String) {
		//TODO - ensure it's an actual url
		return new Url(s);
	}

	@:to
	public function toString():String {
		return this;
	}

	public static function stringAdapter(): TStringAdapter<Url>{
        return new TStringAdapter(Std.string, fromString);
	}
}