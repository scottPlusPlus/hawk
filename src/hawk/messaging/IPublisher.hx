package hawk.messaging;

import tink.CoreApi;
import tink.CoreApi.Error;
import tink.CoreApi.Noise;
import tink.CoreApi.Outcome;

interface IPublisher {
    function publish(msg:Message):Promise<Noise>;
}