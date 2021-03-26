package hawk_test.store;

import hawk.store.postgres.PostgresDataStoreFactory;
import hawk.store.postgres.PostgresKVStoreFactory;
import hawk.authservice.AuthUserStore;
import hawk.store.postgres.PostgresDataStore;
import utest.Assert;
import utest.Async;

class PostgresStoreFactoriesTest extends utest.Test {
	public function testKVStoreFactoryCompiles() {
        var factory = new PostgresKVStoreFactory(123);
		Assert.notNull(factory);
	}

    public function testDataStoreFactoryCompiles(){
        var factory = new PostgresDataStoreFactory(123);
		Assert.notNull(factory);
    }
}
