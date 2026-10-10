import { router } from '@kit.ArkUI'
import promptAction from '@ohos.promptAction'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { cameraPicker, camera } from '@kit.CameraKit'
import { fileIo as fs } from '@kit.CoreFileKit'
import { util } from '@kit.ArkTS'
import { ExchangeApi } from '../api/ExchangeApi'
import { ExchangeGoodsModel } from '../model/DataModels'
import { imageResource } from '../common/ImageUtil'
import { UserStore } from '../common/UserStore'
import { HttpUtil } from '../common/HttpUtil'
import { parseJson } from '../common/JsonHelper.js'

class UploadResult {
  code: number = 0
  message: string = ''
  data: string = ''
}

class UploadBody {
  base64: string = ''
}

@CustomDialog
struct PublishExchangeDialog {
  controller?: CustomDialogController
  onPublish: (name: string, image: string, wantName: string, description: string, location: string) => void = () => {}
  @State name: string = ''
  @State wantName: string = ''
  @State description: string = ''
  @State location: string = ''
  @State previewUri: string = ''
  @State submitting: boolean = false

  async takePhoto() {
    try {
      const profile: cameraPicker.PickerProfile = {
        cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK
      }
      const result = await cameraPicker.pick(getContext(this), [cameraPicker.PickerMediaType.PHOTO], profile)
      if (result.resultUri) {
        this.previewUri = result.resultUri
      }
    } catch (e) {
      promptAction.showToast({ message: '拍照失败' })
    }
  }

  async selectFromAlbum() {
    try {
      const options = new photoAccessHelper.PhotoSelectOptions()
      options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
      options.maxSelectNumber = 1
      const picker = new photoAccessHelper.PhotoViewPicker()
      const result = await picker.select(options)
      if (result.photoUris.length > 0) {
        this.previewUri = result.photoUris[0]
      }
    } catch (e) {
      promptAction.showToast({ message: '选择图片失败' })
    }
  }

  async uploadImage(): Promise<string> {
    if (!this.previewUri) {
      return 'phone1'
    }
    try {
      const file = fs.openSync(this.previewUri, fs.OpenMode.READ_ONLY)
      const stat = fs.statSync(this.previewUri)
      const buf = new ArrayBuffer(stat.size)
      fs.readSync(file.fd, buf)
      fs.closeSync(file)
      const helper = new util.Base64Helper()
      const base64 = helper.encodeToStringSync(new Uint8Array(buf))
      const body = new UploadBody()
      body.base64 = base64
      const json = await HttpUtil.post('/upload/image', body)
      const result = parseJson(json) as UploadResult
      if (result.code === 200) {
        return result.data
      }
      return 'phone1'
    } catch (e) {
      return 'phone1'
    }
  }

  async submit() {
    if (!this.name.trim()) {
      promptAction.showToast({ message: '请填写换出物品' })
      return
    }
    if (!this.previewUri) {
      promptAction.showToast({ message: '请上传物品图片' })
      return
    }
    if (!this.wantName.trim()) {
      promptAction.showToast({ message: '请填写想换物品' })
      return
    }
    if (!this.description.trim()) {
      promptAction.showToast({ message: '请填写换物描述' })
      return
    }
    this.submitting = true
    const image = await this.uploadImage()
    this.submitting = false
    this.onPublish(this.name.trim(), image, this.wantName.trim(), this.description.trim(), this.location.trim() || '同城')
    this.controller?.close()
  }

  build() {
    Column({ space: 12 }) {
      Text('发布换物').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#333')
      TextInput({ placeholder: '换出物品（如：iPhone 13）' })
        .height(42)
        .fontSize(14)
        .onChange((v: string) => { this.name = v })

      Column({ space: 8 }) {
        Text('物品图片').fontSize(14).fontColor('#333').width('100%')
        Row({ space: 10 }) {
          Button('📷 拍照')
            .fontSize(13).height(34)
            .backgroundColor('#1A5FD6').fontColor('#fff').borderRadius(17)
            .onClick(() => { this.takePhoto() })
          Button('🖼 相册')
            .fontSize(13).height(34)
            .backgroundColor('#fff').fontColor('#1A5FD6')
            .border({ width: 1, color: '#1A5FD6' }).borderRadius(17)
            .onClick(() => { this.selectFromAlbum() })
        }
        .width('100%')
        if (this.previewUri) {
          Image(this.previewUri).width(80).height(80).objectFit(ImageFit.Cover).borderRadius(8)
        }
      }
      .width('100%')

      TextInput({ placeholder: '想换物品（如：iPad 或平板）' })
        .height(42)
        .fontSize(14)
        .onChange((v: string) => { this.wantName = v })

      Column({ space: 6 }) {
        Text('描述').fontSize(14).fontColor('#333').width('100%')
        TextArea({ placeholder: '描述物品的成色、使用情况、期望等' })
          .height(70)
          .fontSize(14)
          .onChange((v: string) => { this.description = v })
      }
      .width('100%')

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
        Button(this.submitting ? '发布中...' : '发布')
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#1A5FD6')
          .fontColor('#fff')
          .borderRadius(20)
          .enabled(!this.submitting)
          .onClick(() => { this.submit() })
      }
      .width('100%')
    }
    .padding(20)
    .width('90%')
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
        onPublish: (name: string, image: string, wantName: string, description: string, location: string) => {
          this.doPublish(name, image, wantName, description, location)
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

  async doPublish(name: string, image: string, wantName: string, description: string, location: string) {
    const isLoggedIn = await UserStore.isLoggedIn()
    if (!isLoggedIn) {
      promptAction.showToast({ message: '请先登录' })
      return
    }
    try {
      const resp = await ExchangeApi.publish(name, wantName, image, description, '', location)
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
                  if (item.description) {
                    Text(item.description)
                      .fontSize(11)
                      .fontColor('#666')
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .width('100%')
                  }
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
