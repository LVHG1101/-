import { router } from '@kit.ArkUI'
import promptAction from '@ohos.promptAction'
import { OrderApi } from '../api/OrderApi'
import { AfterSaleApi } from '../api/AfterSaleApi'
import { TradeOrderModel, OrderGoodsItem, AfterSaleModel } from '../model/DataModels'
import { imageResource } from '../common/ImageUtil'

interface OrderListParams {
  mode: string
}

const PAY_METHODS: string[] = ['wechat', 'alipay', 'balance']
const PAY_LABELS: string[] = ['微信支付', '支付宝', '余额支付']

function statusLabel(status: string): string {
  if (status === 'PENDING_PAY') return '待付款'
  if (status === 'PENDING_RECEIVE') return '待收货'
  if (status === 'AFTER_SALE') return '售后处理中'
  if (status === 'REFUNDED') return '已退款'
  if (status === 'COMPLETED') return '已完成'
  if (status === 'CANCELLED') return '已取消'
  return status
}

function statusColor(status: string): string {
  if (status === 'CANCELLED' || status === 'REFUNDED') return '#999'
  return '#1A5FD6'
}

function pageTitle(mode: string): string {
  if (mode === 'PENDING_PAY') return '待付款'
  if (mode === 'PENDING_RECEIVE') return '待收货'
  if (mode === 'AFTER_SALE') return '退换/售后'
  if (mode === 'COMPLETED') return '已完成'
  return '全部订单'
}

@Entry
@Component
struct OrderList {
  @State orders: TradeOrderModel[] = []
  @State afterSales: AfterSaleModel[] = []
  @State mode: string = 'ALL'
  @State isLoading: boolean = true
  @State loadError: string = ''

  aboutToAppear(): void {
    const params = router.getParams() as OrderListParams
    this.mode = params?.mode ?? 'ALL'
    this.loadOrders()
  }

  onPageShow(): void {
    this.loadOrders()
  }

  async loadOrders() {
    this.isLoading = true
    this.loadError = ''
    try {
      const all = await OrderApi.list()
      this.orders = this.mode === 'ALL' ? all : all.filter((o: TradeOrderModel) => o.status === this.mode)
      this.afterSales = await AfterSaleApi.my()
    } catch (e) {
      this.orders = []
      this.afterSales = []
      this.loadError = '订单加载失败，请确认后端已启动且已登录'
    } finally {
      this.isLoading = false
    }
  }

  afterSaleOf(order: TradeOrderModel): AfterSaleModel | null {
    const found = this.afterSales.filter((a: AfterSaleModel) => a.orderId === order.id)
    return found.length > 0 ? found[0] : null
  }

  afterSaleStatusLabel(s: string): string {
    if (s === 'PENDING') return '平台处理中'
    if (s === 'APPROVED') return '已同意退款'
    if (s === 'REJECTED') return '已驳回'
    return s
  }

  /** 没有售后记录时返回空串，避免在 UI 里用非空断言 */
  afterSaleText(order: TradeOrderModel): string {
    const a = this.afterSaleOf(order)
    return a === null ? '' : this.afterSaleStatusLabel(a.status)
  }

  afterSaleRemark(order: TradeOrderModel): string {
    const a = this.afterSaleOf(order)
    return a === null ? '' : a.adminRemark
  }

  getOrderTotalCount(order: TradeOrderModel): number {
    let sum = 0
    for (const i of order.items) {
      sum += i.count
    }
    return sum
  }

  goPay(order: TradeOrderModel) {
    promptAction.showActionMenu({
      title: '选择支付方式',
      buttons: [
        { text: PAY_LABELS[0], color: '#1A5FD6' },
        { text: PAY_LABELS[1], color: '#1A5FD6' },
        { text: PAY_LABELS[2], color: '#1A5FD6' }
      ]
    }).then((result: promptAction.ActionMenuSuccessResponse) => {
      const idx = result.index
      if (idx >= 0 && idx < PAY_METHODS.length) {
        this.doPay(order, PAY_METHODS[idx])
      }
    }).catch(() => {
    })
  }

  async doPay(order: TradeOrderModel, payMethod: string) {
    try {
      const resp = await OrderApi.pay(order.id, payMethod)
      if (resp.code === 200) {
        promptAction.showToast({ message: '支付成功' })
        this.loadOrders()
      } else {
        promptAction.showToast({ message: resp.message || '支付失败' })
      }
    } catch (e) {
      promptAction.showToast({ message: '网络请求失败' })
    }
  }

  async doCancel(order: TradeOrderModel) {
    try {
      const resp = await OrderApi.cancel(order.id)
      promptAction.showToast({ message: resp.code === 200 ? '订单已取消' : (resp.message || '取消失败') })
      this.loadOrders()
    } catch (e) {
      promptAction.showToast({ message: '网络请求失败' })
    }
  }

  async doConfirmReceive(order: TradeOrderModel) {
    try {
      const resp = await OrderApi.confirm(order.id)
      promptAction.showToast({ message: resp.code === 200 ? '已确认收货' : (resp.message || '操作失败') })
      this.loadOrders()
    } catch (e) {
      promptAction.showToast({ message: '网络请求失败' })
    }
  }

  async doAfterSale(order: TradeOrderModel) {
    try {
      const resp = await AfterSaleApi.apply(order.id, '用户申请退换/售后')
      promptAction.showToast({ message: resp.code === 200 ? '售后申请已提交，等待平台处理' : (resp.message || '提交失败') })
      this.loadOrders()
    } catch (e) {
      promptAction.showToast({ message: '网络请求失败' })
    }
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.back')).width(22).height(22)
          .onClick(() => { router.back() })
        Text(pageTitle(this.mode))
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Blank().width(22)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      .backgroundColor('#fff')

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(40).height(40).color('#1A5FD6')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#f5f5f5')
      } else if (this.loadError !== '') {
        Column({ space: 12 }) {
          Text(this.loadError)
            .fontSize(14)
            .fontColor('#999')
            .textAlign(TextAlign.Center)
          Button('重新加载')
            .fontSize(13)
            .height(34)
            .backgroundColor('#1A5FD6')
            .fontColor('#fff')
            .borderRadius(17)
            .onClick(() => { this.loadOrders() })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .padding(24)
        .backgroundColor('#f5f5f5')
      } else if (this.orders.length === 0) {
        Column({ space: 12 }) {
          Text('暂无相关订单')
            .fontSize(14)
            .fontColor('#999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#f5f5f5')
      } else {
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.orders, (order: TradeOrderModel) => {
              Column({ space: 10 }) {
                Row() {
                  Text('订单号 ' + order.orderNo)
                    .fontSize(12)
                    .fontColor('#999')
                  Blank()
                  Text(statusLabel(order.status))
                    .fontSize(13)
                    .fontColor(statusColor(order.status))
                    .fontWeight(FontWeight.Bold)
                }
                .width('100%')

                Divider().color('#F0F0F0')

                Column({ space: 8 }) {
                  ForEach(order.items, (item: OrderGoodsItem) => {
                    Row({ space: 10 }) {
                      Image(imageResource(item.image))
                        .width(56).height(56)
                        .objectFit(ImageFit.Contain)
                        .backgroundColor('#F7F7F7')
                        .borderRadius(6)

                      Column({ space: 4 }) {
                        Text(item.name)
                          .fontSize(13)
                          .fontColor('#333')
                          .maxLines(2)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                        Text('¥' + item.price.toFixed(2) + ' x' + item.count)
                          .fontSize(12)
                          .fontColor('#999')
                      }
                      .layoutWeight(1)
                      .alignItems(HorizontalAlign.Start)
                    }
                    .width('100%')
                  }, (item: OrderGoodsItem) => order.id + '_' + item.goodsId)
                }
                .width('100%')

                Row() {
                  Text('共' + this.getOrderTotalCount(order) + '件商品')
                    .fontSize(12)
                    .fontColor('#999')
                  Blank()
                  Text('合计: ¥' + order.totalPrice.toFixed(2))
                    .fontSize(15)
                    .fontColor('#e0620d')
                    .fontWeight(FontWeight.Bold)
                }
                .width('100%')

                if (this.afterSaleText(order) !== '') {
                  Column({ space: 3 }) {
                    Row() {
                      Text('售后状态：')
                        .fontSize(12)
                        .fontColor('#999')
                      Text(this.afterSaleText(order))
                        .fontSize(12)
                        .fontColor('#e0620d')
                    }
                    if (this.afterSaleRemark(order) !== '') {
                      Text('平台回复：' + this.afterSaleRemark(order))
                        .fontSize(11)
                        .fontColor('#666')
                        .width('100%')
                    }
                  }
                  .alignItems(HorizontalAlign.Start)
                  .width('100%')
                  .padding(8)
                  .backgroundColor('#FFF7F0')
                  .borderRadius(6)
                }

                if (order.status === 'PENDING_PAY') {
                  Row({ space: 10 }) {
                    Blank()
                    Button('取消订单')
                      .fontSize(13).height(34)
                      .backgroundColor('#F5F5F5').fontColor('#666')
                      .borderRadius(17).padding({ left: 16, right: 16 })
                      .onClick(() => { this.doCancel(order) })
                    Button('去支付')
                      .fontSize(13).height(34)
                      .backgroundColor('#1A5FD6').fontColor('#fff')
                      .borderRadius(17).padding({ left: 16, right: 16 })
                      .onClick(() => { this.goPay(order) })
                  }
                  .width('100%')
                } else if (order.status === 'PENDING_RECEIVE') {
                  Row({ space: 10 }) {
                    Blank()
                    Button('申请售后')
                      .fontSize(13).height(34)
                      .backgroundColor('#F5F5F5').fontColor('#666')
                      .borderRadius(17).padding({ left: 16, right: 16 })
                      .onClick(() => { this.doAfterSale(order) })
                    Button('确认收货')
                      .fontSize(13).height(34)
                      .backgroundColor('#1A5FD6').fontColor('#fff')
                      .borderRadius(17).padding({ left: 16, right: 16 })
                      .onClick(() => { this.doConfirmReceive(order) })
                  }
                  .width('100%')
                } else if (order.status === 'COMPLETED') {
                  Row({ space: 10 }) {
                    Blank()
                    Button('申请售后')
                      .fontSize(13).height(34)
                      .backgroundColor('#F5F5F5').fontColor('#666')
                      .borderRadius(17).padding({ left: 16, right: 16 })
                      .onClick(() => { this.doAfterSale(order) })
                  }
                  .width('100%')
                } else if (order.status === 'AFTER_SALE') {
                  Text('售后处理中，请耐心等待平台处理')
                    .fontSize(12).fontColor('#999').width('100%')
                } else if (order.status === 'REFUNDED') {
                  Text('该订单已退款')
                    .fontSize(12).fontColor('#999').width('100%')
                } else if (order.status === 'CANCELLED') {
                  Text('该订单已取消')
                    .fontSize(12).fontColor('#999').width('100%')
                }
              }
              .width('100%')
              .padding(14)
              .backgroundColor('#fff')
              .borderRadius(8)
            }, (order: TradeOrderModel) => order.id.toString())
          }
          .padding(12)
        }
        .layoutWeight(1)
        .backgroundColor('#f5f5f5')
      }
    }
    .width('100%')
    .height('100%')
  }
}
