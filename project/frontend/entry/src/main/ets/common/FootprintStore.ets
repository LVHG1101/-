import { FootprintApi } from '../api/FootprintApi'
import { FootprintModel } from '../model/DataModels'
import { UserStore } from './UserStore'

/**
 * 浏览足迹全部走后端 /footprint 接口，数据按用户隔离。
 * 未登录时不做任何网络请求，直接返回空列表。
 */
export class FootprintStore {
  static async getFootprints(): Promise<FootprintModel[]> {
    const loggedIn = await UserStore.isLoggedIn()
    if (!loggedIn) {
      return []
    }
    try {
      return await FootprintApi.list()
    } catch (e) {
      return []
    }
  }

  static async recordVisit(goodsId: number, name: string, price: number, image: string): Promise<void> {
    const loggedIn = await UserStore.isLoggedIn()
    if (!loggedIn) {
      return
    }
    try {
      await FootprintApi.add(goodsId, name, price, image)
    } catch (e) {
    }
  }

  static async removeFootprint(goodsId: number): Promise<void> {
    await FootprintApi.remove(goodsId)
  }

  static async clearAll(): Promise<void> {
    await FootprintApi.clear()
  }
}
