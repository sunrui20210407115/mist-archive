import { GameState, LogEntry, SceneId, STAGE_ENDED, STAGE_INVESTIGATE, cloneState } from '../model/GameTypes';
import { createInitialState, NODES } from '../model/StoryData';
import { RuleEngine } from '../service/RuleEngine';
import { SaveService } from '../service/SaveService';
import { LogRepo } from '../service/LogRepo';

// 会话状态：页面通过 @ObjectLink 订阅本对象
@Observed
export class GameStore {
  state: GameState = createInitialState();
  message: string = '点击“接受调查”开始';
  hasSave: boolean = false;
  homeMode: boolean = false;
  saving: boolean = false;

  async restore(): Promise<void> {
    const saved = await SaveService.load();
    if (saved) {
      this.state = saved;
      this.hasSave = true;
      this.homeMode = false;
      this.message = '已恢复到上次进度';
    }
  }

  async newCase(): Promise<void> {
    await SaveService.clear();
    const next: GameState = cloneState(createInitialState());
    next.stage = STAGE_INVESTIGATE;
    this.state = next;
    this.hasSave = true;
    this.homeMode = false;
    this.message = '案件已建立，从图书馆闭架书库开始调查';
    await this.persist();
  }

  async restart(): Promise<void> {
    await SaveService.clear();
    const next: GameState = cloneState(createInitialState());
    next.stage = STAGE_INVESTIGATE;
    this.state = next;
    this.homeMode = false;
    this.message = '已重开案件，进度归零';
    await this.persist();
  }

  backToHome(): void {
    this.homeMode = true;
    this.message = '已返回案件入口';
  }

  setScene(scene: string): void {
    if (this.state.stage === STAGE_ENDED) {
      return;
    }
    const next: GameState = cloneState(this.state);
    next.sceneId = scene as SceneId;
    for (let i = 0; i < NODES.length; i++) {
      if (NODES[i].sceneId === next.sceneId) {
        next.currentNodeId = NODES[i].id;
        break;
      }
    }
    this.state = next;
  }

  choose(nodeId: string, choiceId: string): void {
    if (this.state.stage === STAGE_ENDED) {
      return;
    }
    const result = RuleEngine.applyChoice(this.state, nodeId, choiceId);
    if (!result.ok) {
      this.message = result.message;
      return;
    }
    this.state = result.state;
    this.message = result.message;
    this.persist();
    const log: LogEntry = {
      nodeId: nodeId,
      choiceId: choiceId,
      clueAdded: result.addedClues.join(','),
      createdAt: Date.now()
    };
    LogRepo.append(log).catch((err: Error) => {
      this.message = '日志写入失败：' + err.message;
    });
  }

  submitFinale(): void {
    if (this.state.stage < 2) {
      this.message = '推理条件尚未集齐，先回到线索板核对';
      return;
    }
    const ending = RuleEngine.resolveEnding(this.state);
    const next: GameState = cloneState(this.state);
    next.stage = STAGE_ENDED;
    next.endingId = ending.id;
    next.sceneId = 'ending';
    this.state = next;
    this.message = ending.title;
    this.persist();
  }

  private persist(): void {
    this.saving = true;
    SaveService.save(this.state).then(() => {
      this.saving = false;
      this.hasSave = true;
    }).catch((err: Error) => {
      this.saving = false;
      this.message = '存档失败：' + err.message;
    });
  }
}
