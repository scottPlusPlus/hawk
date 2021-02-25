package hawk.async_iterator;

import tink.CoreApi;

class PagedAsyncIterator<T> {
	private var _currentPage:Array<T>;
	private var _index:UInt = 0;
	private var _nextPage:Promise<Array<T>>;

	private var _loadNextPage:Void->Promise<Array<T>>;

	public function new(loadPage:Void->Promise<Array<T>>) {
		_loadNextPage = loadPage;
	}

	public function hasNext():Promise<Bool> {
		return ensureCurrentPage().next(function(_) {
			return _currentPage.length > 0;
		});
	}

	public function next():Promise<T> {
		return ensureCurrentPage().next(iterateCurrentPage);
	}

	private function ensureCurrentPage():Promise<Noise> {
		if (_currentPage == null) {
			return loadNextPage().next(moveToNextPage);
		}
		if (_index == _currentPage.length) {
			return loadNextPage().next(moveToNextPage);
		}
		return Noise;
	}

	private function loadNextPage():Promise<Array<T>> {
		if (_nextPage == null) {
			_nextPage = _loadNextPage();
		}
		return _nextPage;
	}

	private function iterateCurrentPage(_):Promise<T> {
		if (_currentPage.length == 0) {
			return Failure(new Error('no more data'));
		}
		var res = _currentPage[_index];
		_index++;
		return res;
	}

	private function moveToNextPage(nextPage:Array<T>):Promise<Noise> {
		_currentPage = nextPage;
		_nextPage = null;
		_index = 0;
		loadNextPage(); // go ahead and start loading the next page
		return Noise;
	}
}
