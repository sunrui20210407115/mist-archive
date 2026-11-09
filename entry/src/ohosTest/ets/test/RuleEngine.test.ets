import { describe, expect, it } from '@ohos/hypium';
import { RuleEngine } from '../../../main/ets/service/RuleEngine';
import { createInitialState } from '../../../main/ets/model/StoryData';
import { Requirement } from '../../../main/ets/model/GameTypes';

// 规则引擎自动化测试：正常、边界、异常三类
export default function ruleEngineTest() {
  describe('RuleEngineTest', () => {

    // 正常 1：无条件需求恒为可用
    it('satisfies_without_requirement', 0, () => {
      const state = createInitialState();
      expect(RuleEngine.satisfies(state, undefined)).assertTrue();
    });

    // 正常 2：持有全部要求线索时条件成立
    it('satisfies_with_all_clues', 0, () => {
      const state = createInitialState();
      state.clues = ['clue_ledger', 'clue_key'];
      const req: Requirement = { clues: ['clue_ledger', 'clue_key'] };
      expect(RuleEngine.satisfies(state, req)).assertTrue();
    });

    // 边界 3：只持有部分线索时应判定不满足
    it('satisfies_with_partial_clues_false', 0, () => {
      const state = createInitialState();
      state.clues = ['clue_ledger'];
      const req: Requirement = { clues: ['clue_ledger', 'clue_key'] };
      expect(RuleEngine.satisfies(state, req)).assertFalse();
    });

    // 边界 4：阶段不足以未达到终局门槛
    it('satisfies_minstage_boundary', 0, () => {
      const state = createInitialState();
      state.stage = 1;
      const req: Requirement = { minStage: 2 };
      expect(RuleEngine.satisfies(state, req)).assertFalse();
    });

    // 正常 5：效果同时新增线索与置位标记
    it('applyEffects_add_clue_and_flag', 0, () => {
      const state = createInitialState();
      const next = RuleEngine.applyEffects(state, {
        addClues: ['clue_tape'],
        setFlags: ['flag_tape_played']
      });
      expect(next.clues.length).assertEqual(1);
      expect(next.clues[0]).assertEqual('clue_tape');
      expect(next.flags['flag_tape_played']).assertTrue();
      expect(state.clues.length).assertEqual(0);
    });

    // 边界 6：重复添加同一条线索应去重
    it('applyEffects_deduplicate_clue', 0, () => {
      const state = createInitialState();
      state.clues = ['clue_ledger'];
      const next = RuleEngine.applyEffects(state, { addClues: ['clue_ledger', 'clue_ledger'] });
      expect(next.clues.length).assertEqual(1);
    });

    // 异常 7：不存在的线索 id 不应写入状态
    it('applyEffects_ignore_unknown_clue', 0, () => {
      const state = createInitialState();
      const next = RuleEngine.applyEffects(state, { addClues: ['clue_not_exists'] });
      expect(next.clues.length).assertEqual(0);
    });

    // 边界 8：阶段只增不减，低阶段推进不应回退
    it('applyEffects_stage_never_rollback', 0, () => {
      const state = createInitialState();
      state.stage = 2;
      const next = RuleEngine.applyEffects(state, { advanceStage: 1 });
      expect(next.stage).assertEqual(2);
    });

    // 异常 9：节点不存在时选择应被拒绝
    it('applyChoice_unknown_node_rejected', 0, () => {
      const state = createInitialState();
      const result = RuleEngine.applyChoice(state, 'node_not_exists', 'any');
      expect(result.ok).assertFalse();
      expect(result.state.clues.length).assertEqual(0);
    });

    // 异常 10：选项不存在时应被拒绝
    it('applyChoice_unknown_choice_rejected', 0, () => {
      const state = createInitialState();
      const result = RuleEngine.applyChoice(state, 'lib_intro', 'choice_not_exists');
      expect(result.ok).assertFalse();
      expect(result.message.length > 0).assertTrue();
    });

    // 异常 11：条件不足的选择应给出提示且不改变状态
    it('applyChoice_requirement_not_met', 0, () => {
      const state = createInitialState();
      const result = RuleEngine.applyChoice(state, 'lab_302', 'play_tape');
      expect(result.ok).assertFalse();
      expect(result.addedClues.length).assertEqual(0);
    });

    // 正常 12：合法选择应写入线索并推进阶段
    it('applyChoice_collect_clue_and_advance', 0, () => {
      const state = createInitialState();
      state.stage = 1;
      const result = RuleEngine.applyChoice(state, 'lib_intro', 'pick_scraps');
      expect(result.ok).assertTrue();
      expect(result.state.clues.indexOf('clue_ledger') >= 0).assertTrue();
      expect(result.addedClues.length).assertEqual(1);
    });

    // 正常 13：条件齐备时裁决为结局 A
    it('resolveEnding_handover', 0, () => {
      const state = createInitialState();
      state.stage = 2;
      state.clues = ['clue_ledger', 'clue_key', 'clue_tape', 'clue_monitor'];
      state.flags['flag_motive'] = true;
      const ending = RuleEngine.resolveEnding(state);
      expect(ending.id).assertEqual('ending_handover');
    });

    // 边界 14：条件缺一项时回落为结局 B
    it('resolveEnding_fallback_alone', 0, () => {
      const state = createInitialState();
      state.stage = 2;
      state.clues = ['clue_ledger', 'clue_key', 'clue_tape'];
      state.flags['flag_motive'] = true;
      const ending = RuleEngine.resolveEnding(state);
      expect(ending.id).assertEqual('ending_alone');
    });

    // 边界 15：线索数量达标且录音已播时阶段推进到 2
    it('evaluateStage_to_ready', 0, () => {
      const state = createInitialState();
      state.stage = 1;
      state.clues = ['clue_ledger', 'clue_key', 'clue_tape', 'clue_monitor'];
      state.flags['flag_tape_played'] = true;
      expect(RuleEngine.evaluateStage(state)).assertEqual(2);
    });
  });
}
