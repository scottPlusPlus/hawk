package hawk_test.messaging;

import tink.CoreApi;

class SubscriberTester<T> {
	public function new() {}

	public var messages:Array<T> = [];
	public var nextHandleResponse = Success(Noise);

	public function handler(msg:T):Promise<Noise> {
		messages.push(msg);
		return nextHandleResponse;
	}
}