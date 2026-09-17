import { router } from '@kit.ArkUI'
import promptAction from '@ohos.promptAction'
import { ServiceApi } from '../api/ServiceApi'
import { ServiceItemModel } from '../model/DataModels'
import { UserStore } from '../common/UserStore'

@Builder
export function buildServiceTab() {
  ServiceTab()
}

@Component
export struct ServiceTab {
  @State services: ServiceItemModel[] = []
  @State isLoggedIn: boolean = false
  @State loaded: boolean = false

  aboutToAppear(): void {
    this.loadServices()
  }

  onPageShow(): void {
    this.loadServices()
  }

  async loadServices() {
    this.isLoggedIn = await UserStore.isLoggedIn()
    if (!this.isLoggedIn) {
      this.services = []
      this.loaded = true
      return
    }
    try {
      this.services = await ServiceApi.list()
    } catch (e) {
      this.services = []
    }
    this.loaded = true
  }

  goDetail(item: ServiceItemModel) {
    router.pushUrl({ url: 'pages/ServiceDetail', params: { serviceId: item.id } })
  }

  goMyOrders() {
    if (!this.isLoggedIn) {
      promptAction.showToast({ message: '请先登录' })
      router.pushUrl({ url: 'pages/Login' })
      return
    }
    router.pushUrl({ url: 'pages/ServiceOrders' })
  }

  build() {
    Column() {
      Row() {
        Text('二手服务')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
        Blank()
        Text('我的预约 ›')
          .fontSize(13)
          .fontColor('#e0620d')
          .onClick(() => { this.goMyOrders() })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 14 })
      .backgroundColor('#fff')

      if (!this.loaded) {
        Column() {
          Text('加载中...').fontSize(13).fontColor('#999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (!this.isLoggedIn) {
        Column({ space: 12 }) {
          Text('🔧').fontSize(48)
          Text('登录后浏览二手服务').fontSize(15).fontColor('#333')
          Text('回收 · 鉴定 · 维修 · 清洗 · 租赁 · 跑腿').fontSize(12).fontColor('#999')
          Button('去登录')
            .width(160)
            .height(40)
            .fontColor('#fff')
            .backgroundColor('#e0620d')
            .borderRadius(20)
            .margin({ top: 8 })
            .onClick(() => { router.pushUrl({ url: 'pages/Login' }) })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 12 }) {
            Column({ space: 4 }) {
              Text('二手服务 · 一站式解决闲置问题')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#fff')
              Text('回收 / 鉴定 / 维修 / 清洗 / 租赁 / 跑腿')
                .fontSize(12)
                .fontColor('#FFE0CC')
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .padding(16)
            .linearGradient({ angle: 135, colors: [['#6EA8FF', 0.0], ['#1A5FD6', 1.0]] })
            .borderRadius(12)

            Grid() {
              ForEach(this.services, (item: ServiceItemModel) => {
                GridItem() {
                  Column({ space: 8 }) {
                    Text(item.icon).fontSize(34)
                    Text(item.name).fontSize(14).fontWeight(FontWeight.Medium).fontColor('#333')
                    Text(item.description)
                      .fontSize(10)
                      .fontColor('#999')
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .width('100%')
                      .textAlign(TextAlign.Center)
                  }
                  .width('100%')
                  .padding({ top: 14, bottom: 14, left: 8, right: 8 })
                  .backgroundColor('#fff')
                  .borderRadius(10)
                  .onClick(() => { this.goDetail(item) })
                }
              }, (item: ServiceItemModel) => item.id.toString())
            }
            .columnsTemplate('1fr 1fr')
            .columnsGap(10)
            .rowsGap(10)

            Blank().height(20)
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
