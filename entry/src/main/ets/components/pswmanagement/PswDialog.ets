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

import { hilog } from '@kit.PerformanceAnalysisKit';
import { PasswordData, PasswordItem, EarnList, TextList, PayList } from './PswViewModel';
import CommonConstants from './CommonConstants';
import  { DataEntity, TableCategory, DatabaseManager} from '../database/Database';

@CustomDialog
export struct PswDialog {
  controller?: CustomDialogController;
  @Link isInsert: boolean;
  @Link newPassword: DataEntity;
  confirm?: (isInsert: boolean, newPassword: DataEntity) => void;
  // @State payList: Array<PasswordItem> = PayList;
  @State earnList: Array<PasswordItem> = EarnList;
  @State bgColor: string = '';
  @State name: string = '';
  @State content: string = '';
  private scroller: Scroller = new Scroller();
  private inputAmount = '';

  @Builder
  TabBuilder(index: number) {
    Column() {
      Text(index === 0 ? $r('app.string.pay_text') : $r('app.string.income_text'))
        .fontSize($r('app.float.font_size_M'))
        .fontColor( '#0A59F7' )
    }
    .width($r('app.float.component_size_LM'))
    .padding({ top: $r('app.float.edge_size_LM'), bottom: $r('app.float.edge_size_S') })
    .margin({ bottom: $r('app.float.edge_size_S') })
    .border({
      width: { bottom: 'app.float.border_size_M' },
      color: '#0A59F7'
    })
  }

  aboutToAppear() {
    // this.inputAmount = this.newPassword.amount.toString();
    this.name = this.newPassword.name;
    this.content = this.newPassword.content;
  }

  selectAccount(item: PasswordItem) {
    this.newPassword.name = item.name;
    this.newPassword.content = item.content;
  }

  build() {
    Column() {
      Image($r('app.media.half'))
        .width($r('app.float.component_size_L'))
        .height($r('app.float.component_size_S'))
        .onClick(() => {
          this.controller?.close();
        })

      Column() {
        Text($r('app.string.count_text'))
          .width('100%')
          .fontSize($r('app.float.font_size_MP'))
          .fontColor(Color.Black)

        Column() {
          // TextInput({
          //   placeholder: $r('app.string.input_text'),
          //   text: this.newPassword.content
          // })
          //   .padding({
          //     left: CommonConstants.MINIMUM_SIZE,
          //     top: CommonConstants.MINIMUM_SIZE,
          //     bottom: CommonConstants.MINIMUM_SIZE
          //   })
          //   .borderRadius(CommonConstants.MINIMUM_SIZE)
          //   .backgroundColor(Color.White)
          //   .type(InputType.Number)
          //   .onChange((value: string) => {
          //     this.inputAmount = value;
          //   })
        }
        .height($r('app.float.component_size_MP'))
        .padding({ top: $r('app.float.edge_size_MPM'), bottom: $r('app.float.edge_size_MM') })
        .borderWidth({ bottom: CommonConstants.FULL_SIZE })
        .borderColor($r('app.color.border_color'))
      }
      .width('100%')
      .padding({ left: $r('app.float.edge_size_M'), right: $r('app.float.edge_size_M') })

      Column() {
        // 平台名称输入框
        Text($r('app.string.platform_name'))
          .fontSize($r('app.float.font_size_S'))
          .margin({ top: 12 })
        TextInput({ placeholder: '输入平台名称' })
          .type(InputType.Normal)
          .width('100%')
          .height(40)
          .onChange((value: string) => {
            this.newPassword.name = value
          })

        // 密码输入框
        Text($r('app.string.password'))
          .fontSize($r('app.float.font_size_S'))
          .margin({ top: 16 })
        TextInput({ placeholder: '输入密码' })
          .type(InputType.Password)
          .width('100%')
          .height(40)
          .onChange((value: string) => {
            this.newPassword.content = value
          })

        // 确认按钮
        Button() {
          Text($r('app.string.confirm_text'))
            .fontSize($r('app.float.font_size_M'))
            .fontColor(Color.White)
        }
        .width('100%')
        .height($r('app.float.component_size_M'))
        .margin({ top: 24 })
        .onClick(() => {
          this.newPassword.timestamp = Date.now();
          this.confirm && this.confirm(this.isInsert, this.newPassword)
          this.controller?.close()
        })
      }.margin({ bottom: 60 }) // 添加底部外边距，让内容上移
      .layoutWeight(CommonConstants.FULL_SIZE)
      .padding({
        bottom: $r('app.float.font_size_L'),
        left: $r('app.float.font_size_L'),
        right: $r('app.float.font_size_L')
      })
      .justifyContent(FlexAlign.End)
    }
    .width('100%')
    .height(440)
    .borderRadius({ topLeft: $r('app.float.font_size_L'), topRight: $r('app.float.font_size_L') })
    .backgroundColor(Color.White)
    .align(Alignment.BottomEnd)
  }
}