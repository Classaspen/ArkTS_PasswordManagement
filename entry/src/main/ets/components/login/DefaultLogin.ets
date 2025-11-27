import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';
// import { OtherWaysToLogin, ReadAgreement } from './OtherWaysToLogin';

const EFFECT_DURATION = 800;
const EFFECT_OPACITY = 0.4;
const SPACE_TEN = 10;

@Component
export struct DefaultLogin {

  userName: string = 'classaspen';
  password: string = '028122082';

  @State inputName: string = '';
  @State inputPassword: string = '';

  @Builder
  DefaultLoginPage() {
    Column({ space: SPACE_TEN }) {
      Row({ space: SPACE_TEN }) {
        Image($r('app.media.avatar'))
          .width($r('app.integer.modalwindow_user_image_height'))
          .height($r('app.integer.modalwindow_user_image_height'))
        Column({ space: SPACE_TEN }) {
          Text($r('app.string.modalwindow_welcome_back'))
            .fontWeight(FontWeight.Bold)
            .fontSize($r('app.integer.modalwindow_font_size_mid'))
            .fontColor(Color.Black)

          Text($r('app.string.modalwindow_more_wonderful_after_login'))
            .fontColor($r('app.color.modalwindow_grey_3'))
        }
        .alignItems(HorizontalAlign.Start)
      }
      .alignItems(VerticalAlign.Center)
      .width($r('app.string.modalwindow_size_full'))

      // 用户名输入框
      TextInput({ placeholder: '请输入用户名', text: this.inputName })
        .fontColor($r('app.color.modalwindow_grey_3'))
        .fontWeight(FontWeight.Bold)
        .padding({ left: $r('app.integer.modalwindow_padding_default') })
        .height($r('app.integer.modalwindow_user_image_height'))
        .width($r('app.string.modalwindow_size_full'))
        .borderRadius($r('app.integer.modalwindow_border_radius'))
        .backgroundColor($r('app.color.modalwindow_grey_e'))
        .onChange((value: string) => {
          this.inputName = value;
        })

      // 密码输入框
      TextInput({ placeholder: '请输入密码', text: this.inputPassword })
        .type(InputType.Password) // 密码类型，显示为圆点
        .fontColor($r('app.color.modalwindow_grey_3'))
        .fontWeight(FontWeight.Bold)
        .padding({ left: $r('app.integer.modalwindow_padding_default') })
        .height($r('app.integer.modalwindow_user_image_height'))
        .width($r('app.string.modalwindow_size_full'))
        .borderRadius($r('app.integer.modalwindow_border_radius'))
        .backgroundColor($r('app.color.modalwindow_grey_e'))
        .margin({ top: SPACE_TEN }) // 与上方输入框保持间距
        .onChange((value: string) => {
          this.inputPassword = value;
        })

      Button($r('app.string.modalwindow_phone_start_login'))
        .fontColor(Color.White)
        .borderRadius($r('app.integer.modalwindow_border_radius'))
        .type(ButtonType.Normal)
        .backgroundColor(this.isLoginEnabled() ? $r('app.color.modalwindow_blue') : $r('app.color.modalwindow_grey_2'))
        .enabled(this.isLoginEnabled()) // 只有输入正确时才可点击
        .onClick(() => {
          if (this.inputName === this.userName && this.inputPassword === this.password) {
            // 调用Toast显示登录成功提示
            promptAction.showToast({ message: $r('app.string.modalwindow_login_success') });
            setTimeout(() => {
              router.replaceUrl({
                url: 'pages/MainPage'
              }, router.RouterMode.Standard)
            }, 1000)
          } else {
            promptAction.showToast({ message: '用户名或密码错误' });
          }
        })
        .width($r('app.string.modalwindow_size_full'))
        .height($r('app.integer.modalwindow_height_fifty'))
        .margin({ top: SPACE_TEN })
    }
    .width($r('app.string.modalwindow_size_full'))
    .height($r('app.string.modalwindow_size_full'))
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.Center)
  }

  private isLoginEnabled(): boolean {
    return this.inputName.length > 0 && this.inputPassword.length > 0;
  }
  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      this.DefaultLoginPage() // 登录页面
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .size({ width: $r('app.string.modalwindow_size_full'), height: $r('app.string.modalwindow_size_full') })
    .padding({
      top: $r('app.integer.modalwindow_padding_default'),
      left: $r('app.integer.modalwindow_padding_default'),
      right: $r('app.integer.modalwindow_padding_default')
    })
    .backgroundColor(Color.White)
  }
}
