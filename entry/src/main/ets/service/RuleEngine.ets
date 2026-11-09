import { AdvanceResult, Choice, Effects, EndingDef, GameState, Requirement, cloneState } from '../model/GameTypes';
import { ENDINGS, findClue, findNode } from '../model/StoryData';

// 规则引擎：条件判定、效果应用、阶段推进、结局裁决
export class RuleEngine {
  // 判定一个选择/节点当前是否可用
  static satisfies(state: GameState, req?: Requirement): boolean {
    if (!req) {
      return true;
    }
    if (req.minStage !== undefined && state.stage < req.minStage) {
      return false;
    }
    if (req.clues) {
      for (let i = 0; i < req.clues.length; i++) {
        if (state.clues.indexOf(req.clues[i]) < 0) {
          return false;
        }
      }
    }
    if (req.anyFlags) {
      let hit: boolean = false;
      for (let i = 0; i < req.anyFlags.length; i++) {
        if (state.flags[req.anyFlags[i]] === true) {
          hit = true;
          break;
        }
      }
      if (!hit) {
        return false;
      }
    }
    if (req.noneFlags) {
      for (let i = 0; i < req.noneFlags.length; i++) {
        if (state.flags[req.noneFlags[i]] === true) {
          return false;
        }
      }
    }
    return true;
  }

  // 应用效果：线索去重、标记置位、阶段只增不减
  static applyEffects(state: GameState, effects?: Effects): GameState {
    const next: GameState = cloneState(state);
    if (effects) {
      if (effects.addClues) {
        for (let i = 0; i < effects.addClues.length; i++) {
          const clueId: string = effects.addClues[i];
          if (next.clues.indexOf(clueId) < 0 && findClue(clueId) !== undefined) {
            next.clues.push(clueId);
          }
        }
      }
      if (effects.setFlags) {
        for (let i = 0; i < effects.setFlags.length; i++) {
          next.flags[effects.setFlags[i]] = true;
        }
      }
      if (effects.clearFlags) {
        for (let i = 0; i < effects.clearFlags.length; i++) {
          next.flags[effects.clearFlags[i]] = false;
        }
      }
      if (effects.advanceStage !== undefined && effects.advanceStage > next.stage) {
        next.stage = effects.advanceStage;
      }
    }
    return next;
  }

  // 阶段推进：接案 -> 调查中 -> 可终局
  static evaluateStage(state: GameState): number {
    if (state.stage >= 3) {
      return 3;
    }
    if (state.stage === 0) {
      return 1;
    }
    if (state.clues.length >= 4 && state.flags['flag_tape_played'] === true) {
      return 2;
    }
    return state.stage;
  }

  // 执行一次选择，返回新状态与提示
  static applyChoice(state: GameState, nodeId: string, choiceId: string): AdvanceResult {
    const node = findNode(nodeId);
    if (!node) {
      return { ok: false, state: state, message: '节点不存在，已停留在当前位置', addedClues: [] };
    }
    let choice: Choice | undefined = undefined;
    for (let i = 0; i < node.choices.length; i++) {
      if (node.choices[i].id === choiceId) {
        choice = node.choices[i];
        break;
      }
    }
    if (!choice) {
      return { ok: false, state: state, message: '该选项不存在', addedClues: [] };
    }
    if (!RuleEngine.satisfies(state, choice.req)) {
      const tip: string = choice.hint ? choice.hint : '条件不足：还缺少必要的线索或前置信息';
      return { ok: false, state: state, message: tip, addedClues: [] };
    }
    const before: string[] = state.clues.slice();
    let next: GameState = RuleEngine.applyEffects(state, choice.effects);
    if (choice.nextNodeId && findNode(choice.nextNodeId) !== undefined) {
      next.currentNodeId = choice.nextNodeId;
      next.sceneId = choice.nextNodeId === 'hall_review' ? 'hall' : next.sceneId;
    }
    if (next.visited.indexOf(nodeId) < 0) {
      next.visited.push(nodeId);
    }
    next.stage = RuleEngine.evaluateStage(next);
    next.updatedAt = Date.now();
    const added: string[] = [];
    for (let i = 0; i < next.clues.length; i++) {
      if (before.indexOf(next.clues[i]) < 0) {
        added.push(next.clues[i]);
      }
    }
    let message: string = '线索已记录';
    if (added.length > 0) {
      const names: string[] = [];
      for (let i = 0; i < added.length; i++) {
        const clue = findClue(added[i]);
        names.push(clue ? clue.name : added[i]);
      }
      message = '获得线索：' + names.join('、');
    } else if (next.stage === 2 && state.stage < 2) {
      message = '推理条件已具备，可以进入复盘台';
    } else {
      message = '记录已更新';
    }
    return { ok: true, state: next, message: message, addedClues: added };
  }

  // 结局裁决：先命中 A 的条件，否则 B
  static resolveEnding(state: GameState): EndingDef {
    for (let i = 0; i < ENDINGS.length; i++) {
      if (RuleEngine.satisfies(state, ENDINGS[i].req)) {
        return ENDINGS[i];
      }
    }
    return ENDINGS[ENDINGS.length - 1];
  }

  static clueCount(state: GameState, total: number): string {
    return state.clues.length.toString() + '/' + total.toString();
  }
}
