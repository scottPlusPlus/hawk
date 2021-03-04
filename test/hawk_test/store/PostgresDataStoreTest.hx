package hawk_test.store;

import hawk.store.PostgresDataStore;
import utest.Assert;
import utest.Async;

class PostgresDataStoreTest extends utest.Test {
	public function testCompiles() {
		var db = new PostgresDataStore(null, "foo", null);
		Assert.notNull(db);
	}
}
