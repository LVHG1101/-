import promptAction from '@ohos.promptAction'
import { router } from '@kit.ArkUI'
import { UserStore } from '../../common/UserStore'

@Builder
export function buildMyTab() {
  MyTabContent()
}

@Component
struct MyTabContent {
  @State isLoggedIn: boolean = false
  @State nickname: string = ''
  @State username: string = ''

  aboutToAppear(): void {
    this.loadUserInfo()
  }

  onPageShow(): void {
    this.loadUserInfo()
  }

  async loadUserInfo() {
    this.isLoggedIn = await UserStore.isLoggedIn()
    if (this.isLoggedIn) {
      this.nickname = await UserStore.getNickname()
      this.username = await UserStore.getUsername()
    }
  }

  goLogin() {
    router.pushUrl({ url: 'pages/Login' })
  }

  async doLogout() {
    await UserStore.logout()
    this.isLoggedIn = false
    this.nickname = ''
    this.username = ''
    promptAction.showToast({ message: '已退出登录' })
  }

  maskUsername(name: string): string {
    if (!name) return ''
    if (name.length <= 6) return name
    return name.substring(0, 4) + '***' + name.substring(name.length - 3)
  }

  goOrderList(mode: string) {
    router.pushUrl({ url: 'pages/OrderList', params: { mode: mode } })
  }

  goFootprint() {
    router.pushUrl({ url: 'pages/Footprint' })
  }

  build() {
    Scroll() {
      Column() {
        Column() {
          Row() {
            Image($r('app.media.my'))
              .width(60)
              .height(60)
              .borderRadius(30)
              .backgroundColor('#fff')

            Column({ space: 6 }) {
              if (this.isLoggedIn) {
                Row({ space: 8 }) {
                  Text(this.maskUsername(this.username))
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#fff')
                  Row() {
                    Text('F').fontSize(11).fontColor('#fff').fontWeight(FontWeight.Bold)
                    Text(' 普通会员').fontSize(11).fontColor('#fff')
                  }
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  .backgroundColor('rgba(255,255,255,0.25)')
                  .borderRadius(10)
                }
              } else {
                Text('登录/注册')
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#fff')
                  .onClick(() => { this.goLogin() })
                Text('登录后享受更多会员权益')
                  .fontSize(12)
                  .fontColor('#FFE0CC')
              }
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 14 })

            Blank()

            Image($r('app.media.cart'))
              .width(20)
              .height(20)
              .fillColor('#fff')
              .onClick(() => {
                promptAction.showToast({ message: '功能开发中' })
              })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 44 })

          Row() {
            this.StatItem('0', '碳积分')
            this.StatItem('良好', '信用分')
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 20, bottom: 16 })

          Row() {
            Text('🌱').fontSize(14)
            Text(' 碳积分兑换环保好礼')
              .fontSize(13)
              .fontColor('#fff')
              .layoutWeight(1)
              .margin({ left: 4 })
            Text('去兑换')
              .fontSize(12)
              .fontColor('#e0620d')
              .backgroundColor('#fff')
              .padding({ left: 12, right: 12, top: 5, bottom: 5 })
              .borderRadius(14)
              .onClick(() => {
                router.pushUrl({ url: 'pages/CarbonPoints' })
              })
          }
          .width('92%')
          .padding({ left: 12, right: 6, top: 4, bottom: 4 })
          .backgroundColor('rgba(255,255,255,0.15)')
          .borderRadius(20)

          Row() {
            Row() {
              Image($r('app.media.order')).width(20).height(20).fillColor('#fff')
              Text(' 我的发布').fontSize(13).fontColor('#fff').margin({ left: 4 })
            }
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center)
            .onClick(() => { router.pushUrl({ url: 'pages/MyGoods' }) })

            Divider().vertical(true).height(14).color('rgba(255,255,255,0.4)')

            Row() {
              Image($r('app.media.moneycard')).width(20).height(20).fillColor('#fff')
              Text(' 拍卖').fontSize(13).fontColor('#fff').margin({ left: 4 })
            }
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center)
            .onClick(() => { router.pushUrl({ url: 'pages/Auction' }) })

            Divider().vertical(true).height(14).color('rgba(255,255,255,0.4)')

            Row() {
              Image($r('app.media.bag')).width(20).height(20).fillColor('#fff')
              Text(' 换物').fontSize(13).fontColor('#fff').margin({ left: 4 })
            }
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center)
            .onClick(() => { router.pushUrl({ url: 'pages/Exchange' }) })
          }
          .width('92%')
          .padding({ top: 16, bottom: 24 })
        }
        .width('100%')
        .linearGradient({
          angle: 135,
          colors: [['#6EA8FF', 0.0], ['#1A5FD6', 1.0]]
        })

        Row() {
          this.OrderStatusItem('待付款', 'PENDING_PAY', $r('app.media.moneycard'))
          this.OrderStatusItem('待收货', 'PENDING_RECEIVE', $r('app.media.car'))
          this.OrderStatusItem('待评价', 'PENDING_REVIEW', $r('app.media.talk'))
          this.OrderStatusItem('退换/售后', 'AFTER_SALE', $r('app.media.remove'))
          this.OrderStatusItem('全部订单', 'ALL', $r('app.media.order'))
        }
        .width('92%')
        .backgroundColor('#fff')
        .borderRadius(10)
        .padding({ top: 16, bottom: 16 })
        .margin({ top: 12 })
        .shadow({ radius: 8, color: '#0000000D', offsetY: 2 })

        Row({ space: 10 }) {
          Column({ space: 6 }) {
            Row() {
              Text('浏览足迹').fontSize(14).fontWeight(FontWeight.Bold).fontColor('#333')
              Blank()
              Text('浏览和收藏 ›').fontSize(10).fontColor('#999')
            }
            .width('100%')

            Row({ space: 8 }) {
              Image($r('app.media.phone2'))
                .width(40).height(40)
                .objectFit(ImageFit.Contain)
                .backgroundColor('#F5F5F5')
                .borderRadius(6)
              Column({ space: 2 }) {
                Text('点击查看').fontSize(12).fontColor('#333')
                Text('你的浏览记录').fontSize(10).fontColor('#999')
              }
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(8)
            .backgroundColor('#F8F8F8')
            .borderRadius(8)
          }
          .layoutWeight(1)
          .padding(10)
          .backgroundColor('#fff')
          .borderRadius(10)
          .alignItems(HorizontalAlign.Start)
          .onClick(() => { this.goFootprint() })

          Column({ space: 6 }) {
            Row() {
              Text('二手交易地址').fontSize(14).fontWeight(FontWeight.Bold).fontColor('#333')
              Blank()
              Text('附近地址 ›').fontSize(10).fontColor('#999')
            }
            .width('100%')

            Column({ space: 2 }) {
              Text('[附近] 距您1.5km').fontSize(11).fontColor('#e0620d')
              Text('查看附近交易地址').fontSize(10).fontColor('#999')
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
            .padding(8)
            .backgroundColor('#F8F8F8')
            .borderRadius(8)
          }
          .layoutWeight(1)
          .padding(10)
          .backgroundColor('#fff')
          .borderRadius(10)
          .alignItems(HorizontalAlign.Start)
          .onClick(() => { router.pushUrl({ url: 'pages/Address' }) })
        }
        .width('92%')
        .margin({ top: 12 })

        Column() {
          this.MenuRow('个人资料', 'pages/Profile')
          Divider().color('#F0F0F0').margin({ left: 16 })
          this.MenuRow('实名认证', 'pages/RealName')
          Divider().color('#F0F0F0').margin({ left: 16 })
          this.MenuRow('我的收藏', 'pages/Favorites')
          Divider().color('#F0F0F0').margin({ left: 16 })
          this.MenuRow('收货地址', 'pages/Address')
          Divider().color('#F0F0F0').margin({ left: 16 })
          this.MenuRow('我的信用', 'pages/Credit')
          Divider().color('#F0F0F0').margin({ left: 16 })
          this.MenuRow('售后服务', '')
          Divider().color('#F0F0F0').margin({ left: 16 })
          this.MenuRow('联系客服', '')
          Divider().color('#F0F0F0').margin({ left: 16 })
          this.MenuRow('关于我们', '')
        }
        .width('92%')
        .backgroundColor('#fff')
        .borderRadius(10)
        .margin({ top: 12 })

        if (this.isLoggedIn) {
          Button('退出登录')
            .width('92%')
            .height(46)
            .fontColor('#e0620d')
            .backgroundColor('#fff')
            .border({ width: 1, color: '#e0620d' })
            .borderRadius(23)
            .margin({ top: 20, bottom: 30 })
            .onClick(() => { this.doLogout() })
        } else {
          Blank().height(30)
        }
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }

  @Builder
  StatItem(value: string, label: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#fff')
      Text(label)
        .fontSize(12)
        .fontColor('#FFE0CC')
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  OrderStatusItem(label: string, mode: string, icon: Resource) {
    Column({ space: 6 }) {
      Image(icon)
        .width(22)
        .height(22)
        .fillColor('#666')
      Text(label)
        .fontSize(11)
        .fontColor('#333')
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.goOrderList(mode)
    })
  }

  @Builder
  MenuRow(title: string, url: string) {
    Row() {
      Text(title)
        .fontSize(15)
        .fontColor('#333')
      Blank()
      Text('›')
        .fontSize(18)
        .fontColor('#ccc')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .onClick(() => {
      if (url.length > 0) {
        router.pushUrl({ url: url })
      } else {
        promptAction.showToast({ message: '功能开发中' })
      }
    })
  }
}
