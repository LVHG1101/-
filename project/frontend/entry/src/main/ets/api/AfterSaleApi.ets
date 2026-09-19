import { HttpUtil } from '../common/HttpUtil'
import { parseJson } from '../common/JsonHelper.js'
import { AfterSaleModel } from '../model/DataModels'

class AfterSaleListResult {
  code: number = 0
  message: string = ''
  data: AfterSaleModel[] = []
}

class ApiResult {
  code: number = 0
  message: string = ''
}

class ApplyBody {
  orderId: number = 0
  reason: string = ''
}

/** 用户侧的售后接口 */
export class AfterSaleApi {
  static async apply(orderId: number, reason: string): Promise<ApiResult> {
    const body = new ApplyBody()
    body.orderId = orderId
    body.reason = reason
    const json = await HttpUtil.postWithAuth('/after-sale/apply', body)
    return parseJson(json) as ApiResult
  }

  static async my(): Promise<AfterSaleModel[]> {
    const json = await HttpUtil.getWithAuth('/after-sale/my')
    const result = parseJson(json) as AfterSaleListResult
    if (result.code !== 200) {
      return []
    }
    return result.data ?? []
  }
}
