package hawk.general_tools.adapters;

abstract TIntAdapter<T>(Adapter<T,Int>) {
    
    public function new(toInt:T->Int, fromInt:Int->T){
        this = new Adapter<T,Int>(toInt, fromInt);
    }

    public inline function toInt(v:T):Int {
        return this.toB(v);
    }

    public inline function fromInt(v:Int):T {
        return this.toA(v);
    }

    public inline function invert():IntTAdapter<T> {
        return this.invert();
    }

    @:to
    public function toAdapter():Adapter<T,Int> {
        return this;
    }

    @:from
    public static function fromAdapter<T>(a:Adapter<T,Int>) {
        return new TIntAdapter(a.toB, a.toA);
    }
}