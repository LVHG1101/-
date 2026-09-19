import { router } from '@kit.ArkUI'
import promptAction from '@ohos.promptAction'
import { ServiceApi } from '../api/ServiceApi'
import { ServiceOrderModel } from '../model/DataModels'
import { UserStore } from '../common/UserStore'

@Entry
@Component
struct ServiceOrders {
  @State orders: ServiceOrderModel[] = []
  @State isLoggedIn: boolean = false

  aboutToAppear(): void {
    this.load()
  }

  onPageShow(): void {
    this.load()
  }

  async load() {
    this.isLoggedIn = await UserStore.isLoggedIn()
    if (!this.isLoggedIn) {
      this.orders = []
      return
    }
    try {
      this.orders = await ServiceApi.myOrders()
    } catch (e) {
      this.orders = []
    }
  }

  statusLabel(status: string): string {
    if (status === 'PENDING') return '待确认'
    if (status === 'CONFIRMED') return '已确认'
    if (status === 'COMPLETED') return '已完成'
    if (status === 'CANCELLED') return '已取消'
    return status
  }

  statusColor(status: string): string {
    if (status === 'PENDING') return '#1A5FD6'
    if (status === 'CONFIRMED') return '#1A5FD6'
    if (status === 'COMPLETED') return '#34a853'
    return '#999'
  }

  async cancelOrder(item: ServiceOrderModel) {
    try {
      const resp = await ServiceApi.cancel(item.id)
      promptAction.showToast({ message: resp.message || '操作完成' })
      this.load()
    } catch (e) {
      promptAction.showToast({ message: '网络请求失败' })
    }
  }

  iconFor(code: string): string {
    if (code === 'recycle') return '♻️'
    if (code === 'authenticate') return '🔍'
    if (code === 'repair') return '🔧'
    if (code === 'clean') return '🧼'
    if (code === 'rent') return '📦'
    if (code === 'errand') return '🛵'
    return '🔧'
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.back')).width(22).height(22)
          .onClick(() => { router.back() })
        Text('我的预约')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Blank().width(22)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      .backgroundColor('#fff')

      if (!this.isLoggedIn) {
        Column({ space: 12 }) {
          Text('登录后查看服务预约').fontSize(14).fontColor('#999')
          Button('去登录')
            .width(160)
            .height(40)
            .fontColor('#fff')
            .backgroundColor('#1A5FD6')
            .borderRadius(20)
            .onClick(() => { router.pushUrl({ url: 'pages/Login' }) })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.orders.length === 0) {
        Column({ space: 12 }) {
          Text('📋').fontSize(48)
          Text('暂无服务预约').fontSize(15).fontColor('#333')
          Text('在「服务」页选择心仪的服务下单吧').fontSize(12).fontColor('#999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.orders, (item: ServiceOrderModel) => {
              Column({ space: 10 }) {
                Row({ space: 10 }) {
                  Text(this.iconFor(item.serviceCode)).fontSize(30)
                  Column({ space: 4 }) {
                    Text(item.serviceName).fontSize(15).fontWeight(FontWeight.Medium).fontColor('#333')
                    Text('预约时间：' + item.appointmentTime).fontSize(12).fontColor('#999')
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                  Text(this.statusLabel(item.status))
                    .fontSize(12)
                    .fontColor(this.statusColor(item.status))
                }
                .width('100%')

                Text('联系人：' + item.contactName + '  ' + item.contactPhone)
                  .fontSize(12)
                  .fontColor('#666')
                  .width('100%')
                if (item.address) {
                  Text('地址：' + item.address).fontSize(12).fontColor('#666').width('100%')
                }
                if (item.remark) {
                  Text('备注：' + item.remark).fontSize(12).fontColor('#666').width('100%')
                }

                if (item.status === 'PENDING') {
                  Row() {
                    Blank()
                    Button('取消预约')
                      .fontSize(12)
                      .height(30)
                      .fontColor('#1A5FD6')
                      .backgroundColor('#fff')
                      .border({ width: 1, color: '#1A5FD6' })
                      .borderRadius(15)
                      .onClick(() => { this.cancelOrder(item) })
                  }
                  .width('100%')
                }
              }
              .width('100%')
              .padding(14)
              .backgroundColor('#fff')
              .borderRadius(10)
            }, (item: ServiceOrderModel) => item.id.toString())
          }
          .width('100%')
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
