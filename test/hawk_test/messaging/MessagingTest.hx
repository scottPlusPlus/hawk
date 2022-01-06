package hawk_test.messaging;

import tink.core.Promise;
import tink.CoreApi.Error;
import tink.CoreApi.Noise;
import tink.CoreApi.Outcome;
import hawk.messaging.*;
import utest.Assert;
import utest.Async;
import haxe.io.Bytes;

using tink.CoreApi.OutcomeTools;
using yaku_core.PromiseX;
using yaku_core.test_utils.PromiseTestUtils;

class MessagingTest extends utest.Test {
	
	public function newStringChannel():LocalChannel<String> {
		var toMsg = function(str:String):Message {
			return Message.fromString(str);
		}
		var fromMsg = function(msg:Message):String {
			return msg.toString();
		}
		var channel = new LocalChannel("foo", toMsg, fromMsg);
		return channel;
	}


	function testPushesSingleMessage(async:utest.Async) {
		var channel = newStringChannel();
		var sub = new SubscriberTester<String>();
		channel.subscribe(sub.handler);

		var expected = "my secret message";

		channel.publish(expected)
		.thenWait(channel.delayMS + 10)
		.assertNoErr()
		.next(function(_){
			Assert.equals(1, sub.messages.length);
			var actual = sub.messages[0];
			Assert.equals(expected, actual);

			return Noise;
		}).closeTestChain(async);
	}

	function testMultipleSubscribers(async:utest.Async) {
		var channel = newStringChannel();
		var sub1 = new SubscriberTester<String>();
		var sub2 = new SubscriberTester<String>();
		channel.subscribe(sub1.handler);
		channel.subscribe(sub2.handler);

		var expected = "my secret message";

		channel.publish(expected)
		.thenWait(channel.delayMS + 10)
		.assertNoErr()
		.next(function(_){
			Assert.equals(expected, sub1.messages[0]);
			Assert.equals(expected, sub2.messages[0]);

			return Noise;
		}).closeTestChain(async);
	}
}
