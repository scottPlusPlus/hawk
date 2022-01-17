package hawk.store;

import haxe.Constraints.IMap;
import hawk.async_iterator.AsyncIteratorWrapper;
import hawk.general_tools.adapters.IteratorAdapter;
import hawk.async_iterator.AsyncIterator;
import zenlog.Log;
import tink.CoreApi;

class LocalMemDataStore<T> implements IDataStore<T> {
	// NOTE: we don't worry about any of these transactions being atomic, because none of the data is persisted
	private var _model:DataModel<T>;

	private var _data:Map<String, Map<String,String>>;

	private var _indexes:Map<String, Map<String,String>>;

	private var _serial:Int;

	private var _primaryKeyField:String;

	public function new(model:DataModel<T>) {
		Log.debug("creating new LDT with model");

		var modelErrs = model.validationErrors();
		if (modelErrs.length != 0){
			var errStr = modelErrs.join(".. ");
			throw ('Invalid Model:  ${errStr}');
		}

		_model = model;
		_data = [];
		_indexes = [];
		for (f in _model.fields) {
			if (f.type == DataFieldType.Primary){
				_primaryKeyField = f.name;
			}
			//TODO - building a separate index for pk is not optimal
			if (f.type == DataFieldType.Unique || f.type == DataFieldType.Primary) {
				Log.debug('creating new index for ${f.name}');
				_indexes.set(f.name, new Map());
			}
		}
		Log.debug("done with LDT");
	}

	public function getIndexByColName(colName:String):IDataStoreIndex<String, T> {
		var indexMap = _indexes.get(colName);
		if (indexMap == null) {
			var errStr = 'no column with name ${colName}';
			Log.error(errStr);
			throw(errStr);
		}

		// K->Promise<DataItem<V>>
		var getFunc = function(colVal:String):Promise<Null<T>> {
			Log.debug('get by col ${colName}:  ${colVal}');
			var pk = indexMap.get(colVal);
			if (pk == null) {
				Log.debug("is null...");
				return Promise.resolve(null);
			}
			var data = _data.get(pk);
			if (data == null) {
				return Promise.resolve(null);
			}
			var obj = _model.adapter.toA(data);
			return Promise.resolve(obj);
		}

		return new DataStoreIndex(getFunc);
	}

	private function restoreItem(data:Map<String,String>):T {
		return _model.adapter.toA(data);
	}

	private function primaryKey(data:IMap<String,String>):String {
		return data.get(_primaryKeyField);
	}

	public function delete(obj:T):Promise<Bool> {
		var data = _model.adapter.toB(obj);
		var pk = primaryKey(data);
		var existing = _data.get(pk);

		if (existing == null) {
			return false;
		}
		var colData = dataToColData(existing);
		for (col in colData) {
			_indexes.get(col.colName).remove(col.value);
		}
		_data.remove(pk);
		return true;
	}

	public function update(obj:T):Promise<T> {
		var data = _model.adapter.toB(obj);
		var pk = primaryKey(data);
		if (pk == null || pk.length == 0){
			return new Error('could not find primary key for  ${obj}');
		}
		return setByPK(pk, data);
	}

	private function setByPK(pk:String, data:IMap<String,String>):Promise<T> {
		Log.debug('set by id:  ${pk}');
		var colData = dataToColData(data);
		var existingData = _data.get(pk);

		for (col in colData) {
			Log.debug('checking for conflict in ${col.colName} / ${col.value}');
			var indexMap = _indexes.get(col.colName);
			if (indexMap == null) {
				var err = new Error('No index for col ${col.colName}');
				Log.error(err);
				return err;
			}
			var foundIndex = indexMap.get(col.value);
			Log.debug('got existing index  ${foundIndex}');
			if (foundIndex != null && foundIndex != pk) {
				return new Error('Data Conflict: col ${col.colName} already has a value for ${col.value}:  ${foundIndex}');
			}
		}

		// kill all existing data
		Log.debug('killing all old assocs');
		if (existingData != null) {
			var previousColsData = dataToColData(existingData);
			for (col in previousColsData) {
				_indexes.get(col.colName).remove(col.value);
			}
		}

		//convert iMap to map...
		var map = new Map<String,String>();
		for (kv in data.keyValueIterator()){
			map.set(kv.key, kv.value);
		}

		_data.set(pk, map);
		for (col in colData) {
			// need to remove old indexes...
			var indexMap = _indexes.get(col.colName);
			Log.debug('setting index for ${col.colName}  ${col.value} = ${pk}');
			indexMap.set(col.value, pk);
		}

		return _model.adapter.toA(data);
	}

	// returns the colName + value for each UNIQUE column
	private function dataToColData(data:IMap<String,String>):Array<ColData> {
		var uniqueCols = new Array<ColData>();
		Log.debug('dataToColData:  ${data}');
		for (field in _model.fields) {
			if (field.type == DataFieldType.Unique || field.type == DataFieldType.Primary) {
				var col = new ColData(field.name, data.get(field.name));
				uniqueCols.push(col);
			}
		}
		return uniqueCols;
	}

	public function create(obj:T):Promise<T> {
		// TODO - need some random ID creator??
		var data = _model.adapter.toB(obj);
		var pk = primaryKey(data);

		// if (_model.serial){
		// 	if (pk != ""){
		// 		return new Error('Primary key should be empty to create.  Got ${pk}');
		// 	}
		// 	pk = Std.string(_serial++);
		// }


		Log.debug('Create New:  with index ${pk} and row:');
		return setByPK(pk, data).next(function(_) {
			data.set(_primaryKeyField, pk);
			return _model.adapter.toA(data);
		});
	}

	public function iterator():AsyncIterator<T> {
		var kvIterator = _data.keyValueIterator();
		var adapt = function(kv:{key:String, value:Map<String,String>}) {
			return _model.adapter.toA(kv.value);
		};
		var diIterator = new IteratorAdapter(kvIterator, adapt);
		var asyncIterator = new AsyncIteratorWrapper(diIterator);
		return asyncIterator;
	}
}


class ColData {
	public function new(colName:String, val:String) {
		this.colName = colName;
		this.value = val;
	}

	public var colName:String;
	public var value:String;
}
