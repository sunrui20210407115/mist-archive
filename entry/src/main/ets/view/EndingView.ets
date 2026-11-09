import { GameStore } from '../viewmodel/GameStore';
import { ENDINGS, CLUES } from '../model/StoryData';
import { EndingDef } from '../model/GameTypes';

@Component
export struct EndingView {
  @ObjectLink store: GameStore;

  currentEnding(): EndingDef {
    for (let i = 0; i < ENDINGS.length; i++) {
      if (ENDINGS[i].id === this.store.state.endingId) {
        return ENDINGS[i];
      }
    }
    return ENDINGS[ENDINGS.length - 1];
  }

  build() {
    Column({ space: 14 }) {
      Blank().height(10)
      Text('结案')
        .fontSize(12)
        .fontColor('#8FA3BF')
        .letterSpacing(3)
      Text(this.currentEnding().title)
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor('#E0A94A')
      Text(this.currentEnding().subtitle)
        .fontSize(12)
        .fontColor('#8FA3BF')
      Blank().height(4)
      Text(this.currentEnding().body)
        .fontSize(13)
        .lineHeight(24)
        .fontColor('#C9D4E2')
        .width('90%')
        .padding(16)
        .borderRadius(12)
        .backgroundColor('#16243A')

      Row({ space: 6 }) {
        Text('已获线索').fontSize(12).fontColor('#8FA3BF')
        Text(this.store.state.clues.length.toString() + ' / ' + CLUES.length.toString())
          .fontSize(12)
          .fontColor('#E0A94A')
      }

      Blank()

      Button('重开案件')
        .width('86%')
        .height(48)
        .fontSize(16)
        .fontColor('#1B1206')
        .backgroundColor('#E0A94A')
        .onClick(() => {
          this.store.restart();
        })

      Button('回到首页')
        .width('86%')
        .height(44)
        .fontSize(14)
        .fontColor('#C9D4E2')
        .backgroundColor('#16243A')
        .onClick(() => {
          this.store.backToHome();
        })
      Blank().height(8)
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
  }
}
