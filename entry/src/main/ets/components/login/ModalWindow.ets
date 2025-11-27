import { DefaultLogin } from './DefaultLogin';

@Component
export struct ModalWindowComponent {
  // 是否显示全屏模态页面
  @State isPresent: boolean = false;

  @Builder
  loginBuilder() {
    Column() {
      DefaultLogin()
    }
  }

  aboutToAppear() {
    this.isPresent = true; // 页面加载时自动显示模态
  }

  build() {
    Column() {
    }
    .bindContentCover($$this.isPresent, this.loginBuilder)
  }
}
