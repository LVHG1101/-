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
  @State isLoading: boolean = true
  @State loadError: string = ''
  private goodsId: number = 0

  aboutToAppear(): void {
    const params = router.getParams() as GoodsDetailParams
    this.goodsId = params?.goodsId ?? 0
    this.loadGoods()
  }

  async loadGoods() {
    this.isLoading = true
    this.loadError = ''

    if (this.goodsId <= 0) {
      this.isLoading = false
      this.loadError = '没有找到商品（缺少商品编号）'
      return
    }

    try {
      const item = await GoodsApi.detail(this.goodsId)
      if (item && item.id > 0) {
        this.goods = item
      } else {
        this.loadError = '商品不存在或已下架'
      }
    } catch (e) {
      this.loadError = '网络请求失败，请确认后端已启动'
    } finally {
      this.isLoading = false
    }
  }

  /** 卖家信誉分文本，避免在 UI 里对可选字段做非空断言 */
  sellerCreditText(): string {
    const s = this.goods.sellerCredit
    return s === undefined ? '--' : s.toString()
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

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(44).height(44).color('#1A5FD6')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#f5f5f5')
      } else if (this.loadError !== '') {
        Column({ space: 14 }) {
          Text(this.loadError)
            .fontSize(14)
            .fontColor('#999')
          Button('重新加载')
            .fontSize(13)
            .height(34)
            .backgroundColor('#1A5FD6')
            .fontColor('#fff')
            .borderRadius(17)
            .padding({ left: 20, right: 20 })
            .onClick(() => { this.loadGoods() })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#f5f5f5')
      } else {
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
                Text('¥' + this.goods.price.toFixed(2))
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1A5FD6')
                Blank()
                if (this.goods.quality) {
                  Text(this.goods.quality)
                    .fontSize(13)
                    .fontColor('#1A5FD6')
                    .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                    .border({ width: 1, color: '#1A5FD6' })
                    .borderRadius(12)
                }
              }
              .width('100%')

              Text(this.goods.name)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333')
                .width('100%')

              if (this.goods.lowCredit) {
                Row({ space: 6 }) {
                  Text('⚠')
                    .fontSize(13)
                    .fontColor('#D93025')
                  Text('该卖家信誉分较低（' + this.sellerCreditText() + ' 分），交易请谨慎')
                    .fontSize(12)
                    .fontColor('#D93025')
                    .layoutWeight(1)
                }
                .width('100%')
                .padding(8)
                .backgroundColor('#FDECEA')
                .borderRadius(6)
              }

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
    }
    .width('100%')
    .height('100%')
  }
}
