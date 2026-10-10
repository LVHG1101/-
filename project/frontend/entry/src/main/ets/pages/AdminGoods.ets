import { router } from '@kit.ArkUI'
import promptAction from '@ohos.promptAction'
import { AdminApi } from '../api/AdminApi'
import { GoodsItemModel } from '../model/DataModels'
import { imageResource } from '../common/ImageUtil'

@Entry
@Component
struct AdminGoods {
  @State list: GoodsItemModel[] = []
  @State isLoading: boolean = true
  @State loadError: string = ''

  onPageShow(): void {
    this.load()
  }

  async load() {
    this.isLoading = true
    this.loadError = ''
    try {
      this.list = await AdminApi.goods()
    } catch (e) {
      this.list = []
      this.loadError = '加载失败，请确认当前账号为管理员'
    } finally {
      this.isLoading = false
    }
  }

  async doOffline(item: GoodsItemModel) {
    try {
      const resp = await AdminApi.offlineGoods(item.id)
      promptAction.showToast({ message: resp.code === 200 ? '已下架' : (resp.message || '操作失败') })
      if (resp.code === 200) {
        this.load()
      }
    } catch (e) {
      promptAction.showToast({ message: '网络请求失败' })
    }
  }

  async doDelete(item: GoodsItemModel) {
    try {
      const resp = await AdminApi.deleteGoods(item.id)
      promptAction.showToast({ message: resp.code === 200 ? '已删除' : (resp.message || '删除失败') })
      if (resp.code === 200) {
        this.load()
      }
    } catch (e) {
      promptAction.showToast({ message: '网络请求失败' })
    }
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.back')).width(22).height(22)
          .onClick(() => { router.back() })
        Text('商品审核')
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
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else if (this.loadError !== '') {
        Column({ space: 12 }) {
          Text(this.loadError).fontSize(14).fontColor('#999')
          Button('重新加载').fontSize(13).height(34)
            .backgroundColor('#1A5FD6').fontColor('#fff').borderRadius(17)
            .onClick(() => { this.load() })
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else if (this.list.length === 0) {
        Column({ space: 12 }) {
          Text('📦').fontSize(48)
          Text('暂无商品').fontSize(14).fontColor('#999')
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.list, (item: GoodsItemModel) => {
              Column({ space: 8 }) {
                Row({ space: 12 }) {
                  Image(imageResource(item.image))
                    .width(72).height(72)
                    .objectFit(ImageFit.Contain)
                    .backgroundColor('#F5F5F5')
                    .borderRadius(8)
                  Column({ space: 4 }) {
                    Row() {
                      Text(item.name)
                        .fontSize(14)
                        .fontColor('#333')
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .layoutWeight(1)
                      if (item.enabled === false) {
                        Text('已下架')
                          .fontSize(10)
                          .fontColor('#999')
                          .backgroundColor('#F0F0F0')
                          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                          .borderRadius(4)
                          .margin({ left: 6 })
                      }
                    }
                    .width('100%')

                    Text('¥' + item.price)
                      .fontSize(15)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#e0620d')
                      .width('100%')
                    Text('卖家：' + (item.sellerName || '未知'))
                      .fontSize(11)
                      .fontColor('#999')
                      .width('100%')
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                }
                .width('100%')

                Row() {
                  Blank()
                  Button('删除')
                    .fontSize(12).height(30)
                    .backgroundColor('#F5F5F5').fontColor('#666').borderRadius(15)
                    .onClick(() => { this.doDelete(item) })
                  if (item.enabled !== false) {
                    Button('下架')
                      .fontSize(12).height(30)
                      .backgroundColor('#e0620d').fontColor('#fff').borderRadius(15)
                      .margin({ left: 8 })
                      .onClick(() => { this.doOffline(item) })
                  }
                }
                .width('100%')
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#fff')
              .borderRadius(10)
            }, (item: GoodsItemModel) => item.id.toString())
          }
          .width('100%')
          .padding(12)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .backgroundColor('#f5f5f5')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}
