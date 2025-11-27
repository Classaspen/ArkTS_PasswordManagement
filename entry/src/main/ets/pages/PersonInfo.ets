import { router } from '@kit.ArkUI';

@Entry
@Component
struct PersonInfo {
  @State userName: string = '李明韩'
  @State userDescription: string = '移动应用开发爱好者'
  @State passwordCount: number = 42 // 先给个固定值测试显示效果

  build() {
    Column() {
      // 头像区域 - 居中显示
      Column() {
        Image($r('app.media.batman'))
          .width(120)
          .height(120)
          .borderRadius(60) // 圆形头像
          .border({ width: 4, color: '#7E57C2' }) // 紫色边框
          .shadow({ radius: 8, color: '#000000', offsetX: 2, offsetY: 2 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .margin({ top: 40, bottom: 40 })

      // 个人信息表单区域
      Column({ space: 20 }) {
        // 姓名输入框
        Column() {
          Text('姓名')
            .fontSize(16)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 8 })
            .alignSelf(ItemAlign.Start) // 靠左对齐

          TextInput({ text: this.userName, placeholder: '请输入姓名' })
            .type(InputType.Normal)
            .width('100%')
            .height(50)
            .backgroundColor(Color.White)
            .borderRadius(12)
            .padding({ left: 16, right: 16 })
            .fontSize(16)
            .textAlign(TextAlign.Start) // 文本靠左对齐
            .onChange((value: string) => {
              this.userName = value
              // 这里可以添加保存逻辑
            })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start) // 容器靠左对齐

        // 个人描述输入框
        Column() {
          Text('个人描述')
            .fontSize(16)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 8 })
            .alignSelf(ItemAlign.Start) // 靠左对齐

          TextInput({ text: this.userDescription, placeholder: '请输入个人描述' })
            .type(InputType.Normal)
            .width('100%')
            .height(120)
            .backgroundColor(Color.White)
            .borderRadius(12)
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
            .fontSize(16)
            .maxLines(4)
            .textAlign(TextAlign.Start) // 文本靠左对齐
            .onChange((value: string) => {
              this.userDescription = value
              // 这里可以添加保存逻辑
            })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start) // 容器靠左对齐

        // 密码统计信息
        Column() {
          Text('密码统计')
            .fontSize(16)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 8 })
            .alignSelf(ItemAlign.Start) // 靠左对齐

          Row() {
            Text('当前存储的密码数：')
              .fontSize(16)
              .fontColor('#666666')

            Text(this.passwordCount.toString())
              .fontSize(18)
              .fontColor('#7E57C2')
              .fontWeight(FontWeight.Bold)
          }
          .width('100%')
          .justifyContent(FlexAlign.Start) // 行内容靠左对齐
          .padding(16)
          .backgroundColor('#F8F5FF')
          .borderRadius(12)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start) // 容器靠左对齐
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start) // 整个表单区域靠左对齐

      // 底部空白区域
      Blank()
        .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8FAFD')
    .padding({ left: 24, right: 24 })
  }
}