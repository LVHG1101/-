import { router } from '@kit.ArkUI'
import promptAction from '@ohos.promptAction'
import { CategoryApi } from '../api/CategoryApi'
import { GoodsItemModel } from '../model/DataModels'
import { imageResource } from '../common/ImageUtil'

interface CategoryEntry {
  name: string
  icon: string
}

interface ServiceEntry {
  name: string
  icon: Resource | null
  emoji: string
}

interface GoodsEntry {
  id: number
  name: string
  price: number
  image: Resource | string
  tag?: string
  condition?: string
  lowCredit?: boolean
}

interface ExchangeGoods {
  id: number
  name: string
  wantName: string
  image: Resource
  owner: string
  location: string
}

interface AuctionGoods {
  id: number
  name: string
  image: Resource
  startPrice: number
  currentPrice: number
  bidCount: number
  endTime: string
}

@Builder
export function buildHomeTab() {
  HomeTab()
}

@Component
export struct HomeTab {
  @State subTabIndex: number = 0;
  @State isRefreshing: boolean = false;

  @State banners: Resource[] = [
    $r('app.media.phone1'),
    $r('app.media.computer'),
    $r('app.media.tv'),
    $r('app.media.watch'),
  ]

  @State categories: CategoryEntry[] = [
    { name: '数码', icon: '📱' },
    { name: '家电', icon: '📺' },
    { name: '家居', icon: '🏠' },
    { name: '其他', icon: '📦' },
    { name: '拍卖', icon: '🔨' },
    { name: '换物', icon: '🔄' },
  ]

  @State nearbyGoods: GoodsEntry[] = [
    { id: 1, name: 'iPhone 15 128G 九成新', price: 3999, image: $r('app.media.phone2'), tag: '同城', condition: '九成新' },
    { id: 2, name: '小米笔记本 Pro 14', price: 3299, image: $r('app.media.computer'), tag: '包邮', condition: '九五新' },
    { id: 3, name: 'iPad Air 5 64G', price: 2499, image: $r('app.media.pad'), condition: '九成新' },
    { id: 4, name: 'AirPods Pro 2', price: 899, image: $r('app.media.hairphone'), condition: '八成新' },
    { id: 5, name: 'Apple Watch S8', price: 1599, image: $r('app.media.watch'), condition: '九成新' },
    { id: 6, name: '小米电视 55寸', price: 1299, image: $r('app.media.tv'), tag: '自提', condition: '九成新' },
  ]

  @State serviceEntries: ServiceEntry[] = [
    { name: '回收', icon: $r('app.media.tradein'), emoji: '♻️' },
    { name: '鉴定', icon: null, emoji: '🔍' },
    { name: '维修', icon: $r('app.media.applicationforrepair'), emoji: '🔧' },
    { name: '清洗', icon: null, emoji: '🧼' },
    { name: '租赁', icon: $r('app.media.install'), emoji: '📦' },
    { name: '跑腿', icon: null, emoji: '🏃' },
  ]

  @State exchangeList: ExchangeGoods[] = [
    { id: 1, name: 'iPhone 13 128G', wantName: 'iPad 或平板', image: $r('app.media.phone2'), owner: '小杨', location: '同城' },
    { id: 2, name: 'AirPods Pro 2', wantName: '蓝牙音箱', image: $r('app.media.hairphone'), owner: '阿凯', location: '附近 2km' },
    { id: 3, name: '机械键盘', wantName: '游戏鼠标', image: $r('app.media.computer'), owner: '大壮', location: '同城' },
    { id: 4, name: 'Apple Watch S8', wantName: '运动耳机', image: $r('app.media.watch'), owner: '小雨', location: '附近 3km' },
    { id: 5, name: 'iPad Air 5', wantName: '轻薄笔记本', image: $r('app.media.pad'), owner: '阿哲', location: '同城' },
    { id: 6, name: '小米电视 55寸', wantName: '投影仪', image: $r('app.media.tv'), owner: '老周', location: '自提' },
  ]

  @State auctionList: AuctionGoods[] = [
    { id: 1, name: '典藏版游戏机', image: $r('app.media.phone1'), startPrice: 500, currentPrice: 1280, bidCount: 23, endTime: '还剩 2小时' },
    { id: 2, name: '复古胶片相机', image: $r('app.media.phone3'), startPrice: 800, currentPrice: 2100, bidCount: 31, endTime: '还剩 45分钟' },
    { id: 3, name: '机械键盘', image: $r('app.media.computer'), startPrice: 100, currentPrice: 350, bidCount: 12, endTime: '还剩 5分钟' },
    { id: 4, name: '限量手办', image: $r('app.media.phone4'), startPrice: 200, currentPrice: 520, bidCount: 18, endTime: '还剩 1天' },
    { id: 5, name: '二手镜头', image: $r('app.media.phone5'), startPrice: 900, currentPrice: 1650, bidCount: 15, endTime: '还剩 3小时' },
    { id: 6, name: '收藏球鞋', image: $r('app.media.phone6'), startPrice: 300, currentPrice: 680, bidCount: 27, endTime: '还剩 8小时' },
  ]

  aboutToAppear(): void {
    this.loadNearbyGoods()
  }

  async loadNearbyGoods() {
    try {
      const goods = await CategoryApi.goods(0)
      if (goods.length > 0) {
        const list: GoodsEntry[] = goods.slice(0, 6).map((g: GoodsItemModel) => {
          const entry: GoodsEntry = {
            id: g.id,
            name: g.name,
            price: g.price,
            image: imageResource(g.image),
            condition: g.quality,
            lowCredit: g.lowCredit === true
          }
          return entry
        })
        this.nearbyGoods = list
      }
    } catch (e) {
    }
  }

  async refreshHome() {
    await this.loadNearbyGoods()
    this.isRefreshing = false
  }

  build() {
    Tabs({ barPosition: BarPosition.Start, index: this.subTabIndex }) {
      TabContent() {
        this.buildHomeContent()
      }.tabBar(this.buildTopTab('首页', 0))

      TabContent() {
        this.buildExchangeContent()
      }.tabBar(this.buildTopTab('换物', 1))

      TabContent() {
        this.buildAuctionContent()
      }.tabBar(this.buildTopTab('拍卖', 2))
    }
    .width('100%')
    .height('100%')
    .barMode(BarMode.Fixed)
    .onChange((idx: number) => {
      this.subTabIndex = idx
    })
    .backgroundColor('#f5f5f5')
  }

  @Builder
  buildTopTab(txt: string, idx: number) {
    Column({ space: 6 }) {
      Text(txt)
        .fontSize(16)
        .fontWeight(this.subTabIndex === idx ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.subTabIndex === idx ? '#1A5FD6' : '#666')
      Divider()
        .width(20)
        .height(3)
        .strokeWidth(3)
        .color(this.subTabIndex === idx ? '#1A5FD6' : Color.Transparent)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 10, bottom: 8 })
  }

  // ===================== 首页内容 =====================
  @Builder
  buildHomeContent() {
    Column() {
      this.buildHeader()
      Refresh({ refreshing: $$this.isRefreshing }) {
        Scroll() {
          Column({ space: 10 }) {
            this.buildCategories()
            this.buildNearby()
            this.buildService()
            Blank().height(20)
          }
          .width('100%')
          .padding({ left: 12, right: 12 })
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor('#f5f5f5')
        .scrollBar(BarState.Off)
      }
      .layoutWeight(1)
      .onRefreshing(() => { this.refreshHome() })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }

  @Builder
  buildHeader() {
    Column({ space: 12 }) {
      Row() {
        Text('二手集市')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#fff')
        Blank()
        Row({ space: 4 }) {
          Image($r('app.media.navigation')).width(14).height(14)
          Text('附近').fontSize(13).fontColor('#fff')
        }
      }
      .width('100%')

      Row() {
        Image($r('app.media.search')).width(18).height(18)
        Text('搜索闲置好物')
          .fontSize(14)
          .fontColor('#999')
          .layoutWeight(1)
          .margin({ left: 8 })
        Text('搜索')
          .fontSize(13)
          .fontColor('#fff')
          .backgroundColor('#1A5FD6')
          .padding({ left: 14, right: 14, top: 6, bottom: 6 })
          .borderRadius(15)
      }
      .width('100%')
      .height(38)
      .padding({ left: 14, right: 6 })
      .backgroundColor('#fff')
      .borderRadius(19)
      .onClick(() => { promptAction.showToast({ message: '搜索功能开发中' }) })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 14 })
    .linearGradient({ angle: 135, colors: [['#6EA8FF', 0.0], ['#1A5FD6', 1.0]] })
  }

  @Builder
  buildCategories() {
    Column() {
      Swiper() {
        ForEach(this.banners, (img: Resource) => {
          Image(img)
            .width('100%')
            .height(140)
            .objectFit(ImageFit.Cover)
            .borderRadius(12)
        })
      }
      .width('100%')
      .height(140)
      .autoPlay(true)
      .loop(true)
      .indicator(DotIndicator.dot().color(Color.White).selectedColor('#1A5FD6'))
      .margin({ top: 10 })

      Grid() {
        ForEach(this.categories, (item: CategoryEntry) => {
          GridItem() {
            Column({ space: 6 }) {
              Text(item.icon).fontSize(30)
              Text(item.name).fontSize(12).fontColor('#333')
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              if (item.name === '拍卖') {
                this.subTabIndex = 2
              } else if (item.name === '换物') {
                this.subTabIndex = 1
              } else {
                AppStorage.setOrCreate('currTabIndex', 1)
              }
            })
          }
        })
      }
      .width('100%')
      .height(150)
      .columnsTemplate('1fr 1fr 1fr')
      .rowsTemplate('1fr 1fr')
      .backgroundColor('#fff')
      .borderRadius(12)
      .padding({ top: 12, bottom: 12 })
      .margin({ top: 10 })
    }
    .width('100%')
  }

  @Builder
  buildNearby() {
    Column({ space: 10 }) {
      Row() {
        Text('附近好物')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
        Blank()
        Text('查看更多 ›').fontSize(12).fontColor('#999')
      }
      .width('100%')

      Grid() {
        ForEach(this.nearbyGoods, (item: GoodsEntry) => {
          GridItem() {
            Column({ space: 4 }) {
              Image(item.image)
                .width('100%')
                .height(120)
                .objectFit(ImageFit.Cover)
                .borderRadius(8)
              Text(item.name)
                .fontSize(13)
                .fontColor('#333')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .width('100%')
              Row() {
                Text('¥' + item.price)
                  .fontSize(15)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1A5FD6')
                Blank()
                if (item.tag) {
                  Text(item.tag)
                    .fontSize(9)
                    .fontColor('#1A5FD6')
                    .border({ width: 1, color: '#1A5FD6' })
                    .padding({ left: 4, right: 4, top: 1, bottom: 1 })
                    .borderRadius(6)
                }
              }
              .width('100%')
              if (item.condition) {
                Text(item.condition)
                  .fontSize(10)
                  .fontColor('#999')
                  .width('100%')
              }
              if (item.lowCredit) {
                Text('⚠ 低信誉卖家')
                  .fontSize(10)
                  .fontColor('#D93025')
                  .backgroundColor('#FDECEA')
                  .padding({ left: 4, right: 4, top: 1, bottom: 1 })
                  .borderRadius(4)
              }
            }
            .width('100%')
            .padding(8)
            .backgroundColor('#fff')
            .borderRadius(10)
            .onClick(() => { router.pushUrl({ url: 'pages/GoodsDetail', params: { goodsId: item.id } }) })
          }
        })
      }
      .width('100%')
      .columnsTemplate('1fr 1fr')
      .columnsGap(10)
      .rowsGap(10)
    }
    .width('100%')
  }

  @Builder
  buildService() {
    Column({ space: 10 }) {
      Row() {
        Text('二手服务')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
        Blank()
        Text('更多 ›').fontSize(12).fontColor('#999')
      }
      .width('100%')

      Row({ space: 0 }) {
        ForEach(this.serviceEntries, (item: ServiceEntry) => {
          Column({ space: 6 }) {
            if (item.icon) {
              Image(item.icon).width(26).height(26)
            } else {
              Text(item.emoji).fontSize(26)
            }
            Text(item.name).fontSize(11).fontColor('#333')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
          .onClick(() => { AppStorage.setOrCreate('currTabIndex', 3) })
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#fff')
    .borderRadius(12)
  }

  // ===================== 换物内容 =====================
  @Builder
  buildExchangeContent() {
    Column() {
      Column({ space: 4 }) {
        Text('以物换物')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#fff')
        Text('闲置换闲置，各取所需')
          .fontSize(12)
          .fontColor('#FFE0CC')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding(16)
      .linearGradient({ angle: 135, colors: [['#6EA8FF', 0.0], ['#1A5FD6', 1.0]] })

      Scroll() {
        Column({ space: 12 }) {
          ForEach(this.exchangeList, (item: ExchangeGoods) => {
            Row({ space: 12 }) {
              Image(item.image)
                .width(72)
                .height(72)
                .objectFit(ImageFit.Contain)
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
              Column({ space: 4 }) {
                Text('换出：' + item.name)
                  .fontSize(14)
                  .fontColor('#333')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('100%')
                Text('想换：' + item.wantName)
                  .fontSize(12)
                  .fontColor('#1A5FD6')
                  .width('100%')
                Text(item.owner + ' · ' + item.location)
                  .fontSize(11)
                  .fontColor('#999')
                  .width('100%')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)

              Button('换一换')
                .fontSize(12)
                .height(30)
                .fontColor('#fff')
                .backgroundColor('#1A5FD6')
                .borderRadius(15)
                .onClick(() => { promptAction.showToast({ message: '换物功能开发中' }) })
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#fff')
            .borderRadius(10)
            .onClick(() => { promptAction.showToast({ message: '换物详情开发中' }) })
          }, (item: ExchangeGoods) => item.id.toString())
        }
        .width('100%')
        .padding(12)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .backgroundColor('#f5f5f5')
    }
    .width('100%')
    .height('100%')
  }

  // ===================== 拍卖内容 =====================
  @Builder
  buildAuctionContent() {
    Column() {
      Column({ space: 4 }) {
        Text('拍卖专场')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#fff')
        Text('稀缺好物，价高者得')
          .fontSize(12)
          .fontColor('#FFE0CC')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding(16)
      .linearGradient({ angle: 135, colors: [['#6EA8FF', 0.0], ['#1A5FD6', 1.0]] })

      Scroll() {
        Column({ space: 12 }) {
          ForEach(this.auctionList, (item: AuctionGoods) => {
            Column({ space: 8 }) {
              Row({ space: 12 }) {
                Image(item.image)
                  .width(80)
                  .height(80)
                  .objectFit(ImageFit.Contain)
                  .backgroundColor('#F5F5F5')
                  .borderRadius(8)
                Column({ space: 4 }) {
                  Text(item.name)
                    .fontSize(15)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#333')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .width('100%')
                  Row() {
                    Text('当前价 ')
                      .fontSize(12)
                      .fontColor('#999')
                    Text('¥' + item.currentPrice)
                      .fontSize(18)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#1A5FD6')
                  }
                  .width('100%')
                  Text('起拍价 ¥' + item.startPrice + ' · ' + item.bidCount + ' 次出价')
                    .fontSize(11)
                    .fontColor('#999')
                    .width('100%')
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)

                Column({ space: 4 }) {
                  Text(item.endTime)
                    .fontSize(11)
                    .fontColor('#1A5FD6')
                  Button('出价')
                    .fontSize(12)
                    .height(30)
                    .fontColor('#fff')
                    .backgroundColor('#1A5FD6')
                    .borderRadius(15)
                    .onClick(() => { promptAction.showToast({ message: '拍卖功能开发中' }) })
                }
                .alignItems(HorizontalAlign.End)
              }
              .width('100%')
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#fff')
            .borderRadius(10)
            .onClick(() => { promptAction.showToast({ message: '拍卖详情开发中' }) })
          }, (item: AuctionGoods) => item.id.toString())
        }
        .width('100%')
        .padding(12)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .backgroundColor('#f5f5f5')
    }
    .width('100%')
    .height('100%')
  }
}
