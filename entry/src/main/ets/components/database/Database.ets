import { relationalStore } from '@kit.ArkData';
import { Context } from '@kit.AbilityKit';
import CommonConstants from '../pswmanagement/CommonConstants';

import { common } from '@kit.AbilityKit';
import { distributedDeviceManager } from '@kit.DistributedServiceKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
// import { AccountData } from '../components/pswmanagement/PswViewModel';

// 定义三表分类枚举
export enum TableCategory {
  IMPORTANT_FREQUENT = 'important_frequent',   // 重要常用
  IMPORTANT_INFREQUENT = 'important_infrequent', // 重要不常用
  UNIMPORTANT = 'unimportant'                 // 不重要
}

// 统一数据结构
export interface DataEntity {
  id?: number;         // 自增主键
  name: string;        // 平台名称
  content: string;     // 密码
  timestamp: number;   // 时间戳
}
// 更新和删除时使用的新接口
export interface InsertDataEntity {
  name: string;
  content: string;
  timestamp: number;
}


export class DatabaseManager {
  private store: relationalStore.RdbStore | null = null;




    context: common.UIAbilityContext | null = null;
  localDeviceNetworkId: string = '';

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }


  // getTableColumns(rdbStore: relationalStore.RdbStore, tableName: string): Promise<string[]> {
  //   return new Promise((resolve) => {
  //     let predicates = new relationalStore.RdbPredicates(tableName);
  //     rdbStore.query(predicates, [], (err, resultSet) => {
  //       resolve(resultSet.columnNames);
  //     });
  //   });
  // }


  private isInitialized: boolean = false; // 添加初始化状态标识

  // async initialize(tablename: string, context: Context): Promise<void> {
  //   if (this.isInitialized) return;
  //   try {
  //     // 创建新数据库
  //     this.store = await relationalStore.getRdbStore(context, CommonConstants.STORE_CONFIG);
  //     hilog.info(0x0000, 'DB', 'RdbStore instance created');
  //
  //     // 执行建表语句
  //     const createTableSQL = `CREATE TABLE IF NOT EXISTS ${tablename} (
  //       id INTEGER PRIMARY KEY AUTOINCREMENT,
  //       name TEXT NOT NULL,
  //       content TEXT NOT NULL,
  //       timestamp INTEGER NOT NULL
  //     )`;
  //     // 校验表结构一致性
  //     const checkTableSchema = async (rdbStore: relationalStore.RdbStore, tableName: string) => {
  //       try {
  //         // 检查表是否存在
  //         const tableCheck = await rdbStore.querySql(
  //           `SELECT name FROM sqlite_master WHERE type='table' AND name='${tableName}'`
  //         );
  //
  //         if (tableCheck.rowCount <= 0) {
  //           console.error(`Table ${tableName} does not exist`);
  //           return;
  //         }
  //
  //         // 获取实际列信息
  //         // const columnResult = await rdbStore.querySql(
  //         //   `PRAGMA table_info(${tableName})`
  //         // );
  //
  //         let predicates = new relationalStore.RdbPredicates(tableName);
  //         if (rdbStore != undefined) {
  //           (rdbStore as relationalStore.RdbStore).query(predicates, [], async (err, resultSet) => {
  //             if (err) {
  //               console.error(`Query failed, code is ${err.code},message is ${err.message}`);
  //               return;
  //             }
  //             actualColumns = resultSet.columnNames;
  //             console.info(`ResultSet column names: ${actualColumns}, column count: ${resultSet.columnCount}`);
  //           });
  //         }
  //
  //
  //         let actualColumns = await this.getTableColumns(rdbStore, tableName);
  //
  //         const expectedColumns = [
  //           'id',
  //           'name',
  //           'content',
  //           'timestamp'
  //         ];
  //         let structureValid: boolean = false;
  //         // 执行结构比对
  //         for (let i = 0; i < expectedColumns.length; i++) {
  //           if (actualColumns[i] !== expectedColumns[i]) {
  //             console.error(`第${i}列不匹配: actual=${actualColumns[i]}, expected=${expectedColumns[i]}`);
  //             break;
  //           }else {
  //             structureValid = true;
  //           }
  //         }
  //         if (!structureValid) {
  //           console.warn(`Schema mismatch detected, rebuilding table ${tableName}`);
  //
  //           // 执行原子化结构更新
  //           await rdbStore.executeSql(`DROP TABLE IF EXISTS ${tableName}`);
  //
  //           const createTableSQL = `CREATE TABLE ${tableName} (
  //             id INTEGER PRIMARY KEY AUTOINCREMENT,
  //             name TEXT NOT NULL,
  //             content TEXT NOT NULL,
  //             timestamp INTEGER NOT NULL
  //           )`;
  //
  //           await rdbStore.executeSql(createTableSQL);
  //           console.info(`Table ${tableName} structure updated`);
  //         }
  //       } catch (err) {
  //         console.error(`Schema validation failed: ${err.message}`);
  //       }
  //     };
  //
  //     // 结构验证工具函数
  //     const validateSchema = (actual: string[], expected: string[]): boolean => {
  //       // 列数量校验
  //       if (actual.length !== expected.length) return false;
  //
  //       // 列顺序与名称校验
  //       for (let i = 0; i < expected.length; i++) {
  //         if (actual[i] !== expected[i]) return false;
  //       }
  //
  //       return true;
  //     };
  //     await checkTableSchema(this.store, tablename);
  //     await this.store.executeSql(createTableSQL);
  //     this.isInitialized = true;
  //   } catch (err) {
  //     hilog.error(0x0000, 'DB', `Database operation failed: ${err.message}`);
  //     throw new Error(`Initialize failed: ${err.message}`); // 抛出异常防止静默失败
  //   }
  // }
  async initialize(tablename: string, context: Context): Promise<void> {
    if (this.isInitialized) return;
    try {
      // 创建新数据库
      this.store = await relationalStore.getRdbStore(context, CommonConstants.STORE_CONFIG);
      hilog.info(0x0000, 'DB', 'RdbStore instance created');

      // 先执行建表语句
      const createTableSQL = `CREATE TABLE IF NOT EXISTS ${tablename} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      content TEXT NOT NULL,
      timestamp INTEGER NOT NULL
    )`;

      await this.store.executeSql(createTableSQL);
      console.info(`Table ${tablename} created or already exists`);

      // 然后进行表结构校验（如果需要）
      await this.checkTableSchema(tablename);

      this.isInitialized = true;
      hilog.info(0x0000, 'DB', 'Database initialized successfully');

    } catch (err) {
      hilog.error(0x0000, 'DB', `Database operation failed: ${err.message}`);
      throw new Error(`Initialize failed: ${err.message}`);
    }
  }

  // 单独的校验方法
  private async checkTableSchema(tableName: string): Promise<void> {
    if(this.store) {
      try {
        const actualColumns = await this.getTableColumns(this.store, tableName);
        const expectedColumns = ['id', 'name', 'content', 'timestamp'];

        // 简化的校验逻辑
        if (actualColumns.length !== expectedColumns.length) {
          console.warn(`Column count mismatch for table ${tableName}`);
          return;
        }

        for (let i = 0; i < expectedColumns.length; i++) {
          if (actualColumns[i] !== expectedColumns[i]) {
            console.warn(`Column mismatch at index ${i}: ${actualColumns[i]} vs ${expectedColumns[i]}`);
            return;
          }
        }

        console.info(`Table ${tableName} schema validation passed`);

      } catch (err) {
        console.error(`Schema validation failed: ${err.message}`);
      }
    }
  }

  // 修复 getTableColumns 方法，确保返回 Promise
  private async getTableColumns(rdbStore: relationalStore.RdbStore, tableName: string): Promise<string[]> {
    return new Promise((resolve, reject) => {
      let predicates = new relationalStore.RdbPredicates(tableName);
      rdbStore.query(predicates, [], (err, resultSet) => {
        if (err) {
          reject(err);
          return;
        }
        const columnNames = resultSet.columnNames;
        resultSet.close();
        resolve(columnNames);
      });
    });
  }



  // Subscribe to data change messages from other devices within the network.
  subscribeDataChange() {
    if (this.store) {
      try {
        // Call the distributed data subscription interface to register observers for the database.
        // When data changes occur in a distributed database, a callback will be called.
        this.store.on('dataChange', relationalStore.SubscribeType.SUBSCRIBE_TYPE_REMOTE, async (devices) => {
          hilog.info(0x0000, 'hilog', CommonConstants.RDB_TAG, 'dataChange devices ' + devices);
          for (let i = 0; i < devices.length; i++) {
            let device = devices[i];
            if (!this.store) {
              return;
            }
            hilog.info(0x0000, 'hilog', CommonConstants.RDB_TAG, `The data of device:${device} has been changed.`);
            const result = await this.remoteQuery(device);
            this.context?.eventHub.emit('dataChange', JSON.stringify(result));
          }
        });
      } catch (err) {
        hilog.info(0x0000, 'hilog', CommonConstants.RDB_TAG,
          `Failed to register observer. Code:${err.code},message:${err.message}`);
      }
    }
  }

  // Get local device ID.
  getLocalDeviceNetworkId() {
    try {
      // create deviceManager.
      const deviceManager = distributedDeviceManager.createDeviceManager('com.example.crossDeviceDataSynchronization');
      // DeviceIds is obtained by calling the getAvailableDeviceListSync method by the DeviceManager.
      if (deviceManager != null) {
        this.localDeviceNetworkId = deviceManager.getLocalDeviceNetworkId();
        hilog.info(0x0000, 'hilog', CommonConstants.RDB_TAG,
          'local device networkId: ' + JSON.stringify(this.localDeviceNetworkId));
      }
    } catch (err) {
      hilog.error(0x0000, 'hilog', CommonConstants.RDB_TAG,
        `Failed to insert data. Code:${err.code}, message:${err.message}`);
    }
  }

  // Query the list of devices within the network.
  getDeviceList(): string[] {
    let deviceManager: distributedDeviceManager.DeviceManager;
    let deviceIds: string[] = [];
    try {
      // create deviceManager.
      deviceManager = distributedDeviceManager.createDeviceManager('com.example.crossDeviceDataSynchronization');
      // DeviceIds is obtained by calling the getAvailableDeviceListSync method by the DeviceManager.
      if (deviceManager != null) {
        let devices = deviceManager.getAvailableDeviceListSync();
        hilog.info(0x0000, 'hilog', CommonConstants.RDB_TAG, 'devices size ' + devices.length);
        for (let i = 0; i < devices.length; i++) {
          deviceIds[i] = devices[i].networkId as string;
          hilog.info(0x0000, 'hilog', CommonConstants.RDB_TAG, 'devices size ' + deviceIds[i]);
        }
      }
    } catch (err) {
      hilog.error(0x0000, 'hilog', CommonConstants.RDB_TAG,
        `Failed to insert data. Code:${err.code}, message:${err.message}`);
    }
    return deviceIds;
  }

  // Synchronize data.
  // async syncData() {
  //   if (this.store) {
  //     const deviceIds: string[] = this.getDeviceList();
  //     if (deviceIds.length === 0) {
  //       return;
  //     }
  //     // Construct predicate objects for synchronizing distributed tables.
  //     const predicates = new relationalStore.RdbPredicates(this.tableName);
  //     // Specify the list of devices to synchronize.
  //     predicates.inDevices(deviceIds);
  //     try {
  //       // Call the interface for synchronizing data to push the current device data changes to other devices in the network.
  //       const result = await this.store.sync(relationalStore.SyncMode.SYNC_MODE_PUSH, predicates);
  //       // Obtain synchronization results.
  //       for (let i = 0; i < result.length; i++) {
  //         const deviceId = result[i][0];
  //         const syncResult = result[i][1];
  //         if (syncResult === 0) {
  //           hilog.info(0x0000, 'hilog', CommonConstants.RDB_TAG, `device:${deviceId} sync success`);
  //         } else {
  //           hilog.error(0x0000, 'hilog', CommonConstants.RDB_TAG,
  //             `device:${deviceId} sync failed, status:${syncResult}`);
  //         }
  //       }
  //     } catch (err) {
  //       hilog.error(0x0000, 'hilog', CommonConstants.RDB_TAG,
  //         'Push data failed, code: ' + err.code + ', message: ' + err.message);
  //     }
  //   }
  // }

  /**
   * Query remote device data within the network
   * @param device device id
   * @returns
   */
  public async remoteQuery(device: string) {
    let list: DataEntity[] = [];
    if (this.store) {
      // Query the list of devices within the network.
      // Construct predicate objects for synchronizing distributed tables.
      const predicates = new relationalStore.RdbPredicates(CommonConstants.ACCOUNT_TABLE.tableName);
      try {
        // Query the distributed tables on devices within the network.
        const resultSet = await this.store.remoteQuery(device, CommonConstants.ACCOUNT_TABLE.tableName, predicates,
          CommonConstants.ACCOUNT_TABLE.columns);
        list = this.formatData(resultSet);
        if (list.length > 0) {
          resultSet.close();
        }
        hilog.info(0x0000, 'hilog', CommonConstants.RDB_TAG, 'Remote query success, row cout: ' + resultSet.rowCount);
        hilog.info(0x0000, 'hilog', CommonConstants.RDB_TAG,
          `ResultSet column names: ${resultSet.columnNames}, column count: ${resultSet.columnCount}`);
      } catch (err) {
        hilog.error(0x0000, 'hilog', CommonConstants.RDB_TAG,
          'Remote query failed, code: ' + err.code + ', message: ' + err.message);
      }
    }
    return list;
  }

  // Format database data.
  formatData(resultSet: relationalStore.ResultSet) {
    let list: DataEntity[] = [];
    const count: number = resultSet.rowCount;

    if (count !== 0 && typeof count === 'number') {
      try {
        resultSet.goToFirstRow();
        for (let i = 0; i < count; i++) {
          const tmp: DataEntity = {
            name: resultSet.getString(resultSet.getColumnIndex('name')),
            content: resultSet.getString(resultSet.getColumnIndex('content')),
            timestamp: resultSet.getLong(resultSet.getColumnIndex('timestamp'))
          };

          // 处理可选字段id
          const idColumn = resultSet.getColumnIndex('id');
          if (idColumn !== -1) {
            tmp.id = resultSet.getLong(idColumn);
          }

          list.push(tmp); // 改用push避免数组空位
          resultSet.goToNextRow();
        }
      } catch (error) {
        hilog.error(0x0000, 'RdbManager', `Format data error. Code:${error.code}, Message: ${error.message}`);
      }
    }
    return list;
  }

  // 查询并输出整个表的数据
  async printoutdb(table: string) {
    if (this.store) {
      let predicates = new relationalStore.RdbPredicates(table);
      this.store.query(predicates, [], (err, resultSet) => {
        if (err) {
          console.error('查询失败:', err);
          return;
        }

        let allData: Array<Record<string, Object>> = [];

        while (resultSet.goToNextRow()) {
          let row: Record<string, Object> = {};
          for (let columnName of resultSet.columnNames) {
            row[columnName] = resultSet.getString(resultSet.getColumnIndex(columnName));
          }
          allData.push(row);
        }

        // 使用 JSON.stringify 格式化输出
        console.log('表数据:', JSON.stringify(allData, null, 2));
        resultSet.close();
      });
    }
  }


  // 插入数据
  async insertData(table: string, data: InsertDataEntity) {
    console.info(`Insert data: ${JSON.stringify(data.content)}`);
    if (!this.isInitialized || !this.store) {
      throw new Error('数据库未初始化');
    }
    const valueBucket: relationalStore.ValuesBucket = {
      'name': data.name,
      'content': data.content,
      'timestamp': data.timestamp,
    };

    try {

      return await this.store?.insert(table, valueBucket);
    } catch (err) {
      console.error(`Insert failed: ${err.code} - ${err.message}`);
      return -1;
    }

  }

  // 删除数据
  async deleteData(table: string, name: string) {
    const predicates = new relationalStore.RdbPredicates(table);
    predicates.equalTo('name', name);

    try {
      return await this.store?.executeSql(
        `DELETE FROM ${table} WHERE name = ?`, [name]
      );
    } catch (err) {
      hilog.error(0x0000, 'DB_ERROR', `Delete failed: ${err.code}`);
      throw new Error(); // 抛出异常供上层处理
    }
  }

  // 更新数据
  async updateData(
    table: string, newdata: DataEntity
  ) {
    const predicates = new relationalStore.RdbPredicates(table);
    predicates.equalTo('id', newdata.id);

    const valueBucket: relationalStore.ValuesBucket = {
      name: newdata.name ?? '',
      content: newdata.content ?? '',
      'timestamp': new Date().getTime()
    };

    try {
      return await this.store?.update(valueBucket, predicates);
    } catch (err) {
      console.error(`Update failed: ${err.code} - ${err.message}`);
      return 0;
    }
  }

  // 查询数据
  async query(table: string, name: string): Promise<DataEntity[]> {
    const predicates = new relationalStore.RdbPredicates(table);

    // 只有当 name 不为空时才添加查询条件
    if (name !== '') {
      predicates.equalTo('name', name);
    }

    if (!this.store) {
      throw new Error('RdbStore is not initialized');
    }

    const resultSet = await this.store.query(predicates, ['id', 'name', 'content', 'timestamp']);

    const entities: DataEntity[] = [];
    for (let i = 0; i < resultSet.rowCount; i++) {
      resultSet.goToRow(i);
      const entity: DataEntity = {
        id: resultSet.getDouble(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        content: resultSet.getString(resultSet.getColumnIndex('content')),
        timestamp: resultSet.getDouble(resultSet.getColumnIndex('timestamp'))
      };
      entities.push(entity);
    }
    resultSet.close();
    return entities;
  }
  updateLocalDataBase(table: string, oldList: Array<DataEntity>, newList: Array<DataEntity>) {
    const mergedList = [...newList, ...oldList];
    const idSet = new Set<number | undefined>(mergedList.map(item => item.id));

    idSet.forEach((id: number | undefined) => {
      const oldItem = oldList.find(item => item.id === id);
      const newItem = newList.find(item => item.id === id);

      if (!oldItem) { // 新增操作
        const target = mergedList.find(item => item.id === id);
        if (target && target.id !== undefined) {
          this.insertData(table, {
            name: target.name,
            content: target.content,
            timestamp: target.timestamp
          });
        }
      } else if (!newItem) { // 删除操作
        if (oldItem.id !== undefined) {
          this.deleteData(table, oldItem.name);
        }
      } else { // 更新操作
        this.updateData(
          table,
          newItem
        );
      }
    });
  }
}

// export default new DatabaseManager(this.context);