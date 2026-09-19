import { HttpUtil } from '../common/HttpUtil'
import { parseJson } from '../common/JsonHelper.js'
import { TradeOrderModel } from '../model/DataModels'

class OrderListResult {
  code: number = 0
  message: string = ''
  data: TradeOrderModel[] = []
}

class OrderResult {
  code: number = 0
  message: string = ''
  data: TradeOrderModel = { id: 0, orderNo: '', totalPrice: 0, status: '', payMethod: '', createTime: '', items: [] }
}

class ApiResult {
  code: number = 0
  message: string = ''
}

class CreateBody {
  cartItemIds: number[] = []
}

class PayBody {
  orderId: number = 0
  payMethod: string = ''
}

export class OrderApi {
  /** 从购物车创建订单 */
  static async create(cartItemIds: number[]): Promise<OrderResult> {
    const body = new CreateBody()
    body.cartItemIds = cartItemIds
    const json = await HttpUtil.postWithAuth('/order/create', body)
    return parseJson(json) as OrderResult
  }

  /** 支付订单 */
  static async pay(orderId: number, payMethod: string): Promise<ApiResult> {
    const body = new PayBody()
    body.orderId = orderId
    body.payMethod = payMethod
    const json = await HttpUtil.postWithAuth('/order/pay', body)
    return parseJson(json) as ApiResult
  }

  /** 订单列表 */
  static async list(): Promise<TradeOrderModel[]> {
    const json = await HttpUtil.getWithAuth('/order/list')
    const result = parseJson(json) as OrderListResult
    if (result.code !== 200) {
      return []
    }
    return result.data ?? []
  }
}
