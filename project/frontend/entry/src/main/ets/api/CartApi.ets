import { HttpUtil } from '../common/HttpUtil'
import { parseJson } from '../common/JsonHelper.js'
import { CartItemModel } from '../model/DataModels'

class CartListResult {
  code: number = 0
  message: string = ''
  data: CartItemModel[] = []
}

class ApiResult {
  code: number = 0
  message: string = ''
}

class AddBody {
  goodsId: number = 0
}

class UpdateBody {
  id: number = 0
  count: number = 1
  selected: boolean = true
}

class DeleteBody {
  id: number = 0
}

class EmptyBody {
}

export class CartApi {
  /** 加入购物车 */
  static async add(goodsId: number): Promise<ApiResult> {
    const body = new AddBody()
    body.goodsId = goodsId
    const json = await HttpUtil.postWithAuth('/cart/add', body)
    return parseJson(json) as ApiResult
  }

  /** 购物车列表 */
  static async list(): Promise<CartItemModel[]> {
    const json = await HttpUtil.getWithAuth('/cart/list')
    const result = parseJson(json) as CartListResult
    if (result.code !== 200) {
      return []
    }
    return result.data ?? []
  }

  /** 更新数量/选中状态 */
  static async update(id: number, count: number, selected: boolean): Promise<ApiResult> {
    const body = new UpdateBody()
    body.id = id
    body.count = count
    body.selected = selected
    const json = await HttpUtil.postWithAuth('/cart/update', body)
    return parseJson(json) as ApiResult
  }

  /** 删除购物车项 */
  static async delete(id: number): Promise<ApiResult> {
    const body = new DeleteBody()
    body.id = id
    const json = await HttpUtil.postWithAuth('/cart/delete', body)
    return parseJson(json) as ApiResult
  }

  /** 清空购物车 */
  static async clear(): Promise<ApiResult> {
    const body = new EmptyBody()
    const json = await HttpUtil.postWithAuth('/cart/clear', body)
    return parseJson(json) as ApiResult
  }
}
