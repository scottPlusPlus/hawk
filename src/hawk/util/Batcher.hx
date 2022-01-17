package hawk.util;

import hawk.store.ArrayKV;
import hawk.store.KVC;
import zenlog.Log;
import haxe.ds.Map;
import haxe.Constraints.IMap;
import tink.CoreApi;

using yaku_core.PromiseX;
using yaku_core.NullX;


class Batcher<X,Y> {

    private var _batchTimer:OpBatcher;
    private var _batchRequest:Array<X>->Promise<ArrayKV<X,Y>>;

    private var _activeRequest:Promise<Noise>;

    private var _pendingPromises:Map<X,PromiseTrigger<Y>>;

    private var _queuedX:Array<X>;
    private var _queuedPromises:Map<X,PromiseTrigger<Y>>;

    public function new(batchRequest:Array<X>->Promise<ArrayKV<X,Y>>, delayMS:UInt, queue:Lazy<Map<X,PromiseTrigger<Y>>>){
        _batchRequest = batchRequest;
        _batchTimer = new OpBatcher(delayMS);
        _batchTimer.signal.handle(onTimerReady);
        _queuedPromises = queue.get();
        _queuedX = new Array<X>();
    }

    public function request(x:X):Promise<Null<Y>>{
        _batchTimer.trigger();
        _queuedX.push(x);
        var promise = new PromiseTrigger<Y>();
        _queuedPromises.set(x, promise);
        return promise.asPromise();
    }

    private function makeBatchRequest(){
        _pendingPromises = _queuedPromises.copy();
        _queuedPromises.clear();
        var vals = _queuedX.copy();
        _queuedX.resize(0);
        var p:Promise<Noise> = _batchRequest(vals).map(handleOutcome).noise();
        _activeRequest = p.recoverWith(Noise).eager();
    }

    private function handleOutcome(o:Outcome<ArrayKV<X,Y>,Error>){
        switch o {
            case Success(res):
                for (kv in res){
                    var pt:PromiseTrigger<Y> = _pendingPromises.get(kv.key).nullThrows('no pending promise for ${kv.key}');
                    pt.resolve(kv.value);
                }
            case Failure(err):
                for (p in _pendingPromises.iterator()){
                    p.reject(err);
                }
        }
        _activeRequest = null;
    }

    private function onTimerReady(){
        if (_activeRequest == null){
            makeBatchRequest();
            return;
        } 
        _activeRequest.next(function(_){
            makeBatchRequest();
            return Noise;
        }).eager();
    }

    public static function stringMapBuilder<Y>():Map<String,PromiseTrigger<Null<Y>>> {
        var m = new Map<String,PromiseTrigger<Null<Y>>>();
        return m;
    }

    public static function intMapBuilder<Y>():Map<Int,PromiseTrigger<Null<Y>>> {
        var m = new Map<Int,PromiseTrigger<Null<Y>>>();
        return m;
    }

    public static function createStringBatcher<Y>(batchRequest:Array<String>->Promise<ArrayKV<String,Y>>, delayMS:UInt):Batcher<String,Y> {
        return new Batcher<String,Y>(batchRequest, delayMS, Batcher.stringMapBuilder);
    }

    public static function createIntBatcher<Y>(batchRequest:Array<Int>->Promise<ArrayKV<Int,Y>>, delayMS:UInt):Batcher<Int,Y> {
        return new Batcher<Int,Y>(batchRequest, delayMS, Batcher.intMapBuilder);
    }

}