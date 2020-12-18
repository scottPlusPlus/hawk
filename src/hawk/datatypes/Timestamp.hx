package hawk.datatypes;

/*
* Represents a timestamp, in milliseconds
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
    @:op(A * B) static function mp(a:Timestamp, b:Float):Float;

    public static function now():Timestamp {
        return Timestamp.fromDate(Date.now());
    }

   
}