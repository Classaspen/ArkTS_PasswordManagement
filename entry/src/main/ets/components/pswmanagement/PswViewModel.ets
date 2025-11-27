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
import  { DataEntity, TableCategory, DatabaseManager, InsertDataEntity} from '../database/Database';

export class PasswordData implements DataEntity {
  id?: number;          // 对应自增主键
  name: string = '';    // 平台名称
  content: string = ''; // 密码内容
  timestamp: number = Date.now(); // 时间戳
}

export interface PasswordItem {
  icon: Resource;
  name: string;        // 平台名称
  content: string;   // 时间戳
}

export const PayList: Array<PasswordItem> = [

];

export const EarnList: Array<PasswordItem> = [

];

export const ImageList: Record<string, Resource> = {

};

export const TextList: Record<string, Resource> = {

};

export interface AccountTable {
  tableName: string;
  sqlCreate: string;
  columns: string[];
}