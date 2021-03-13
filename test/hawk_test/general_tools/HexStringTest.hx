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

	function testJsonArray() {
		var array = new Array<HexString>();
		var hex = HexString.fromStringUTF8(TestVals.gibberish);
		array.push(hex);
		hex = HexString.fromStringUTF8(TestVals.jibbaJabba);

		var writer = new json2object.JsonWriter<Array<HexString>>();
		var json = writer.write(array);

		var parser = new json2object.JsonParser<Array<HexString>>();
		var arrayOut = parser.fromJson(json);
		Assert.equals(array[0], arrayOut[0]);
	}
}

class Foo {
	public function new() {}

	public var data:HexString;
}
