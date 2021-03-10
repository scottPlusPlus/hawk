package hawk.store;

import hawk.general_tools.adapters.Adapter;

abstract KVAdapter<KA,VA,KB,VB> (Adapter<KV<KA,VA>,KV<KB,VB>>)   {

    public function new(keyAdapter:Adapter<KA,KB>, valAdapter:Adapter<VA,VB>){

        var bToA = function(kv: KV<KB,VB>){
			return new KVC<KA,VA>(keyAdapter.toA(kv.key), valAdapter.toA(kv.value));
		};
		var aToB = function(kv: KV<KA,VA>){
			return new KVC<KB,VB>(keyAdapter.toB(kv.key), valAdapter.toB(kv.value));
		};
		this = new Adapter<KV<KA,VA>,KV<KB,VB>>(aToB, bToA);
    }

    public inline function toB(a:KV<KA,VA>):KV<KB,VB>{
        return this.toB(a);
    }

    public inline function toA(b:KV<KB,VB>):KV<KA,VA>{
        return this.toA(b);
    }
    
    public function invert():Adapter<KV<KB,VB>,KV<KA,VA>> {
        return this.invert();
    }

    @:to
	public function toAdapter():Adapter<KV<KA,VA>,KV<KB,VB>> {
		return this;
	}

}