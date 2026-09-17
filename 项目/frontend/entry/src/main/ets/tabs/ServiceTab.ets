@Builder
export function buildServiceTab() {
  ServiceTab()
}

@Component
export struct ServiceTab {
  build() {
    Column() {
      Text($r('app.string.tab_bar_service'))
        .fontSize(18)
        .fontColor('#999999')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
