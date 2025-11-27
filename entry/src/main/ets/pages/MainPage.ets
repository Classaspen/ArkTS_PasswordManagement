import { router } from '@kit.ArkUI';

// 基础框架
@Entry
@Component
struct MainPage {
  @State private refreshFlag: boolean = false;

  // 页面生命周期
  aboutToAppear() {
    console.log('MainPage loaded');
  }

  private cardSize: number = 120 // 正方形边长
  private cardRadius: number = 16 // 圆角半径

  build() {
    Column() {

      Column() {
        // 动态彩虹条 - 修正后的写法
        Row()
          .linearGradient({
            angle: 90,
            colors: [
              [$r('app.color.card1_color'), 0.0],   // 红
              [$r('app.color.card2_color'), 0.25],  // 黄
              [$r('app.color.card3_color'), 0.5],   // 青
              [$r('app.color.special_card_color'), 0.75], // 紫
              [$r('app.color.card1_color'), 1.0]    // 红（循环）
            ]
          })
          .width('90%')
          .height(120)
          .borderRadius(4)
          // 添加半透明粗边框
          .border({
            width: 8,
            color: {
              top: Color.White,
              right: Color.White,
              bottom: Color.White,
              left: Color.White
            }
          })
          .opacity(0.3) // 边框半透明
          .margin({ bottom: 30 })
          .animation({
            duration: 3000,
            curve: Curve.EaseInOut,
            iterations: -1,
            playMode: PlayMode.Alternate
          })

        // 第一行卡片
        Row({ space: 20 }) {
          this.BuildCard(
            $r('app.string.mainpage_feature1'),
            $r('app.color.card1_color'),
            $r('app.color.card1_border'),
            (): void => {
              router.pushUrl({
                url: 'pages/PswManagement',
                params: { table: 'important_infrequent' }
              }, router.RouterMode.Single)
            }
          )
          this.BuildCard(
            $r('app.string.mainpage_feature2'),
            $r('app.color.card2_color'),
            $r('app.color.card2_border'),
            (): void => {
              router.pushUrl({
                url: 'pages/PswManagement',
                params: { table: 'important_frequent' }
              }, router.RouterMode.Single)
            }
          )
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceEvenly)
        .margin({ bottom: 20 })

        // 第二行卡片
        Row({ space: 20 }) {
          this.BuildCard(
            $r('app.string.mainpage_feature3'),
            $r('app.color.card3_color'),
            $r('app.color.card3_border'),
            (): void => {
              router.pushUrl({
                url: 'pages/PswManagement',
                params: { table: 'unimportant' }
              }, router.RouterMode.Single)
            }
          )
          this.BuildSpecialCard(
            $r('app.string.mainpage_feature4'),
            $r('app.color.special_card_color'),
            $r('app.color.special_card_border')
          )
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceEvenly)
      }
      .layoutWeight(2) // 让卡片组占据更多空间

      Blank()
        .layoutWeight(1)
    }
    .padding(40) // 增加内边距让卡片更大
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_color'))
  }

  // 统一卡片构建方法 - 增大尺寸
  @Builder
  BuildCard(text: Resource, color: Resource, borderColor: Resource, onClick: () => void) {
    Button() {
      Text(text)
        .fontSize(22) // 增大字体
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
    }
    .backgroundColor(color)
    .border({ width: 4, color: borderColor })
    .borderRadius(24) // 增大圆角
    .width(140) // 增大宽度
    .height(240) // 增大高度
    .onClick(onClick)
  }

  // 特殊卡片 - 增大尺寸并使内容居中
  @Builder
  BuildSpecialCard(text: Resource, color: Resource, borderColor: Resource) {
    Column() {
      Image($r('app.media.ic_user'))
        .width(60) // 增大图标
        .height(60)
        .margin({ bottom: 16 })

      Text(text)
        .fontSize(22) // 增大字体
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
    }
    .backgroundColor(color)
    .border({ width: 4, color: borderColor })
    .borderRadius(24)
    .width(140) // 增大宽度
    .height(240) // 增大高度
    .justifyContent(FlexAlign.Center) // 垂直居中
    .alignItems(HorizontalAlign.Center) // 水平居中
    .onClick(() => {
      router.pushUrl({
        url: 'pages/PersonInfo',
      }, router.RouterMode.Single)
    })
  }
}
