import promptAction from '@ohos.promptAction'

interface CategoryGoods {
  id: number
  name: string
  price: number
  image?: Resource
  emoji?: string
  condition: string
}

interface CategoryNode {
  name: string
  icon: string
  goods: CategoryGoods[]
}

@Builder
export function buildCategoryTab() {
  CategoryTab()
}

@Component
export struct CategoryTab {
  @State currentIndex: number = 0

  @State categories: CategoryNode[] = [
    {
      name: '数码', icon: '📱',
      goods: [
        { id: 101, name: 'iPhone 15 128G', price: 3999, image: $r('app.media.phone2'), condition: '九成新' },
        { id: 102, name: '小米笔记本 Pro', price: 3299, image: $r('app.media.computer'), condition: '九五新' },
        { id: 103, name: 'iPad Air 5', price: 2499, image: $r('app.media.pad'), condition: '九成新' },
        { id: 104, name: 'AirPods Pro 2', price: 899, image: $r('app.media.hairphone'), condition: '八成新' },
        { id: 105, name: 'Apple Watch S8', price: 1599, image: $r('app.media.watch'), condition: '九成新' },
        { id: 106, name: '小米 14 Ultra', price: 4299, image: $r('app.media.phone1'), condition: '九五新' },
      ]
    },
    {
      name: '图书', icon: '📚',
      goods: [
        { id: 201, name: '高等数学教材', price: 15, emoji: '📕', condition: '八成新' },
        { id: 202, name: '经典小说合集', price: 25, emoji: '📗', condition: '九成新' },
        { id: 203, name: '考研英语真题', price: 20, emoji: '📘', condition: '七成新' },
        { id: 204, name: '编程入门教程', price: 30, emoji: '📙', condition: '九成新' },
      ]
    },
    {
      name: '服饰', icon: '👕',
      goods: [
        { id: 301, name: '纯棉T恤 M码', price: 39, emoji: '👕', condition: '全新' },
        { id: 302, name: '秋冬外套', price: 129, emoji: '🧥', condition: '九成新' },
        { id: 303, name: '运动鞋 42码', price: 199, emoji: '👟', condition: '八成新' },
        { id: 304, name: '牛仔裤', price: 59, emoji: '👖', condition: '九成新' },
      ]
    },
    {
      name: '家居', icon: '🏠',
      goods: [
        { id: 401, name: '小米电视 55寸', price: 1299, image: $r('app.media.tv'), condition: '九成新' },
        { id: 402, name: '米家空调 1.5匹', price: 1599, image: $r('app.media.airconditaion'), condition: '九成新' },
        { id: 403, name: '米家冰箱 530L', price: 2299, image: $r('app.media.icebox'), condition: '九五新' },
        { id: 404, name: '洗衣机 10kg', price: 899, image: $r('app.media.washingmachine'), condition: '八成新' },
        { id: 405, name: '智能门锁', price: 499, image: $r('app.media.lock'), condition: '九成新' },
      ]
    },
    {
      name: '母婴', icon: '🍼',
      goods: [
        { id: 501, name: '婴儿推车', price: 299, emoji: '🛴', condition: '八成新' },
        { id: 502, name: '儿童玩具积木', price: 45, emoji: '🧸', condition: '九成新' },
        { id: 503, name: '婴儿床', price: 399, emoji: '🛏️', condition: '八成新' },
      ]
    },
    {
      name: '运动', icon: '🏃',
      goods: [
        { id: 601, name: '篮球', price: 89, emoji: '🏀', condition: '八成新' },
        { id: 602, name: '瑜伽垫', price: 35, emoji: '🧘', condition: '九成新' },
        { id: 603, name: '双肩运动包', price: 99, image: $r('app.media.bag'), condition: '九成新' },
        { id: 604, name: '电动牙刷', price: 59, image: $r('app.media.brushteeth'), condition: '全新' },
      ]
    },
  ]

  build() {
    Row() {
      List() {
        ForEach(this.categories, (item: CategoryNode, index: number) => {
          ListItem() {
            Column({ space: 6 }) {
              Text(item.icon).fontSize(22)
              Text(item.name)
                .fontSize(13)
                .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Normal)
                .fontColor(this.currentIndex === index ? '#1A5FD6' : '#515151')
            }
            .width('100%')
            .padding({ top: 18, bottom: 18 })
            .alignItems(HorizontalAlign.Center)
            .backgroundColor(this.currentIndex === index ? '#fff' : '#f6f6f6')
            .border({ width: { left: 3 }, color: this.currentIndex === index ? '#1A5FD6' : Color.Transparent })
            .onClick(() => { this.currentIndex = index })
          }
        })
      }
      .width(88)
      .height('100%')
      .scrollBar(BarState.Off)
      .backgroundColor('#f6f6f6')

      Column() {
        Row() {
          Text(this.categories[this.currentIndex].icon + ' ' + this.categories[this.currentIndex].name)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333')
          Blank()
          Text('共' + this.categories[this.currentIndex].goods.length + '件')
            .fontSize(12)
            .fontColor('#999')
        }
        .width('100%')
        .padding({ left: 14, right: 14, top: 16, bottom: 12 })

        Scroll() {
          Grid() {
            ForEach(this.categories[this.currentIndex].goods, (item: CategoryGoods) => {
              GridItem() {
                Column({ space: 6 }) {
                  if (item.image) {
                    Image(item.image)
                      .width('100%')
                      .height(110)
                      .objectFit(ImageFit.Cover)
                      .borderRadius(8)
                  } else {
                    Text(item.emoji ?? '📦')
                      .fontSize(56)
                      .width('100%')
                      .height(110)
                      .textAlign(TextAlign.Center)
                      .backgroundColor('#F5F7FA')
                      .borderRadius(8)
                  }
                  Text(item.name)
                    .fontSize(12)
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
                    Text(item.condition)
                      .fontSize(10)
                      .fontColor('#999')
                  }
                  .width('100%')
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
          .padding({ left: 12, right: 12, bottom: 20 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .layoutWeight(1)
      .height('100%')
      .backgroundColor('#fff')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}
