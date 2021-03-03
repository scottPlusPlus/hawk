package hawk.store;

import hawk.async_iterator.PagedAsyncIterator;
import hawk.async_iterator.AsyncIterator;
import thx.AnonymousMap;
import tink.CoreApi;
import zenlog.Log;

class PostgresDataStore<T> implements IDataStore<T> {

    private var _postgresClient:Dynamic;
    private var _tableName:String;
    private var _model:DataModel<T>;

    public function new(postgresClient:Dynamic, tableName:String, model:DataModel<T>) {
        if (tableName.toLowerCase() != tableName){
            throw('table name should be lowercase');
        }
        if (StringTools.trim(tableName) != tableName){
            throw('table name should be trimmed...');
        }

        _postgresClient = postgresClient;
        _tableName = tableName;
		_model = model;
	}

    public function init():Promise<PostgresDataStore<T>>{
        var p = new PromiseTrigger<PostgresDataStore<T>>();

        var fields = "";
        for (f in _model.fields){
            fields += f.name;
            if (f.unique){
                fields += " UNIQUE";
            }
            fields += ", ";
        }
        fields = fields.substr(0,-1);

        var query = '
        CREATE TABLE IF NOT EXISTS ${_tableName} (
            pk SERIAL PRIMARY KEY,
            ${fields}
          );
        ';

        logQuery(query);
        _postgresClient.query(query, function(err:Dynamic, res:Dynamic){
            if (err != null) {
                var e = queryErr('Create Table ${_tableName}:  ${err}');
                Log.error(e);
                p.reject(e);
                return;
            }
            //Log.info('successfully created table ${_tableName} in db');
            p.resolve(this);
        });
        return p;
    }

    public function create(data:T):Promise<IDataItem<T>> {
		var row = _model.adapter.toB(data);
        var query = "INSERT INTO _table_ (_fields_)
        VALUES(_vals_)";

        query = StringTools.replace(query, "_table_", _tableName);
        query = StringTools.replace(query, "_fields_", fieldsCSV());
        query = StringTools.replace(query, "_vals_", valsCSV(row));

        logQuery(query);

        var p = new PromiseTrigger<Int>();
        _postgresClient.query(query, function(err:Dynamic, res:Dynamic) {
            if (err != null) {
                var e = queryErr('create:  ${err}');
                Log.error(e);
                p.reject(e);
                return;
            }
            Log.info('Postgres Create RES = ${res}');
            p.resolve(res.pk);
        });
        return p.asPromise().next(function(pk:Int){
            return createDataItem(pk, row);
        });
	}


    private function fieldsCSV():String {
        var str = "";
        for (f in _model.fields){
            str += f.name + ", ";
        }
        return str.substr(0, -2);
    }

    private function settersCSV(v:Array<String>):String {
        var str = "";
        for (i in 0...v.length){
            str += _model.fields[i].name + " = " + v[i] + ", ";
        }
        return str.substr(0, -2);
    }

    private function valsCSV(v:Array<String>):String {
        var str = "";
        for (i in 0...v.length){
            str += "'" + v[i] + "', ";
        }
        return str.substr(0, -2);
    }

	private function createDataItem(primaryKey:Int, data:DataRow):IDataItem<T> {
		var deps = {
			adapter: _model.adapter,
			save: setByPK,
			delete: deleteByPK
		};
		var dataItem = new DataItem<T>(deps, primaryKey, data);
		return dataItem;
	}

    private function setByPK(primaryKey:Int, row:DataRow):Promise<Noise> {
        var query = " UPDATE _table_
        SET _setters_
        WHERE pk = _pk_";

        query = StringTools.replace(query, "_table_", _tableName);
        query = StringTools.replace(query, "_setters_", settersCSV(row));
        query = StringTools.replace(query, "_pk_", Std.string(primaryKey));

        logQuery(query);

        var p = new PromiseTrigger<Noise>();
        _postgresClient.query(query, function(err:Dynamic, res:Dynamic) {
            if (err != null) {
                var e = queryErr('UPDATE  ${primaryKey}:  ${err}');
                Log.error(e);
                p.reject(e);
                return;
            }
            p.resolve(Noise);
        });
        return p;
    }

    private function deleteByPK(pk:Int):Promise<Bool> {
        var query = "DELETE FROM _table_ WHERE pk = _pk_";
        query = StringTools.replace(query, "_table_", _tableName);
        query = StringTools.replace(query, "_pk_", Std.string(pk));

        logQuery(query);
        var p = new PromiseTrigger<Bool>();
        _postgresClient.query(query, function(err:Dynamic, res:Dynamic) {
            if (err != null) {
                var e = queryErr('remove ${pk}:  ${err}');
                Log.error(e);
                p.reject(e);
            }
            p.resolve(true);
        });
        return p;
    }

    private function selectByPK(pk:Int):Promise<Null<IDataItem<T>>> {
        var query = "SELECT FROM _table_ WHERE pk = _pk_";
        query = StringTools.replace(query, "_table_", _tableName);
        query = StringTools.replace(query, "_pk_", Std.string(pk));

        logQuery(query);
        var p = new PromiseTrigger<Null<IDataItem<T>>>();
        _postgresClient.query(query, function(err:Dynamic, res:Dynamic) {
            if (err != null) {
                var e = queryErr('remove ${pk}:  ${err}');
                Log.error(e);
                p.reject(e);
            }
            var rows:Array<Dynamic> = res.rows;

            if (rows == null){
                //Log.debug("rows is null");
                p.resolve(null);
                return;
            }

            if (rows.length == 0){
                //Log.debug("rows is empty");
                p.resolve(null);
                return;
            }

            if (rows.length != 1){
                Log.warn("got more rows than expected... " + rows.length);
            }

            var dataRow = rowToDataRow(rows[0]);
            var dataItem = createDataItem(pk, dataRow);
            p.resolve(dataItem);
        });
        return p;
    }

    private function rowToDataRow(row:Dynamic):DataRow {
        var map = new AnonymousMap<String>(row[0]);
        var res = new Array<String>();
        for (f in _model.fields){
            res.push(map.get(f.name));
        }
        return res;
    }

    public function iterator():AsyncIterator<IDataItem<T>>  {
        var postgresPager = new DatabasePager(25, getPage);
        var pagedIterator = new PagedAsyncIterator(postgresPager.loadNext);
        return pagedIterator;
    }

    public function getPage(limit:UInt, offset:UInt):Promise<Array<IDataItem<T>>>{
        var query = "SELECT * FROM $0 ORDER BY pk ASC LIMIT $2 OFFSET $3";
        query = StringTools.replace(query, "$0", _tableName);
        query = StringTools.replace(query, "$2", Std.string(limit));
        query = StringTools.replace(query, "$3", Std.string(offset));
        logQuery(query);
        
        var p = new PromiseTrigger<Array<IDataItem<T>>>();
        _postgresClient.query(query, function(err:Dynamic, res:Dynamic) {
            if (err != null) {
                var e = queryErr('GET PAGE ${limit} ${offset}:  ${err}');
                Log.error(e);
                p.reject(e);
            }

            var rows:Array<Dynamic> = res.rows;
            var arr = new Array<IDataItem<T>>();
            for (r in rows){
                var dataRow = rowToDataRow(r);
                var dataItem = createDataItem(r.pk, dataRow);
                arr.push(dataItem);
            }
            p.resolve(arr);
        });
        return p;
    }


    public function getIndexByColName(colName:String):IDataStoreIndex<String, T> {
        throw('not implemented yet...');
    }


    private inline function logQuery(query:String){
        Log.debug("postgres query:  " + query);
    }

    private inline function queryErr(err:String):Error{
        return new Error('postgres error:  ${err}');
    }
}