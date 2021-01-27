package hawk.testutils;

import tink.CoreApi;
import utest.Assert;

class PromiseTestUtils {
	public function new(){}

	public static inline function assertNoErr<T>(p:Promise<T>):Promise<T> {
		return p.mapError(function(err:Error){
            Assert.isNull(err);
            return err;
		});
	}

	public static inline function endTestChain<T>(p:Promise<T>, async:utest.Async){
		return PromiseTestUtils.assertNoErr(p).next(function(v:T){
			async.done();
			return v;
		}).eager();


	}
}