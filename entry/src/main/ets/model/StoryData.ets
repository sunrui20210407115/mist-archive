import { Clue, EndingDef, EventNode, GameState, STAGE_ACCEPT } from './GameTypes';

// 6 条可查阅线索
export const CLUES: Clue[] = [
  { id: 'clue_ledger', name: '借阅登记本残页', sceneId: 'lib',
    detail: '被撕下的一页：案发当晚 22:40，有人以“校史馆整理”名义借走 3 号档案盒，签名一栏被墨水涂掉。' },
  { id: 'clue_key', name: '值班台备用钥匙', sceneId: 'lib',
    detail: '钥匙牌编号 B-07，钥匙串上缺一把。B-07 对应校史馆后门的旧锁，值班记录里没有领用记录。' },
  { id: 'clue_tape', name: '社团排练录音磁带', sceneId: 'lib',
    detail: '磁带标签写着“十月排练 第 3 次”。盒内纸条注明：录音机在三楼 302，磁带需另找。' },
  { id: 'clue_monitor', name: '门禁记录打印件', sceneId: 'lab',
    detail: '23:10 有人用工号刷开三层门禁，工号末两位被涂改液覆盖，只能看出“20xx”。' },
  { id: 'clue_note', name: '匿名纸条', sceneId: 'dorm',
    detail: '压在晾衣绳夹子上的字条：“别查了，档案不在馆里。”纸边有实验室常用的蓝色标签胶痕。' },
  { id: 'clue_roster', name: '值夜表', sceneId: 'dorm',
    detail: '当晚值班签名是“周”，但周当晚请假回家；签名笔迹与登记本残页上的涂改笔压一致。' }
];

// 12 个事件节点：条件与效果真实改变后续可做的事
export const NODES: EventNode[] = [
  {
    id: 'lib_intro', sceneId: 'lib', title: '闭架书库入口',
    body: '闭架书库的门虚掩着，地上散着几片纸屑。登记台在左侧，值班室的灯还亮着。',
    choices: [
      { id: 'pick_scraps', label: '蹲下捡起纸屑', effects: { addClues: ['clue_ledger'] }, nextNodeId: 'lib_intro' },
      { id: 'to_desk', label: '先去登记台', nextNodeId: 'lib_desk' },
      { id: 'to_guard', label: '去值班室找老管理员', nextNodeId: 'lib_guard' }
    ]
  },
  {
    id: 'lib_desk', sceneId: 'lib', title: '登记台抽屉',
    body: '登记台抽屉锁着，锁孔边缘有新鲜的划痕。抽屉侧面贴着一张“钥匙领用须登记”的旧告示。',
    choices: [
      { id: 'ask_guard', label: '回值班室问钥匙', nextNodeId: 'lib_guard' },
      { id: 'force_drawer', label: '用回形针撬开抽屉', hint: '抽屉是铁皮的，硬撬会留下明显痕迹，先确认有没有更稳妥的办法。', nextNodeId: 'lib_desk' }
    ]
  },
  {
    id: 'lib_guard', sceneId: 'lib', title: '值班室：老管理员',
    body: '老管理员正在登记还书。他抬眼看了看你手里的调查授权，没有说话。',
    choices: [
      { id: 'explain', label: '说明来意，请他配合', effects: { setFlags: ['flag_guard_trust'] }, nextNodeId: 'lib_guard_trust' },
      { id: 'ask_box', label: '直接追问 3 号档案盒', effects: { setFlags: ['flag_guard_alert'] }, nextNodeId: 'lib_guard_press' }
    ]
  },
  {
    id: 'lib_guard_trust', sceneId: 'lib', title: '管理员的配合',
    body: '他把钥匙串推到台面上：“B-07 那把昨天就不见了，我没敢报。抽屉你自己开吧，别把锁弄坏。”',
    choices: [
      { id: 'take_key', label: '取走备用钥匙并登记', effects: { addClues: ['clue_key'] }, nextNodeId: 'lib_desk' }
    ]
  },
  {
    id: 'lib_guard_press', sceneId: 'lib', title: '管理员的戒备',
    body: '“档案盒？我什么都不知道。”他把登记本合上，转身去整理书架，谈话到此为止。',
    choices: [
      { id: 'back_off', label: '先退一步，换个说法', effects: { clearFlags: ['flag_guard_alert'] }, nextNodeId: 'lib_guard' },
      { id: 'leave', label: '离开值班室', nextNodeId: 'lib_intro' }
    ]
  },
  {
    id: 'lib_return', sceneId: 'lib', title: '归还箱里的磁带',
    body: '归还箱最底层压着一个没有编号的磁带盒，标签被水泡过，只剩“排练”两个字。',
    req: { clues: ['clue_ledger'] },
    choices: [
      { id: 'take_tape', label: '取出磁带核对标签', effects: { addClues: ['clue_tape'] }, nextNodeId: 'lib_return' },
      { id: 'skip', label: '放回原处', nextNodeId: 'lib_intro' }
    ]
  },
  {
    id: 'lab_gate', sceneId: 'lab', title: '三层门禁',
    body: '门禁读卡器旁边贴着一张夜间出入记录打印件，边缘被人撕过。保安在传达室里看电视。',
    choices: [
      { id: 'ask_security', label: '请保安调出原始记录', req: { anyFlags: ['flag_guard_trust'] },
        effects: { addClues: ['clue_monitor'] }, nextNodeId: 'lab_gate' },
      { id: 'copy_print', label: '只抄下打印件上的时间', effects: { addClues: ['clue_monitor'] }, nextNodeId: 'lab_gate' },
      { id: 'go_302', label: '直接上 302', nextNodeId: 'lab_302' }
    ]
  },
  {
    id: 'lab_302', sceneId: 'lab', title: '302 排练室',
    body: '排练室角落堆着社团的道具，桌上有一台旧录音机，电源线还插着。',
    choices: [
      { id: 'play_tape', label: '放入磁带播放', req: { clues: ['clue_tape'] },
        effects: { setFlags: ['flag_tape_played'] }, nextNodeId: 'lab_302_play' },
      { id: 'check_desk', label: '翻看桌上的排练签到表', nextNodeId: 'lab_302_sign' }
    ]
  },
  {
    id: 'lab_302_play', sceneId: 'lab', title: '磁带里的争吵',
    body: '录音里先是排练的口令，随后两个人压低声音争执：“盒子今晚必须挪走”“钥匙你拿的？”录音到这句断了。',
    choices: [
      { id: 'note_voice', label: '记下争执中的“盒子”和“钥匙”', effects: { setFlags: ['flag_motive'] }, nextNodeId: 'lab_302_play' },
      { id: 'rewind', label: '倒回重听一遍', nextNodeId: 'lab_302_play' }
    ]
  },
  {
    id: 'lab_302_sign', sceneId: 'lab', title: '排练签到表',
    body: '签到表上当晚来了 5 个人，最后一个签名是“周”，时间 22:35。表格下方压着一张实验室蓝色标签纸。',
    choices: [
      { id: 'compare', label: '把标签纸与纸条比对', req: { clues: ['clue_note'] },
        effects: { setFlags: ['flag_label_match'] }, nextNodeId: 'lab_302_sign' },
      { id: 'back', label: '先离开排练室', nextNodeId: 'lab_gate' }
    ]
  },
  {
    id: 'dorm_note', sceneId: 'dorm', title: '晾晒区的纸条',
    body: '晾衣绳的夹子上压着一张对折的纸，字迹刻意写得歪斜。夹子旁边落着一小片蓝色标签。',
    choices: [
      { id: 'take_note', label: '收起纸条', effects: { addClues: ['clue_note'] }, nextNodeId: 'dorm_note' },
      { id: 'to_office', label: '去宿舍值班室', nextNodeId: 'dorm_office' }
    ]
  },
  {
    id: 'dorm_office', sceneId: 'dorm', title: '宿舍值班室',
    body: '值班室墙上挂着本周值夜表。阿姨正在打电话，桌上摊着请假条。',
    choices: [
      { id: 'read_roster', label: '核对值夜表签名', effects: { addClues: ['clue_roster'] }, nextNodeId: 'dorm_office' },
      { id: 'ask_aunt', label: '问阿姨当晚谁值的班', req: { clues: ['clue_roster'] },
        effects: { setFlags: ['flag_night_confirm'] }, nextNodeId: 'dorm_office' }
    ]
  },
  {
    id: 'hall_review', sceneId: 'hall', title: '线索复盘台',
    body: '把 6 条线索摊在桌上，三条推理条件需要逐条核对：物证链、动机、时间线。',
    choices: [
      { id: 'to_finale', label: '进入终局判断', req: { minStage: 2 }, nextNodeId: 'hall_review' }
    ]
  }
];

// 2 个由不同条件触发的结局
export const ENDINGS: EndingDef[] = [
  {
    id: 'ending_handover', title: '结局 A：移交校方',
    subtitle: '物证链闭合 · 动机成立 · 时间线吻合',
    body: '你把借阅残页、B-07 钥匙、磁带录音与门禁记录按时间排好：22:35 签到、22:40 借盒、23:10 刷卡进楼。值夜签名与涂改笔压一致，纸条上的蓝色标签与排练室属于同一批耗材。校方当晚封存了档案盒，调查记录移交档案室。',
    req: {
      clues: ['clue_ledger', 'clue_key', 'clue_tape', 'clue_monitor'],
      anyFlags: ['flag_motive', 'flag_label_match'],
      minStage: 2
    }
  },
  {
    id: 'ending_alone', title: '结局 B：独自结案',
    subtitle: '证据存在缺口，结论未被采信',
    body: '你把推测写成一份个人记录，但缺少能闭合物证链的关键一环。校方以“证据不足”退回材料，档案盒的去向仍没有定论。档案室的灯灭了，案子悬在那里。',
    req: {}
  }
];

export function createInitialState(): GameState {
  return {
    stage: STAGE_ACCEPT,
    sceneId: 'lib',
    currentNodeId: 'lib_intro',
    clues: [],
    flags: {},
    visited: [],
    endingId: '',
    updatedAt: Date.now()
  };
}

export function findNode(nodeId: string): EventNode | undefined {
  for (let i = 0; i < NODES.length; i++) {
    if (NODES[i].id === nodeId) {
      return NODES[i];
    }
  }
  return undefined;
}

export function findClue(clueId: string): Clue | undefined {
  for (let i = 0; i < CLUES.length; i++) {
    if (CLUES[i].id === clueId) {
      return CLUES[i];
    }
  }
  return undefined;
}
