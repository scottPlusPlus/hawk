package hawk_test.util;

import yaku_core.test_utils.TestVals;
import hawk.util.AsyncStateX;
import hawk.util.AsyncState;
import tink.CoreApi;
import utest.Assert;
import utest.Async;

class AsyncStateXTest extends utest.Test {

	function testNull() {
        var np:Null<Promise<String>> = null;
        var actual = AsyncStateX.fromNullPromise(np);
        switch(actual){
            case Empty:
                Assert.pass();
            default:
                Assert.fail('expected AsyncState.Empty');
        }
	}

    function testLoading(){
        var pt = new PromiseTrigger<String>();
        var np:Null<Promise<String>> = pt.asPromise();
        var actual = AsyncStateX.fromNullPromise(np);
        switch(actual){
            case Loading(_):
                Assert.pass();
            default:
                Assert.fail('expected AsyncState.Loading');
        }
    }

    function testReady(){
        var pt = new PromiseTrigger<String>();
        var np:Null<Promise<String>> = pt.asPromise();
        pt.resolve(TestVals.jibbaJabba);
        var actual = AsyncStateX.fromNullPromise(np);
        switch(actual){
            case Ready(v):
                Assert.equals(TestVals.jibbaJabba, v);
            default:
                Assert.fail('expected AsyncState.Ready');
        }
    }

    function testFailed(){
        var pt = new PromiseTrigger<String>();
        var np:Null<Promise<String>> = pt.asPromise();
        pt.reject(new Error('err'));
        var actual = AsyncStateX.fromNullPromise(np);
        switch(actual){
            case AsyncState.Failed(err):
                Assert.equals('err', err.message);
            default:
                Assert.fail('expected AsyncState.Failed');
        }
    }

}
