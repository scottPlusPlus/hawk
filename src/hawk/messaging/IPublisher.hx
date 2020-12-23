package hawk.messaging;

import tink.CoreApi;
import tink.CoreApi.Error;
import tink.CoreApi.Noise;
import tink.CoreApi.Outcome;

interface IPublisher<T> {
    function publish(msg:T):Promise<Noise>;
}