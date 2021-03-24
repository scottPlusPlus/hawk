package hawk.messaging;

import tink.CoreApi;
import hawk.general_tools.adapters.Adapter;

class PubAdapter<A,B> implements IPublisher<A> {

    private var _wrappedPub:IPublisher<B>;
    private var _adapter:Adapter<A,B>;

    public function new(pub:IPublisher<B>, adapter:Adapter<A,B>){
        _wrappedPub = pub;
        _adapter = adapter;
    }

    public function publish(msg:A):Promise<Noise> {
        var b = _adapter.toB(msg);
        return _wrappedPub.publish(b);
    }
}