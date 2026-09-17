import { router } from '@kit.ArkUI'
import promptAction from '@ohos.promptAction'
import { OrderStore } from '../common/OrderStore'
import { OrderModel, OrderStatus, OrderGoodsItem } from '../model/DataModels'

function getImageResource(filename: string): Resource {
  if (filename === 'phone1.png') { return $r('app.media.phone1') }
  if (filename === 'phone2.png') { return $r('app.media.phone2') }
  if (filename === 'phone3.png') { return $r('app.media.phone3') }
  if (filename === 'phone4.png') { return $r('app.media.phone4') }
  if (filename === 'computer.png') { return $r('app.media.computer') }
  if (filename === 'tv.png') { return $r('app.media.tv') }
  if (filename === 'hairphone.png' || filename === 'hairphone.jpg') { return $r('app.media.hairphone') }
  if (filename === 'watch.png' || filename === 'watch.jpg') { return $r('app.media.watch') }
  if (filename === 'icebox.png') { return $r('app.media.icebox') }
  if (filename === 'washingmachine.png') { return $r('app.media.washingmachine') }
  if (filename === 'rangehood.png') { return $r('app.media.rangehood') }
  if (filename === 'waitcleaning.png') { return $r('app.media.waitcleaning') }
  if (filename === 'lock.png') { return $r('app.media.lock') }
  if (filename === 'airconditaion.png') { return $r('app.media.airconditaion') }
  if (filename === 'fan.png') { return $r('app.media.fan') }
  if (filename === 'washcar.png') { return $r('app.media.washcar') }
  if (filename === 'bag.png') { return $r('app.media.bag') }
  if (filename === 'brushteeth.png') { return $r('app.media.brushteeth') }
  if (filename === 'pad.png') { return $r('app.media.pad') }
  if (filename === 'phone5.png') { return $r('app.media.phone5') }
  if (filename === 'phone6.png') { return $r('app.media.phone6') }
  if (filename === 'phone7.png') { return $r('app.media.phone7') }
  if (filename === 'phone8.png') { return $r('app.media.phone8') }
  return $r('app.media.phone1')
}

interface OrderListParams {
  mode: string
}

function statusLabel(status: OrderStatus): string {
  if (status === OrderStatus.PENDING_PAY) return '待付款'
  if (status === OrderStatus.PENDING_RECEIVE) return '待收货'
  if (status === OrderStatus.PENDING_REVIEW) return '待评价'
  if (status === OrderStatus.AFTER_SALE) return '退换/售后中'
  if (status === OrderStatus.COMPLETED) return '已完成'
  return ''
}

function pageTitle(mode: string): string {
  if (mode === 'PENDING_PAY') return '待付款'
  if (mode === 'PENDING_RECEIVE') return '待收货'
  if (mode === 'PENDING_REVIEW') return '待评价'
  if (mode === 'AFTER_SALE') return '退换/售后'
  return '全部订单'
}

@Entry
@Component
struct OrderList {
  @State orders: OrderModel[] = []
  @State mode: string = 'ALL'

  aboutToAppear(): void {
    const params = router.getParams() as OrderListParams
    this.mode = params?.mode ?? 'ALL'
    this.loadOrders()
  }

  onPageShow(): void {
    this.loadOrders()
  }

  async loadOrders() {
    if (this.mode === 'ALL') {
      this.orders = await OrderStore.getAllOrders()
    } else {
      this.orders = await OrderStore.getOrdersByStatus(this.mode as OrderStatus)
    }
  }

  goPay(order: OrderModel) {
    router.pushUrl({ url: 'pages/OrderConfirm', params: { orderId: order.orderId } })
  }

  async confirmReceive(order: OrderModel) {
    await OrderStore.confirmReceive(order.orderId)
    promptAction.showToast({ message: '已确认收货' })
    this.loadOrders()
  }

  async applyAfterSale(order: OrderModel) {
    await OrderStore.applyAfterSale(order.orderId, '用户申请退换货')
    promptAction.showToast({ message: '已提交售后申请' })
    this.loadOrders()
  }

  goReview(order: OrderModel) {
    router.pushUrl({ url: 'pages/Review', params: { orderId: order.orderId } })
  }

  async cancelOrder(order: OrderModel) {
    await OrderStore.deleteOrder(order.orderId)
    promptAction.showToast({ message: '已取消订单' })
    this.loadOrders()
  }

  getOrderTotalCount(order: OrderModel): number {
    return order.items.reduce((sum, i) => sum + i.count, 0)
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

      if (this.orders.length === 0) {
        Column({ space: 12 }) {
          Text('暂无相关订单')
            .fontSize(14)
            .fontColor('#999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.orders, (order: OrderModel) => {
              Column({ space: 10 }) {
                Row() {
                  Text('订单号 ' + order.orderId.substring(3))
                    .fontSize(12)
                    .fontColor('#999')
                  Blank()
                  Text(statusLabel(order.status))
                    .fontSize(13)
                    .fontColor('#e0620d')
                    .fontWeight(FontWeight.Bold)
                }
                .width('100%')

                Divider().color('#F0F0F0')

                Column({ space: 8 }) {
                  ForEach(order.items, (item: OrderGoodsItem) => {
                    Row({ space: 10 }) {
                      Image(getImageResource(item.image))
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
                        Text('¥' + item.price.toFixed(0) + ' x' + item.count)
                          .fontSize(12)
                          .fontColor('#999')
                      }
                      .layoutWeight(1)
                      .alignItems(HorizontalAlign.Start)
                    }
                    .width('100%')
                  }, (item: OrderGoodsItem) => item.goodsId.toString())
                }
                .width('100%')

                Row() {
                  Text('共' + this.getOrderTotalCount(order) + '件商品').fontSize(12).fontColor('#999')
                  Blank()
                  Text('合计: ¥' + order.totalPrice.toFixed(2))
                    .fontSize(15)
                    .fontColor('#e0620d')
                    .fontWeight(FontWeight.Bold)
                }
                .width('100%')

                if (order.status === OrderStatus.PENDING_PAY) {
                  Row({ space: 10 }) {
                    Blank()
                    Button('取消订单')
                      .fontSize(13)
                      .height(34)
                      .backgroundColor('#F5F5F5')
                      .fontColor('#666')
                      .borderRadius(17)
                      .padding({ left: 16, right: 16 })
                      .onClick(() => { this.cancelOrder(order) })
                    Button('去支付')
                      .fontSize(13)
                      .height(34)
                      .backgroundColor('#e0620d')
                      .fontColor('#fff')
                      .borderRadius(17)
                      .padding({ left: 16, right: 16 })
                      .onClick(() => { this.goPay(order) })
                  }
                  .width('100%')
                } else if (order.status === OrderStatus.PENDING_RECEIVE) {
                  Row({ space: 10 }) {
                    Blank()
                    Button('申请售后')
                      .fontSize(13)
                      .height(34)
                      .backgroundColor('#F5F5F5')
                      .fontColor('#666')
                      .borderRadius(17)
                      .padding({ left: 16, right: 16 })
                      .onClick(() => { this.applyAfterSale(order) })
                    Button('确认收货')
                      .fontSize(13)
                      .height(34)
                      .backgroundColor('#e0620d')
                      .fontColor('#fff')
                      .borderRadius(17)
                      .padding({ left: 16, right: 16 })
                      .onClick(() => { this.confirmReceive(order) })
                  }
                  .width('100%')
                } else if (order.status === OrderStatus.PENDING_REVIEW) {
                  Row({ space: 10 }) {
                    Blank()
                    Button('申请售后')
                      .fontSize(13)
                      .height(34)
                      .backgroundColor('#F5F5F5')
                      .fontColor('#666')
                      .borderRadius(17)
                      .padding({ left: 16, right: 16 })
                      .onClick(() => { this.applyAfterSale(order) })
                    Button('去评价')
                      .fontSize(13)
                      .height(34)
                      .backgroundColor('#e0620d')
                      .fontColor('#fff')
                      .borderRadius(17)
                      .padding({ left: 16, right: 16 })
                      .onClick(() => { this.goReview(order) })
                  }
                  .width('100%')
                } else if (order.status === OrderStatus.AFTER_SALE) {
                  Text('售后处理中，请耐心等待客服处理')
                    .fontSize(12)
                    .fontColor('#999')
                    .width('100%')
                } else if (order.status === OrderStatus.COMPLETED && order.review) {
                  Column({ space: 4 }) {
                    Row() {
                      Text('我的评价：').fontSize(12).fontColor('#999')
                      Text('★'.repeat(order.review.rating) + '☆'.repeat(5 - order.review.rating))
                        .fontSize(12)
                        .fontColor('#FFA500')
                    }
                    Text(order.review.content)
                      .fontSize(12)
                      .fontColor('#666')
                  }
                  .width('100%')
                  .alignItems(HorizontalAlign.Start)
                }
              }
              .width('100%')
              .padding(14)
              .backgroundColor('#fff')
              .borderRadius(8)
            }, (order: OrderModel) => order.orderId)
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
