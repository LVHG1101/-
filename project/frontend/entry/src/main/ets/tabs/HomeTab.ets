import promptAction from '@ohos.promptAction'

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
  image: Resource
  tag?: string
  condition?: string
}

@Builder
export function buildHomeTab() {
  HomeTab()
}

@Component
export struct HomeTab {
  @State banners: Resource[] = [
    $r('app.media.phone1'),
    $r('app.media.computer'),
    $r('app.media.tv'),
    $r('app.media.watch'),
  ]

  @State categories: CategoryEntry[] = [
    { name: '数码', icon: '📱' },
    { name: '图书', icon: '📚' },
    { name: '服饰', icon: '👕' },
    { name: '家居', icon: '🏠' },
    { name: '母婴', icon: '🍼' },
    { name: '运动', icon: '🏃' },
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

  @State auctionGoods: GoodsEntry[] = [
    { id: 11, name: '典藏版游戏机', price: 999, image: $r('app.media.phone1'), tag: '热拍中' },
    { id: 12, name: '机械键盘', price: 299, image: $r('app.media.computer'), tag: '限时' },
    { id: 13, name: '复古相机', price: 1999, image: $r('app.media.phone3'), tag: '热拍中' },
  ]

  @State exchangeGoods: GoodsEntry[] = [
    { id: 21, name: '耳机换音箱', price: 0, image: $r('app.media.hairphone'), tag: '换物' },
    { id: 22, name: '平板换笔记本', price: 0, image: $r('app.media.pad'), tag: '换物' },
    { id: 23, name: '键盘换鼠标', price: 0, image: $r('app.media.computer'), tag: '换物' },
  ]

  @State serviceEntries: ServiceEntry[] = [
    { name: '回收', icon: $r('app.media.tradein'), emoji: '♻️' },
    { name: '鉴定', icon: null, emoji: '🔍' },
    { name: '维修', icon: $r('app.media.applicationforrepair'), emoji: '🔧' },
    { name: '清洗', icon: null, emoji: '🧼' },
    { name: '租赁', icon: $r('app.media.install'), emoji: '📦' },
    { name: '跑腿', icon: null, emoji: '🏃' },
  ]

  build() {
    Column() {
      this.buildHeader()
      Scroll() {
        Column({ space: 10 }) {
          this.buildCategories()
          this.buildAuction()
          this.buildNearby()
          this.buildExchange()
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
          }
        })
      }
      .width('100%')
      .height(150)
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .rowsTemplate('1fr 1fr')
      .backgroundColor('#fff')
      .borderRadius(12)
      .padding({ top: 12, bottom: 12 })
      .margin({ top: 10 })
    }
    .width('100%')
  }

  @Builder
  buildAuction() {
    Column({ space: 10 }) {
      Row() {
        Text('🔨 拍卖专场')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#fff')
        Blank()
        Text('更多 ›').fontSize(12).fontColor('#fff')
      }
      .width('100%')

      Scroll() {
        Row({ space: 10 }) {
          ForEach(this.auctionGoods, (item: GoodsEntry) => {
            Column({ space: 4 }) {
              Image(item.image)
                .width(110)
                .height(90)
                .objectFit(ImageFit.Cover)
                .borderRadius(8)
              Text(item.name)
                .fontSize(12)
                .fontColor('#333')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .width(110)
              Row() {
                Text('¥' + item.price + ' 起')
                  .fontSize(13)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1A5FD6')
                Blank()
                if (item.tag) {
                  Text(item.tag)
                    .fontSize(9)
                    .fontColor('#fff')
                    .backgroundColor('#1A5FD6')
                    .padding({ left: 5, right: 5, top: 2, bottom: 2 })
                    .borderRadius(8)
                }
              }
              .width(110)
            }
            .width(110)
            .onClick(() => { promptAction.showToast({ message: '拍卖功能开发中' }) })
          })
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
    }
    .width('100%')
    .padding(12)
    .linearGradient({ angle: 135, colors: [['#6EA8FF', 0.0], ['#1A5FD6', 1.0]] })
    .borderRadius(12)
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
            }
            .width('100%')
            .padding(8)
            .backgroundColor('#fff')
            .borderRadius(10)
            .onClick(() => { promptAction.showToast({ message: '商品详情开发中' }) })
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
  buildExchange() {
    Column({ space: 10 }) {
      Row() {
        Text('🔄 换物专区')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
        Blank()
        Text('更多 ›').fontSize(12).fontColor('#999')
      }
      .width('100%')

      Scroll() {
        Row({ space: 10 }) {
          ForEach(this.exchangeGoods, (item: GoodsEntry) => {
            Column({ space: 4 }) {
              Image(item.image)
                .width(110)
                .height(90)
                .objectFit(ImageFit.Cover)
                .borderRadius(8)
              Text(item.name)
                .fontSize(12)
                .fontColor('#333')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .width(110)
              Text(item.tag ?? '换物')
                .fontSize(11)
                .fontColor('#1A5FD6')
                .width(110)
            }
            .width(110)
            .onClick(() => { promptAction.showToast({ message: '换物功能开发中' }) })
          })
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#fff')
    .borderRadius(12)
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
          .onClick(() => { promptAction.showToast({ message: item.name + '服务开发中' }) })
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#fff')
    .borderRadius(12)
  }
}
