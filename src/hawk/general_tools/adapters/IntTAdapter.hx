package hawk.general_tools.adapters;

abstract IntTAdapter<T>(Adapter<Int,T>) {
    
    public function new(fromInt:Int->T, toInt:T->Int){
        this = new Adapter<Int,T>(fromInt, toInt);
    }

    public inline function toInt(v:T):Int {
        return this.toA(v);
    }

    public inline function fromInt(v:Int):T {
        return this.toB(v);
    }

    public inline function invert():TIntAdapter<T> {
        return this.invert();
    }

    @:to
    public function toAdapter<T>():Adapter<Int,T> {
        return this;
    }

    @:from
    public static function fromAdapter<T>(a:Adapter<Int,T>) {
        return new IntTAdapter(a.toB, a.toA);
    }
}