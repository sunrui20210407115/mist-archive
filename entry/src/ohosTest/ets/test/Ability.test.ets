import { describe, expect, it } from '@ohos/hypium';

// 基础断言用例，用于验证测试框架本身正常运行
export default function abilityTest() {
  describe('ActsAbilityTest', () => {
    it('assertContain', 0, () => {
      expect('迷雾档案').assertContain('档案');
    });
  });
}
