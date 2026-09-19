import { router } from '@kit.ArkUI'
import promptAction from '@ohos.promptAction'
import { AdminApi } from '../api/AdminApi'
import { ServiceItemModel } from '../model/DataModels'

@Entry
@Component
struct AdminService {
  @State list: ServiceItemModel[] = []
  @State isLoading: boolean = true
  @State loadError: string = ''

  // 编辑表单
  @State editing: boolean = false
  @State editId: number = 0
  @State formName: string = ''
  @State formIcon: string = ''
  @State formDesc: string = ''
  @State formPrice: string = ''
  @State formEnabled: boolean = true

  onPageShow(): void {
    this.load()
  }

  async load() {
    this.isLoading = true
    this.loadError = ''
    try {
      this.list = await AdminApi.services()
    } catch (e) {
      this.list = []
      this.loadError = '加载失败，请确认后端已启动且当前账号为管理员'
    } finally {
      this.isLoading = false
    }
  }

  openNew() {
    this.editId = 0
    this.formName = ''
    this.formIcon = ''
    this.formDesc = ''
    this.formPrice = '0'
    this.formEnabled = true
    this.editing = true
  }

  openEdit(item: ServiceItemModel) {
    this.editId = item.id
    this.formName = item.name
    this.formIcon = item.icon
    this.formDesc = item.description
    this.formPrice = item.price.toString()
    this.formEnabled = item.enabled
    this.editing = true
  }

  async save() {
    if (!this.formName.trim()) {
      promptAction.showToast({ message: '服务名称不能为空' })
      return
    }
    const price = Number(this.formPrice)
    if (isNaN(price) || price < 0) {
      promptAction.showToast({ message: '价格必须是不小于 0 的数字' })
      return
    }
    try {
      const resp = await AdminApi.saveService(this.editId, '', this.formName.trim(),
        this.formIcon.trim(), this.formDesc.trim(), price, this.formEnabled)
      if (resp.code === 200) {
        promptAction.showToast({ message: '保存成功' })
        this.editing = false
        this.load()
      } else {
        promptAction.showToast({ message: resp.message || '保存失败' })
      }
    } catch (e) {
      promptAction.showToast({ message: '网络请求失败' })
    }
  }

  async toggle(item: ServiceItemModel) {
    try {
      const resp = await AdminApi.toggleService(item.id)
      if (resp.code === 200) {
        promptAction.showToast({ message: resp.message || '已更新' })
        this.load()
      } else {
        promptAction.showToast({ message: resp.message || '操作失败' })
      }
    } catch (e) {
      promptAction.showToast({ message: '网络请求失败' })
    }
  }

  async remove(item: ServiceItemModel) {
    try {
      const resp = await AdminApi.deleteService(item.id)
      if (resp.code === 200) {
        promptAction.showToast({ message: '已删除' })
        this.load()
      } else {
        promptAction.showToast({ message: resp.message || '删除失败' })
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
        Text('服务项目管理')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Text('新增')
          .fontSize(14)
          .fontColor('#1A5FD6')
          .onClick(() => { this.openNew() })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      .backgroundColor('#fff')

      if (this.editing) {
        Scroll() {
          Column({ space: 12 }) {
            Text(this.editId > 0 ? '编辑服务项' : '新增服务项')
              .fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333').width('100%')

            TextInput({ placeholder: '服务名称，如：上门回收', text: this.formName })
              .height(44).borderRadius(8).backgroundColor('#F5F5F5')
              .onChange((v: string) => { this.formName = v })

            TextInput({ placeholder: '图标（单个字符或 emoji，可留空）', text: this.formIcon })
              .height(44).borderRadius(8).backgroundColor('#F5F5F5')
              .onChange((v: string) => { this.formIcon = v })

            TextInput({ placeholder: '参考价/起价（元）', text: this.formPrice })
              .type(InputType.Number)
              .height(44).borderRadius(8).backgroundColor('#F5F5F5')
              .onChange((v: string) => { this.formPrice = v })

            TextArea({ placeholder: '服务说明', text: this.formDesc })
              .height(90).borderRadius(8).backgroundColor('#F5F5F5')
              .onChange((v: string) => { this.formDesc = v })

            Row() {
              Text('上架状态').fontSize(14).fontColor('#333')
              Blank()
              Toggle({ type: ToggleType.Switch, isOn: this.formEnabled })
                .onChange((on: boolean) => { this.formEnabled = on })
            }
            .width('100%')

            Row({ space: 12 }) {
              Button('取消')
                .layoutWeight(1).height(44)
                .backgroundColor('#F5F5F5').fontColor('#666').borderRadius(22)
                .onClick(() => { this.editing = false })
              Button('保存')
                .layoutWeight(1).height(44)
                .backgroundColor('#1A5FD6').fontColor('#fff').borderRadius(22)
                .onClick(() => { this.save() })
            }
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#fff')
          .borderRadius(10)
        }
        .layoutWeight(1)
        .padding(12)
        .backgroundColor('#f5f5f5')
      } else if (this.isLoading) {
        Column() { LoadingProgress().width(40).height(40).color('#1A5FD6') }
          .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else if (this.loadError !== '') {
        Column({ space: 12 }) {
          Text(this.loadError).fontSize(13).fontColor('#999').textAlign(TextAlign.Center)
          Button('重新加载').fontSize(13).height(34)
            .backgroundColor('#1A5FD6').fontColor('#fff').borderRadius(17)
            .onClick(() => { this.load() })
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center).padding(24)
      } else {
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.list, (item: ServiceItemModel) => {
              Column({ space: 8 }) {
                Row({ space: 8 }) {
                  Text(item.icon ? item.icon : '服')
                    .fontSize(16)
                    .width(34).height(34)
                    .textAlign(TextAlign.Center)
                    .backgroundColor('#EAF2FF')
                    .borderRadius(17)
                  Column({ space: 2 }) {
                    Text(item.name)
                      .fontSize(15).fontWeight(FontWeight.Bold).fontColor('#333')
                    Text('¥' + item.price.toFixed(2) + ' 起')
                      .fontSize(12).fontColor('#e0620d')
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                  Text(item.enabled ? '已上架' : '已下架')
                    .fontSize(11)
                    .fontColor(item.enabled ? '#1A5FD6' : '#999')
                    .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                    .border({ width: 1, color: item.enabled ? '#1A5FD6' : '#ccc' })
                    .borderRadius(10)
                }
                .width('100%')

                Text(item.description)
                  .fontSize(12).fontColor('#666').width('100%')

                Row({ space: 10 }) {
                  Blank()
                  Button(item.enabled ? '下架' : '上架')
                    .fontSize(12).height(32)
                    .backgroundColor('#F5F5F5').fontColor('#666')
                    .borderRadius(16).padding({ left: 14, right: 14 })
                    .onClick(() => { this.toggle(item) })
                  Button('编辑')
                    .fontSize(12).height(32)
                    .backgroundColor('#EAF2FF').fontColor('#1A5FD6')
                    .borderRadius(16).padding({ left: 14, right: 14 })
                    .onClick(() => { this.openEdit(item) })
                  Button('删除')
                    .fontSize(12).height(32)
                    .backgroundColor('#FFF3E8').fontColor('#e0620d')
                    .borderRadius(16).padding({ left: 14, right: 14 })
                    .onClick(() => { this.remove(item) })
                }
                .width('100%')
              }
              .width('100%')
              .padding(14)
              .backgroundColor('#fff')
              .borderRadius(8)
            }, (item: ServiceItemModel) => item.id.toString())
          }
          .padding(12)
        }
        .layoutWeight(1)
        .backgroundColor('#f5f5f5')
      }
    }
    .width('100%')
    .height('100%')
  }
}
