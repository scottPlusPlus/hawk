package hawk.messaging;

import tink.CoreApi;
import hawk.messaging.ISubscriber;
import hawk.messaging.IPublisher;

interface IChannelFactory<T> {
    function getPub(name:String):Promise<IPublisher<T>>;
    function getSub(name:String):Promise<ISubscriber<T>>;
}