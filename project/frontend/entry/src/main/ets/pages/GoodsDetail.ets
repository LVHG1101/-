import { router } from '@kit.ArkUI'
import promptAction from '@ohos.promptAction'
import { GoodsApi } from '../api/GoodsApi'
import { CartApi } from '../api/CartApi'
import { GoodsItemModel } from '../model/DataModels'
import { imageResource } from '../common/ImageUtil'

interface GoodsDetailParams {
  goodsId: number
}

@Entry
@Component
struct GoodsDetail {
  @State goods: GoodsItemModel = { id: 0, name: '', price: 0, image: '', quality: '', categoryId: 0 }
  private goodsId: number = 0

  aboutToAppear(): void {
    const params = router.getParams() as GoodsDetailParams
    this.goodsId = params?.goodsId ?? 0
    this.loadGoods()
  }

  async loadGoods() {
    try {
      const item = await GoodsApi.detail(this.goodsId)
      if (item) {
        this.goods = item
      }
    } catch (e) {
    }
  }

  addToCart() {
    CartApi.add(this.goodsId).then((resp) => {
      if (resp.code === 200) {
        promptAction.showToast({ message: '已加入购物车' })
      } else if (resp.code === 401) {
        promptAction.showToast({ message: '请先登录' })
      } else {
        promptAction.showToast({ message: resp.message || '加入失败' })
      }
    }).catch(() => {
      promptAction.showToast({ message: '网络请求失败' })
    })
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.back')).width(22).height(22)
          .onClick(() => { router.back() })
        Text('商品详情')
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
          Image(imageResource(this.goods.image))
            .width('100%')
            .height(280)
            .objectFit(ImageFit.Contain)
            .backgroundColor('#F7F7F7')
            .borderRadius(10)

          Column({ space: 10 }) {
            Row() {
              Text('¥' + this.goods.price)
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1A5FD6')
              Blank()
              Text(this.goods.quality)
                .fontSize(13)
                .fontColor('#1A5FD6')
                .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                .border({ width: 1, color: '#1A5FD6' })
                .borderRadius(12)
            }
            .width('100%')

            Text(this.goods.name)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333')
              .width('100%')

            if (this.goods.description) {
              Text('商品描述')
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333')
                .width('100%')
                .margin({ top: 8 })
              Text(this.goods.description)
                .fontSize(13)
                .fontColor('#666')
                .width('100%')
            }
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
        Button('加入购物车')
          .width('100%')
          .height(46)
          .fontColor('#fff')
          .backgroundColor('#1A5FD6')
          .borderRadius(23)
          .onClick(() => { this.addToCart() })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 10, bottom: 10 })
      .backgroundColor('#fff')
    }
    .width('100%')
    .height('100%')
  }
}
