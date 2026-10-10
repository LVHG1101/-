import { HttpUtil } from '../common/HttpUtil'
import { parseJson } from '../common/JsonHelper.js'

export class FavoriteModel {
  id: number = 0
  userId: number = 0
  goodsId: number = 0
  name: string = ''
  price: number = 0
  image: string = ''
  createTime: string = ''
}

class FavoriteListResult {
  code: number = 0
  message: string = ''
  data: FavoriteModel[] = []
}

class ApiResult {
  code: number = 0
  message: string = ''
}

class GoodsIdBody {
  goodsId: number = 0
}

export class FavoriteApi {
  static async list(): Promise<FavoriteModel[]> {
    const json = await HttpUtil.getWithAuth('/favorite/list')
    const result = parseJson(json) as FavoriteListResult
    if (result.code !== 200) {
      return []
    }
    return result.data ?? []
  }

  static async add(goodsId: number): Promise<ApiResult> {
    const body = new GoodsIdBody()
    body.goodsId = goodsId
    const json = await HttpUtil.postWithAuth('/favorite/add', body)
    return parseJson(json) as ApiResult
  }

  static async remove(goodsId: number): Promise<ApiResult> {
    const body = new GoodsIdBody()
    body.goodsId = goodsId
    const json = await HttpUtil.postWithAuth('/favorite/remove', body)
    return parseJson(json) as ApiResult
  }
}
