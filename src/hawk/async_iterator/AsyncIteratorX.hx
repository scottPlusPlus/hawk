package hawk.async_iterator;

import tink.CoreApi;

class AsyncIteratorX {
	public static function forEach<T>(i:AsyncIterator<T>, handler:T->Promise<Noise>):Promise<Noise> {
		return i.hasNext().flatMap(function(o:Outcome<Bool, Error>):Promise<Noise> {
			return switch o {
				case Failure(err):
					return Promise.reject(err);
				case Success(b):
					if (!b) {
						return Promise.resolve(Noise);
					}
					return i.next().next(function(v:T) {
						return handler(v).next(function(_) {
							return AsyncIteratorX.forEach(i, handler);
						});
					});
			}
		});
	}
}
