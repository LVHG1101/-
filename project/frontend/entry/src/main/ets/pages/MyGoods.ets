import { router } from '@kit.ArkUI'

@Entry
@Component
struct MyGoods {
  build() {
    Column() {
      Row() {
        Image($r('app.media.back')).width(22).height(22)
          .onClick(() => { router.back() })
        Text('我的发布')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Blank().width(22)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      .backgroundColor('#fff')

      Column({ space: 10 }) {
        Text('我的发布')
          .fontSize(16)
          .fontColor('#333')
        Text('功能开发中')
          .fontSize(13)
          .fontColor('#999')
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}
