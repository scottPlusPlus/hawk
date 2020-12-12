package hawk.datatypes;

import tink.CoreApi.Outcome;
import tink.core.Error;

abstract Password(String) {

    public function new(str:String){
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

    public static function createValid(str:String):Outcome<Password,Error> {
        str = StringTools.trim(str);
        if (str.length < 8){
            return Failure( new Error(ErrorCode.BadRequest, 'password must be at least 8 characters'));
        }
        if (str.length > 128){
          return Failure( new Error(ErrorCode.BadRequest, 'password must be less than 128 chars'));
        }
        return Success( new Password(str));
    }
    
}