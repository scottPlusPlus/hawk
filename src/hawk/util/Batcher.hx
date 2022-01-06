package hawk.util;

import zenlog.Log;
import haxe.ds.Map;
import haxe.Constraints.IMap;
import tink.CoreApi;

using yaku_core.PromiseX;


class Batcher<X,Y> {

    private var _batchTimer:OpBatcher;
    private var _batchRequest:Array<X>->Promise<IMap<X,Y>>;

    private var _activeRequest:Promise<Noise>;

    private var _pendingPromises:IMap<X,PromiseTrigger<Null<Y>>>;

    private var _queuedX:Array<X>;
    private var _queuedPromises:IMap<X,PromiseTrigger<Null<Y>>>;

    private var _buildMap:Void->IMap<X,PromiseTrigger<Null<Y>>>;

    public function new(batchRequest:Array<X>->Promise<IMap<X,Y>>, delayMS:UInt, buildMap:Void->IMap<X,PromiseTrigger<Null<Y>>>){
        _batchRequest = batchRequest;
        _batchTimer = new OpBatcher(delayMS);
        _batchTimer.signal.handle(onTimerReady);
        _buildMap = buildMap;
        _queuedPromises = _buildMap();
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

    private function handleOutcome(o:Outcome<IMap<X,Y>,Error>){
        switch o {
            case Success(data):
                sortResults(data);
            case Failure(err):
                for (p in _pendingPromises.iterator()){
                    p.reject(err);
                }
        }
        _activeRequest = null;
    }

    private function sortResults(m:IMap<X,Y>){
        for (kv in _pendingPromises.keyValueIterator()){
            var promise = kv.value;
            var val = m.get(kv.key);
            if (val == null){
                promise.resolve(null);
            } else {
                promise.resolve(val);
            }
        }
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

    public static function stringMapBuilder<Y>():IMap<String,PromiseTrigger<Null<Y>>> {
        var m = new Map<String,PromiseTrigger<Null<Y>>>();
        return m;
    }

    public static function intMapBuilder<Y>():IMap<Int,PromiseTrigger<Null<Y>>> {
        var m = new Map<Int,PromiseTrigger<Null<Y>>>();
        return m;
    }

    public static function createStringBatcher<Y>(batchRequest:Array<String>->Promise<IMap<String,Y>>, delayMS:UInt):Batcher<String,Y> {
        return new Batcher<String,Y>(batchRequest, delayMS, Batcher.stringMapBuilder);
    }

    public static function createIntBatcher<Y>(batchRequest:Array<Int>->Promise<IMap<Int,Y>>, delayMS:UInt):Batcher<Int,Y> {
        return new Batcher<Int,Y>(batchRequest, delayMS, Batcher.intMapBuilder);
    }

}