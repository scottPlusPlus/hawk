package hawk.general_tools.adapters;

using yaku_core.NullX;

class CommonAdapters {

    public static function stringIntAdapter():StringTAdapter<Int> {
        var toInt = function(str:String):Int{
            return Std.parseInt(str).nullThrows();
        }
        return new StringTAdapter(toInt, Std.string);
    }
}