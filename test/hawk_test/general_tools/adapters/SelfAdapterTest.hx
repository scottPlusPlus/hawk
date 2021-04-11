package hawk_test.general_tools.adapters;

import hawk.general_tools.adapters.SelfAdapter;
import utest.Assert;
import hawk.general_tools.adapters.Adapter;

class SelfAdapterTest  extends utest.Test {

    public function testString(){
        var adapter:Adapter<String,String> = SelfAdapter.create();
        var val = "foo";
        Assert.equals(val, adapter.toA(val));
        Assert.equals(val, adapter.toB(val));
    }

    public function testInt(){
        var adapter:Adapter<Int,Int> = SelfAdapter.create();
        var val = 123;
        Assert.equals(val, adapter.toA(val));
        Assert.equals(val, adapter.toB(val));
    }
}
