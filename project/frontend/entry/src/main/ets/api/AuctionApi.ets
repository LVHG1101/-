import { HttpUtil } from '../common/HttpUtil'
import { parseJson } from '../common/JsonHelper.js'
import { AuctionGoodsModel, AuctionBidModel } from '../model/DataModels'

class AuctionListResult {
  code: number = 0
  message: string = ''
  data: AuctionGoodsModel[] = []
}

class AuctionMineResult {
  code: number = 0
  message: string = ''
  data: AuctionMineData = new AuctionMineData()
}

class AuctionMineData {
  auctions: AuctionGoodsModel[] = []
  bids: AuctionBidModel[] = []
}

class ApiResult {
  code: number = 0
  message: string = ''
}

class BidBody {
  auctionId: number = 0
  price: number = 0
}

class PublishBody {
  name: string = ''
  image: string = ''
  startPrice: number = 0
  endTime: number = 0
}

export class AuctionApi {
  /** 拍卖列表 */
  static async list(): Promise<AuctionGoodsModel[]> {
    const json = await HttpUtil.get('/auction/list')
    const result = parseJson(json) as AuctionListResult
    if (result.code !== 200) {
      return []
    }
    return result.data ?? []
  }

  /** 发布拍卖 */
  static async publish(name: string, image: string, startPrice: number, endTime: number): Promise<ApiResult> {
    const body = new PublishBody()
    body.name = name
    body.image = image
    body.startPrice = startPrice
    body.endTime = endTime
    const json = await HttpUtil.postWithAuth('/auction/publish', body)
    return parseJson(json) as ApiResult
  }

  /** 出价 */
  static async bid(auctionId: number, price: number): Promise<ApiResult> {
    const body = new BidBody()
    body.auctionId = auctionId
    body.price = price
    const json = await HttpUtil.postWithAuth('/auction/bid', body)
    return parseJson(json) as ApiResult
  }

  /** 我的拍卖 + 我的出价 */
  static async mine(): Promise<AuctionMineData> {
    const json = await HttpUtil.getWithAuth('/auction/mine')
    const result = parseJson(json) as AuctionMineResult
    if (result.code !== 200) {
      return new AuctionMineData()
    }
    return result.data ?? new AuctionMineData()
  }
}
