package hawk.util;

import tink.core.Error;
import tink.core.Promise;

enum AsyncState<T> {
    Empty;
    Loading(p:Promise<T>);
    Ready(value:T);
    Failed(error:Error);
}