package hawk.general_tools.adapters;

abstract TStringAdapter<T>(Adapter<T,String>) {
    
    public function new(toString:T->String, fromString:String->T){
        this = new Adapter<T,String>(toString, fromString);
    }

    public inline function toString(v:T):String {
        return this.toB(v);
    }

    public inline function fromString(v:String):T {
        return this.toA(v);
    }

    public inline function invert():StringTAdapter<T> {
        return this.invert();
    }

    @:to
    public function toAdapter():Adapter<T,String> {
        return this;
    }

    @:from
    public static function fromAdapter<T>(a:Adapter<T,String>) {
        return new TStringAdapter(a.toB, a.toA);
    }
}