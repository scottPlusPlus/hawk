package hawk.util;

class NullX {

    public static inline function valOr<T>(n:Null<T>, alt:T):T {
        return n != null ? n : alt;
    }

    public static inline function nullSure<T>(n:Null<T>):T {
        if (n == null){
            throw('unexpected null!');
        }
        return n;
    }
}