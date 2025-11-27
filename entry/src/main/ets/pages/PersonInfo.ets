import { router } from '@kit.ArkUI';
import  { DataEntity, TableCategory, DatabaseManager, InsertDataEntity} from '../components/database/Database';
import { LengthMetrics } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import preferences from '@ohos.data.preferences';

@Entry
@Component
struct PersonInfo {
  @State userName: string = '李明韩'
  @State userDescription: string = '人类'
  @State passwordCount: number = 0

  private dbManager: DatabaseManager = new DatabaseManager(this.getUIContext().getHostContext()as common.UIAbilityContext)
  private preferences: preferences.Preferences | null = null;

  async aboutToAppear() {
    // 初始化Preferences
    try {
      this.preferences = await preferences.getPreferences(this.getUIContext().getHostContext() as common.UIAbilityContext, 'user_profile');

      // 读取保存的用户名和个人描述，并转换为string
      const savedName = await this.preferences.get('userName', '李明韩');
      const savedDescription = await this.preferences.get('userDescription', '人类');

      this.userName = String(savedName);
      this.userDescription = String(savedDescription);
    } catch (error) {
      console.error('Preferences初始化失败:', error);
    }

    // 初始化数据库（选择任意一个表名即可）
    await this.dbManager.initialize('important_frequent', this.getUIContext().getHostContext() as common.UIAbilityContext);

    this.passwordCount = await this.dbManager.getTotalPasswordCount();
  }

  async aboutToDisappear() {
    // 在页面消失时保存数据
    if (this.preferences) {
      try {
        await this.preferences.put('userName', this.userName);
        await this.preferences.put('userDescription', this.userDescription);
        await this.preferences.flush();
      } catch (error) {
        console.error('保存数据失败:', error);
      }
    }
  }

  private async saveUserName(value: string) {
    this.userName = value;
    if (this.preferences) {
      try {
        await this.preferences.put('userName', value);
        await this.preferences.flush();
      } catch (error) {
        console.error('保存用户名失败:', error);
      }
    }
  }

  private async saveUserDescription(value: string) {
    this.userDescription = value;
    if (this.preferences) {
      try {
        await this.preferences.put('userDescription', value);
        await this.preferences.flush();
      } catch (error) {
        console.error('保存个人描述失败:', error);
      }
    }
  }

  build() {
    Column() {
      // 头像区域 - 居中显示
      Column() {
        Image($r('app.media.avatar'))
          .width(120)
          .height(120)
          .borderRadius(100) // 圆形头像
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
            .alignSelf(ItemAlign.Start)

          TextInput({ text: this.userName, placeholder: '请输入姓名' })
            .type(InputType.Normal)
            .width('100%')
            .height(50)
            .backgroundColor(Color.White)
            .borderRadius(12)
            .padding({ left: 16, right: 16 })
            .fontSize(16)
            .textAlign(TextAlign.Start)
            .onChange((value: string) => {
              this.saveUserName(value); // 实时保存用户名
            })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        // 个人描述输入框
        Column() {
          Text('个人描述')
            .fontSize(16)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 8 })
            .alignSelf(ItemAlign.Start)

          TextInput({ text: this.userDescription, placeholder: '请输入个人描述' })
            .type(InputType.Normal)
            .width('100%')
            .height(120)
            .backgroundColor(Color.White)
            .borderRadius(12)
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
            .fontSize(16)
            .maxLines(4)
            .textAlign(TextAlign.Start)
            .onChange((value: string) => {
              this.saveUserDescription(value); // 实时保存个人描述
            })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        // 密码统计信息
        Column() {
          Text('密码统计')
            .fontSize(16)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 8 })
            .alignSelf(ItemAlign.Start)

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
          .justifyContent(FlexAlign.Start)
          .padding(16)
          .backgroundColor('#F8F5FF')
          .borderRadius(12)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

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