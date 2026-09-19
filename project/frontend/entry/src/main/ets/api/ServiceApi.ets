import { HttpUtil } from '../common/HttpUtil'
import { parseJson } from '../common/JsonHelper.js'
import { ServiceItemModel, ServiceOrderModel } from '../model/DataModels'

class ServiceListResult {
  code: number = 0
  message: string = ''
  data: ServiceItemModel[] = []
}

class ServiceDetailResult {
  code: number = 0
  message: string = ''
  data: ServiceItemModel = { id: 0, code: '', name: '', icon: '', description: '', price: 0, enabled: true }
}

class ServiceOrderListResult {
  code: number = 0
  message: string = ''
  data: ServiceOrderModel[] = []
}

class ApiResult {
  code: number = 0
  message: string = ''
}

class OrderBody {
  serviceId: number = 0
  contactName: string = ''
  contactPhone: string = ''
  address: string = ''
  appointmentTime: string = ''
  remark: string = ''
}

class CancelBody {
  orderId: number = 0
}

export class ServiceApi {
  /** 服务项目列表 */
  static async list(): Promise<ServiceItemModel[]> {
    const json = await HttpUtil.get('/service/list')
    const result = parseJson(json) as ServiceListResult
    if (result.code !== 200) {
      return []
    }
    return result.data ?? []
  }

  /** 服务详情 */
  static async detail(id: number): Promise<ServiceItemModel | null> {
    const json = await HttpUtil.get('/service/detail?id=' + id)
    const result = parseJson(json) as ServiceDetailResult
    if (result.code !== 200) {
      return null
    }
    return result.data
  }

  /** 提交服务预约 */
  static async createOrder(serviceId: number, contactName: string, contactPhone: string,
    address: string, appointmentTime: string, remark: string): Promise<ApiResult> {
    const body = new OrderBody()
    body.serviceId = serviceId
    body.contactName = contactName
    body.contactPhone = contactPhone
    body.address = address
    body.appointmentTime = appointmentTime
    body.remark = remark
    const json = await HttpUtil.postWithAuth('/service/order', body)
    return parseJson(json) as ApiResult
  }

  /** 我的服务预约 */
  static async myOrders(): Promise<ServiceOrderModel[]> {
    const json = await HttpUtil.getWithAuth('/service/orders')
    const result = parseJson(json) as ServiceOrderListResult
    if (result.code !== 200) {
      return []
    }
    return result.data ?? []
  }

  /** 取消预约 */
  static async cancel(orderId: number): Promise<ApiResult> {
    const body = new CancelBody()
    body.orderId = orderId
    const json = await HttpUtil.postWithAuth('/service/cancel', body)
    return parseJson(json) as ApiResult
  }
}
