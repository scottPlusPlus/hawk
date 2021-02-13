package hawk.general_tools.adapters;

class SelfAdapter {

    public static function create<T>():Adapter<T,T>{
        var f = function(v:T):T{
            return v;
        }
        return new Adapter<T,T>(f,f);
    }

}