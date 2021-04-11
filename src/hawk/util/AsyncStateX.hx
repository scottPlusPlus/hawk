package hawk.util;

import tink.CoreApi;
using hawk.util.NullX;

class AsyncStateX {
	public static function fromPromise<T>(p:Promise<T>):AsyncState<T> {
		switch (p.status) {
			case Ready(result):
				switch (result.get()) {
					case Success(data):
						return Ready(data);
					case Failure(failure):
						return Failed(failure);
				}
			default:
				return Loading(p);
		}
	}

    public static function fromNullPromise<T>(np:Null<Promise<T>>):AsyncState<T> {
        if (np == null){
            return Empty;
        }
        return fromPromise(np.nullThrows());
    }

    public static function fromOptionPromise<T>(o:Option<Promise<T>>):AsyncState<T> {
        switch(o){
            case None:
                return Empty;
            case Some(v):
                return fromPromise(v);
        }
    }
}
