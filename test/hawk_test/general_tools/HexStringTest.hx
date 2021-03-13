package hawk_test.general_tools;

import hawk.testutils.TestVals;
import hawk.general_tools.HexString;
import hawk.testutils.TestLogger;
import zenlog.Log;
import utest.Assert;

class HexStringTest extends utest.Test {
	function testInOut() {
		var hex = HexString.fromStringUTF8(TestVals.gibberish);
		var strRes = hex.toStringUTF8();
		Assert.equals(TestVals.gibberish, strRes);
	}

	function testJson() {
		var blob = new Foo();
		blob.data = HexString.fromStringUTF8(TestVals.gibberish);
		var writer = new json2object.JsonWriter<Foo>();
		var json = writer.write(blob);

		var parser = new json2object.JsonParser<Foo>();
		var blobOut = parser.fromJson(json);
		var actual = blobOut.data.toStringUTF8();
		Assert.equals(TestVals.gibberish, actual);
	}
}

class Foo {
	public function new() {}

	public var data:HexString;
}
