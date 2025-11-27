import { router } from '@kit.ArkUI';
import autoFillManager from '@ohos.app.ability.autoFillManager';
import {ModalWindowComponent } from "../components/login/ModalWindow";

@Entry
@Component
struct UnifiedPage {
  @State showWelcome: boolean = true;

  onPageShow() {
    setTimeout(() => {
      this.showWelcome = false
    }, 2000)
  }

  build() {
    Column() {
      if (this.showWelcome) {
        Stack({ alignContent: Alignment.Center }) {
          Column() {
            Text('欢迎进入密码管理系统')
              .fontSize(32)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
          }
          .alignItems(HorizontalAlign.Center)

          Text('028122082李明韩||移动应用开发')
            .fontSize(12)
            .fontColor('#666666')
            .position({ x: '90%', y: '80%' })
            .translate({ x: '-100%', y: '-100%' })
            .margin({ right: 16, bottom: 16 })
        }
        .width('100%')
        .height('100%')

      } else {
        // 登录界面
        RelativeContainer() {
          ModalWindowComponent()
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}