import { router } from '@kit.ArkUI'
import promptAction from '@ohos.promptAction'
import { AdminApi } from '../api/AdminApi'
import { AdminServiceOrderModel } from '../model/DataModels'

const FILTERS: string[] = ['PENDING', 'CONFIRMED', 'COMPLETED', 'ALL']

function filterLabel(f: string): string {
  if (f === 'PENDING') return '待确认'
  if (f === 'CONFIRMED') return '已确认'
  if (f === 'COMPLETED') return '已完成'
  return '全部'
}

function statusLabel(s: string): string {
  if (s === 'PENDING') return '待确认'
  if (s === 'CONFIRMED') return '已确认'
  if (s === 'COMPLETED') return '已完成'
  if (s === 'CANCELLED') return '已取消'
  return s
}

function statusColor(s: string): string {
  if (s === 'PENDING') return '#e0620d'
  if (s === 'CONFIRMED') return '#1A5FD6'
  if (s === 'COMPLETED') return '#2E9E5B'
  return '#999'
}

@Entry
@Component
struct AdminServiceOrder {
  @State list: AdminServiceOrderModel[] = []
  @State filter: string = 'PENDING'
  @State isLoading: boolean = true
  @State loadError: string = ''

  onPageShow(): void {
    this.load()
  }

  async load() {
    this.isLoading = true
    this.loadError = ''
    try {
      this.list = await AdminApi.serviceOrders(this.filter)
    } catch (e) {
      this.list = []
      this.loadError = '加载失败，请确认后端已启动且当前账号为管理员'
    } finally {
      this.isLoading = false
    }
  }

  async changeStatus(item: AdminServiceOrderModel, status: string, tip: string) {
    try {
      const resp = await AdminApi.updateServiceOrderStatus(item.id, status)
      if (resp.code === 200) {
        promptAction.showToast({ message: tip })
        this.load()
      } else {
        promptAction.showToast({ message: resp.message || '操作失败' })
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
        Text('预约单管理')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Blank().width(22)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      .backgroundColor('#fff')

      Row() {
        ForEach(FILTERS, (f: string) => {
          Text(filterLabel(f))
            .fontSize(13)
            .fontColor(this.filter === f ? '#fff' : '#666')
            .backgroundColor(this.filter === f ? '#1A5FD6' : '#fff')
            .padding({ left: 14, right: 14, top: 6, bottom: 6 })
            .borderRadius(15)
            .margin({ right: 8 })
            .onClick(() => {
              this.filter = f
              this.load()
            })
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 10, bottom: 10 })
      .backgroundColor('#fff')

      if (this.isLoading) {
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
      } else if (this.list.length === 0) {
        Column() {
          Text('暂无相关预约单').fontSize(14).fontColor('#999')
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.list, (item: AdminServiceOrderModel) => {
              Column({ space: 8 }) {
                Row() {
                  Text((item.serviceIcon ? item.serviceIcon + ' ' : '') + item.serviceName)
                    .fontSize(15).fontWeight(FontWeight.Bold).fontColor('#333')
                  Blank()
                  Text(statusLabel(item.status))
                    .fontSize(13).fontWeight(FontWeight.Bold)
                    .fontColor(statusColor(item.status))
                }
                .width('100%')

                Divider().color('#F0F0F0')

                Row() {
                  Text('下单用户 ID：').fontSize(12).fontColor('#999')
                  Text(item.userId.toString()).fontSize(12).fontColor('#333')
                  Blank()
                  Text('预约单号 ' + item.id.toString()).fontSize(11).fontColor('#bbb')
                }
                .width('100%')

                Column({ space: 3 }) {
                  Text('联系人：' + item.contactName + '   ' + item.contactPhone)
                    .fontSize(12).fontColor('#333').width('100%')
                  Text('上门地址：' + (item.address ? item.address : '未填写'))
                    .fontSize(12).fontColor('#333').width('100%')
                  Text('预约时间：' + item.appointmentTime)
                    .fontSize(12).fontColor('#333').width('100%')
                  if (item.remark) {
                    Text('备注：' + item.remark)
                      .fontSize(12).fontColor('#666').width('100%')
                  }
                }
                .alignItems(HorizontalAlign.Start)
                .width('100%')

                Row({ space: 10 }) {
                  Blank()
                  if (item.status === 'PENDING') {
                    Button('取消')
                      .fontSize(12).height(32)
                      .backgroundColor('#F5F5F5').fontColor('#666')
                      .borderRadius(16).padding({ left: 14, right: 14 })
                      .onClick(() => { this.changeStatus(item, 'CANCELLED', '已取消该预约') })
                    Button('确认接单')
                      .fontSize(12).height(32)
                      .backgroundColor('#1A5FD6').fontColor('#fff')
                      .borderRadius(16).padding({ left: 14, right: 14 })
                      .onClick(() => { this.changeStatus(item, 'CONFIRMED', '已确认接单') })
                  } else if (item.status === 'CONFIRMED') {
                    Button('取消')
                      .fontSize(12).height(32)
                      .backgroundColor('#F5F5F5').fontColor('#666')
                      .borderRadius(16).padding({ left: 14, right: 14 })
                      .onClick(() => { this.changeStatus(item, 'CANCELLED', '已取消该预约') })
                    Button('标记完成')
                      .fontSize(12).height(32)
                      .backgroundColor('#2E9E5B').fontColor('#fff')
                      .borderRadius(16).padding({ left: 14, right: 14 })
                      .onClick(() => { this.changeStatus(item, 'COMPLETED', '已完成该服务') })
                  }
                }
                .width('100%')
              }
              .width('100%')
              .padding(14)
              .backgroundColor('#fff')
              .borderRadius(8)
            }, (item: AdminServiceOrderModel) => item.id.toString())
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
