package hawk.datatypes;

import tink.core.Outcome;
import tink.core.Error;
import hawk.general_tools.adapters.StringTAdapter;
/*
* Represents a unix timestamp, in milliseconds
*/
abstract Timestamp(UInt) to UInt to Int {

    private function new(v:UInt){
        this = v;
    }

    @:from
    static public function fromUInt(v:UInt) {
      return new Timestamp(v);
    }
  
    @:to
    public function toUInt():UInt {
      return this;
    }

    @:from
    static public function fromInt(v:Int):Timestamp{
        return Timestamp.fromUInt(v);
    }

    @:to
    public function toInt():Int {
      return this;
    }

    @:from
    static public function fromDate(v:Date) {
        var val = Math.floor(v.getTime());
        return new Timestamp(val);
    }
  
    @:to
    public function toDate():Date {
      return Date.fromTime(this);
    }

    @:op(A > B) static function gt(a:Timestamp, b:Timestamp):Bool;
    @:op(A < B) static function ls(a:Timestamp, b:Timestamp):Bool;
    @:op(A + B) static function add(a:Timestamp, b:Timestamp):Timestamp;
    @:op(A - B) static function sub(a:Timestamp, b:Timestamp):Timestamp;
    @:op(A * B) static function mp(a:Timestamp, b:Int):Timestamp;


    public static function now():Timestamp {
        return Timestamp.fromDate(Date.now());
    }

    public static function toString(t:Timestamp):String { 
      return Std.string(t.toUInt());
    }

    public static function fromString(str:String):Timestamp {
      var i = Std.parseInt(str);
      return fromInt(i);
    }


    static final _regex = ~/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/i;

    public static function fromFormString(str:String):Outcome<Timestamp,Error> {
      var str = StringTools.replace(str, "T", " ");
      while (str.length < 19){
        str += ":00";
      }
      if (!_regex.match(str)){
        return Failure(new Error('no match'));
      }
      var d = Date.fromString(str);
      return Success(fromDate(d)); 
    }


    public static final HOUR:Timestamp = Timestamp.fromUInt(1000 * 60 * 60);
    public static final SECOND:Timestamp = Timestamp.fromUInt(1000);
    public static final DAY:Timestamp = Timestamp.fromUInt(1000 * 60 * 60 * 24);

    public static function fromJson(j:String):Timestamp {
      return Timestamp.fromString(j);
    }
  
    public static function toJson(x:Timestamp):String {
      return Timestamp.toString(x);
    }
  
    public static final jsonAdapter = new StringTAdapter(Timestamp.fromJson, Timestamp.toJson);
}