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
using hawk.util.PromiseX;
using hawk.testutils.PromiseTestUtils;

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
	
	function testSanity() {
		Assert.equals(2, 1 + 1);
	}



	function testPushesSingleMessage(async:utest.Async) {
		var channel = newStringChannel();
		var sub = new SubscriberTest();
		channel.subscribe(sub.handler);

		var expected = "my secret message";

		channel.publish(expected)
		.thenWait(channel.delayMS + 10)
		.assertNoErr()
		.next(function(_){
			Assert.equals(1, sub.messages.length);
			var actual = sub.messages[0];
			Assert.equals(expected, actual);
			async.done();
			return Noise;
		}).eager();
	}

	function testMultipleSubscribers(async:utest.Async) {
		var channel = newStringChannel();
		var sub1 = new SubscriberTest();
		var sub2 = new SubscriberTest();
		channel.subscribe(sub1.handler);
		channel.subscribe(sub2.handler);

		var expected = "my secret message";

		channel.publish(expected)
		.thenWait(channel.delayMS + 10)
		.assertNoErr()
		.next(function(_){
			Assert.equals(expected, sub1.messages[0]);
			Assert.equals(expected, sub2.messages[0]);
			async.done();
			return Noise;
		}).eager();
	}
}

class SubscriberTest {
	public function new() {}

	public var messages:Array<String> = [];
	public var nextHandleResponse = Success(Noise);

	public function handler(msg:String):Promise<Noise> {
		messages.push(msg);
		return nextHandleResponse;
	}
}