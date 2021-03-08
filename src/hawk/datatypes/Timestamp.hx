package hawk.datatypes;

/*
* Represents a unix timestamp, in milliseconds
*/
abstract Timestamp(UInt) {

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


    public static final HOUR:Timestamp = Timestamp.fromUInt(1000 * 60 * 60);
    public static final SECOND:Timestamp = Timestamp.fromUInt(1000);
    public static final DAY:Timestamp = Timestamp.fromUInt(1000 * 60 * 60 * 24);
}