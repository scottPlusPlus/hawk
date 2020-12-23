package hawk.messaging;

import tink.CoreApi.Promise;
import tink.CoreApi.Noise;

typedef MsgHandler<T> = T->Promise<Noise>;
