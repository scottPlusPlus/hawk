package hawk.messaging;

interface ISubscriber<T> {
    function subscribe(handler:MsgHandler<T>):Void;
}