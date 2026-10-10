import { HttpUtil } from '../common/HttpUtil'
import { parseJson } from '../common/JsonHelper.js'

export class AddressModel {
  id: number = 0
  userId: number = 0
  name: string = ''
  phone: string = ''
  province: string = ''
  city: string = ''
  district: string = ''
  detail: string = ''
  isDefault: boolean = false
}

class AddressListResult {
  code: number = 0
  message: string = ''
  data: AddressModel[] = []
}

class ApiResult {
  code: number = 0
  message: string = ''
}

class AddressIdBody {
  addressId: number = 0
}

export class AddressApi {
  static async list(): Promise<AddressModel[]> {
    const json = await HttpUtil.getWithAuth('/address/list')
    const result = parseJson(json) as AddressListResult
    if (result.code !== 200) {
      return []
    }
    return result.data ?? []
  }

  static async save(addr: AddressModel): Promise<ApiResult> {
    const json = await HttpUtil.postWithAuth('/address/save', addr)
    return parseJson(json) as ApiResult
  }

  static async setDefault(addressId: number): Promise<ApiResult> {
    const body = new AddressIdBody()
    body.addressId = addressId
    const json = await HttpUtil.postWithAuth('/address/default', body)
    return parseJson(json) as ApiResult
  }

  static async delete(addressId: number): Promise<ApiResult> {
    const body = new AddressIdBody()
    body.addressId = addressId
    const json = await HttpUtil.postWithAuth('/address/delete', body)
    return parseJson(json) as ApiResult
  }
}
