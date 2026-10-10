import { HttpUtil } from '../common/HttpUtil'
import { parseJson } from '../common/JsonHelper.js'
import { ExchangeGoodsModel, ExchangeApplyModel } from '../model/DataModels'

class ExchangeListResult {
  code: number = 0
  message: string = ''
  data: ExchangeGoodsModel[] = []
}

class ExchangeMineResult {
  code: number = 0
  message: string = ''
  data: ExchangeMineData = new ExchangeMineData()
}

class ExchangeMineData {
  published: ExchangeGoodsModel[] = []
  applies: ExchangeApplyModel[] = []
}

class ApiResult {
  code: number = 0
  message: string = ''
}

class PublishBody {
  name: string = ''
  wantName: string = ''
  image: string = ''
  description: string = ''
  owner: string = ''
  location: string = ''
}

class ApplyBody {
  exchangeId: number = 0
  message: string = ''
}

export class ExchangeApi {
  /** 换物列表 */
  static async list(): Promise<ExchangeGoodsModel[]> {
    const json = await HttpUtil.get('/exchange/list')
    const result = parseJson(json) as ExchangeListResult
    if (result.code !== 200) {
      return []
    }
    return result.data ?? []
  }

  /** 发布换物 */
  static async publish(name: string, wantName: string, image: string, description: string,
    owner: string, location: string): Promise<ApiResult> {
    const body = new PublishBody()
    body.name = name
    body.wantName = wantName
    body.image = image
    body.description = description
    body.owner = owner
    body.location = location
    const json = await HttpUtil.postWithAuth('/exchange/publish', body)
    return parseJson(json) as ApiResult
  }

  /** 申请换物 */
  static async apply(exchangeId: number, message: string): Promise<ApiResult> {
    const body = new ApplyBody()
    body.exchangeId = exchangeId
    body.message = message
    const json = await HttpUtil.postWithAuth('/exchange/apply', body)
    return parseJson(json) as ApiResult
  }

  /** 我的换物（发布的 + 申请的） */
  static async mine(): Promise<ExchangeMineData> {
    const json = await HttpUtil.getWithAuth('/exchange/mine')
    const result = parseJson(json) as ExchangeMineResult
    if (result.code !== 200) {
      return new ExchangeMineData()
    }
    return result.data ?? new ExchangeMineData()
  }
}
