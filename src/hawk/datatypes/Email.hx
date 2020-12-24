package hawk.datatypes;

import tink.CoreApi;
import js.html.audio.BiquadFilterNode;


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

    public function isValid():Outcome<Noise,Error> {
      if (this != StringTools.trim(this)){
        var err = new Error('email should be trim');
        return Failure(err);
      }
      if (this.length > 128){
        var err = new Error('email must be less than 128 chars');
        return Failure(err);
      }
      
      if (!_regex.match(this)){
        var err = new Error('invalid email address');
        return Failure(err);
      }
      return Success(Noise);
    }

    public static function createValid(str:String):Outcome<Email,Error> {
      str = StringTools.trim(str);
      if (str.length > 128){
        return Failure( new Error('email must be less than 128 chars'));
      }
      
      if (!_regex.match(str)){
        return Failure( new Error('invalid email address'));
      }
      return Success( new Email(str));
  }
}