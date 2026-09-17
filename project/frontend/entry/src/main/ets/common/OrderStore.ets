import preferences from '@ohos.data.preferences'
import { common } from '@kit.AbilityKit'
import { OrderModel, OrderStatus, OrderGoodsItem, AddressModel, ReviewModel } from '../model/DataModels'

const PREF_NAME = 'secondhand_order_pref'
const KEY_ORDERS = 'orders'

export class OrderStore {
  private static store: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    OrderStore.store = await preferences.getPreferences(context, PREF_NAME)
  }

  private static async getStore(): Promise<preferences.Preferences> {
    if (!OrderStore.store) {
      throw new Error('OrderStore 尚未初始化，请先在 EntryAbility 调用 OrderStore.init(context)')
    }
    return OrderStore.store
  }

  static async getAllOrders(): Promise<OrderModel[]> {
    const store = await OrderStore.getStore()
    const raw = await store.get(KEY_ORDERS, '[]') as string
    try {
      const list = JSON.parse(raw) as OrderModel[]
      return list.sort((a, b) => b.createTime.localeCompare(a.createTime))
    } catch (e) {
      return []
    }
  }

  static async saveAllOrders(orders: OrderModel[]): Promise<void> {
    const store = await OrderStore.getStore()
    await store.put(KEY_ORDERS, JSON.stringify(orders))
    await store.flush()
  }

  static async getOrdersByStatus(status: OrderStatus): Promise<OrderModel[]> {
    const all = await OrderStore.getAllOrders()
    return all.filter(o => o.status === status)
  }

  static async getOrderById(orderId: string): Promise<OrderModel | null> {
    const all = await OrderStore.getAllOrders()
    return all.find(o => o.orderId === orderId) ?? null
  }

  static async createPendingOrder(items: OrderGoodsItem[], totalPrice: number): Promise<string> {
    const orders = await OrderStore.getAllOrders()
    const orderId = 'ORD' + Date.now().toString()
    const newOrder: OrderModel = {
      orderId: orderId,
      items: items,
      totalPrice: totalPrice,
      status: OrderStatus.PENDING_PAY,
      createTime: new Date().toISOString()
    }
    orders.push(newOrder)
    await OrderStore.saveAllOrders(orders)
    return orderId
  }

  static async completePayment(orderId: string, payMethod: string, address: AddressModel): Promise<void> {
    const orders = await OrderStore.getAllOrders()
    const order = orders.find(o => o.orderId === orderId)
    if (order) {
      order.status = OrderStatus.PENDING_RECEIVE
      order.payMethod = payMethod
      order.address = address
      await OrderStore.saveAllOrders(orders)
    }
  }

  static async confirmReceive(orderId: string): Promise<void> {
    const orders = await OrderStore.getAllOrders()
    const order = orders.find(o => o.orderId === orderId)
    if (order) {
      order.status = OrderStatus.PENDING_REVIEW
      await OrderStore.saveAllOrders(orders)
    }
  }

  static async submitReview(orderId: string, rating: number, content: string): Promise<void> {
    const orders = await OrderStore.getAllOrders()
    const order = orders.find(o => o.orderId === orderId)
    if (order) {
      const review: ReviewModel = {
        rating: rating,
        content: content,
        reviewTime: new Date().toISOString()
      }
      order.review = review
      order.status = OrderStatus.COMPLETED
      await OrderStore.saveAllOrders(orders)
    }
  }

  static async applyAfterSale(orderId: string, reason: string): Promise<void> {
    const orders = await OrderStore.getAllOrders()
    const order = orders.find(o => o.orderId === orderId)
    if (order) {
      order.status = OrderStatus.AFTER_SALE
      order.afterSaleReason = reason
      await OrderStore.saveAllOrders(orders)
    }
  }

  static async deleteOrder(orderId: string): Promise<void> {
    const orders = await OrderStore.getAllOrders()
    const filtered = orders.filter(o => o.orderId !== orderId)
    await OrderStore.saveAllOrders(filtered)
  }
}
