package hawk_test.counters;

import hawk.counters.LeakyBucketCounters;
import hawk.datatypes.Timestamp;
import hawk.datatypes.Email;
import utest.Assert;

class LeakyBucketCountersTest extends utest.Test {
	function testSanity() {
        Assert.equals(1,1);
    }

    function testHappyPath() {
        var fakeTimeMS:UInt = 0;
        var getTime = function():Timestamp {
            return Timestamp.fromUInt(fakeTimeMS);
        };
        var counters = new LeakyBucketCounters(10, 1000, getTime);
        
        final key = "key";

        var actual = counters.add(key, 10);
        Assert.same(10, actual);

        fakeTimeMS += 400;
        actual = counters.add(key,0);
        Assert.same(6, actual);

        fakeTimeMS += 500;
        actual = counters.add(key,0);
        Assert.same(1, actual);

        fakeTimeMS += 100;
        actual = counters.add(key,0);
        Assert.same(0, actual);

        fakeTimeMS += 1500;
        actual = counters.add(key,0);
        Assert.same(0, actual);
    }

    function testMultipleKeys() {
        var fakeTimeMS:UInt = 0;
        var getTime = function():Timestamp {
            return Timestamp.fromUInt(fakeTimeMS);
        };
        var counters = new LeakyBucketCounters(10, 1000, getTime);
        
        final key1 = "key1";
        final key2 = "key2";

        var actual = counters.add(key1, 10);
        Assert.same(10, actual);
        actual = counters.add(key2, 5);
        Assert.same(5, actual);

        fakeTimeMS += 200;
        actual = counters.add(key1,0);
        Assert.same(8, actual);
        actual = counters.add(key2,0);
        Assert.same(3, actual);

        fakeTimeMS += 100;
        actual = counters.add(key1,0);
        Assert.same(7, actual);

        //skipping check on key2, should still be correct later
        fakeTimeMS += 100;
        actual = counters.add(key1,0);
        Assert.same(6, actual);
        actual = counters.add(key2,0);
        Assert.same(1, actual);
    }

    function testJson(){
        var fakeTimeMS:UInt = 0;
        var getTime = function():Timestamp {
            return Timestamp.fromUInt(fakeTimeMS);
        };
        var counters = new LeakyBucketCounters(10, 1000, getTime);
        
        final key1 = "key1";
        final key2 = "key2";

        var actual = counters.add(key1, 10);
        Assert.same(10, actual);
        actual = counters.add(key2, 5);
        Assert.same(5, actual);


    }
}
