package hawk.messaging;

import hawk.datatypes.Timestamp;
import hawk.datatypes.UUID;

class BaseEvent {

    public final uid:UUID;
    public final time:Timestamp;

    public function new(){
        this.uid = UUID.gen();
        this.time = Timestamp.now();
    }
}