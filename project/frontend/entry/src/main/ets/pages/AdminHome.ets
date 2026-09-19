import { router } from '@kit.ArkUI'
import { AdminApi } from '../api/AdminApi'
import { CreditApi, AdminUserModel } from '../api/CreditApi'
import { UserStore } from '../common/UserStore'

@Entry
@Component
struct AdminHome {
  @State nickname: string = ''
  @State pendingAfterSale: number = 0
  @State pendingServiceOrder: number = 0
  @State lowCreditCount: number = 0
  @State loadError: string = ''

  // @Entry 页面，返回本页时会重新触发
  onPageShow(): void {
    this.load()
  }

  async load() {
    this.loadError = ''
    this.nickname = await UserStore.getNickname()
    try {
      const afterSales = await AdminApi.afterSales('PENDING')
      this.pendingAfterSale = afterSales.length
      const orders = await AdminApi.serviceOrders('PENDING')
      this.pendingServiceOrder = orders.length
      const users = await CreditApi.users()
      this.lowCreditCount = users.filter((u: AdminUserModel) => u.lowCredit).length
    } catch (e) {
      this.loadError = '数据加载失败，请确认后端已启动且当前账号为管理员'
    }
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.back')).width(22).height(22)
          .onClick(() => { router.back() })
        Text('管理后台')
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
          Row() {
            Text('当前管理员：')
              .fontSize(13)
              .fontColor('#999')
            Text(this.nickname)
              .fontSize(13)
              .fontColor('#1A5FD6')
              .fontWeight(FontWeight.Medium)
          }
          .width('100%')
          .padding(14)
          .backgroundColor('#EAF2FF')
          .borderRadius(10)

          if (this.loadError !== '') {
            Text(this.loadError)
              .fontSize(13)
              .fontColor('#e0620d')
              .width('100%')
              .padding(12)
              .backgroundColor('#FFF3E8')
              .borderRadius(10)
          }

          // 卡片必须内联渲染：@Builder 按值传参不会随状态变化重建，角标会停在首次渲染的值
          Row() {
            Column({ space: 4 }) {
              Text('售后管理').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333')
              Text('处理用户提交的退换/售后申请').fontSize(12).fontColor('#999')
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            if (this.pendingAfterSale > 0) {
              Text(this.pendingAfterSale.toString())
                .fontSize(11).fontColor('#fff').backgroundColor('#e0620d')
                .padding({ left: 8, right: 8, top: 2, bottom: 2 }).borderRadius(10)
            }
            Text('›').fontSize(18).fontColor('#ccc').margin({ left: 8 })
          }
          .width('100%').padding(16).backgroundColor('#fff').borderRadius(10)
          .onClick(() => { router.pushUrl({ url: 'pages/AdminAfterSale' }) })

          Row() {
            Column({ space: 4 }) {
              Text('服务项目管理').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333')
              Text('新增、编辑、删除服务项，上下架').fontSize(12).fontColor('#999')
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            Text('›').fontSize(18).fontColor('#ccc').margin({ left: 8 })
          }
          .width('100%').padding(16).backgroundColor('#fff').borderRadius(10)
          .onClick(() => { router.pushUrl({ url: 'pages/AdminService' }) })

          Row() {
            Column({ space: 4 }) {
              Text('预约单管理').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333')
              Text('查看并处理全部用户的服务预约').fontSize(12).fontColor('#999')
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            if (this.pendingServiceOrder > 0) {
              Text(this.pendingServiceOrder.toString())
                .fontSize(11).fontColor('#fff').backgroundColor('#e0620d')
                .padding({ left: 8, right: 8, top: 2, bottom: 2 }).borderRadius(10)
            }
            Text('›').fontSize(18).fontColor('#ccc').margin({ left: 8 })
          }
          .width('100%').padding(16).backgroundColor('#fff').borderRadius(10)
          .onClick(() => { router.pushUrl({ url: 'pages/AdminServiceOrder' }) })

          Row() {
            Column({ space: 4 }) {
              Text('用户信誉管理').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333')
              Text('查看用户信誉分，手动调整分值').fontSize(12).fontColor('#999')
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            if (this.lowCreditCount > 0) {
              Text(this.lowCreditCount.toString())
                .fontSize(11).fontColor('#fff').backgroundColor('#e0620d')
                .padding({ left: 8, right: 8, top: 2, bottom: 2 }).borderRadius(10)
            }
            Text('›').fontSize(18).fontColor('#ccc').margin({ left: 8 })
          }
          .width('100%').padding(16).backgroundColor('#fff').borderRadius(10)
          .onClick(() => { router.pushUrl({ url: 'pages/AdminUser' }) })
        }
        .width('92%')
        .padding({ top: 12, bottom: 20 })
      }
      .layoutWeight(1)
      .backgroundColor('#f5f5f5')
    }
    .width('100%')
    .height('100%')
  }
}
