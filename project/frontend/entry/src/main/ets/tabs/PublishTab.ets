import promptAction from '@ohos.promptAction'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { cameraPicker, camera } from '@kit.CameraKit'
import { fileIo as fs } from '@kit.CoreFileKit'
import { util } from '@kit.ArkTS'
import { CategoryApi } from '../api/CategoryApi'
import { GoodsApi } from '../api/GoodsApi'
import { HttpUtil } from '../common/HttpUtil'
import { parseJson } from '../common/JsonHelper.js'
import { CategoryItemModel } from '../model/DataModels'

class UploadResult {
  code: number = 0
  message: string = ''
  data: string = ''
}

class UploadBody {
  base64: string = ''
}

@Builder
export function buildPublishTab() {
  PublishTab()
}

@Component
export struct PublishTab {
  @State name: string = ''
  @State description: string = ''
  @State price: string = ''
  @State qualityIndex: number = 1
  @State categoryIndex: number = 0
  @State categories: CategoryItemModel[] = []
  @State isSubmitting: boolean = false
  @State previewUri: string = ''
  @State uploadedImage: string = ''

  private qualities: string[] = ['全新', '几乎全新', '轻微使用痕迹', '明显使用痕迹', '严重使用痕迹']

  aboutToAppear(): void {
    this.loadCategories()
  }

  async loadCategories() {
    try {
      this.categories = await CategoryApi.list()
    } catch (e) {
      this.categories = []
    }
  }

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
      return this.uploadedImage
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
        this.uploadedImage = result.data
        return result.data
      }
      return ''
    } catch (e) {
      return ''
    }
  }

  async submit() {
    if (!this.name.trim()) {
      promptAction.showToast({ message: '请填写商品名称' })
      return
    }
    if (!this.price.trim()) {
      promptAction.showToast({ message: '请填写价格' })
      return
    }
    const priceNum = Number(this.price)
    if (isNaN(priceNum) || priceNum <= 0) {
      promptAction.showToast({ message: '请输入正确的价格' })
      return
    }
    if (this.categories.length === 0) {
      promptAction.showToast({ message: '分类加载失败，请检查后端' })
      return
    }
    this.isSubmitting = true
    try {
      const imageName = await this.uploadImage()
      const finalImage = imageName || 'phone1'
      const resp = await GoodsApi.publish(
        this.name.trim(),
        priceNum,
        finalImage,
        this.qualities[this.qualityIndex],
        this.description.trim(),
        this.categories[this.categoryIndex].id
      )
      if (resp.code === 200) {
        promptAction.showToast({ message: '发布成功' })
        this.name = ''
        this.description = ''
        this.price = ''
        this.previewUri = ''
        this.uploadedImage = ''
      } else if (resp.code === 401) {
        promptAction.showToast({ message: '请先登录' })
      } else {
        promptAction.showToast({ message: resp.message || '发布失败' })
      }
    } catch (e) {
      promptAction.showToast({ message: '网络请求失败，请检查后端地址' })
    } finally {
      this.isSubmitting = false
    }
  }

  build() {
    Column() {
      Row() {
        Text('发布闲置')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 14 })
      .backgroundColor('#fff')

      Scroll() {
        Column({ space: 12 }) {
          Column({ space: 6 }) {
            Text('商品名称').fontSize(14).fontColor('#333').width('100%')
            TextInput({ placeholder: '请输入商品名称' })
              .height(44)
              .fontSize(14)
              .onChange((v: string) => { this.name = v })
          }
          .width('100%')
          .padding(14)
          .backgroundColor('#fff')
          .borderRadius(10)

          Column({ space: 6 }) {
            Text('价格（元）').fontSize(14).fontColor('#333').width('100%')
            TextInput({ placeholder: '请输入价格' })
              .height(44)
              .fontSize(14)
              .type(InputType.Number)
              .onChange((v: string) => { this.price = v })
          }
          .width('100%')
          .padding(14)
          .backgroundColor('#fff')
          .borderRadius(10)

          Column({ space: 8 }) {
            Text('成色').fontSize(14).fontColor('#333').width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.qualities, (q: string, index: number) => {
                Text(q)
                  .fontSize(13)
                  .fontColor(this.qualityIndex === index ? '#fff' : '#666')
                  .backgroundColor(this.qualityIndex === index ? '#1A5FD6' : '#f5f5f5')
                  .padding({ left: 14, right: 14, top: 6, bottom: 6 })
                  .borderRadius(16)
                  .margin({ right: 8, bottom: 8 })
                  .onClick(() => { this.qualityIndex = index })
              })
            }
            .width('100%')
          }
          .width('100%')
          .padding(14)
          .backgroundColor('#fff')
          .borderRadius(10)

          Column({ space: 8 }) {
            Text('分类').fontSize(14).fontColor('#333').width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.categories, (c: CategoryItemModel, index: number) => {
                Text(c.name)
                  .fontSize(13)
                  .fontColor(this.categoryIndex === index ? '#fff' : '#666')
                  .backgroundColor(this.categoryIndex === index ? '#1A5FD6' : '#f5f5f5')
                  .padding({ left: 14, right: 14, top: 6, bottom: 6 })
                  .borderRadius(16)
                  .margin({ right: 8, bottom: 8 })
                  .onClick(() => { this.categoryIndex = index })
              })
            }
            .width('100%')
          }
          .width('100%')
          .padding(14)
          .backgroundColor('#fff')
          .borderRadius(10)

          Column({ space: 10 }) {
            Text('商品图片').fontSize(14).fontColor('#333').width('100%')
            Row({ space: 12 }) {
              Button('📷 拍照')
                .fontSize(14)
                .height(36)
                .fontColor('#fff')
                .backgroundColor('#1A5FD6')
                .borderRadius(18)
                .onClick(() => { this.takePhoto() })
              Button('🖼 相册')
                .fontSize(14)
                .height(36)
                .fontColor('#1A5FD6')
                .backgroundColor('#fff')
                .border({ width: 1, color: '#1A5FD6' })
                .borderRadius(18)
                .onClick(() => { this.selectFromAlbum() })
            }
            .width('100%')

            if (this.previewUri) {
              Image(this.previewUri)
                .width(120)
                .height(120)
                .objectFit(ImageFit.Cover)
                .borderRadius(10)
            }
          }
          .width('100%')
          .padding(14)
          .backgroundColor('#fff')
          .borderRadius(10)

          Column({ space: 6 }) {
            Text('商品描述').fontSize(14).fontColor('#333').width('100%')
            TextArea({ placeholder: '描述一下你的闲置物品（成色、购买时间、使用情况等）' })
              .height(100)
              .fontSize(14)
              .onChange((v: string) => { this.description = v })
          }
          .width('100%')
          .padding(14)
          .backgroundColor('#fff')
          .borderRadius(10)

          Button(this.isSubmitting ? '发布中...' : '发布')
            .width('100%')
            .height(46)
            .fontColor('#fff')
            .backgroundColor('#1A5FD6')
            .borderRadius(23)
            .enabled(!this.isSubmitting)
            .margin({ top: 4, bottom: 30 })
            .onClick(() => { this.submit() })
        }
        .width('100%')
        .padding(12)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .backgroundColor('#f5f5f5')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}
