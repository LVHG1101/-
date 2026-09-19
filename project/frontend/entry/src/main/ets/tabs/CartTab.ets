import { router } from '@kit.ArkUI'
import promptAction from '@ohos.promptAction'
import { CartApi } from '../api/CartApi'
import { CartItemModel } from '../model/DataModels'
import { imageResource } from '../common/ImageUtil'
import { UserStore } from '../common/UserStore'

@Builder
export function buildCartTab() {
  CartTab()
}

@Component
export struct CartTab {
  @State cartList: CartItemModel[] = []
  @State isEditMode: boolean = false
  @State isLoggedIn: boolean = false
  @State isRefreshing: boolean = false

  aboutToAppear(): void {
    this.loadCart()
  }

  onPageShow(): void {
    this.loadCart()
  }

  async loadCart() {
    this.isLoggedIn = await UserStore.isLoggedIn()
    if (!this.isLoggedIn) {
      this.cartList = []
      return
    }
    try {
      this.cartList = await CartApi.list()
    } catch (e) {
      this.cartList = []
    }
  }

  async refreshCart() {
    await this.loadCart()
    this.isRefreshing = false
  }

  async changeCount(item: CartItemModel, delta: number) {
    const count = Math.max(1, item.count + delta)
    try {
      await CartApi.update(item.id, count, item.selected)
      this.loadCart()
    } catch (e) {
      promptAction.showToast({ message: '操作失败' })
    }
  }

  async toggleSelect(item: CartItemModel) {
    try {
      await CartApi.update(item.id, item.count, !item.selected)
      this.loadCart()
    } catch (e) {
      promptAction.showToast({ message: '操作失败' })
    }
  }

  async removeItem(item: CartItemModel) {
    try {
      await CartApi.delete(item.id)
      promptAction.showToast({ message: '已删除' })
      this.loadCart()
    } catch (e) {
      promptAction.showToast({ message: '操作失败' })
    }
  }

  isAllSelected(): boolean {
    return this.cartList.length > 0 && this.cartList.every(i => i.selected)
  }

  async toggleSelectAll() {
    const target = !this.isAllSelected()
    try {
      for (const item of this.cartList) {
        await CartApi.update(item.id, item.count, target)
      }
      this.loadCart()
    } catch (e) {
      promptAction.showToast({ message: '操作失败' })
    }
  }

  async deleteSelected() {
    try {
      for (const item of this.cartList) {
        if (item.selected) {
          await CartApi.delete(item.id)
        }
      }
      promptAction.showToast({ message: '已删除选中商品' })
      this.loadCart()
    } catch (e) {
      promptAction.showToast({ message: '操作失败' })
    }
  }

  getSelectedCount(): number {
    return this.cartList.filter(i => i.selected).length
  }

  getTotalPrice(): number {
    return this.cartList.filter(i => i.selected).reduce((sum, i) => sum + i.price * i.count, 0)
  }

  goCheckout() {
    if (this.getSelectedCount() === 0) {
      promptAction.showToast({ message: '请先选择商品' })
      return
    }
    const selectedIds = this.cartList.filter(i => i.selected).map(i => i.id)
    router.pushUrl({ url: 'pages/OrderConfirm', params: { cartItemIds: selectedIds } })
  }

  @Builder
  buildCartItem(item: CartItemModel) {
    Row({ space: 10 }) {
      Checkbox({ name: item.id.toString() })
        .select(item.selected)
        .shape(CheckBoxShape.CIRCLE)
        .selectedColor('#1A5FD6')
        .onChange((value: boolean) => { this.toggleSelect(item) })

      Image(imageResource(item.image))
        .width(72)
        .height(72)
        .objectFit(ImageFit.Contain)
        .backgroundColor('#F7F7F7')
        .borderRadius(8)

      Column({ space: 6 }) {
        Text(item.name)
          .fontSize(14)
          .fontColor('#333')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Row() {
          Text('¥' + item.price.toFixed(2))
            .fontSize(16)
            .fontColor('#1A5FD6')
            .fontWeight(FontWeight.Bold)
          Blank()
          if (this.isEditMode) {
            Button('删除')
              .fontSize(13)
              .height(28)
              .fontColor('#1A5FD6')
              .backgroundColor('#fff')
              .border({ width: 1, color: '#1A5FD6' })
              .borderRadius(14)
              .onClick(() => { this.removeItem(item) })
          } else {
            Row({ space: 4 }) {
              Button('-')
                .width(26).height(26)
                .fontSize(14)
                .backgroundColor('#f5f5f5')
                .fontColor('#333')
                .borderRadius(13)
                .onClick(() => { this.changeCount(item, -1) })
              Text(item.count.toString())
                .fontSize(14)
                .width(28)
                .textAlign(TextAlign.Center)
              Button('+')
                .width(26).height(26)
                .fontSize(14)
                .backgroundColor('#1A5FD6')
                .fontColor('#fff')
                .borderRadius(13)
                .onClick(() => { this.changeCount(item, 1) })
            }
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(10)
    .backgroundColor('#fff')
    .borderRadius(10)
  }

  build() {
    Column() {
      Row() {
        Blank().width(24)
        Text('购物车')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Text(this.isEditMode ? '完成' : '编辑')
          .fontSize(15)
          .fontColor('#1A5FD6')
          .onClick(() => { this.isEditMode = !this.isEditMode })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 14, bottom: 14 })
      .backgroundColor('#fff')

      if (!this.isLoggedIn) {
        Column({ space: 12 }) {
          Text('🛒').fontSize(48)
          Text('登录后查看购物车').fontSize(15).fontColor('#333')
          Button('去登录')
            .width(160)
            .height(40)
            .fontColor('#fff')
            .backgroundColor('#1A5FD6')
            .borderRadius(20)
            .onClick(() => { promptAction.showToast({ message: '请到「我的」页登录' }) })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.cartList.length === 0) {
        Column({ space: 14 }) {
          Image($r('app.media.cart')).width(64).height(64).opacity(0.4)
          Text('购物车空空如也').fontSize(14).fontColor('#999')
          Text('快去挑选心仪的闲置好物吧').fontSize(12).fontColor('#ccc')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Refresh({ refreshing: $$this.isRefreshing }) {
          Scroll() {
            Column({ space: 10 }) {
              ForEach(this.cartList, (item: CartItemModel) => {
                this.buildCartItem(item)
              }, (item: CartItemModel) => item.id.toString())
            }
            .width('100%')
            .padding(12)
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .backgroundColor('#f5f5f5')
        }
        .layoutWeight(1)
        .onRefreshing(() => { this.refreshCart() })
      }

      if (this.isLoggedIn && this.cartList.length > 0) {
        Row() {
          Checkbox({ name: 'selectAll' })
            .select(this.isAllSelected())
            .shape(CheckBoxShape.CIRCLE)
            .selectedColor('#1A5FD6')
            .onChange((value: boolean) => { this.toggleSelectAll() })
          Text('全选')
            .fontSize(14)
            .fontColor('#333')
            .margin({ left: 4 })

          Blank()

          if (this.isEditMode) {
            Button('删除')
              .width(90)
              .height(40)
              .backgroundColor('#1A5FD6')
              .fontColor('#fff')
              .borderRadius(20)
              .enabled(this.getSelectedCount() > 0)
              .onClick(() => { this.deleteSelected() })
          } else {
            Text('合计: ¥' + this.getTotalPrice().toFixed(2))
              .fontSize(16)
              .fontColor('#1A5FD6')
              .fontWeight(FontWeight.Bold)
              .margin({ right: 12 })

            Button('结算(' + this.getSelectedCount() + ')')
              .width(110)
              .height(42)
              .backgroundColor(this.getSelectedCount() > 0 ? '#1A5FD6' : '#ccc')
              .fontColor('#fff')
              .borderRadius(21)
              .onClick(() => { this.goCheckout() })
          }
        }
        .width('100%')
        .height(60)
        .padding({ left: 14, right: 14 })
        .backgroundColor('#fff')
        .border({ width: { top: 1 }, color: '#f0f0f0' })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}
