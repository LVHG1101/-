import { HttpUtil } from '../common/HttpUtil'
import { parseJson } from '../common/JsonHelper.js'
import { AfterSaleModel, ServiceItemModel, AdminServiceOrderModel } from '../model/DataModels'

/** /admin/** 全部接口都要求管理员令牌，普通用户会拿到 403 */

class AfterSaleListResult {
  code: number = 0
  message: string = ''
  data: AfterSaleModel[] = []
}

class ServiceListResult {
  code: number = 0
  message: string = ''
  data: ServiceItemModel[] = []
}

class ServiceOrderListResult {
  code: number = 0
  message: string = ''
  data: AdminServiceOrderModel[] = []
}

class ApiResult {
  code: number = 0
  message: string = ''
}

class HandleBody {
  id: number = 0
  approve: boolean = true
  remark: string = ''
}

class IdBody {
  id: number = 0
}

class ServiceSaveBody {
  id?: number
  code: string = ''
  name: string = ''
  icon: string = ''
  description: string = ''
  price: number = 0
  enabled: boolean = true
}

class ServiceOrderStatusBody {
  id: number = 0
  status: string = ''
}

export class AdminApi {
  // ---------------- 售后 ----------------

  static async afterSales(status: string): Promise<AfterSaleModel[]> {
    const path = status && status !== 'ALL'
      ? '/admin/after-sales?status=' + status
      : '/admin/after-sales'
    const json = await HttpUtil.getWithAuth(path)
    const result = parseJson(json) as AfterSaleListResult
    if (result.code !== 200) {
      return []
    }
    return result.data ?? []
  }

  static async handleAfterSale(id: number, approve: boolean, remark: string): Promise<ApiResult> {
    const body = new HandleBody()
    body.id = id
    body.approve = approve
    body.remark = remark
    const json = await HttpUtil.postWithAuth('/admin/after-sale/handle', body)
    return parseJson(json) as ApiResult
  }

  // ---------------- 服务项 ----------------

  static async services(): Promise<ServiceItemModel[]> {
    const json = await HttpUtil.getWithAuth('/admin/services')
    const result = parseJson(json) as ServiceListResult
    if (result.code !== 200) {
      return []
    }
    return result.data ?? []
  }

  static async saveService(id: number, code: string, name: string, icon: string,
    description: string, price: number, enabled: boolean): Promise<ApiResult> {
    const body = new ServiceSaveBody()
    body.id = id > 0 ? id : undefined
    body.code = code
    body.name = name
    body.icon = icon
    body.description = description
    body.price = price
    body.enabled = enabled
    const json = await HttpUtil.postWithAuth('/admin/service/save', body)
    return parseJson(json) as ApiResult
  }

  static async toggleService(id: number): Promise<ApiResult> {
    const body = new IdBody()
    body.id = id
    const json = await HttpUtil.postWithAuth('/admin/service/toggle', body)
    return parseJson(json) as ApiResult
  }

  static async deleteService(id: number): Promise<ApiResult> {
    const body = new IdBody()
    body.id = id
    const json = await HttpUtil.postWithAuth('/admin/service/delete', body)
    return parseJson(json) as ApiResult
  }

  // ---------------- 预约单 ----------------

  static async serviceOrders(status: string): Promise<AdminServiceOrderModel[]> {
    const path = status && status !== 'ALL'
      ? '/admin/service-orders?status=' + status
      : '/admin/service-orders'
    const json = await HttpUtil.getWithAuth(path)
    const result = parseJson(json) as ServiceOrderListResult
    if (result.code !== 200) {
      return []
    }
    return result.data ?? []
  }

  static async updateServiceOrderStatus(id: number, status: string): Promise<ApiResult> {
    const body = new ServiceOrderStatusBody()
    body.id = id
    body.status = status
    const json = await HttpUtil.postWithAuth('/admin/service-order/status', body)
    return parseJson(json) as ApiResult
  }
}
