import { GameStore } from '../viewmodel/GameStore';
import { SCENE_NAMES } from '../model/GameTypes';

@Component
export struct HomeView {
  @ObjectLink store: GameStore;

  @Builder
  StatLine(label: string, value: string) {
    Row() {
      Text(label).fontSize(12).fontColor('#8FA3BF')
      Blank()
      Text(value).fontSize(12).fontColor('#E0A94A')
    }
    .width('100%')
  }

  build() {
    Column({ space: 16 }) {
      Blank().height(24)
      Text('迷雾档案')
        .fontSize(36)
        .fontWeight(FontWeight.Bold)
        .fontColor('#F2F5F9')
        .letterSpacing(4)
      Text('校园线索推理 · 多结局探索')
        .fontSize(14)
        .fontColor('#8FA3BF')
      Blank().height(8)

      Column() {
        Text('校史馆 3 号档案盒在闭馆后失踪。你接下了这桩调查：')
          .fontSize(13)
          .fontColor('#C9D4E2')
          .lineHeight(22)
        Text('三个场景、六条线索、两个结局，线索会改变你能做的事。')
          .fontSize(13)
          .fontColor('#C9D4E2')
          .lineHeight(22)
      }
      .width('86%')
      .padding(16)
      .borderRadius(12)
      .backgroundColor('#16243A')

      Button('接受调查')
        .width('86%')
        .height(48)
        .fontSize(16)
        .fontColor('#1B1206')
        .backgroundColor('#E0A94A')
        .onClick(() => {
          this.store.newCase();
        })

      Button('继续上次调查')
        .width('86%')
        .height(48)
        .fontSize(16)
        .fontColor('#E0A94A')
        .backgroundColor('#16243A')
        .border({ width: 1, color: '#3A4D6B' })
        .enabled(this.store.hasSave)
        .opacity(this.store.hasSave ? 1 : 0.45)
        .onClick(() => {
          this.store.restore();
        })

      Button('重开案件')
        .width('86%')
        .height(44)
        .fontSize(14)
        .fontColor('#8FA3BF')
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.store.restart();
        })

      if (this.store.hasSave) {
        Column({ space: 6 }) {
          this.StatLine('当前阶段', this.store.state.stage >= 2 ? '可进入终局' : '调查中')
          this.StatLine('已获线索', this.store.state.clues.length.toString() + ' / 6')
          this.StatLine('所在场景', SCENE_NAMES[this.store.state.sceneId])
        }
        .width('86%')
        .padding(14)
        .borderRadius(10)
        .backgroundColor('#101D30')
      }
      Blank()
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }
}
