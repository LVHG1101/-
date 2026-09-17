@Builder
export function buildCategoryTab() {
  CategoryTab()
}

@Component
export struct CategoryTab {
  build() {
    Column() {
      Text($r('app.string.tab_bar_category'))
        .fontSize(18)
        .fontColor('#999999')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
