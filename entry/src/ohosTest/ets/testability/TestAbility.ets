import { abilityDelegatorRegistry } from '@kit.TestKit';
import { UIAbility, Want, AbilityConstant } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Hypium } from '@ohos/hypium';
import testsuite from '../test/List.test';

const domain: number = 0x0000;
const tag: string = 'testTag';

export default class TestAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(domain, tag, '%{public}s', 'TestAbility onCreate');
    Hypium.hypiumTest(abilityDelegatorRegistry.getAbilityDelegator(),
      abilityDelegatorRegistry.getArguments(), testsuite);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(domain, tag, '%{public}s', 'TestAbility onWindowStageCreate');
    windowStage.loadContent('testability/pages/Index', (err) => {
      if (err.code) {
        hilog.error(domain, tag, 'loadContent failed: %{public}s', JSON.stringify(err));
      }
    });
  }

  onDestroy(): void {
    hilog.info(domain, tag, '%{public}s', 'TestAbility onDestroy');
  }
}
