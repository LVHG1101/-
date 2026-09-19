import { router } from '@kit.ArkUI'
import promptAction from '@ohos.promptAction'
import { ServiceApi } from '../api/ServiceApi'
import { ServiceItemModel } from '../model/DataModels'
import { UserStore } from '../common/UserStore'

// Index.ets 里「服务」是第 4 个 Tab（下标 3）。若组员调整了 Tab 顺序，这个常量要跟着改
const SERVICE_TAB_INDEX: number = 3

@Builder
export function buildServiceTab() {
  ServiceTab()
}

@Component
export struct ServiceTab {
  @State services: ServiceItemModel[] = []
  @State isLoggedIn: boolean = false
  @State loaded: boolean = false
  @State isRefreshing: boolean = false
  // 子组件收不到 onPageShow，靠 UserStore.notifyLoginStateChanged() 广播的计数器触发刷新
  @StorageLink('loginTick') @Watch('onLoginTickChanged') loginTick: number = 0
  // 从子页面返回时由 Index.onPageShow 广播；管理员改过服务项后回来能看到最新列表
  @StorageLink('pageShowTick') @Watch('onVisibleAgain') pageShowTick: number = 0
  // 切回服务 Tab 时刷新
  @StorageLink('currTabIndex') @Watch('onTabChanged') currTabIndex: number = 0

  private fallbackServices: ServiceItemModel[] = [
    { id: 1, code: 'recycle', name: '上门回收', icon: '♻️', description: '闲置物品上门回收，旧手机、旧家电、旧书刊均可，估价后当面结算', price: 0, enabled: true },
    { id: 2, code: 'authenticate', name: '专业鉴定', icon: '🔍', description: '数码、腕表、奢侈品真伪与成色鉴定，出具鉴定报告', price: 9.9, enabled: true },
    { id: 3, code: 'repair', name: '维修保养', icon: '🔧', description: '手机、电脑、家电等常见故障维修，支持上门或到店', price: 29, enabled: true },
    { id: 4, code: 'clean', name: '清洗护理', icon: '🧼', description: '家电清洗、衣物洗护、箱包护理等深度清洁服务', price: 19.9, enabled: true },
    { id: 5, code: 'rent', name: '物品租赁', icon: '📦', description: '相机、乐器、工具、数码等按天租赁，免押金可担保', price: 9.9, enabled: true },
    { id: 6, code: 'errand', name: '同城跑腿', icon: '🛵', description: '同城取送、代买代排、搬货跑腿等即时服务', price: 5, enabled: true },
  ]

  aboutToAppear(): void {
    this.loadServices()
  }

  onLoginTickChanged(): void {
    this.loadServices()
  }

  onVisibleAgain(): void {
    this.loadServices()
  }

  onTabChanged(): void {
    if (this.currTabIndex === SERVICE_TAB_INDEX) {
      this.loadServices()
    }
  }

  async loadServices() {
    this.isLoggedIn = await UserStore.isLoggedIn()
    try {
      this.services = await ServiceApi.list()
    } catch (e) {
      this.services = []
    }
    if (this.services.length === 0) {
      this.services = this.fallbackServices
    }
    this.loaded = true
  }

  async refreshServices() {
    await this.loadServices()
    this.isRefreshing = false
  }

  goDetail(item: ServiceItemModel) {
    router.pushUrl({ url: 'pages/ServiceDetail', params: { serviceId: item.id } })
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
          .fontColor('#1A5FD6')
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
      } else {
        Refresh({ refreshing: $$this.isRefreshing }) {
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
                    Text(this.iconFor(item.code)).fontSize(34)
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
        .layoutWeight(1)
        .onRefreshing(() => { this.refreshServices() })
      }
    }
    .width('100%')
    .height('100%')
  }
}
