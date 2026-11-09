// 业务数据模型：状态、线索、事件节点、日志、结局
export type SceneId = 'lib' | 'lab' | 'dorm' | 'hall' | 'ending';

export interface Requirement {
  clues?: string[];        // 必须同时持有的线索
  anyFlags?: string[];     // 任一标记成立即可
  noneFlags?: string[];    // 任一标记成立则不可选
  minStage?: number;
}

export interface Effects {
  addClues?: string[];
  setFlags?: string[];
  clearFlags?: string[];
  advanceStage?: number;
}

export interface Choice {
  id: string;
  label: string;
  req?: Requirement;
  effects?: Effects;
  nextNodeId?: string;
  hint?: string;           // 条件不满足时给玩家的提示
}

export interface EventNode {
  id: string;
  sceneId: SceneId;
  title: string;
  body: string;
  req?: Requirement;
  choices: Choice[];
}

export interface Clue {
  id: string;
  name: string;
  sceneId: SceneId;
  detail: string;
}

export interface GameState {
  stage: number;
  sceneId: SceneId;
  currentNodeId: string;
  clues: string[];
  flags: Record<string, boolean>;
  visited: string[];
  endingId: string;
  updatedAt: number;
}

export interface SavePayload {
  version: number;
  state: GameState;
}

export interface LogEntry {
  nodeId: string;
  choiceId: string;
  clueAdded: string;
  createdAt: number;
}

export interface AdvanceResult {
  ok: boolean;
  state: GameState;
  message: string;
  addedClues: string[];
}

export interface EndingDef {
  id: string;
  title: string;
  subtitle: string;
  body: string;
  req: Requirement;
}

export const STAGE_ACCEPT: number = 0;
export const STAGE_INVESTIGATE: number = 1;
export const STAGE_READY: number = 2;
export const STAGE_ENDED: number = 3;

export const SCENE_NAMES: Record<string, string> = {
  'lib': '图书馆闭架书库',
  'lab': '实验楼三层',
  'dorm': '宿舍区晾晒区',
  'hall': '线索复盘台',
  'ending': '结案'
};

export function cloneState(source: GameState): GameState {
  const flags: Record<string, boolean> = {};
  const keys = Object.keys(source.flags);
  for (let i = 0; i < keys.length; i++) {
    flags[keys[i]] = source.flags[keys[i]];
  }
  return {
    stage: source.stage,
    sceneId: source.sceneId,
    currentNodeId: source.currentNodeId,
    clues: source.clues.slice(),
    flags: flags,
    visited: source.visited.slice(),
    endingId: source.endingId,
    updatedAt: source.updatedAt
  };
}
