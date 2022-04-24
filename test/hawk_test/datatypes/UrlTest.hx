package hawk_test.datatypes;

import yaku_core.test_utils.TestVals;
import yaku_core.test_utils.TestUtils;
import utest.Assert;
import hawk.datatypes.Url;

class UrlTest extends utest.Test {

	private static final exampleUrlStr = "https://www.example.com";

	function testTrim() {
		var bad = "  http://www.test.com  ";
		var expected = StringTools.trim(bad);

		var urlExplicit = new Url(bad);
		var urlImplicit:Url = bad;

		Assert.same(expected, urlExplicit.toString());
		Assert.same(expected, urlImplicit.toString());
	}

	function testJson() {
		var u = new Url(exampleUrlStr);
		var j = Url.toJson(u);
		var u2 = Url.fromJson(j);
		Assert.same(exampleUrlStr, u2.toString());		
	}

	function testTink() {
		var u = new Url(exampleUrlStr);
		var tinkU:tink.Url = u.toString();
		Assert.same("https", tinkU.scheme);
		Assert.same("www.example.com", tinkU.host);
	}

	function testValidation() {
		var u = new Url(TestVals.gibberish);
		var v = Url.validation(u);
		Assert.isFalse(v.isValid());

		u = new Url(exampleUrlStr);
		v = Url.validation(u);
		Assert.isTrue(v.isValid());
	}
}
