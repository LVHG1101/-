import { HttpUtil } from '../common/HttpUtil'
import { parseJson } from '../common/JsonHelper.js'

export class CarbonRecordModel {
  id: number = 0
  delta: number = 0
  reason: string = ''
  createTime: string = ''
}

export class CarbonMyResult {
  code: number = 0
  message: string = ''
  balance: number = 0
  records: CarbonRecordModel[] = []
}

export class CarbonApi {
  static async my(): Promise<CarbonMyResult> {
    const json = await HttpUtil.getWithAuth('/carbon/my')
    return parseJson(json) as CarbonMyResult
  }
}
