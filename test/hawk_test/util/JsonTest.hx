package hawk_test.util;

import utest.Assert;
import hawk.util.Json;

class JsonTest extends utest.Test {


	function testArrayString() {
        var expected = ["foo", "bar", "etc"];
        var j = Json.write().fromArrayOfString(expected);
        var actual = Json.read().toArrayOfString(j);
		Assert.same(actual, expected);
	}

}