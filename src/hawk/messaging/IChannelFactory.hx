package hawk.messaging;

import hawk.general_tools.adapters.Adapter;
import tink.CoreApi;
import hawk.messaging.ISubscriber;
import hawk.messaging.IPublisher;

interface IChannelFactory<DT> {
    function getPub<T>(name:String, adapter:Adapter<T,DT>):Promise<IPublisher<T>>;
    function getSub<T>(name:String, adapter:Adapter<T,DT>):Promise<ISubscriber<T>>;
}