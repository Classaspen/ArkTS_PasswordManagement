
import { DefaultLogin } from './DefaultLogin';

/**
 *
 * 功能描述：全屏登录页面：在主页面点击跳转到全屏登录页后，显示全屏模态页面，全屏模态页面从下方滑出并覆盖整个屏幕，模态页面内容自定义，此处分为默认一键登录方式和其他登录方式。
 *
 * 推荐场景：需要登录场景的app
 *
 * 核心组件：
 * 1. DefaultLogin
 *
 * 实现步骤：
 * 1. 模态转场是新的界面覆盖在旧的界面上，旧的界面不消失的一种转场方式。
 * 2. 通过bindContentCover属性为Button组件绑定全屏模态页面，点击Button后显示模态页面，模态页面内容自定义，包含默认一键登录页面和其他登录方式页面。
 */

@Component
export struct ModalWindowComponent {
  // 是否显示全屏模态页面
  @State isPresent: boolean = false;

  @Builder
  loginBuilder() {
    Column() {
      DefaultLogin({ isPresentInLoginView: this.isPresent }) // 通过@State和@Link使isPresentInLoginView和isPresent产生关联
    }
  }

  aboutToAppear() {
    this.isPresent = true; // 页面加载时自动显示模态
  }

  build() {
    Column() {
    }
    .bindContentCover($$this.isPresent, this.loginBuilder) // 绑定到父容器
  }
}
