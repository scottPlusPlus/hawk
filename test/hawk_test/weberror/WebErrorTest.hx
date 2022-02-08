package hawk_test.weberror;

import zenlog.Log;
import tink.core.Error.ErrorCode;
import yaku_core.test_utils.TestVals;
import hawk.util.AsyncStateX;
import hawk.util.AsyncState;
import tink.CoreApi;
import utest.Assert;
import utest.Async;

using hawk.weberror.WebErrorX;
using yaku_core.test_utils.PromiseTestUtils;

class WebErrorTest extends utest.Test {

	function testEnhancePromise(async:utest.Async) {

        var expectedPublicMessage = "a better public message";
        var expectedContext = "some context";

        var pt = new PromiseTrigger<String>();
        var p = pt.asPromise();
        p.enhanceErr(expectedContext, expectedPublicMessage).mapError(function(err){
            Log.debug('mapping error');
            var webErr = err.asWebErr();
            Assert.equals(expectedPublicMessage, webErr.publicMsg);
            Assert.contains(expectedContext, webErr.context);
            return err;
        }).closeTestChain(async, true);

        pt.reject(new Error(ErrorCode.I_am_a_Teapot, "some private bad thing"));
	}


}
