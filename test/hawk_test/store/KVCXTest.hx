package hawk_test.store;

import utest.Assert;
import utest.Async;
import hawk.store.KVCX;
import hawk.store.KVC;

using yaku_core.OutcomeX;

class KVCXTest  extends utest.Test {

	public function testCollapseNulls() {

        var kvcArray = new Array<KVC<Int,Null<String>>>();

        kvcArray.push(new KVC(1, "one"));
        kvcArray.push(new KVC(2, null));

        var outcome = KVCX.collapseNulls(kvcArray);
        Assert.isTrue(outcome.isFailure());

        kvcArray.pop();
        kvcArray.push(new KVC(2, "two"));
        kvcArray.push(new KVC(3, "three"));
        outcome = KVCX.collapseNulls(kvcArray);

        Assert.isFalse(outcome.isFailure());
        var res = outcome.sure();
        Assert.equals("one", res[0].value);
        Assert.equals("two", res[1].value);
        Assert.equals("three", res[2].value);
    }

}
	