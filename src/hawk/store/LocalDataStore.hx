package hawk.store;

import hawk.async_iterator.AsyncIteratorWrapper;
import hawk.general_tools.adapters.IteratorAdapter;
import hawk.async_iterator.AsyncIterator;
import zenlog.Log;
import tink.CoreApi;

class LocalDataStore<T> implements IDataStore<T> {
	// NOTE: we don't worry about any of these transactions being atomic, because none of the data is persisted
	private var _model:DataModel<T>;

	private var _data:Map<Int, DataRow>;

	private var _indexes:Map<String, Map<String, Int>>;

	private var _serial:Int;

	public function new(model:DataModel<T>) {
		Log.debug("creating new LDT with model");
		_model = model;
		_data = [];
		_indexes = [];
		for (f in _model.fields) {
			if (f.unique) {
				Log.debug('creating new index for ${f.name}');
				_indexes.set(f.name, new Map());
			}
		}
		Log.debug("done with LDT");
	}

	public function getIndexByColName(colName:String):IDataStoreIndex<String, T> {
		var indexMap = _indexes.get(colName);
		if (indexMap == null) {
			throw('no column with name ${colName}');
		}

		// K->Promise<DataItem<V>>
		var getFunc = function(k:String):Promise<Null<IDataItem<T>>> {
			Log.debug('get by col ${colName}:  ${k}');
			var index = indexMap.get(k);
			if (index == null) {
				Log.debug("is null...");
				return Promise.resolve(null);
			}
			var data = _data.get(index);
			if (data == null) {
				return Promise.resolve(null);
			}
			var item = createDataItem(index, data);
			return Promise.resolve(item);
		}

		return new DataStoreIndex(getFunc);
	}

	private function createDataItem(index:Int, data:DataRow):IDataItem<T> {
		var deps = {
			adapter: _model.adapter,
			save: setByID,
			delete: deleteByID
		};
		var dataItem = new DataItem<T>(deps, index, data);
		return dataItem;
	}

	private function deleteByID(id:Int):Promise<Bool> {
		var row = _data.get(id);
		if (row == null) {
			return false;
		}
		var colData = dataToColData(row);
		for (col in colData) {
			_indexes.get(col.colName).remove(col.value);
		}
		_data.remove(id);
		return true;
	}

	private function setByID(id:Int, row:DataRow):Promise<Noise> {
		Log.debug('set by id:  ${id}');
		var colData = dataToColData(row);
		var existingData = _data.get(id);

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
			if (foundIndex != null && foundIndex != id) {
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

		_data.set(id, row);
		for (col in colData) {
			// need to remove old indexes...
			var indexMap = _indexes.get(col.colName);
			Log.debug('setting index for ${col.colName}  ${col.value} = ${id}');
			indexMap.set(col.value, id);
		}

		return Noise;
	}

	// returns the colName + value for each UNIQUE column
	private function dataToColData(d:DataRow):Array<ColData> {
		var uniqueCols = new Array<ColData>();
		var data = d.toArray();
		Log.debug('dataToColData:  ${data}');
		var length = Math.round(Math.min(data.length, _model.fields.length));
		for (i in 0...length) {
			Log.debug('try col ${i}');
			var field = _model.fields[i];
			if (field.unique) {
				var col = new ColData(field.name, data[i]);
				uniqueCols.push(col);
			}
		}
		return uniqueCols;
	}

	public function create(data:T):Promise<IDataItem<T>> {
		// TODO - need some random ID creator??
		var newIndex = _serial++;
		Log.debug('Create New:  with index ${newIndex} and row:');
		var row = _model.adapter.toB(data);
		Log.debug('${row}');
		return setByID(newIndex, row).next(function(_) {
			return createDataItem(newIndex, row);
		});
	}

	public function iterator():AsyncIterator<IDataItem<T>> {
		var kvIterator = _data.keyValueIterator();
		var adapt = function(kv:{key:Int, value:DataRow}) {
			return createDataItem(kv.key, kv.value);
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
