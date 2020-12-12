package hawk.messaging;

import tink.CoreApi.Promise;
import tink.CoreApi.Error;
import tink.CoreApi.Noise;
import tink.CoreApi.Outcome;

typedef MsgHandler = Message->Promise<Noise>;