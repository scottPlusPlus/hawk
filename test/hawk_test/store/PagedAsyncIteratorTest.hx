package hawk_test.store;

import zenlog.Log;
import hawk.async_iterator.AsyncIteratorX;
import hawk.async_iterator.PagedAsyncIterator;
import tink.CoreApi;
import utest.Assert;
import utest.Async;

using yaku_core.test_utils.PromiseTestUtils;

class PagedAsyncIteratorTest  extends utest.Test {

	public function testHappy(async:utest.Async) {
        var data = [[1,2,3],[4,5,6],[7,8,9]];
        var server = new PageServer(data);

        var pagedIterator = new PagedAsyncIterator(server.loadNextPage);

        var actual = new Array<Int>();

        AsyncIteratorX.forEach(pagedIterator, function(v:Int){
            Log.debug("foreach handling " + v);
            actual.push(v);
            return Noise;
        }).next(function(_){
            Assert.same([1,2,3,4,5,6,7,8,9], actual);
            return Noise;
        }).closeTestChain(async);
    }

    public function testError(async:utest.Async) {
        var data = [[1,2,3],[4,5,6],[7,8,9]];
        var server = new PageServer(data);

        var pagedIterator = new PagedAsyncIterator(server.loadNextPage);

        var actual = new Array<Int>();
        var myErr = new Error('oh no!');

        AsyncIteratorX.forEach(pagedIterator, function(v:Int){
            Log.debug("foreach handling " + v);
            actual.push(v);
            if (v == 4){
                return myErr;
            }
            return Noise;
        }).flatMap(function(o){
            return switch o {
                case Failure(err):
                    Assert.same(myErr.message, err.message);
                    Assert.same([1,2,3,4], actual);
                    async.done();
                    return Promise.NOISE;
                case Success(b):
                   Assert.fail('expected an error here');
                   async.done();
                   return Promise.NOISE;
            }
        }).eager();
    }

} 

class PageServer<T> {
    private var _pages:Array<Array<T>> = [];
    
    //FIFO
    public function new(data:Array<Array<T>>){
        _pages = data;
        _pages.reverse();
    }

    public function loadNextPage():Promise<Array<T>>{
        Log.debug('calling loadNextPage with   ${_pages}');
        if (_pages.length == 0){
            return [];
        }
        return _pages.pop();
    }
}