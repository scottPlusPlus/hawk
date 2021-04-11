package hawk.general_tools.adapters;

abstract StringTAdapter<T>(Adapter<String,T>) {
    
    public function new(fromString:String->T, toString:T->String){
        this = new Adapter<String,T>(fromString, toString);
    }

    public inline function toString(v:T):String {
        return this.toA(v);
    }

    public inline function fromString(v:String):T {
        return this.toB(v);
    }

    public inline function invert():TStringAdapter<T> {
        return this.invert();
    }

    @:to
    public function toAdapter():Adapter<String,T> {
        return this;
    }

    @:from
    public static function fromAdapter<T>(a:Adapter<String,T>) {
        return new StringTAdapter(a.toB, a.toA);
    }
}