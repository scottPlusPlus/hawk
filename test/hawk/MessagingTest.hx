package test.hawk;

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
using test.hawk.testutils.PromiseTestUtils;

class MessagingTest extends utest.Test {
	function testSanity() {
		Assert.equals(2, 1 + 1);
	}

	function testPushesSingleMessage(async:utest.Async) {
		var channel = new LocalChannel("foo");
		var sub = new SubscriberTest();
		channel.subscribe(sub.handler);

		var expected = "my secret message";
		var bytes = Bytes.ofString(expected);
		var msg = new Message(bytes);

		channel.publish(msg)
		.thenWait(channel.delayMS + 10)
		.assertNoErr()
		.next(function(_){
			Assert.equals(1, sub.messages.length);
			var actual = sub.messages[0].body().toString();
			Assert.equals(expected, actual);
			async.done();
			return Noise;
		}).eager();
	}

	function testMultipleSubscribers(async:utest.Async) {
		var channel = new LocalChannel("foo");
		var sub1 = new SubscriberTest();
		var sub2 = new SubscriberTest();
		channel.subscribe(sub1.handler);
		channel.subscribe(sub2.handler);

		var expected = "my secret message";
		var bytes = Bytes.ofString(expected);
		var msg = new Message(bytes);


		channel.publish(msg)
		.thenWait(channel.delayMS + 10)
		.assertNoErr()
		.next(function(_){
			Assert.equals(expected, sub1.messages[0].body().toString());

			Assert.equals(expected, sub2.messages[0].body().toString());
			async.done();
			return Noise;
		}).eager();
	}
}

class SubscriberTest {
	public function new() {}

	public var messages:Array<Message> = [];
	public var nextHandleResponse = Success(Noise);

	public function handler(msg:Message):Promise<Noise> {
		messages.push(msg);
		return nextHandleResponse;
	}
}
