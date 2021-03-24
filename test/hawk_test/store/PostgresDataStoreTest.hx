package hawk_test.store;

import hawk.authservice.AuthUserStore;
import hawk.store.postgres.PostgresDataStore;
import utest.Assert;
import utest.Async;

class PostgresDataStoreTest extends utest.Test {
	public function testCompiles() {
		var db = new PostgresDataStore(null, "foo", AuthUserStore.model());
		Assert.notNull(db);
	}
}
