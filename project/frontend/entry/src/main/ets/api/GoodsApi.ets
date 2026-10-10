import { HttpUtil } from '../common/HttpUtil'
import { parseJson } from '../common/JsonHelper.js'
import { GoodsItemModel } from '../model/DataModels'

class GoodsDetailResult {
  code: number = 0
  message: string = ''
  data: GoodsItemModel = { id: 0, name: '', price: 0, image: '', quality: '', categoryId: 0 }
}

class GoodsListResult {
  code: number = 0
  message: string = ''
  data: GoodsItemModel[] = []
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

class GoodsIdBody {
  goodsId: number = 0
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

  /** 商品搜索 */
  static async search(keyword: string, categoryId: number, sortBy: string): Promise<GoodsItemModel[]> {
    let path = '/goods/search?'
    if (keyword) {
      path += 'keyword=' + encodeURIComponent(keyword) + '&'
    }
    if (categoryId > 0) {
      path += 'categoryId=' + categoryId + '&'
    }
    if (sortBy) {
      path += 'sortBy=' + sortBy
    }
    const json = await HttpUtil.get(path)
    const result = parseJson(json) as GoodsListResult
    if (result.code !== 200) {
      return []
    }
    return result.data ?? []
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

  /** 我发布的商品 */
  static async mine(): Promise<GoodsItemModel[]> {
    const json = await HttpUtil.getWithAuth('/goods/mine')
    const result = parseJson(json) as GoodsListResult
    if (result.code !== 200) {
      return []
    }
    return result.data ?? []
  }

  /** 下架商品 */
  static async offline(goodsId: number): Promise<ApiResult> {
    const body = new GoodsIdBody()
    body.goodsId = goodsId
    const json = await HttpUtil.postWithAuth('/goods/offline', body)
    return parseJson(json) as ApiResult
  }

  /** 重新上架商品 */
  static async online(goodsId: number): Promise<ApiResult> {
    const body = new GoodsIdBody()
    body.goodsId = goodsId
    const json = await HttpUtil.postWithAuth('/goods/online', body)
    return parseJson(json) as ApiResult
  }

  /** 删除商品 */
  static async delete(goodsId: number): Promise<ApiResult> {
    const body = new GoodsIdBody()
    body.goodsId = goodsId
    const json = await HttpUtil.postWithAuth('/goods/delete', body)
    return parseJson(json) as ApiResult
  }
}
