import { router } from '@kit.ArkUI'
import promptAction from '@ohos.promptAction'
import { ServiceApi } from '../api/ServiceApi'
import { ServiceItemModel } from '../model/DataModels'

function pad(n: number): string {
  return n < 10 ? '0' + n : '' + n
}

interface ServiceDetailParams {
  serviceId: number
}

@Entry
@Component
struct ServiceDetail {
  @State service: ServiceItemModel = {
    id: 0, code: '', name: '', icon: '🔧', description: '', price: 0, enabled: true
  }
  @State contactName: string = ''
  @State contactPhone: string = ''
  @State address: string = ''
  @State remark: string = ''
  @State dateStr: string = ''
  @State timeStr: string = ''
  @State isLoading: boolean = false
  private serviceId: number = 0
  private selectedDate: Date = new Date()
  private selectedTime: Date = new Date()

  aboutToAppear(): void {
    const params = router.getParams() as ServiceDetailParams
    this.serviceId = params?.serviceId ?? 0
    const now = new Date()
    this.dateStr = `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())}`
    this.timeStr = `${pad(now.getHours())}:${pad(now.getMinutes())}`
    this.loadService()
  }

  async loadService() {
    try {
      const item = await ServiceApi.detail(this.serviceId)
      if (item) {
        this.service = item
      }
    } catch (e) {
    }
  }

  async submit() {
    if (!this.contactName.trim()) {
      promptAction.showToast({ message: '请填写联系人' })
      return
    }
    if (!this.contactPhone.trim()) {
      promptAction.showToast({ message: '请填写联系方式' })
      return
    }
    if (!this.address.trim()) {
      promptAction.showToast({ message: '请填写服务地址' })
      return
    }
    this.isLoading = true
    try {
      const appointmentTime = `${this.dateStr} ${this.timeStr}`
      const resp = await ServiceApi.createOrder(
        this.serviceId, this.contactName.trim(), this.contactPhone.trim(),
        this.address.trim(), appointmentTime, this.remark.trim())
      if (resp.code === 200) {
        promptAction.showToast({ message: '预约成功' })
        router.replaceUrl({ url: 'pages/ServiceOrders' })
      } else {
        promptAction.showToast({ message: resp.message || '预约失败' })
      }
    } catch (e) {
      promptAction.showToast({ message: '网络请求失败，请检查后端地址' })
    } finally {
      this.isLoading = false
    }
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.back')).width(22).height(22)
          .onClick(() => { router.back() })
        Text('服务预约')
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
          // 服务信息
          Column({ space: 6 }) {
            Row({ space: 12 }) {
              Text(this.service.icon).fontSize(40)
              Column({ space: 4 }) {
                Text(this.service.name).fontSize(17).fontWeight(FontWeight.Bold).fontColor('#333')
                Text(this.service.description)
                  .fontSize(12)
                  .fontColor('#999')
                  .maxLines(3)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                if (this.service.price > 0) {
                  Text('参考价 ¥' + this.service.price.toFixed(2) + ' 起')
                    .fontSize(12)
                    .fontColor('#e0620d')
                }
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#fff')
          .borderRadius(10)

          // 预约时间
          Column({ space: 10 }) {
            Row() {
              Text('预约时间').fontSize(15).fontWeight(FontWeight.Medium).fontColor('#333')
              Blank()
              Text(`${this.dateStr} ${this.timeStr}`).fontSize(14).fontColor('#e0620d')
            }
            .width('100%')

            DatePicker({
              start: new Date('2020-1-1'),
              end: new Date('2030-12-31'),
              selected: this.selectedDate
            })
              .onDateChange((value: Date) => {
                this.dateStr = `${value.getFullYear()}-${pad(value.getMonth() + 1)}-${pad(value.getDate())}`
              })

            TimePicker({ selected: this.selectedTime })
              .onChange((value: TimePickerResult) => {
                this.timeStr = `${pad(value.hour)}:${pad(value.minute)}`
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#fff')
          .borderRadius(10)

          // 预约信息表单
          Column({ space: 12 }) {
            TextInput({ placeholder: '请输入联系人' })
              .height(44)
              .fontSize(14)
              .onChange((v: string) => { this.contactName = v })
            TextInput({ placeholder: '请输入联系方式' })
              .height(44)
              .fontSize(14)
              .onChange((v: string) => { this.contactPhone = v })
            TextInput({ placeholder: '请输入服务地址' })
              .height(44)
              .fontSize(14)
              .onChange((v: string) => { this.address = v })
            TextInput({ placeholder: '备注（选填）' })
              .height(44)
              .fontSize(14)
              .onChange((v: string) => { this.remark = v })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#fff')
          .borderRadius(10)

          Button(this.isLoading ? '提交中...' : '提交预约')
            .width('100%')
            .height(46)
            .fontColor('#fff')
            .backgroundColor('#e0620d')
            .borderRadius(23)
            .enabled(!this.isLoading)
            .margin({ top: 4, bottom: 30 })
            .onClick(() => { this.submit() })
        }
        .width('100%')
        .padding(12)
      }
      .layoutWeight(1)
      .backgroundColor('#f5f5f5')
    }
    .width('100%')
    .height('100%')
  }
}
