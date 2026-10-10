import { router } from '@kit.ArkUI'
import promptAction from '@ohos.promptAction'
import { FavoriteApi, FavoriteModel } from '../api/FavoriteApi'
import { imageResource } from '../common/ImageUtil'

@Entry
@Component
struct Favorites {
  @State list: FavoriteModel[] = []
  @State isLoading: boolean = true
  @State loadError: string = ''

  onPageShow(): void {
    this.load()
  }

  async load() {
    this.isLoading = true
    this.loadError = ''
    try {
      this.list = await FavoriteApi.list()
    } catch (e) {
      this.list = []
      this.loadError = '加载失败，请确认已登录'
    } finally {
      this.isLoading = false
    }
  }

  async remove(item: FavoriteModel) {
    try {
      const resp = await FavoriteApi.remove(item.goodsId)
      promptAction.showToast({ message: resp.code === 200 ? '已取消收藏' : (resp.message || '操作失败') })
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
        Text('我的收藏')
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
          Text('⭐').fontSize(48)
          Text('暂无收藏').fontSize(14).fontColor('#999')
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.list, (item: FavoriteModel) => {
              Row({ space: 12 }) {
                Image(imageResource(item.image))
                  .width(72).height(72)
                  .objectFit(ImageFit.Contain)
                  .backgroundColor('#F5F5F5')
                  .borderRadius(8)
                Column({ space: 4 }) {
                  Text(item.name)
                    .fontSize(14)
                    .fontColor('#333')
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .width('100%')
                  Text('¥' + item.price)
                    .fontSize(15)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#e0620d')
                    .width('100%')
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)

                Button('取消收藏')
                  .fontSize(12)
                  .height(30)
                  .fontColor('#666')
                  .backgroundColor('#F5F5F5')
                  .borderRadius(15)
                  .onClick(() => { this.remove(item) })
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#fff')
              .borderRadius(10)
              .onClick(() => { router.pushUrl({ url: 'pages/GoodsDetail', params: { goodsId: item.goodsId } }) })
            }, (item: FavoriteModel) => item.id.toString())
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
