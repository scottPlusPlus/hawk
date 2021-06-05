package hawk.general_tools;

import hawk.general_tools.adapters.StringTAdapter;
import haxe.io.Bytes;

/**
  Data that has been encoded as a hexidecimal string
**/
abstract HexString(String) {
    
    private function new(str:String){
        this = str;
    }

    public static function fromStringUTF8(str:String){
        var b = Bytes.ofString(str);
        var hex = b.toHex();
        return new HexString(hex);
    }

    public function toStringUTF8():String {
        var b = Bytes.ofHex(this);
        return b.toString();
    }

    public function adapterFromUtf8():StringAdapter<HexString> {
        return new StringTAdapter(toStringUTF8, fromStringUTF8);
    }

    @:from
	static public function fromString(s:String) {
		return new HexString(s);
	}

	@:to
	public function toString() {
		return this;
	}
} 