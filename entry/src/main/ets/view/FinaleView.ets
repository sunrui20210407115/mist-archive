import { GameStore } from '../viewmodel/GameStore';

@Component
export struct FinaleView {
  @ObjectLink store: GameStore;
  onBack: () => void = () => {};

  chainOk(): boolean {
    const need: string[] = ['clue_ledger', 'clue_key', 'clue_tape', 'clue_monitor'];
    for (let i = 0; i < need.length; i++) {
      if (this.store.state.clues.indexOf(need[i]) < 0) {
        return false;
      }
    }
    return true;
  }

  motiveOk(): boolean {
    return this.store.state.flags['flag_motive'] === true || this.store.state.flags['flag_label_match'] === true;
  }

  timelineOk(): boolean {
    return this.store.state.flags['flag_night_confirm'] === true || this.store.state.clues.indexOf('clue_roster') >= 0;
  }

  @Builder
  CheckLine(title: string, detail: string, ok: boolean) {
    Row({ space: 10 }) {
      Text(ok ? '✓' : '○').fontSize(18).fontColor(ok ? '#3FC27A' : '#8FA3BF')
      Column() {
        Text(title).fontSize(14).fontColor('#F2F5F9')
        Text(detail).fontSize(11).fontColor('#8FA3BF').margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding(12)
    .borderRadius(10)
    .backgroundColor('#101D30')
  }

  build() {
    Column({ space: 12 }) {
      Text('终局判断')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#F2F5F9')
        .width('100%')
      Text('向校方提交结论前，逐条确认推理条件是否成立。任一条不成立，结论不会被采信。')
        .fontSize(12)
        .lineHeight(20)
        .fontColor('#8FA3BF')
        .width('100%')

      this.CheckLine('物证链', '借阅残页 · 备用钥匙 · 磁带 · 门禁记录', this.chainOk())
      this.CheckLine('动机', '录音中的争执或标签比对', this.motiveOk())
      this.CheckLine('时间线', '值夜表与门禁时间是否对得上', this.timelineOk())

      Column({ space: 8 }) {
        Text('当前持有线索').fontSize(12).fontColor('#8FA3BF').width('100%')
        Text(this.store.state.clues.length.toString() + ' / 6 条')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#E0A94A')
          .width('100%')
      }
      .width('100%')
      .padding(14)
      .borderRadius(12)
      .backgroundColor('#16243A')
      .alignItems(HorizontalAlign.Start)

      Blank()

      Button('提交结论')
        .width('100%')
        .height(48)
        .fontSize(16)
        .fontColor('#1B1206')
        .backgroundColor('#E0A94A')
        .onClick(() => {
          this.store.submitFinale();
        })

      Button('返回线索板继续核对')
        .width('100%')
        .height(44)
        .fontSize(14)
        .fontColor('#C9D4E2')
        .backgroundColor('#16243A')
        .onClick(() => {
          this.onBack();
        })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
  }
}
