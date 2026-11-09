import { GameStore } from '../viewmodel/GameStore';
import { CLUES, NODES } from '../model/StoryData';
import { Clue, SCENE_NAMES } from '../model/GameTypes';

@Component
export struct ClueBoardView {
  @ObjectLink store: GameStore;
  onBack: () => void = () => {};
  onFinale: () => void = () => {};

  hasAll(ids: string[]): boolean {
    for (let i = 0; i < ids.length; i++) {
      if (this.store.state.clues.indexOf(ids[i]) < 0) {
        return false;
      }
    }
    return true;
  }

  @Builder
  CondRow(title: string, detail: string, ok: boolean) {
    Row({ space: 10 }) {
      Text(ok ? '✓' : '○')
        .fontSize(18)
        .fontColor(ok ? '#3FC27A' : '#8FA3BF')
      Column() {
        Text(title).fontSize(14).fontColor('#F2F5F9')
        Text(detail).fontSize(11).fontColor('#8FA3BF').margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      Text(ok ? '已成立' : '待补齐')
        .fontSize(11)
        .fontColor(ok ? '#3FC27A' : '#C05A5A')
    }
    .width('100%')
    .padding(12)
    .borderRadius(10)
    .backgroundColor('#101D30')
  }

  @Builder
  ClueCard(clue: Clue) {
    Column({ space: 6 }) {
      Row() {
        Text(this.store.state.clues.indexOf(clue.id) >= 0 ? clue.name : '未发现线索')
          .fontSize(14)
          .fontColor(this.store.state.clues.indexOf(clue.id) >= 0 ? '#F2F5F9' : '#5E7190')
        Blank()
        Text(SCENE_NAMES[clue.sceneId])
          .fontSize(11)
          .fontColor('#6C81A0')
      }
      Text(this.store.state.clues.indexOf(clue.id) >= 0 ? clue.detail : '继续在该场景探索，可能找到这条线索。')
        .fontSize(12)
        .lineHeight(20)
        .fontColor(this.store.state.clues.indexOf(clue.id) >= 0 ? '#C9D4E2' : '#4E6079')
    }
    .width('100%')
    .padding(14)
    .borderRadius(12)
    .backgroundColor(this.store.state.clues.indexOf(clue.id) >= 0 ? '#16243A' : '#0F1A2A')
    .border({ width: 1, color: this.store.state.clues.indexOf(clue.id) >= 0 ? '#2F4560' : '#1B2A3F' })
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        Text('线索板').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#F2F5F9')
        Blank()
        Text(this.store.state.clues.length.toString() + ' / ' + CLUES.length.toString())
          .fontSize(13)
          .fontColor('#E0A94A')
      }
      .width('100%')

      Text('三条推理条件')
        .fontSize(12)
        .fontColor('#8FA3BF')
        .width('100%')

      this.CondRow('物证链', '借阅残页 · 备用钥匙 · 磁带 · 门禁记录',
        this.hasAll(['clue_ledger', 'clue_key', 'clue_tape', 'clue_monitor']))
      this.CondRow('动机', '录音中的争执或标签比对',
        this.store.state.flags['flag_motive'] === true || this.store.state.flags['flag_label_match'] === true)
      this.CondRow('时间线', '值夜表与门禁时间是否对得上',
        this.store.state.flags['flag_night_confirm'] === true || this.store.state.clues.indexOf('clue_roster') >= 0)

      Scroll() {
        Column({ space: 10 }) {
          ForEach(CLUES, (item: Clue) => {
            this.ClueCard(item);
          })
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      Row({ space: 12 }) {
        Button('返回探索')
          .layoutWeight(1)
          .height(44)
          .fontSize(14)
          .fontColor('#C9D4E2')
          .backgroundColor('#16243A')
          .onClick(() => {
            this.onBack();
          })
        Button('进入终局')
          .layoutWeight(1)
          .height(44)
          .fontSize(14)
          .fontColor('#1B1206')
          .backgroundColor('#E0A94A')
          .enabled(this.store.state.stage >= 2)
          .opacity(this.store.state.stage >= 2 ? 1 : 0.45)
          .onClick(() => {
            this.onFinale();
          })
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
  }
}
