package hawk.datatypes;

import js.html.audio.BiquadFilterNode;
import tink.core.Error;
import tink.CoreApi.Outcome;


abstract Email(String) {

  //see also: http://emailregex.com/
  static final _regex = ~/[A-Z0-9._%-]+@[A-Z0-9.-]+.[A-Z][A-Z][A-Z]?/i;

    private function new(str:String){
        this = str; 
    }

    @:from
    static public function fromString(s:String) {
      return new Email(s);
    }
  
    @:to
    public function toString() {
      return this;
    }

    public static function createValid(str:String):Outcome<Email,Error> {
      str = StringTools.trim(str);
      if (str.length > 128){
        return Failure( new Error(ErrorCode.BadRequest, 'email must be less than 128 chars'));
      }
      
      if (!_regex.match(str)){
        return Failure( new Error(ErrorCode.BadRequest, 'invalid email address'));
      }
      return Success( new Email(str));
  }
}