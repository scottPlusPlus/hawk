package hawk.messaging;

import tink.CoreApi.Error;
import tink.CoreApi.Noise;
import tink.CoreApi.Outcome;

interface ISubscriber {
    function subscribe(handler:MsgHandler):Void;
}