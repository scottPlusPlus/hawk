package hawk_test.messaging;

import hawk.general_tools.adapters.CommonAdapters;
import hawk.general_tools.adapters.Adapter;
import yaku_core.PromiseX;
import yaku_core.test_utils.TestVals;
import hawk.messaging.*;
import utest.Assert;
import utest.Async;
import tink.CoreApi;

using yaku_core.test_utils.PromiseTestUtils;

class LocalChannelFactoryTest extends utest.Test {
	public function testLocalChannelFactoryHappy(async:utest.Async) {
		var factory = new LocalChannelFactory();
		var pub:IPublisher<Int>;
		var sub:ISubscriber<Int>;
		var tester = new SubscriberTester<Int>();

		var setup = function() {
			var adapter = CommonAdapters.stringIntAdapter().invert();
			var setp = factory.getPub(TestVals.foo, adapter).next(function(res) {
				pub = res;
				return Noise;
			});
			var sets = factory.getSub(TestVals.foo, adapter).next(function(res) {
				sub = res;
				return Noise;
			});
			return Promise.inParallel([setp, sets]);
		}

		setup().next(function(_) {
			sub.subscribe(tester.handler);
			pub.publish(1);
			pub.publish(2);
			return PromiseX.waitPromise(200);
		}).next(function(_){
			Assert.same([1, 2], tester.messages);
			return Noise;
		}).closeTestChain(async);
	}
}
