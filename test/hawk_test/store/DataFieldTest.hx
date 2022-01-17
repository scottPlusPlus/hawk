package hawk_test.store;

import hawk.store.DataField;
import utest.Assert;

class DataFieldTest extends utest.Test {
	public function testValidation() {
		var field = new DataField("validfield");
		var errs = field.validationErrors();
		Assert.equals(0, errs.length);

		var invalidNames = [
			"my field",
			"MyField",
			"field123",
			"field_foo",
			"",
			"field ",
			"f'ld",
			"f{ield"
		];
		for (invalid in invalidNames) {
			field.name = invalid;
			errs = field.validationErrors();
			Assert.equals(1, errs.length, 'invalid field passed:  ${invalid}');
		}
	}
}
