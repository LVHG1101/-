import { router } from '@kit.ArkUI'
import promptAction from '@ohos.promptAction'
import { AddressApi, AddressModel } from '../api/AddressApi'

@CustomDialog
struct AddressEditDialog {
  controller?: CustomDialogController
  editItem: AddressModel | null = null
  onSave: (addr: AddressModel) => void = () => {}
  @State name: string = ''
  @State phone: string = ''
  @State province: string = ''
  @State detail: string = ''
  @State isDefault: boolean = false

  aboutToAppear(): void {
    if (this.editItem) {
      this.name = this.editItem.name
      this.phone = this.editItem.phone
      this.province = this.editItem.province
      this.detail = this.editItem.detail
      this.isDefault = this.editItem.isDefault
    }
  }

  build() {
    Column({ space: 12 }) {
      Text(this.editItem ? '编辑地址' : '新增地址').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#333')
      TextInput({ text: this.name, placeholder: '收货人姓名' })
        .height(42).fontSize(14)
        .onChange((v: string) => { this.name = v })
      TextInput({ text: this.phone, placeholder: '手机号' })
        .height(42).fontSize(14).type(InputType.PhoneNumber)
        .onChange((v: string) => { this.phone = v })
      TextInput({ text: this.province, placeholder: '省市区（如：浙江省杭州市西湖区）' })
        .height(42).fontSize(14)
        .onChange((v: string) => { this.province = v })
      TextInput({ text: this.detail, placeholder: '详细地址（街道、门牌号）' })
        .height(42).fontSize(14)
        .onChange((v: string) => { this.detail = v })
      Row() {
        Text('设为默认地址').fontSize(14).fontColor('#333')
        Blank()
        Toggle({ type: ToggleType.Switch, isOn: this.isDefault })
          .onChange((isOn: boolean) => { this.isDefault = isOn })
      }
      .width('100%')

      Row({ space: 12 }) {
        Button('取消')
          .layoutWeight(1).height(40).backgroundColor('#f5f5f5').fontColor('#333').borderRadius(20)
          .onClick(() => { this.controller?.close() })
        Button('保存')
          .layoutWeight(1).height(40).backgroundColor('#1A5FD6').fontColor('#fff').borderRadius(20)
          .onClick(() => {
            const addr = new AddressModel()
            addr.id = this.editItem ? this.editItem.id : 0
            addr.name = this.name.trim()
            addr.phone = this.phone.trim()
            addr.province = this.province.trim()
            addr.detail = this.detail.trim()
            addr.isDefault = this.isDefault
            this.onSave(addr)
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
struct Address {
  @State list: AddressModel[] = []
  @State isLoading: boolean = true
  @State loadError: string = ''
  private editController: CustomDialogController | null = null

  onPageShow(): void {
    this.load()
  }

  async load() {
    this.isLoading = true
    this.loadError = ''
    try {
      this.list = await AddressApi.list()
    } catch (e) {
      this.list = []
      this.loadError = '加载失败，请确认已登录'
    } finally {
      this.isLoading = false
    }
  }

  fullAddress(a: AddressModel): string {
    return (a.province || '') + (a.city || '') + (a.district || '') + (a.detail || '')
  }

  openEditDialog(item: AddressModel | null) {
    this.editController = new CustomDialogController({
      builder: AddressEditDialog({
        editItem: item,
        onSave: (addr: AddressModel) => { this.doSave(addr) }
      }),
      autoCancel: true
    })
    this.editController.open()
  }

  async doSave(addr: AddressModel) {
    if (!addr.name || !addr.phone) {
      promptAction.showToast({ message: '请填写姓名和手机号' })
      return
    }
    try {
      const resp = await AddressApi.save(addr)
      promptAction.showToast({ message: resp.code === 200 ? '保存成功' : (resp.message || '保存失败') })
      if (resp.code === 200) {
        this.load()
      }
    } catch (e) {
      promptAction.showToast({ message: '网络请求失败' })
    }
  }

  async doDelete(item: AddressModel) {
    try {
      const resp = await AddressApi.delete(item.id)
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
        Text('收货地址')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Text('新增')
          .fontSize(14)
          .fontColor('#1A5FD6')
          .onClick(() => { this.openEditDialog(null) })
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
          Text('📍').fontSize(48)
          Text('暂无收货地址').fontSize(14).fontColor('#999')
          Button('新增地址').fontSize(13).height(34)
            .backgroundColor('#1A5FD6').fontColor('#fff').borderRadius(17)
            .onClick(() => { this.openEditDialog(null) })
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.list, (item: AddressModel) => {
              Column({ space: 8 }) {
                Row() {
                  Text(item.name).fontSize(15).fontWeight(FontWeight.Bold).fontColor('#333')
                  Blank()
                  Text(item.phone).fontSize(14).fontColor('#666')
                  if (item.isDefault) {
                    Text('默认')
                      .fontSize(10).fontColor('#1A5FD6')
                      .border({ width: 1, color: '#1A5FD6' })
                      .padding({ left: 6, right: 6, top: 1, bottom: 1 })
                      .borderRadius(4)
                      .margin({ left: 8 })
                  }
                }
                .width('100%')

                Text(this.fullAddress(item))
                  .fontSize(13).fontColor('#666').width('100%')

                Row() {
                  Blank()
                  Button('删除')
                    .fontSize(12).height(30).backgroundColor('#F5F5F5').fontColor('#666').borderRadius(15)
                    .onClick(() => { this.doDelete(item) })
                  Button('编辑')
                    .fontSize(12).height(30).backgroundColor('#1A5FD6').fontColor('#fff').borderRadius(15)
                    .margin({ left: 8 })
                    .onClick(() => { this.openEditDialog(item) })
                }
                .width('100%')
              }
              .width('100%')
              .padding(14)
              .backgroundColor('#fff')
              .borderRadius(10)
            }, (item: AddressModel) => item.id.toString())
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
