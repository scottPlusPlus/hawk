package hawk.messaging;

import tink.CoreApi;
import hawk.general_tools.adapters.Adapter;

class SubAdapter<A,B> implements ISubscriber<A> {

    private var _wrappedSub:ISubscriber<B>;
    private var _adapter:Adapter<A,B>;

    public function new(sub:ISubscriber<B>, adapter:Adapter<A,B>){
        _wrappedSub = sub;
        _adapter = adapter;
    }

    private function createHandler(handler:MsgHandler<A>):MsgHandler<B>{
        return function(msg:B):Promise<Noise> {
            var a = _adapter.toA(msg);
            return handler(a);
        };
    }

    public function subscribe(handler:MsgHandler<A>):Void {
        var h = createHandler(handler);
        return _wrappedSub.subscribe(h);
    }
}