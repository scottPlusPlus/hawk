package hawk_test.general_tools.adapters;

import hawk.general_tools.adapters.StringTAdapter;
import hawk.general_tools.adapters.Adapter;
import utest.Assert;

class AdapterTest extends utest.Test {

    private function stringToInt(str:String):Int {
        return Std.parseInt(str);
    }

	function testAdapter() {
        var adapterIS = new Adapter(Std.string, stringToInt);
        Assert.equals("5", adapterIS.toB(5));
        Assert.equals(42, adapterIS.toA("42"));

        var adapterSI = new Adapter(stringToInt, Std.string);
        Assert.equals("5", adapterSI.toA(5));
        Assert.equals(42, adapterSI.toB("42"));
	}

    function testInvert() {
        var adapterIS = new Adapter(Std.string, stringToInt);
        var adapterSI = adapterIS.invert();
        Assert.equals("5", adapterSI.toA(5));
        Assert.equals(42, adapterSI.toB("42"));
    }

    function testStringTAdapter(){
        var stringAdapter = new StringTAdapter(stringToInt, Std.string);
        Assert.equals("5", stringAdapter.toString(5));
        Assert.equals(42, stringAdapter.fromString("42"));

        var adapter = convertAdapter(stringAdapter);
        Assert.equals("5", adapter.toA(5));
        Assert.equals(42, adapter.toB("42"));
    }

    private function convertAdapter<T1,T2>(a:Adapter<T1,T2>):Adapter<T1,T2>{
        return a;
    }
}
