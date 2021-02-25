package hawk.general_tools.adapters;

class AdapterX<A,B> {

    public static function arrayToB<A,B>(adapter:Adapter<A,B>, arr:Array<A>):Array<B> {
        var arrB = new Array<B>();
        arrB.resize(arr.length);
        for (i in 0...arr.length){
            arrB[i] = adapter.toB(arr[i]);
        }
        return arrB;
    }

    public static function arrayToA<A,B>(adapter:Adapter<A,B>, arr:Array<B>):Array<A> {
        var arrA = new Array<A>();
        arrA.resize(arr.length);
        for (i in 0...arr.length){
            arrA[i] = adapter.toA(arr[i]);
        }
        return arrA;
    }

    public static function nullAdapter<A,B>(adapter:Adapter<A,B>):Adapter<Null<A>,Null<B>> {
        var aToB = function(a:Null<A>):Null<B>{
            if (a == null){
                return null;
            }
            return adapter.toB(a);
        }
        var bToA = function(b:Null<B>):Null<A>{
            if (b == null){
                return null;
            }
            return adapter.toA(b);
        }
        return new Adapter(aToB, bToA);
    }
}