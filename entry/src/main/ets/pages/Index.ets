import { GameStore } from '../viewmodel/GameStore';
import { STAGE_ACCEPT, STAGE_ENDED } from '../model/GameTypes';
import { HomeView } from '../view/HomeView';
import { ExploreView } from '../view/ExploreView';
import { ClueBoardView } from '../view/ClueBoardView';
import { FinaleView } from '../view/FinaleView';
import { EndingView } from '../view/EndingView';

@Entry
@Component
struct Index {
  @State store: GameStore = new GameStore();
  @State panel: string = 'explore';

  aboutToAppear(): void {
    this.store.restore();
  }

  stageText(): string {
    if (this.store.state.stage === STAGE_ACCEPT) {
      return '待接案';
    }
    if (this.store.state.stage === 1) {
      return '调查中';
    }
    if (this.store.state.stage === 2) {
      return '可终局';
    }
    return '已结案';
  }

  @Builder
  NavItem(label: string, key: string) {
    Text(label)
      .fontSize(13)
      .fontColor(this.panel === key ? '#E0A94A' : '#8FA3BF')
      .layoutWeight(1)
      .textAlign(TextAlign.Center)
      .onClick(() => {
        this.panel = key;
      })
  }

  build() {
    Column() {
      Row() {
        Text('迷雾档案')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#F2F5F9')
        Blank()
        Text(this.stageText())
          .fontSize(11)
          .fontColor('#E0A94A')
          .backgroundColor('#1B2A3F')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(10)
        Text('线索 ' + this.store.state.clues.length.toString() + '/6')
          .fontSize(11)
          .fontColor('#8FA3BF')
          .margin({ left: 8 })
      }
      .width('100%')
      .height(44)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#0B1626')

      if (this.store.message.length > 0) {
        Text(this.store.message)
          .fontSize(11)
          .fontColor('#9FB3CB')
          .width('100%')
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor('#101D30')
      }

      Column() {
        if (this.store.homeMode || this.store.state.stage === STAGE_ACCEPT) {
          HomeView({ store: this.store })
        } else if (this.store.state.stage === STAGE_ENDED) {
          EndingView({ store: this.store })
        } else if (this.panel === 'board') {
          ClueBoardView({
            store: this.store,
            onBack: () => {
              this.panel = 'explore';
            },
            onFinale: () => {
              this.panel = 'finale';
            }
          })
        } else if (this.panel === 'finale' && this.store.state.stage >= 2) {
          FinaleView({
            store: this.store,
            onBack: () => {
              this.panel = 'board';
            }
          })
        } else {
          ExploreView({ store: this.store })
        }
      }
      .layoutWeight(1)

      if (this.store.state.stage > STAGE_ACCEPT && this.store.state.stage < STAGE_ENDED) {
        Row() {
          this.NavItem('探索', 'explore')
          this.NavItem('线索板', 'board')
          if (this.store.state.stage >= 2) {
            this.NavItem('终局', 'finale')
          }
        }
        .width('100%')
        .height(48)
        .backgroundColor('#0B1626')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0E1A2B')
  }
}
