package hawk_test.general_tools.adapters;

import utest.Assert;
import hawk.general_tools.adapters.Adapter;
import hawk.general_tools.adapters.CommonAdapters;

class StringAdapterTest  extends utest.Test {

    public function testCasts(){
        var valS = "42";
        var valI = 42;

        var aStringInt = CommonAdapters.stringIntAdapter();
        var aIntString = aStringInt.invert();

        var genaStringInt:Adapter<String,Int> = aStringInt;
        aStringInt = genaStringInt;
        Assert.equals(valI, genaStringInt.toB(valS));
        Assert.equals(valI, aStringInt.fromString(valS));
        
        var genaIntString:Adapter<Int,String> = aIntString;
        aIntString = genaIntString;
        Assert.equals(valS, genaStringInt.toA(valI));
        Assert.equals(valS, aStringInt.toString(valI));
    }
}
