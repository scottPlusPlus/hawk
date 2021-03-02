package hawk.store;

import tink.CoreApi;

interface IDataItem<T> {
   function value():T;
   function mutate(data:T):Promise<T>;
   function delete():Promise<Noise>;
}