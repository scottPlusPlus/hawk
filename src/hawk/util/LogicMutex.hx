package hawk.util;

import tink.CoreApi;
import polygonal.ds.ArrayedQueue;

class LogicMutex {
	private var _queue:ArrayedQueue<PromiseTrigger<Lock>>;
	private var _currentLock:Lock;

	public function new() {
        _queue = new ArrayedQueue<PromiseTrigger<Lock>>();
    }

	public function aquire():Promise<Lock> {
		var p = new PromiseTrigger<Lock>();
		if (_currentLock == null) {
			_currentLock = newLock();
			p.resolve(_currentLock);
		} else {
			_queue.enqueue(p);
		}
		return p;
	}

	private function newLock():Lock {
		return new Lock(lockReleased);
	}

	private function lockReleased() {
		if (_queue.isEmpty()) {
			_currentLock = null;
			return;
		}
		_currentLock = newLock();
		var p = _queue.dequeue();
		p.resolve(_currentLock);
	}
}

class Lock {
	public function new(onRelease:Void->Void) {
		_onRelease = onRelease;
	}

	private var _onRelease:Void->Void;

	public function release() {
		_onRelease();
	}
}
