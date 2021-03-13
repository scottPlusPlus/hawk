package hawk.general_tools;

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
} 