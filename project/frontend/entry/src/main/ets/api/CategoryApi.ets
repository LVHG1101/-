import { HttpUtil } from '../common/HttpUtil'
import { parseJson } from '../common/JsonHelper.js'
import { CategoryItemModel, GoodsItemModel } from '../model/DataModels'

class CategoryListResult {
  code: number = 0
  message: string = ''
  data: CategoryItemModel[] = []
}

class GoodsListResult {
  code: number = 0
  message: string = ''
  data: GoodsItemModel[] = []
}

export class CategoryApi {
  /** 分类列表 */
  static async list(): Promise<CategoryItemModel[]> {
    const json = await HttpUtil.get('/category/list')
    const result = parseJson(json) as CategoryListResult
    if (result.code !== 200) {
      return []
    }
    return result.data ?? []
  }

  /** 商品列表（可按分类过滤） */
  static async goods(categoryId: number): Promise<GoodsItemModel[]> {
    const path = categoryId > 0 ? '/goods/list?categoryId=' + categoryId : '/goods/list'
    const json = await HttpUtil.get(path)
    const result = parseJson(json) as GoodsListResult
    if (result.code !== 200) {
      return []
    }
    return result.data ?? []
  }
}
