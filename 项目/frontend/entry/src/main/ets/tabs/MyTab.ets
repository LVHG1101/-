@Builder
export function buildMyTab() {
  MyTab()
}

@Component
export struct MyTab {
  build() {
    Column() {
      Text($r('app.string.tab_bar_my'))
        .fontSize(18)
        .fontColor('#999999')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
