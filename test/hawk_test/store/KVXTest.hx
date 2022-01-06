package hawk_test.store;

import utest.Assert;
import utest.Async;
import hawk.store.KV;
import hawk.store.KVX;
import hawk.store.KVC;

using yaku_core.OutcomeX;

class KVXTest  extends utest.Test {

	public function testCollapseNulls() {
        Assert.isTrue(true);
        var kvArray = new Array<KV<Int,Null<String>>>();

        kvArray.push(new KVC(1, "one"));
        kvArray.push(new KVC(2, null));

        var outcome = KVX.collapseNulls(kvArray);
        Assert.isTrue(outcome.isFailure());

        kvArray.pop();
        kvArray.push(new KVC(2, "two"));
        kvArray.push(new KVC(3, "three"));
        outcome = KVX.collapseNulls(kvArray);

        Assert.isFalse(outcome.isFailure());
        var res = outcome.sure();
        Assert.equals("one", res[0].value);
        Assert.equals("two", res[1].value);
        Assert.equals("three", res[2].value);
    }

}
	