package hawk_test.store;


import hawk.authservice.AuthUserStore;
import utest.Assert;

using hawk.store.DataModelX;

class DataModelXTest extends utest.Test {

    public function testStringAdapter(){
        var model = AuthUserStore.model();
        var adapter = model.stringAdapter();

        var expected = model.example;
        var str = adapter.toB(expected);
        var actual =  adapter.toA(str);
        Assert.same(expected, actual);
    }

}