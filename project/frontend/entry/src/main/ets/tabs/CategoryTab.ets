import { router } from '@kit.ArkUI'
import promptAction from '@ohos.promptAction'
import { CategoryApi } from '../api/CategoryApi'
import { CartApi } from '../api/CartApi'
import { CategoryItemModel, GoodsItemModel } from '../model/DataModels'
import { imageResource } from '../common/ImageUtil'

@Builder
export function buildCategoryTab() {
  CategoryTab()
}

@Component
export struct CategoryTab {
  @State categories: CategoryItemModel[] = []
  @State goods: GoodsItemModel[] = []
  @State currentIndex: number = 0
  @State loaded: boolean = false
  @State isRefreshing: boolean = false

  private fallbackCategories: CategoryItemModel[] = [
    { id: 1, code: 'digital', name: '数码', icon: '数' },
    { id: 2, code: 'appliance', name: '家电', icon: '电' },
    { id: 3, code: 'home', name: '家居', icon: '居' },
    { id: 4, code: 'other', name: '其他', icon: '其' },
  ]

  private fallbackGoods: GoodsItemModel[] = [
    { id: 1, name: 'iPhone 15 128G', price: 3999, image: 'phone2', quality: '九成新', categoryId: 1 },
    { id: 2, name: '小米笔记本 Pro 14', price: 3299, image: 'computer', quality: '九五新', categoryId: 1 },
    { id: 3, name: 'iPad Air 5 64G', price: 2499, image: 'pad', quality: '九成新', categoryId: 1 },
    { id: 4, name: 'AirPods Pro 2', price: 899, image: 'hairphone', quality: '八成新', categoryId: 1 },
  ]

  aboutToAppear(): void {
    this.loadCategories()
  }

  async loadCategories() {
    try {
      this.categories = await CategoryApi.list()
    } catch (e) {
      this.categories = []
    }
    if (this.categories.length === 0) {
      this.categories = this.fallbackCategories
    }
    this.loaded = true
    this.loadGoods(0)
  }

  async loadGoods(index: number) {
    this.currentIndex = index
    if (this.categories.length === 0) {
      this.goods = []
      return
    }
    const categoryId = this.categories[index].id
    try {
      this.goods = await CategoryApi.goods(categoryId)
    } catch (e) {
      this.goods = []
    }
    if (this.goods.length === 0 && this.currentIndex === 0) {
      this.goods = this.fallbackGoods
    }
  }

  async refreshGoods() {
    await this.loadGoods(this.currentIndex)
    this.isRefreshing = false
  }

  iconFor(code: string): string {
    if (code === 'digital') return '📱'
    if (code === 'appliance') return '📺'
    if (code === 'home') return '🏠'
    if (code === 'other') return '📦'
    return '📦'
  }

  addToCart(item: GoodsItemModel) {
    CartApi.add(item.id).then((resp) => {
      if (resp.code === 200) {
        promptAction.showToast({ message: '已加入购物车' })
      } else if (resp.code === 401) {
        promptAction.showToast({ message: '请先登录' })
      } else {
        promptAction.showToast({ message: resp.message || '加入失败' })
      }
    }).catch(() => {
      promptAction.showToast({ message: '网络请求失败' })
    })
  }

  build() {
    Row() {
      List() {
        ForEach(this.categories, (item: CategoryItemModel, index: number) => {
          ListItem() {
            Column({ space: 6 }) {
              Text(this.iconFor(item.code)).fontSize(22)
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
            .onClick(() => { this.loadGoods(index) })
          }
        })
      }
      .width(88)
      .height('100%')
      .scrollBar(BarState.Off)
      .backgroundColor('#f6f6f6')

      Column() {
        Row() {
          Text(this.iconFor(this.categories.length > 0 ? this.categories[this.currentIndex].code : '') + ' ' +
            (this.categories.length > 0 ? this.categories[this.currentIndex].name : ''))
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333')
          Blank()
          Text('共' + this.goods.length + '件')
            .fontSize(12)
            .fontColor('#999')
        }
        .width('100%')
        .padding({ left: 14, right: 14, top: 16, bottom: 12 })

        if (this.goods.length === 0) {
          Column({ space: 10 }) {
            Text('📦').fontSize(48)
            Text('该分类暂无商品').fontSize(14).fontColor('#999')
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          Refresh({ refreshing: $$this.isRefreshing }) {
            Scroll() {
            Grid() {
              ForEach(this.goods, (item: GoodsItemModel) => {
                GridItem() {
                  Column({ space: 6 }) {
                    Image(imageResource(item.image))
                      .width('100%')
                      .height(110)
                      .objectFit(ImageFit.Cover)
                      .borderRadius(8)
                      .onClick(() => { router.pushUrl({ url: 'pages/GoodsDetail', params: { goodsId: item.id } }) })
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
                      Text(item.quality)
                        .fontSize(10)
                        .fontColor('#999')
                    }
                    .width('100%')
                    Button('加入购物车')
                      .fontSize(11)
                      .height(26)
                      .width('100%')
                      .fontColor('#fff')
                      .backgroundColor('#1A5FD6')
                      .borderRadius(13)
                      .onClick(() => { this.addToCart(item) })
                  }
                  .width('100%')
                  .padding(8)
                  .backgroundColor('#fff')
                  .borderRadius(10)
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
          .onRefreshing(() => { this.refreshGoods() })
        }
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
