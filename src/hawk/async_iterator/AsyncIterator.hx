package hawk.async_iterator;

import tink.CoreApi.Promise;

typedef AsyncIterator<T> = {
	function next():Promise<T>;
	function hasNext():Promise<Bool>;
}