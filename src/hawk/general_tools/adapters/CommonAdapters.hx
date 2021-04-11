package hawk.general_tools.adapters;

using hawk.util.NullX;

class CommonAdapters {

    public static function stringIntAdapter():StringTAdapter<Int> {
        var toInt = function(str:String):Int{
            return Std.parseInt(str).nullThrows();
        }
        return new StringTAdapter(toInt, Std.string);
    }
}