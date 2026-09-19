import { router } from '@kit.ArkUI'
import promptAction from '@ohos.promptAction'
import { AdminApi } from '../api/AdminApi'
import { AfterSaleModel } from '../model/DataModels'

const FILTERS: string[] = ['PENDING', 'APPROVED', 'REJECTED', 'ALL']

function filterLabel(f: string): string {
  if (f === 'PENDING') return '待处理'
  if (f === 'APPROVED') return '已同意'
  if (f === 'REJECTED') return '已驳回'
  return '全部'
}

function statusLabel(s: string): string {
  if (s === 'PENDING') return '待处理'
  if (s === 'APPROVED') return '已同意'
  if (s === 'REJECTED') return '已驳回'
  return s
}

function statusColor(s: string): string {
  if (s === 'PENDING') return '#e0620d'
  if (s === 'APPROVED') return '#1A5FD6'
  return '#999'
}

@Entry
@Component
struct AdminAfterSale {
  @State list: AfterSaleModel[] = []
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
      this.list = await AdminApi.afterSales(this.filter)
    } catch (e) {
      this.list = []
      this.loadError = '加载失败，请确认后端已启动且当前账号为管理员'
    } finally {
      this.isLoading = false
    }
  }

  async handle(item: AfterSaleModel, approve: boolean) {
    try {
      const resp = await AdminApi.handleAfterSale(item.id, approve, approve ? '平台已同意售后' : '不符合售后条件，予以驳回')
      if (resp.code === 200) {
        promptAction.showToast({ message: resp.message || '处理成功' })
        this.load()
      } else {
        promptAction.showToast({ message: resp.message || '处理失败' })
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
        Text('售后管理')
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
          Text('暂无相关售后申请').fontSize(14).fontColor('#999')
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.list, (item: AfterSaleModel) => {
              Column({ space: 8 }) {
                Row() {
                  Text('订单号 ' + item.orderNo)
                    .fontSize(12)
                    .fontColor('#999')
                  Blank()
                  Text(statusLabel(item.status))
                    .fontSize(13)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(statusColor(item.status))
                }
                .width('100%')

                Divider().color('#F0F0F0')

                Row() {
                  Text('申请人：').fontSize(12).fontColor('#999')
                  Text(item.username ? item.username : ('用户' + item.userId))
                    .fontSize(12).fontColor('#333')
                  Blank()
                  Text('金额 ¥' + item.totalPrice.toFixed(2))
                    .fontSize(13).fontColor('#e0620d').fontWeight(FontWeight.Bold)
                }
                .width('100%')

                Column({ space: 2 }) {
                  Text('售后原因').fontSize(11).fontColor('#999')
                  Text(item.reason).fontSize(13).fontColor('#333').width('100%')
                }
                .alignItems(HorizontalAlign.Start)
                .width('100%')

                if (item.adminRemark && item.adminRemark !== '') {
                  Column({ space: 2 }) {
                    Text('处理备注').fontSize(11).fontColor('#999')
                    Text(item.adminRemark).fontSize(12).fontColor('#666').width('100%')
                  }
                  .alignItems(HorizontalAlign.Start)
                  .width('100%')
                }

                Text('申请时间 ' + item.applyTime)
                  .fontSize(11).fontColor('#bbb').width('100%')

                if (item.status === 'PENDING') {
                  Row({ space: 10 }) {
                    Blank()
                    Button('驳回')
                      .fontSize(13).height(34)
                      .backgroundColor('#F5F5F5').fontColor('#666')
                      .borderRadius(17).padding({ left: 16, right: 16 })
                      .onClick(() => { this.handle(item, false) })
                    Button('同意售后')
                      .fontSize(13).height(34)
                      .backgroundColor('#1A5FD6').fontColor('#fff')
                      .borderRadius(17).padding({ left: 16, right: 16 })
                      .onClick(() => { this.handle(item, true) })
                  }
                  .width('100%')
                }
              }
              .width('100%')
              .padding(14)
              .backgroundColor('#fff')
              .borderRadius(8)
            }, (item: AfterSaleModel) => item.id.toString())
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
