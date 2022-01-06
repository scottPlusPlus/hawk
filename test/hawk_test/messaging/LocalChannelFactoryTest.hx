package hawk_test.messaging;

import yaku_core.PromiseX;
import yaku_core.test_utils.TestVals;
import hawk.messaging.*;
import utest.Assert;
import utest.Async;
import tink.CoreApi;

using hawk.testutils.PromiseTestUtils;

class LocalChannelFactoryTest extends utest.Test {
	public function testLocalChannelFactoryHappy(async:utest.Async) {
		var factory = new LocalChannelFactory();
		var pub:IPublisher<String>;
		var sub:ISubscriber<String>;
		var tester = new SubscriberTester<String>();

		var setup = function() {
			var setp = factory.getPub(TestVals.foo).next(function(res) {
				pub = res;
				return Noise;
			});
			var sets = factory.getSub(TestVals.foo).next(function(res) {
				sub = res;
				return Noise;
			});
			return Promise.inParallel([setp, sets]);
		}

		setup().next(function(_) {
			sub.subscribe(tester.handler);
			pub.publish(TestVals.gibberish);
			pub.publish(TestVals.jibbaJabba);
			return PromiseX.waitPromise(200);
		}).next(function(_){
			Assert.same([TestVals.gibberish, TestVals.jibbaJabba], tester.messages);
			return Noise;
		}).closeTestChain(async);
	}
}
