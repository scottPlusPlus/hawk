package hawk.general_tools.adapters;

class Adapter<A,B> {

    private var _toA:B->A;
    private var _toB:A->B;

    public function new(aToB:A->B, bToA:B->A){
        _toA = bToA;
        _toB = aToB;
    }

    public inline function toB(a:A):B{
        return _toB(a);
    }

    public inline function toA(b:B):A{
        return _toA(b);
    }
    
    public function invert():Adapter<B,A> {
        return new Adapter<B,A>(_toA, _toB);
    }
}