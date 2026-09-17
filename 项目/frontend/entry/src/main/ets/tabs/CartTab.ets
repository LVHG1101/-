@Builder
export function buildCartTab() {
  CartTab()
}

@Component
export struct CartTab {
  build() {
    Column() {
      Text($r('app.string.tab_bar_cart'))
        .fontSize(18)
        .fontColor('#999999')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
