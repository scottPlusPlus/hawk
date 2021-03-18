package hawk_test.util;

import tink.CoreApi;
import utest.Assert;
import hawk.util.FutureX;

using hawk.testutils.PromiseTestUtils;
using hawk.util.PromiseX;

class PromiseXTest extends utest.Test {
	
    function testRecoverWithOnFailure(async:utest.Async) {

        var pt = new PromiseTrigger<Int>();
        pt.reject(new Error('a wild err appeared!'));
        pt.asPromise().recoverWith(5).next(function(v){
            Assert.equals(5, v);
            return Noise;
        }).closeTestChain(async);
    }

    function testRecoverWithOnSuccess(async:utest.Async) {

        var pt = new PromiseTrigger<Int>();
        pt.resolve(11);
        pt.asPromise().recoverWith(5).next(function(v){
            Assert.equals(11, v);
            return Noise;
        }).closeTestChain(async);
    }
}