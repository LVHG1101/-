import { HttpUtil } from '../common/HttpUtil'
import { parseJson } from '../common/JsonHelper.js'
import { FootprintModel } from '../model/DataModels'

class FootprintListResult {
  code: number = 0
  message: string = ''
  data: FootprintModel[] = []
}

class VisitBody {
  goodsId: number = 0
  name: string = ''
  price: number = 0
  image: string = ''
}

class GoodsIdBody {
  goodsId: number = 0
}

class EmptyBody {
}

export class FootprintApi {
  /** 拉取当前登录用户的浏览足迹（按浏览时间倒序） */
  static async list(): Promise<FootprintModel[]> {
    const json = await HttpUtil.getWithAuth('/footprint/list')
    const result = parseJson(json) as FootprintListResult
    if (result.code !== 200) {
      return []
    }
    return result.data ?? []
  }

  static async add(goodsId: number, name: string, price: number, image: string): Promise<void> {
    const body = new VisitBody()
    body.goodsId = goodsId
    body.name = name
    body.price = price
    body.image = image
    await HttpUtil.postWithAuth('/footprint/add', body)
  }

  static async remove(goodsId: number): Promise<void> {
    const body = new GoodsIdBody()
    body.goodsId = goodsId
    await HttpUtil.postWithAuth('/footprint/remove', body)
  }

  static async clear(): Promise<void> {
    await HttpUtil.postWithAuth('/footprint/clear', new EmptyBody())
  }
}
