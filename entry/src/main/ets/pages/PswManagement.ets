/*
 *  Copyright (c) 2025 Huawei Device Co., Ltd.
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
import { router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { LengthMetrics } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { systemDateTime } from '@kit.BasicServicesKit';
import { PasswordData, ImageList, TextList } from '../components/pswmanagement/PswViewModel';
import CommonConstants from '../components/pswmanagement/CommonConstants';
import { PswDialog } from '../components/pswmanagement/PswDialog';
// import { RdbManager } from '../utils/RdbManager';
import  { DataEntity, TableCategory, DatabaseManager, InsertDataEntity} from '../components/database/Database';

@Entry
@Component
struct PswHomePage {
  @State passwords: Array<DataEntity> = [];
  @State table: string = ''; //传递的数据库的表名
  @State searchText: string = '';
  @State isEdit: boolean = false;
  @State isInsert: boolean = false;
  // @State newAccount: AccountData = {
  //   id: '',
  //   accountType: 0,
  //   typeText: '',
  //   amount: 0
  // };
  @State newPassword: DataEntity = {
    id: 0,
    name: '',
    content: '',
    timestamp: 0
  };
  @State index: number = -1;
  private deleteList: Array<DataEntity> = [];

  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private dbManager: DatabaseManager = new DatabaseManager(this.context);
  async aboutToAppear() {
    const params = router.getParams() as Record<string, string | undefined>;
    this.table = params.table || 'default';

    await this.dbManager.initialize(this.table, this.context);
    this.dbManager.subscribeDataChange();

    let result: DataEntity[] = await this.dbManager.query(this.table, '');
    this.passwords = result;

    this.context.eventHub.on('dataChange', this.eventFunc);
  }

  searchController: SearchController = new SearchController();
  dialogController: CustomDialogController = new CustomDialogController({
    builder: PswDialog({
      isInsert: $isInsert,
      newPassword: $newPassword,
      confirm: (isInsert: boolean, newPassword: DataEntity) => this.accept(isInsert, newPassword)
    }),
    keyboardAvoidDistance: LengthMetrics.vp(0),
    customStyle: true,
    alignment: DialogAlignment.Bottom
  });

  async accept(isInsert: boolean, newPassword: DataEntity): Promise<void> {
    const insertNewPsw: InsertDataEntity = {
      name: newPassword.name,
      content: newPassword.content,
      timestamp: newPassword.timestamp
    };

    if (isInsert) {
      // 插入数据并获取返回的rowId
      const rowId = await this.dbManager.insertData(this.table, insertNewPsw);

      if (rowId > 0) {
        // 重新查询数据库获取完整数据（包含正确的id）
        const result: DataEntity[] = await this.dbManager.query(this.table, '');
        this.passwords = result;

        console.log("Insert table name:", this.table);
        hilog.info(0x0000, 'hilog', `New entry: ${newPassword.name} (TS: ${newPassword.timestamp})`);
      }

    } else {
      // 更新操作
      await this.dbManager.updateData(this.table, newPassword);

      // 更新本地数组
      this.passwords = this.passwords.map((item: DataEntity) =>
      item.id === newPassword.id ? newPassword : item
      );

      this.index = -1;
    }
    await this.dbManager.printoutdb(this.table);//输出表内容。
  }

  aboutToDisappear(): void {
    this.context.eventHub.off('dataChange', this.eventFunc);
  }

  // Function for Monitoring Data Changes.
  eventFunc = (value: string) => {
    const list: DataEntity[] = JSON.parse(value);
    this.dbManager.updateLocalDataBase(this.table, this.passwords, list)
    this.passwords = list;  ///高危
  };

  selectListItem(item: DataEntity) {
    this.isInsert = false;
    this.index = this.passwords.indexOf(item);
    this.newPassword = {
      id: item.id,
      name: item.name,
      content: item.content,
      timestamp: item.timestamp
    };
  }

  async deleteListItem() {
    // 使用倒序循环避免索引错位
    for (let i = this.deleteList.length - 1; i >= 0; i--) {
      const item = this.deleteList[i];
      try {
        // 同步更新UI数据
        this.passwords = this.passwords.filter(account => account.name !== item.name);
        // 等待数据库操作完成
        await this.dbManager.deleteData(this.table, item.name!); // 添加 ! 断言
      } catch (err) {
        console.error(`Failed to delete ${item.name}:`, err);
        // 可添加重试逻辑或错误回滚
      }
    }
    this.deleteList = [];
    this.isEdit = false;
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.TopStart }) {
        Flex({ direction: FlexDirection.Column }) {
          this.NavigationTitle();

          List({ space: CommonConstants.FULL_SIZE }) {
            ForEach(this.passwords, (item: DataEntity, index: number) => {
              ListItem() {
                Column() {
                  Row() {
                    Row() {
                      Text(item.name)
                        .fontSize(24)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#000000')
                    }
                    .margin({ right: 16 })

                    Text(TextList[item.name])
                      .fontSize($r('app.float.font_size_M'))
                      .fontColor('rgba(0, 0, 0, 0.9)')
                      .lineHeight(21)

                    Blank()
                      .layoutWeight(1)

                    Text(item.content)
                      .fontSize(16)
                      .fontColor('app.color.main_color')

                    if (this.isEdit) {
                      Row() {
                        Toggle({ type: ToggleType.Checkbox })
                          .onChange((isOn) => {
                            if (isOn) {
                              this.deleteList.push(item);
                            } else {
                              let index = this.deleteList.indexOf(item);
                              this.deleteList.splice(index, 1);
                            }
                          })
                      }
                      .margin({ left: 10 })
                    }
                  }
                  .width('100%')
                  .padding({ top: 4, bottom: 4 })

                  if (index !== this.passwords.length - 1) {
                    Divider()
                      .color('rgba(0,0,0,0.2)')
                      .strokeWidth(0.5)
                      .margin({
                        left: 68
                      })
                  }
                }
              }
              .width('100%')
              .height(48)
              .padding({
                left: 12,
                right: 12,
              })
              .backgroundColor(Color.White)
              .onClick(() => {
                this.selectListItem(item);
                this.dialogController.open();
              })
            })
          }
          .width('100%')
          .flexGrow(1)
          .borderRadius(16)
          .clip(true)
          .padding({
            top: this.passwords.length ? 4 : 0,
            bottom: this.passwords.length ? 4 : 0
          })
        }

        if (!this.isEdit) {
          Row() {
            SymbolGlyph($r('sys.symbol.plus'))
              .fontSize(24)
              .fontColor([Color.White])
              .fontWeight(400)
          }
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .width(48)
          .height(48)
          .backgroundColor('#0A59F7')
          .borderRadius('50%')
          .position({ left: '50%', bottom: 26 })
          .translate({ x: '-50%' })
          .onClick(() => {
            this.isInsert = true;
            this.newPassword = {
              // id: undefined, // 自增主键可不传
              name: '',       // 对应平台名称
              content: '',    // 对应密码字段
              timestamp: Date.now() // 自动生成时间戳
            };
            this.dialogController.open();
          })
        }

        if (this.isEdit) {
          Column() {
            SymbolGlyph($r('sys.symbol.trash'))
              .fontSize(20)
              .fontColor([Color.Black])
              .fontWeight(400)
            Text($r('app.string.delete_text'))
              .fontSize(12)
              .fontColor('rgba(0, 0, 0, 0.9)')
              .lineHeight(16)
              .fontWeight(400)
              .margin({ top: 6 })
          }
          .position({ left: '50%', bottom: 0 })
          .translate({ x: '-50%' })
          .onClick(() => {
            this.deleteListItem();
          })
        }
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16 })
    .backgroundColor($r('app.color.background_color'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  NavigationTitle() {
    Flex({ alignItems: ItemAlign.Center }) {
      if (this.isEdit) {
        Row() {
          SymbolGlyph($r('sys.symbol.xmark'))
            .fontColor(['rgba(0,0,0,0.9)'])
            .fontSize(24)
        }
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .width(40)
        .height(40)
        .backgroundColor('rgba(0, 0, 0, 0.05)')
        .borderRadius(40)
        .margin({ right: 8 })
        .onClick(() => {
          if (this.isEdit) {
            this.isEdit = !this.isEdit;
          }
        })
      }

      Text(this.isEdit ? $r('app.string.edit_text') : $r('app.string.psw_title'))
        .fontSize(20)
        .fontWeight(700)
        .lineHeight(27)
        .fontColor('rgba(0, 0, 0, 0.9)')
        .flexGrow(1)

      Row() {
        if (this.isEdit) {
          SymbolGlyph($r('sys.symbol.checkmark'))
            .fontColor(['rgba(0,0,0,0.9)'])
            .fontSize(24)
        } else {
          SymbolGlyph($r('sys.symbol.square_and_pencil'))
            .fontSize(24)
            .fontWeight(400)
        }
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .width(40)
      .height(40)
      .backgroundColor('rgba(0, 0, 0, 0.05)')
      .borderRadius(40)
      .onClick(() => {
        if (this.passwords.length === 0) {
          try {
            this.getUIContext().getPromptAction().showToast({ message: $r('app.string.add_Psw') });
          } catch (error) {
            hilog.error(0x0000, 'PswHomePage', `have error .Code:${error.code},message: ${error.message}`);
          }
          return;
        }
        this.isEdit = !this.isEdit;
      })
    }
    .height(56)
    .flexShrink(0)
  }
}