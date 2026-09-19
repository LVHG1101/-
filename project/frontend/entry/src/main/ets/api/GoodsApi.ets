import { HttpUtil } from '../common/HttpUtil'
import { parseJson } from '../common/JsonHelper.js'
import { GoodsItemModel } from '../model/DataModels'

class GoodsDetailResult {
  code: number = 0
  message: string = ''
  data: GoodsItemModel = { id: 0, name: '', price: 0, image: '', quality: '', categoryId: 0 }
}

class ApiResult {
  code: number = 0
  message: string = ''
}

class PublishBody {
  name: string = ''
  price: number = 0
  image: string = ''
  quality: string = ''
  description: string = ''
  categoryId: number = 0
}

export class GoodsApi {
  /** 商品详情 */
  static async detail(id: number): Promise<GoodsItemModel | null> {
    const json = await HttpUtil.get('/goods/detail?id=' + id)
    const result = parseJson(json) as GoodsDetailResult
    if (result.code !== 200) {
      return null
    }
    return result.data
  }

  /** 发布商品 */
  static async publish(name: string, price: number, image: string, quality: string,
    description: string, categoryId: number): Promise<ApiResult> {
    const body = new PublishBody()
    body.name = name
    body.price = price
    body.image = image
    body.quality = quality
    body.description = description
    body.categoryId = categoryId
    const json = await HttpUtil.postWithAuth('/goods/publish', body)
    return parseJson(json) as ApiResult
  }
}
