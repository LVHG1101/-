import { router } from '@kit.ArkUI'
import promptAction from '@ohos.promptAction'
import { CartApi } from '../api/CartApi'
import { OrderApi } from '../api/OrderApi'
import { CartItemModel } from '../model/DataModels'
import { imageResource } from '../common/ImageUtil'

interface OrderConfirmParams {
  cartItemIds: number[]
}

@Entry
@Component
struct OrderConfirm {
  @State items: CartItemModel[] = []
  @State payIndex: number = 1
  private cartItemIds: number[] = []
  private payMethods: string[] = ['华为支付', '微信支付', '支付宝', '余额']

  aboutToAppear(): void {
    const params = router.getParams() as OrderConfirmParams
    this.cartItemIds = params?.cartItemIds ?? []
    this.loadItems()
  }

  async loadItems() {
    try {
      const all = await CartApi.list()
      const idSet = new Set<number>(this.cartItemIds)
      this.items = all.filter((i: CartItemModel) => idSet.has(i.id))
    } catch (e) {
      this.items = []
    }
  }

  getTotalPrice(): number {
    return this.items.reduce((sum, i) => sum + i.price * i.count, 0)
  }

  async submit() {
    if (this.items.length === 0) {
      promptAction.showToast({ message: '没有可结算的商品' })
      return
    }
    try {
      const resp = await OrderApi.create(this.cartItemIds)
      if (resp.code !== 200) {
        promptAction.showToast({ message: resp.message || '下单失败' })
        return
      }
      const payResp = await OrderApi.pay(resp.data.id, this.payMethods[this.payIndex])
      if (payResp.code === 200) {
        promptAction.showToast({ message: '支付成功' })
        router.back()
      } else {
        promptAction.showToast({ message: payResp.message || '支付失败' })
      }
    } catch (e) {
      promptAction.showToast({ message: '网络请求失败，请检查后端地址' })
    }
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.back')).width(22).height(22)
          .onClick(() => { router.back() })
        Text('确认订单')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Blank().width(22)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      .backgroundColor('#fff')

      Scroll() {
        Column({ space: 12 }) {
          Column({ space: 10 }) {
            Text('商品清单')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333')
              .width('100%')
            ForEach(this.items, (item: CartItemModel) => {
              Row({ space: 10 }) {
                Image(imageResource(item.image))
                  .width(60).height(60)
                  .objectFit(ImageFit.Contain)
                  .backgroundColor('#F7F7F7')
                  .borderRadius(6)
                Column({ space: 4 }) {
                  Text(item.name)
                    .fontSize(13)
                    .fontColor('#333')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .width('100%')
                  Text('¥' + item.price.toFixed(2) + ' × ' + item.count)
                    .fontSize(12)
                    .fontColor('#999')
                    .width('100%')
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
            }, (item: CartItemModel) => item.id.toString())
          }
          .width('100%')
          .padding(14)
          .backgroundColor('#fff')
          .borderRadius(10)

          Column({ space: 4 }) {
            Text('支付方式')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333')
              .width('100%')
              .margin({ bottom: 4 })
            ForEach(this.payMethods, (method: string, index: number) => {
              Row({ space: 10 }) {
                Text(method).fontSize(14).fontColor('#333').layoutWeight(1)
                Text(this.payIndex === index ? '●' : '○')
                  .fontSize(18)
                  .fontColor(this.payIndex === index ? '#1A5FD6' : '#ccc')
              }
              .width('100%')
              .padding({ top: 12, bottom: 12 })
              .onClick(() => { this.payIndex = index })
            })
          }
          .width('100%')
          .padding(14)
          .backgroundColor('#fff')
          .borderRadius(10)

          Row() {
            Text('应付金额').fontSize(14).fontColor('#333')
            Blank()
            Text('¥' + this.getTotalPrice().toFixed(2))
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1A5FD6')
          }
          .width('100%')
          .padding(14)
          .backgroundColor('#fff')
          .borderRadius(10)
        }
        .width('100%')
        .padding(12)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .backgroundColor('#f5f5f5')

      Row() {
        Text('合计: ¥' + this.getTotalPrice().toFixed(2))
          .fontSize(15)
          .fontColor('#333')
        Blank()
        Button('立即支付')
          .width(120)
          .height(42)
          .fontColor('#fff')
          .backgroundColor('#1A5FD6')
          .borderRadius(21)
          .onClick(() => { this.submit() })
      }
      .width('100%')
      .height(60)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#fff')
      .border({ width: { top: 1 }, color: '#f0f0f0' })
    }
    .width('100%')
    .height('100%')
  }
}
