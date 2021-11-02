package hawk_test.macros;

import utest.Assert;
import hawk.general_tools.adapters.TStringAdapter;

class JsonizeTest extends utest.Test {
	
    function testJsonizeToFrom() {
        var obj = new JTest(4);
        var json = JTest.toJson(obj);
        var obj2 = JTest.fromJson(json);
		Assert.equals(4, obj2.data);
	}
}

@:build(hawk.macros.Jsonize.process())
class JTest {
	public function new(val:Int) {
        this.data = val;
    }
	public var data:Int;
}
