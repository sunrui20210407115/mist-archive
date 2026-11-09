import { relationalStore } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { LogEntry } from '../model/GameTypes';

// 执行日志：关系型数据库（结构化记录、可查询）
export class LogRepo {
  private static store: relationalStore.RdbStore | undefined = undefined;
  private static readonly DB_NAME: string = 'mist_archive.db';
  private static readonly TABLE: string = 'event_log';
  private static readonly CREATE_SQL: string =
    'CREATE TABLE IF NOT EXISTS event_log (' +
      'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
      'node_id TEXT NOT NULL, ' +
      'choice_id TEXT NOT NULL, ' +
      'clue_added TEXT, ' +
      'created_at INTEGER NOT NULL)';

  static async init(context: common.UIAbilityContext): Promise<void> {
    if (LogRepo.store) {
      return;
    }
    LogRepo.store = await relationalStore.getRdbStore(context, {
      name: LogRepo.DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    });
    await LogRepo.store.executeSql(LogRepo.CREATE_SQL);
  }

  static async append(entry: LogEntry): Promise<void> {
    if (!LogRepo.store) {
      return;
    }
    const values: relationalStore.ValuesBucket = {
      'node_id': entry.nodeId,
      'choice_id': entry.choiceId,
      'clue_added': entry.clueAdded,
      'created_at': entry.createdAt
    };
    await LogRepo.store.insert(LogRepo.TABLE, values);
  }

  static async recent(limit: number): Promise<LogEntry[]> {
    const list: LogEntry[] = [];
    if (!LogRepo.store) {
      return list;
    }
    const sql: string = 'SELECT node_id, choice_id, clue_added, created_at FROM ' +
      LogRepo.TABLE + ' ORDER BY id DESC LIMIT ?';
    const resultSet = await LogRepo.store.querySql(sql, [limit]);
    while (resultSet.goToNextRow()) {
      list.push({
        nodeId: resultSet.getString(resultSet.getColumnIndex('node_id')),
        choiceId: resultSet.getString(resultSet.getColumnIndex('choice_id')),
        clueAdded: resultSet.getString(resultSet.getColumnIndex('clue_added')),
        createdAt: resultSet.getLong(resultSet.getColumnIndex('created_at'))
      });
    }
    resultSet.close();
    return list;
  }

  static async count(): Promise<number> {
    if (!LogRepo.store) {
      return 0;
    }
    const resultSet = await LogRepo.store.querySql('SELECT COUNT(*) AS total FROM ' + LogRepo.TABLE);
    let total: number = 0;
    if (resultSet.goToFirstRow()) {
      total = resultSet.getLong(resultSet.getColumnIndex('total'));
    }
    resultSet.close();
    return total;
  }
}
