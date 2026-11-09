import { GameStore } from '../viewmodel/GameStore';
import { NODES, findClue } from '../model/StoryData';
import { Choice, EventNode, SCENE_NAMES } from '../model/GameTypes';
import { RuleEngine } from '../service/RuleEngine';

@Component
export struct ExploreView {
  @ObjectLink store: GameStore;
  @State activeNodeId: string = '';

  aboutToAppear(): void {
    this.syncActive();
  }

  nodesOfScene(): EventNode[] {
    const list: EventNode[] = [];
    for (let i = 0; i < NODES.length; i++) {
      if (NODES[i].sceneId === this.store.state.sceneId) {
        list.push(NODES[i]);
      }
    }
    return list;
  }

  syncActive(): void {
    const nodes: EventNode[] = this.nodesOfScene();
    this.activeNodeId = nodes.length > 0 ? nodes[0].id : '';
  }

  activeNode(): EventNode | undefined {
    for (let i = 0; i < NODES.length; i++) {
      if (NODES[i].id === this.activeNodeId) {
        return NODES[i];
      }
    }
    return undefined;
  }

  isEnabled(choice: Choice): boolean {
    return RuleEngine.satisfies(this.store.state, choice.req);
  }

  reqText(choice: Choice): string {
    if (!choice.req || !choice.req.clues) {
      return '';
    }
    const names: string[] = [];
    for (let i = 0; i < choice.req.clues.length; i++) {
      const clue = findClue(choice.req.clues[i]);
      names.push(clue ? clue.name : choice.req.clues[i]);
    }
    return '需要先取得：' + names.join('、');
  }

  @Builder
  ChoiceButton(nodeId: string, choice: Choice) {
    Column({ space: 4 }) {
      Button(choice.label)
        .width('100%')
        .height(44)
        .fontSize(14)
        .fontColor(this.isEnabled(choice) ? '#F2F5F9' : '#5E7190')
        .backgroundColor(this.isEnabled(choice) ? '#1E3350' : '#0F1A2A')
        .border({ width: 1, color: this.isEnabled(choice) ? '#3A567C' : '#1B2A3F' })
        .enabled(this.isEnabled(choice))
        .onClick(() => {
          this.store.choose(nodeId, choice.id);
        })
      if (!this.isEnabled(choice)) {
        Text(this.reqText(choice).length > 0 ? this.reqText(choice) : (choice.hint ? choice.hint : '条件不足'))
          .fontSize(11)
          .fontColor('#C05A5A')
          .width('100%')
      }
    }
    .width('100%')
  }

  build() {
    Column({ space: 10 }) {
      Row({ space: 8 }) {
        ForEach(['lib', 'lab', 'dorm'], (scene: string) => {
          Text(SCENE_NAMES[scene])
            .fontSize(12)
            .fontColor(this.store.state.sceneId === scene ? '#1B1206' : '#C9D4E2')
            .backgroundColor(this.store.state.sceneId === scene ? '#E0A94A' : '#16243A')
            .padding({ left: 12, right: 12, top: 7, bottom: 7 })
            .borderRadius(14)
            .onClick(() => {
              this.store.setScene(scene);
              this.syncActive();
            })
        }, (scene: string) => scene)
      }
      .width('100%')

      Scroll() {
        Column({ space: 10 }) {
          ForEach(this.nodesOfScene(), (node: EventNode) => {
            Column({ space: 6 }) {
              Row() {
                Text(node.title)
                  .fontSize(14)
                  .fontColor(this.activeNodeId === node.id ? '#E0A94A' : '#F2F5F9')
                Blank()
                if (this.store.state.visited.indexOf(node.id) >= 0) {
                  Text('已访问').fontSize(10).fontColor('#6C81A0')
                }
              }
              .width('100%')
              .padding({ left: 14, right: 14, top: 12, bottom: 12 })
            }
            .borderRadius(10)
            .backgroundColor(this.activeNodeId === node.id ? '#16243A' : '#101D30')
            .border({ width: 1, color: this.activeNodeId === node.id ? '#E0A94A' : '#1B2A3F' })
            .onClick(() => {
              this.activeNodeId = node.id;
            })
          }, (node: EventNode) => node.id)

          if (this.activeNode() !== undefined) {
            Column({ space: 8 }) {
              Text(this.activeNode()?.title)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#F2F5F9')
              Text(this.activeNode()?.body)
                .fontSize(13)
                .lineHeight(22)
                .fontColor('#C9D4E2')
              Blank().height(2)
              ForEach(this.activeNode()?.choices, (choice: Choice) => {
                this.ChoiceButton(this.activeNodeId, choice);
              }, (choice: Choice) => choice.id)
            }
            .width('100%')
            .padding(14)
            .borderRadius(12)
            .backgroundColor('#16243A')
            .alignItems(HorizontalAlign.Start)
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16, top: 10, bottom: 8 })
  }
}
