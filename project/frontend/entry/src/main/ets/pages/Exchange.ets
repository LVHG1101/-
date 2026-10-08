import { router } from '@kit.ArkUI'
import promptAction from '@ohos.promptAction'
import { ExchangeApi } from '../api/ExchangeApi'
import { ExchangeGoodsModel } from '../model/DataModels'
import { imageResource } from '../common/ImageUtil'
import { UserStore } from '../common/UserStore'

@CustomDialog
struct PublishExchangeDialog {
  controller?: CustomDialogController
  onPublish: (name: string, wantName: string, location: string) => void = () => {}
  @State name: string = ''
  @State wantName: string = ''
  @State location: string = ''

  build() {
    Column({ space: 12 }) {
      Text('发布换物').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#333')
      TextInput({ placeholder: '换出物品（如：iPhone 13）' })
        .height(42)
        .fontSize(14)
        .onChange((v: string) => { this.name = v })
      TextInput({ placeholder: '想换物品（如：iPad 或平板）' })
        .height(42)
        .fontSize(14)
        .onChange((v: string) => { this.wantName = v })
      TextInput({ placeholder: '位置（如：同城 / 附近 2km）' })
        .height(42)
        .fontSize(14)
        .onChange((v: string) => { this.location = v })
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
            if (this.name.trim() && this.wantName.trim()) {
              this.onPublish(this.name.trim(), this.wantName.trim(), this.location.trim() || '同城')
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

@CustomDialog
struct ApplyExchangeDialog {
  controller?: CustomDialogController
  exchangeName: string = ''
  onApply: (message: string) => void = () => {}
  @State message: string = ''

  build() {
    Column({ space: 12 }) {
      Text('申请换物').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#333')
      Text('对方换出：' + this.exchangeName).fontSize(13).fontColor('#999')
      TextArea({ placeholder: '留言（如：我可以用 XX 和你换，怎么联系）' })
        .height(90)
        .fontSize(14)
        .onChange((v: string) => { this.message = v })
      Row({ space: 12 }) {
        Button('取消')
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#f5f5f5')
          .fontColor('#333')
          .borderRadius(20)
          .onClick(() => { this.controller?.close() })
        Button('提交申请')
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#1A5FD6')
          .fontColor('#fff')
          .borderRadius(20)
          .onClick(() => {
            this.onApply(this.message.trim())
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
struct Exchange {
  @State exchanges: ExchangeGoodsModel[] = []
  private publishController: CustomDialogController | null = null
  private applyController: CustomDialogController | null = null

  aboutToAppear(): void {
    this.loadExchanges()
  }

  async loadExchanges() {
    try {
      this.exchanges = await ExchangeApi.list()
    } catch (e) {
      this.exchanges = []
    }
  }

  openPublishDialog() {
    this.publishController = new CustomDialogController({
      builder: PublishExchangeDialog({
        onPublish: (name: string, wantName: string, location: string) => {
          this.doPublish(name, wantName, location)
        }
      }),
      autoCancel: true
    })
    this.publishController.open()
  }

  openApplyDialog(item: ExchangeGoodsModel) {
    this.applyController = new CustomDialogController({
      builder: ApplyExchangeDialog({
        exchangeName: item.name,
        onApply: (message: string) => { this.doApply(item, message) }
      }),
      autoCancel: true
    })
    this.applyController.open()
  }

  async doPublish(name: string, wantName: string, location: string) {
    const isLoggedIn = await UserStore.isLoggedIn()
    if (!isLoggedIn) {
      promptAction.showToast({ message: '请先登录' })
      return
    }
    try {
      const resp = await ExchangeApi.publish(name, wantName, 'phone1', '', location)
      if (resp.code === 200) {
        promptAction.showToast({ message: '发布成功' })
        this.loadExchanges()
      } else {
        promptAction.showToast({ message: resp.message || '发布失败' })
      }
    } catch (e) {
      promptAction.showToast({ message: '网络请求失败' })
    }
  }

  async doApply(item: ExchangeGoodsModel, message: string) {
    const isLoggedIn = await UserStore.isLoggedIn()
    if (!isLoggedIn) {
      promptAction.showToast({ message: '请先登录' })
      return
    }
    try {
      const resp = await ExchangeApi.apply(item.id, message)
      if (resp.code === 200) {
        promptAction.showToast({ message: '申请已提交' })
      } else {
        promptAction.showToast({ message: resp.message || '申请失败' })
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
        Text('以物换物')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Text('发布换物')
          .fontSize(14)
          .fontColor('#1A5FD6')
          .onClick(() => { this.openPublishDialog() })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      .backgroundColor('#fff')

      if (this.exchanges.length === 0) {
        Column({ space: 12 }) {
          Text('🔄').fontSize(48)
          Text('暂无换物信息').fontSize(14).fontColor('#999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#f5f5f5')
      } else {
        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.exchanges, (item: ExchangeGoodsModel) => {
              Row({ space: 12 }) {
                Image(imageResource(item.image))
                  .width(72).height(72)
                  .objectFit(ImageFit.Contain)
                  .backgroundColor('#F5F5F5')
                  .borderRadius(8)
                Column({ space: 4 }) {
                  Text('换出：' + item.name)
                    .fontSize(14)
                    .fontColor('#333')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .width('100%')
                  Text('想换：' + item.wantName)
                    .fontSize(12)
                    .fontColor('#1A5FD6')
                    .width('100%')
                  if (item.owner) {
                    Text(item.owner + ' · ' + item.location)
                      .fontSize(11)
                      .fontColor('#999')
                      .width('100%')
                  }
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)

                Button('申请换物')
                  .fontSize(12)
                  .height(30)
                  .fontColor('#fff')
                  .backgroundColor('#1A5FD6')
                  .borderRadius(15)
                  .onClick(() => { this.openApplyDialog(item) })
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#fff')
              .borderRadius(10)
            }, (item: ExchangeGoodsModel) => item.id.toString())
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
