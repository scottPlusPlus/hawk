package hawk.general_tools.adapters;

class IteratorAdapter<A, B> {
	private var _iterator:Iterator<A>;
	private var _adapter:A->B;

	public function new(iterator:Iterator<A>, adapter:A->B) {
		_iterator = iterator;
		_adapter = adapter;
	}

	public function hasNext() :Bool {
		return _iterator.hasNext();
	}

	public function next():B {
		return _adapter(_iterator.next());
	}
}
