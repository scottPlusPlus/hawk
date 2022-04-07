package hawk_test.requestlog;

import hawk.requestlog.RequestLogService;
import hawk.requestlog.RequestLogStore;
import hawk.store.LocalMemDataStore;
import tink.core.Noise;
import tink.core.Error;
import zenlog.Log;
import utest.Assert;

using yaku_core.OutcomeX;
using yaku_core.PromiseX;
using yaku_core.NullX;
using yaku_core.test_utils.PromiseTestUtils;

class RequestLogTest extends utest.Test {
	// @:timeout(600)
	function testSanity(async:utest.Async) {
		var service = service();
		Assert.notNull(service);
		var dummyReq = {
			originalUrl: "testUrl",
			ip: "123"
		}
		return service.middlewareHandle(dummyReq, null).next(function(_) {
			return service.printLogs(null).next(function(res) {
				Assert.stringContains("testUrl", res);
				Assert.stringContains("123", res);
				return Noise;
			});
		}).closeTestChain(async);
	}

	function service():RequestLogService {
		var localStore = new LocalMemDataStore(RequestLogStore.model());
		return new RequestLogService(localStore);
	}
}
