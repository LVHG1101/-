import promptAction from '@ohos.promptAction'

interface CartGoods {
  id: number
  name: string
  price: number
  image: Resource
  condition: string
  count: number
  selected: boolean
  invalid?: boolean
}

@Builder
export function buildCartTab() {
  CartTab()
}

@Component
export struct CartTab {
  @State cartList: CartGoods[] = [
    { id: 1, name: 'iPhone 15 128G', price: 3999, image: $r('app.media.phone2'), condition: '九成新', count: 1, selected: true },
    { id: 2, name: 'AirPods Pro 2', price: 899, image: $r('app.media.hairphone'), condition: '八成新', count: 2, selected: true },
    { id: 3, name: 'Apple Watch S8', price: 1599, image: $r('app.media.watch'), condition: '九成新', count: 1, selected: false },
  ]

  @State invalidGoods: CartGoods[] = [
    { id: 99, name: '小米电视 55寸', price: 1299, image: $r('app.media.tv'), condition: '九成新', count: 1, selected: false, invalid: true },
  ]

  @State isEditMode: boolean = false

  copyItem(src: CartGoods): CartGoods {
    return {
      id: src.id,
      name: src.name,
      price: src.price,
      image: src.image,
      condition: src.condition,
      count: src.count,
      selected: src.selected,
      invalid: src.invalid
    }
  }

  toggleSelect(item: CartGoods) {
    const idx = this.cartList.findIndex(i => i.id === item.id)
    if (idx >= 0) {
      const copy = this.copyItem(this.cartList[idx])
      copy.selected = !copy.selected
      const newList = [...this.cartList]
      newList[idx] = copy
      this.cartList = newList
    }
  }

  changeCount(item: CartGoods, delta: number) {
    const idx = this.cartList.findIndex(i => i.id === item.id)
    if (idx >= 0) {
      const copy = this.copyItem(this.cartList[idx])
      copy.count = Math.max(1, copy.count + delta)
      const newList = [...this.cartList]
      newList[idx] = copy
      this.cartList = newList
    }
  }

  removeItem(item: CartGoods) {
    this.cartList = this.cartList.filter(i => i.id !== item.id)
    promptAction.showToast({ message: '已删除' })
  }

  isAllSelected(): boolean {
    return this.cartList.length > 0 && this.cartList.every(i => i.selected)
  }

  toggleSelectAll() {
    const target = !this.isAllSelected()
    this.cartList = this.cartList.map(i => {
      const copy = this.copyItem(i)
      copy.selected = target
      return copy
    })
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
    promptAction.showToast({ message: '结算功能开发中' })
  }

  @Builder
  buildCartItem(item: CartGoods) {
    Row({ space: 10 }) {
      Checkbox({ name: item.id.toString() })
        .select(item.selected)
        .shape(CheckBoxShape.CIRCLE)
        .selectedColor('#1A5FD6')
        .onChange((value: boolean) => {
          this.toggleSelect(item)
        })

      Image(item.image)
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
        Text(item.condition)
          .fontSize(11)
          .fontColor('#999')
          .width('100%')
        Row() {
          Text('¥' + item.price.toFixed(2))
            .fontSize(16)
            .fontColor('#1A5FD6')
            .fontWeight(FontWeight.Bold)
          Blank()
          if (this.isEditMode) {
            Text('删除')
              .fontSize(13)
              .fontColor('#1A5FD6')
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
              .onClick(() => { this.removeItem(item) })
          } else {
            Row({ space: 4 }) {
              Text('-')
                .width(26).height(26)
                .textAlign(TextAlign.Center)
                .fontSize(16)
                .backgroundColor('#f5f5f5')
                .fontColor('#333')
                .borderRadius(13)
                .onClick(() => { this.changeCount(item, -1) })
              Text(item.count.toString())
                .fontSize(14)
                .width(28)
                .textAlign(TextAlign.Center)
              Text('+')
                .width(26).height(26)
                .textAlign(TextAlign.Center)
                .fontSize(16)
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

  @Builder
  buildInvalidItem(item: CartGoods) {
    Row({ space: 10 }) {
      Image(item.image)
        .width(72)
        .height(72)
        .objectFit(ImageFit.Contain)
        .backgroundColor('#F2F2F2')
        .borderRadius(8)
        .opacity(0.4)
      Column({ space: 6 }) {
        Text(item.name)
          .fontSize(14)
          .fontColor('#999')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text('该商品已失效')
          .fontSize(11)
          .fontColor('#ccc')
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Text('失效')
        .fontSize(11)
        .fontColor('#999')
        .padding({ left: 10, right: 10, top: 4, bottom: 4 })
        .backgroundColor('#f0f0f0')
        .borderRadius(12)
    }
    .width('100%')
    .padding(10)
    .backgroundColor('#fafafa')
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

      Scroll() {
        Column({ space: 10 }) {
          if (this.cartList.length === 0 && this.invalidGoods.length === 0) {
            Column({ space: 14 }) {
              Image($r('app.media.cart')).width(64).height(64).opacity(0.4)
              Text('购物车空空如也').fontSize(14).fontColor('#999')
              Text('快去挑选心仪的闲置好物吧').fontSize(12).fontColor('#ccc')
            }
            .width('100%')
            .padding({ top: 80 })
            .justifyContent(FlexAlign.Center)
          } else {
            ForEach(this.cartList, (item: CartGoods) => {
              this.buildCartItem(item)
            }, (item: CartGoods) => item.id.toString())

            if (this.invalidGoods.length > 0) {
              Row() {
                Text('失效商品')
                  .fontSize(12)
                  .fontColor('#999')
                Blank()
                Text('清空 ›')
                  .fontSize(12)
                  .fontColor('#999')
                  .onClick(() => {
                    this.invalidGoods = []
                    promptAction.showToast({ message: '已清空失效商品' })
                  })
              }
              .width('100%')
              .padding({ left: 4, right: 4, top: 6 })

              ForEach(this.invalidGoods, (item: CartGoods) => {
                this.buildInvalidItem(item)
              }, (item: CartGoods) => item.id.toString())
            }
          }
        }
        .width('100%')
        .padding(12)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .backgroundColor('#f5f5f5')

      if (this.cartList.length > 0) {
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
              .onClick(() => {
                this.cartList = this.cartList.filter(i => !i.selected)
                promptAction.showToast({ message: '已删除选中商品' })
              })
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
