package hawk_test.util;

import yaku_core.test_utils.TestVals;
import zenlog.Log;
import utest.Assert;
import hawk.util.Json;

class JsonTest extends utest.Test {


	function testArrayString() {
        var expected = ["foo", "bar", "etc"];
        var j = Json.write().fromArrayOfString(expected);
        var actual = Json.read().toArrayOfString(j);
		Assert.same(actual, expected);
	}

    function testMapOfString(){
        var expected = new Map<String,String>();
        expected.set(TestVals.key1, TestVals.val1);
        expected.set(TestVals.key2, TestVals.val2);
        var j = Json.write().fromMapOfStringString(expected);
        var actual = Json.read().toMapOfStringString(j);
        Assert.same(expected, actual);
    }

    // function testAnonToJson(){
    //     var test1 = { key1: "foobar", key2: "etc...", key3: 123};
    //     printBoth(test1);

    //     var test2 = { key1: "foobar", key2: ["foo", "bar", "etc"]};
    //     printBoth(test2);
    //     Assert.equals(1,1);
    // }

    function printBoth(obj:Dynamic){
        Log.info("stringify:");
        Log.info(haxe.Json.stringify(obj));
        Log.info("through anon:");
        Log.info(Json.anonToJson(obj));
    }

}