import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { GameState, SavePayload, STAGE_ACCEPT, cloneState } from '../model/GameTypes';
import { findClue } from '../model/StoryData';

// 存档服务：Preferences 快照 + 版本号校验 + 损坏回退
export class SaveService {
  private static readonly STORE_NAME: string = 'mist_archive_save';
  private static readonly KEY_STATE: string = 'game_state';
  private static readonly STATE_VERSION: number = 2;
  private static store: preferences.Preferences | undefined = undefined;

  static async init(context: common.UIAbilityContext): Promise<void> {
    if (SaveService.store) {
      return;
    }
    SaveService.store = await preferences.getPreferences(context, { name: SaveService.STORE_NAME });
  }

  static async save(state: GameState): Promise<void> {
    if (!SaveService.store) {
      return;
    }
    const payload: SavePayload = { version: SaveService.STATE_VERSION, state: state };
    await SaveService.store.put(SaveService.KEY_STATE, JSON.stringify(payload));
    await SaveService.store.flush();
  }

  static async load(): Promise<GameState | null> {
    if (!SaveService.store) {
      return null;
    }
    const raw = await SaveService.store.get(SaveService.KEY_STATE, '') as string;
    if (!raw || raw.length === 0) {
      return null;
    }
    try {
      const payload = JSON.parse(raw) as SavePayload;
      if (payload.version !== SaveService.STATE_VERSION) {
        return null;
      }
      return SaveService.normalize(payload.state);
    } catch (err) {
      await SaveService.clear();
      return null;
    }
  }

  static async clear(): Promise<void> {
    if (!SaveService.store) {
      return;
    }
    await SaveService.store.delete(SaveService.KEY_STATE);
    await SaveService.store.flush();
  }

  // 字段校验：类型不对或线索 id 不存在时丢弃，不抛异常
  static normalize(source: GameState | undefined): GameState | null {
    if (!source) {
      return null;
    }
    const stage: number = typeof source.stage === 'number' ? source.stage : STAGE_ACCEPT;
    const currentNodeId: string = typeof source.currentNodeId === 'string' ? source.currentNodeId : 'lib_intro';
    const validClues: string[] = [];
    if (Array.isArray(source.clues)) {
      for (let i = 0; i < source.clues.length; i++) {
        const id: string = source.clues[i];
        if (typeof id === 'string' && findClue(id) !== undefined && validClues.indexOf(id) < 0) {
          validClues.push(id);
        }
      }
    }
    const flags: Record<string, boolean> = {};
    if (source.flags && typeof source.flags === 'object') {
      const keys = Object.keys(source.flags);
      for (let i = 0; i < keys.length; i++) {
        flags[keys[i]] = source.flags[keys[i]] === true;
      }
    }
    const visited: string[] = Array.isArray(source.visited) ? source.visited : [];
    const state: GameState = {
      stage: stage,
      sceneId: typeof source.sceneId === 'string' ? source.sceneId : 'lib',
      currentNodeId: currentNodeId,
      clues: validClues,
      flags: flags,
      visited: visited,
      endingId: typeof source.endingId === 'string' ? source.endingId : '',
      updatedAt: typeof source.updatedAt === 'number' ? source.updatedAt : Date.now()
    };
    return cloneState(state);
  }
}
