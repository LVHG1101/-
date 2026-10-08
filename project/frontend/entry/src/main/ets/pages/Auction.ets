import { router } from '@kit.ArkUI'
import promptAction from '@ohos.promptAction'
import { AuctionApi } from '../api/AuctionApi'
import { AuctionGoodsModel } from '../model/DataModels'
import { imageResource } from '../common/ImageUtil'
import { UserStore } from '../common/UserStore'

@CustomDialog
struct BidDialog {
  controller?: CustomDialogController
  auctionName: string = ''
  currentPrice: number = 0
  onBid: (price: number) => void = () => {}
  @State price: string = ''

  build() {
    Column({ space: 14 }) {
      Text('出价').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#333')
      Text(this.auctionName).fontSize(14).fontColor('#333')
      Text('当前价 ¥' + this.currentPrice.toFixed(0)).fontSize(13).fontColor('#999')
      TextInput({ placeholder: '请输入出价（元）' })
        .type(InputType.Number)
        .height(44)
        .fontSize(14)
        .onChange((v: string) => { this.price = v })
      Row({ space: 12 }) {
        Button('取消')
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#f5f5f5')
          .fontColor('#333')
          .borderRadius(20)
          .onClick(() => { this.controller?.close() })
        Button('确认出价')
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#1A5FD6')
          .fontColor('#fff')
          .borderRadius(20)
          .onClick(() => {
            const p = Number(this.price)
            if (p > 0) {
              this.onBid(p)
            }
            this.controller?.close()
          })
      }
      .width('100%')
    }
    .padding(20)
    .width('80%')
  }
}

@CustomDialog
struct PublishAuctionDialog {
  controller?: CustomDialogController
  onPublish: (name: string, startPrice: number, hours: number) => void = () => {}
  @State name: string = ''
  @State startPrice: string = ''
  @State hours: number = 24

  build() {
    Column({ space: 12 }) {
      Text('发布拍卖').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#333')
      TextInput({ placeholder: '拍卖品名称' })
        .height(42)
        .fontSize(14)
        .onChange((v: string) => { this.name = v })
      TextInput({ placeholder: '起拍价（元）' })
        .type(InputType.Number)
        .height(42)
        .fontSize(14)
        .onChange((v: string) => { this.startPrice = v })
      Row({ space: 8 }) {
        Text('时长').fontSize(14).fontColor('#666')
        ForEach([12, 24, 48, 72], (h: number) => {
          Text(h + '小时')
            .fontSize(13)
            .fontColor(this.hours === h ? '#fff' : '#666')
            .backgroundColor(this.hours === h ? '#1A5FD6' : '#f5f5f5')
            .padding({ left: 12, right: 12, top: 5, bottom: 5 })
            .borderRadius(14)
            .onClick(() => { this.hours = h })
        })
      }
      .width('100%')
      Row({ space: 12 }) {
        Button('取消')
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#f5f5f5')
          .fontColor('#333')
          .borderRadius(20)
          .onClick(() => { this.controller?.close() })
        Button('发布')
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#1A5FD6')
          .fontColor('#fff')
          .borderRadius(20)
          .onClick(() => {
            const p = Number(this.startPrice)
            if (this.name.trim() && p > 0) {
              this.onPublish(this.name.trim(), p, this.hours)
            }
            this.controller?.close()
          })
      }
      .width('100%')
    }
    .padding(20)
    .width('85%')
  }
}

@Entry
@Component
struct Auction {
  @State auctions: AuctionGoodsModel[] = []
  private bidDialogController: CustomDialogController | null = null
  private publishDialogController: CustomDialogController | null = null

  aboutToAppear(): void {
    this.loadAuctions()
  }

  async loadAuctions() {
    try {
      this.auctions = await AuctionApi.list()
    } catch (e) {
      this.auctions = []
    }
  }

  formatCountdown(endTime: number): string {
    const diff = endTime - Date.now()
    if (diff <= 0) {
      return '已结束'
    }
    const hours = Math.floor(diff / (60 * 60 * 1000))
    const minutes = Math.floor((diff % (60 * 60 * 1000)) / (60 * 1000))
    if (hours > 0) {
      return '剩余 ' + hours + '小时' + minutes + '分'
    }
    return '剩余 ' + minutes + '分钟'
  }

  openBidDialog(item: AuctionGoodsModel) {
    this.bidDialogController = new CustomDialogController({
      builder: BidDialog({
        auctionName: item.name,
        currentPrice: item.currentPrice,
        onBid: (price: number) => { this.doBid(item, price) }
      }),
      autoCancel: true
    })
    this.bidDialogController.open()
  }

  openPublishDialog() {
    this.publishDialogController = new CustomDialogController({
      builder: PublishAuctionDialog({
        onPublish: (name: string, startPrice: number, hours: number) => {
          this.doPublish(name, startPrice, hours)
        }
      }),
      autoCancel: true
    })
    this.publishDialogController.open()
  }

  async doBid(item: AuctionGoodsModel, price: number) {
    try {
      const resp = await AuctionApi.bid(item.id, price)
      if (resp.code === 200) {
        promptAction.showToast({ message: '出价成功' })
        this.loadAuctions()
      } else if (resp.code === 401) {
        promptAction.showToast({ message: '请先登录' })
      } else {
        promptAction.showToast({ message: resp.message || '出价失败' })
      }
    } catch (e) {
      promptAction.showToast({ message: '网络请求失败' })
    }
  }

  async doPublish(name: string, startPrice: number, hours: number) {
    const isLoggedIn = await UserStore.isLoggedIn()
    if (!isLoggedIn) {
      promptAction.showToast({ message: '请先登录' })
      return
    }
    try {
      const endTime = Date.now() + hours * 60 * 60 * 1000
      const resp = await AuctionApi.publish(name, 'phone1', startPrice, endTime)
      if (resp.code === 200) {
        promptAction.showToast({ message: '发布成功' })
        this.loadAuctions()
      } else {
        promptAction.showToast({ message: resp.message || '发布失败' })
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
        Text('拍卖专场')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Text('发布拍卖')
          .fontSize(14)
          .fontColor('#1A5FD6')
          .onClick(() => { this.openPublishDialog() })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      .backgroundColor('#fff')

      if (this.auctions.length === 0) {
        Column({ space: 12 }) {
          Text('🔨').fontSize(48)
          Text('暂无拍卖中的商品').fontSize(14).fontColor('#999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#f5f5f5')
      } else {
        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.auctions, (item: AuctionGoodsModel) => {
              Column({ space: 8 }) {
                Row({ space: 12 }) {
                  Image(imageResource(item.image))
                    .width(80).height(80)
                    .objectFit(ImageFit.Contain)
                    .backgroundColor('#F5F5F5')
                    .borderRadius(8)
                  Column({ space: 4 }) {
                    Text(item.name)
                      .fontSize(15)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#333')
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .width('100%')
                    Row() {
                      Text('当前价 ')
                        .fontSize(12)
                        .fontColor('#999')
                      Text('¥' + item.currentPrice.toFixed(0))
                        .fontSize(18)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#1A5FD6')
                    }
                    .width('100%')
                    Text('起拍价 ¥' + item.startPrice.toFixed(0) + ' · ' + item.bidCount + ' 次出价')
                      .fontSize(11)
                      .fontColor('#999')
                      .width('100%')
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)

                  Column({ space: 4 }) {
                    Text(this.formatCountdown(item.endTime))
                      .fontSize(11)
                      .fontColor('#1A5FD6')
                    Button('出价')
                      .fontSize(12)
                      .height(30)
                      .fontColor('#fff')
                      .backgroundColor('#1A5FD6')
                      .borderRadius(15)
                      .onClick(() => { this.openBidDialog(item) })
                  }
                  .alignItems(HorizontalAlign.End)
                }
                .width('100%')
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#fff')
              .borderRadius(10)
            }, (item: AuctionGoodsModel) => item.id.toString())
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
