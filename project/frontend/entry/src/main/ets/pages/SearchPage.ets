import { router } from '@kit.ArkUI'
import promptAction from '@ohos.promptAction'
import { GoodsApi } from '../api/GoodsApi'
import { CategoryApi } from '../api/CategoryApi'
import { GoodsItemModel, CategoryItemModel } from '../model/DataModels'
import { imageResource } from '../common/ImageUtil'

@Entry
@Component
struct SearchPage {
  @State keyword: string = ''
  @State categories: CategoryItemModel[] = []
  @State categoryIndex: number = -1
  @State sortBy: string = ''
  @State goods: GoodsItemModel[] = []
  @State searched: boolean = false
  @State loading: boolean = false

  aboutToAppear(): void {
    this.loadCategories()
  }

  async loadCategories() {
    try {
      this.categories = await CategoryApi.list()
    } catch (e) {
      this.categories = []
    }
  }

  async doSearch() {
    if (!this.keyword.trim() && this.categoryIndex < 0) {
      promptAction.showToast({ message: '请输入关键词或选择分类' })
      return
    }
    this.loading = true
    const categoryId = this.categoryIndex >= 0 && this.categories.length > 0
      ? this.categories[this.categoryIndex].id : 0
    try {
      this.goods = await GoodsApi.search(this.keyword.trim(), categoryId, this.sortBy)
    } catch (e) {
      this.goods = []
    }
    this.searched = true
    this.loading = false
  }

  selectCategory(index: number) {
    this.categoryIndex = index
    this.doSearch()
  }

  selectSort(sort: string) {
    this.sortBy = sort
    this.doSearch()
  }

  goDetail(item: GoodsItemModel) {
    router.pushUrl({ url: 'pages/GoodsDetail', params: { goodsId: item.id } })
  }

  @Builder
  buildGoodsCard(item: GoodsItemModel) {
    Row({ space: 10 }) {
      Image(imageResource(item.image))
        .width(80)
        .height(80)
        .objectFit(ImageFit.Contain)
        .backgroundColor('#F7F7F7')
        .borderRadius(8)
      Column({ space: 4 }) {
        Text(item.name)
          .fontSize(14)
          .fontColor('#333')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Row() {
          Text('¥' + item.price)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A5FD6')
          Blank()
          if (item.quality) {
            Text(item.quality)
              .fontSize(11)
              .fontColor('#999')
          }
        }
        .width('100%')
        if (item.lowCredit) {
          Text('⚠ 低信誉卖家')
            .fontSize(10)
            .fontColor('#D93025')
            .backgroundColor('#FDECEA')
            .padding({ left: 4, right: 4, top: 1, bottom: 1 })
            .borderRadius(4)
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(10)
    .backgroundColor('#fff')
    .borderRadius(10)
    .onClick(() => { this.goDetail(item) })
  }

  build() {
    Column() {
      // 顶部搜索栏
      Row() {
        Image($r('app.media.back')).width(22).height(22)
          .onClick(() => { router.back() })
        Row() {
          Image($r('app.media.search')).width(18).height(18)
          TextInput({ placeholder: '搜索闲置好物', text: this.keyword })
            .layoutWeight(1)
            .height(36)
            .fontSize(14)
            .backgroundColor(Color.Transparent)
            .onChange((v: string) => { this.keyword = v })
        }
        .layoutWeight(1)
        .height(38)
        .padding({ left: 10, right: 10 })
        .backgroundColor('#f5f5f5')
        .borderRadius(19)
        .margin({ left: 10 })
        Text('搜索')
          .fontSize(15)
          .fontColor('#1A5FD6')
          .fontWeight(FontWeight.Medium)
          .margin({ left: 12 })
          .onClick(() => { this.doSearch() })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('#fff')

      // 分类筛选
      Scroll() {
        Row({ space: 8 }) {
          Text('全部')
            .fontSize(13)
            .fontColor(this.categoryIndex === -1 ? '#fff' : '#666')
            .backgroundColor(this.categoryIndex === -1 ? '#1A5FD6' : '#f5f5f5')
            .padding({ left: 14, right: 14, top: 6, bottom: 6 })
            .borderRadius(16)
            .onClick(() => { this.selectCategory(-1) })
          ForEach(this.categories, (c: CategoryItemModel, index: number) => {
            Text(c.name)
              .fontSize(13)
              .fontColor(this.categoryIndex === index ? '#fff' : '#666')
              .backgroundColor(this.categoryIndex === index ? '#1A5FD6' : '#f5f5f5')
              .padding({ left: 14, right: 14, top: 6, bottom: 6 })
              .borderRadius(16)
              .onClick(() => { this.selectCategory(index) })
          })
        }
        .padding({ left: 16, right: 16 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .padding({ top: 4, bottom: 4 })
      .backgroundColor('#fff')

      // 排序
      Row({ space: 16 }) {
        Text('综合')
          .fontSize(13)
          .fontColor(this.sortBy === '' ? '#1A5FD6' : '#666')
          .fontWeight(this.sortBy === '' ? FontWeight.Medium : FontWeight.Normal)
          .onClick(() => { this.selectSort('') })
        Text('价格 ↑')
          .fontSize(13)
          .fontColor(this.sortBy === 'price_asc' ? '#1A5FD6' : '#666')
          .fontWeight(this.sortBy === 'price_asc' ? FontWeight.Medium : FontWeight.Normal)
          .onClick(() => { this.selectSort('price_asc') })
        Text('价格 ↓')
          .fontSize(13)
          .fontColor(this.sortBy === 'price_desc' ? '#1A5FD6' : '#666')
          .fontWeight(this.sortBy === 'price_desc' ? FontWeight.Medium : FontWeight.Normal)
          .onClick(() => { this.selectSort('price_desc') })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor('#fff')
      .border({ width: { top: 1 }, color: '#f5f5f5' })

      // 结果区
      if (this.loading) {
        Column() {
          LoadingProgress().width(40).height(40).color('#1A5FD6')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#f5f5f5')
      } else if (!this.searched) {
        Column({ space: 10 }) {
          Text('🔍').fontSize(48)
          Text('输入关键词或选择分类开始搜索').fontSize(14).fontColor('#999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#f5f5f5')
      } else if (this.goods.length === 0) {
        Column({ space: 10 }) {
          Text('📦').fontSize(48)
          Text('没有找到相关商品').fontSize(14).fontColor('#999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#f5f5f5')
      } else {
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.goods, (item: GoodsItemModel) => {
              this.buildGoodsCard(item)
            }, (item: GoodsItemModel) => item.id.toString())
          }
          .width('100%')
          .padding(12)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .backgroundColor('#f5f5f5')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}
