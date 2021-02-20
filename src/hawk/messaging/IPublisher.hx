package hawk.messaging;

import tink.CoreApi;

interface IPublisher<T> {
    function publish(msg:T):Promise<Noise>;
}