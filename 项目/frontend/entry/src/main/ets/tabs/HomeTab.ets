@Builder
export function buildHomeTab() {
  HomeTab()
}

@Component
export struct HomeTab {
  build() {
    Column() {
      Text($r('app.string.tab_bar_home'))
        .fontSize(18)
        .fontColor('#999999')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
