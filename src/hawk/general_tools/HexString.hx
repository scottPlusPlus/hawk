package hawk.general_tools;

import hawk.general_tools.adapters.Adapter;
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

    public static function toStringUTF8(hex:HexString):String {
        var b = Bytes.ofHex(hex);
        return b.toString();
    }

    public static function adapterFromUtf8():StringTAdapter<HexString> {
        return new StringTAdapter(fromStringUTF8, toStringUTF8);
    }

    public static function adapterFromUtf8ToHexAsString():Adapter<String,String> {
        var fromUtf8ToHex = function(str:String):String {
            return fromStringUTF8(str);
        }
        var fromHexToUtf8 = function(str:String):String {
            return toStringUTF8(str);
        }
        return new Adapter(fromUtf8ToHex, fromHexToUtf8);
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