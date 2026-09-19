import { router } from '@kit.ArkUI'
import promptAction from '@ohos.promptAction'
import { FootprintStore } from '../common/FootprintStore'
import { UserStore } from '../common/UserStore'
import { FootprintModel } from '../model/DataModels'

function getImageResource(filename: string): Resource {
  if (filename === 'phone1.png') { return $r('app.media.phone1') }
  if (filename === 'phone2.png') { return $r('app.media.phone2') }
  if (filename === 'phone3.png') { return $r('app.media.phone3') }
  if (filename === 'phone4.png') { return $r('app.media.phone4') }
  if (filename === 'computer.png') { return $r('app.media.computer') }
  if (filename === 'tv.png') { return $r('app.media.tv') }
  if (filename === 'hairphone.png' || filename === 'hairphone.jpg') { return $r('app.media.hairphone') }
  if (filename === 'watch.png' || filename === 'watch.jpg') { return $r('app.media.watch') }
  if (filename === 'icebox.png') { return $r('app.media.icebox') }
  if (filename === 'washingmachine.png') { return $r('app.media.washingmachine') }
  if (filename === 'rangehood.png') { return $r('app.media.rangehood') }
  if (filename === 'waitcleaning.png') { return $r('app.media.waitcleaning') }
  if (filename === 'lock.png') { return $r('app.media.lock') }
  if (filename === 'airconditaion.png') { return $r('app.media.airconditaion') }
  if (filename === 'fan.png') { return $r('app.media.fan') }
  if (filename === 'washcar.png') { return $r('app.media.washcar') }
  if (filename === 'bag.png') { return $r('app.media.bag') }
  if (filename === 'brushteeth.png') { return $r('app.media.brushteeth') }
  if (filename === 'pad.png') { return $r('app.media.pad') }
  if (filename === 'phone5.png') { return $r('app.media.phone5') }
  if (filename === 'phone6.png') { return $r('app.media.phone6') }
  if (filename === 'phone7.png') { return $r('app.media.phone7') }
  if (filename === 'phone8.png') { return $r('app.media.phone8') }
  return $r('app.media.phone1')
}

@Entry
@Component
struct Footprint {
  @State footprints: FootprintModel[] = []
  @State isEditMode: boolean = false
  @State isLoggedIn: boolean = true

  aboutToAppear(): void {
    this.loadFootprints()
  }

  onPageShow(): void {
    this.loadFootprints()
  }

  async loadFootprints() {
    this.isLoggedIn = await UserStore.isLoggedIn()
    this.footprints = await FootprintStore.getFootprints()
  }

  async removeItem(item: FootprintModel) {
    await FootprintStore.removeFootprint(item.goodsId)
    promptAction.showToast({ message: '已删除足迹' })
    this.loadFootprints()
  }

  async clearAll() {
    await FootprintStore.clearAll()
    promptAction.showToast({ message: '已清空足迹' })
    this.loadFootprints()
  }

  goDetail(item: FootprintModel) {
    router.pushUrl({ url: 'pages/GoodsDetail', params: { goodsId: item.goodsId } })
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.back')).width(22).height(22)
          .onClick(() => { router.back() })
        Text('浏览足迹')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        if (this.footprints.length > 0) {
          Text(this.isEditMode ? '完成' : '清空')
            .fontSize(14)
            .fontColor('#666')
            .onClick(() => {
              if (this.isEditMode) {
                this.isEditMode = false
              } else {
                this.clearAll()
              }
            })
        } else {
          Blank().width(22)
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      .backgroundColor('#fff')

      if (this.footprints.length === 0) {
        Column({ space: 12 }) {
          Text(this.isLoggedIn ? '还没有浏览记录' : '登录后可同步浏览足迹')
            .fontSize(14)
            .fontColor('#999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Grid() {
            ForEach(this.footprints, (item: FootprintModel) => {
              GridItem() {
                Stack({ alignContent: Alignment.TopEnd }) {
                  Column() {
                    Image(getImageResource(item.image))
                      .width('100%')
                      .aspectRatio(1)
                      .objectFit(ImageFit.Contain)
                      .backgroundColor('#F7F7F7')
                      .borderRadius({ topLeft: 8, topRight: 8 })

                    Column({ space: 4 }) {
                      Text(item.name)
                        .fontSize(13)
                        .fontColor('#333')
                        .maxLines(2)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .width('100%')
                      Text('¥' + item.price.toFixed(2))
                        .fontSize(15)
                        .fontColor('#e0620d')
                        .fontWeight(FontWeight.Bold)
                    }
                    .alignItems(HorizontalAlign.Start)
                    .width('100%')
                    .padding(8)
                  }
                  .backgroundColor('#fff')
                  .borderRadius(8)
                  .clip(true)
                  .onClick(() => {
                    this.goDetail(item)
                  })

                  if (this.isEditMode) {
                    Text('✕')
                      .fontSize(12)
                      .fontColor('#fff')
                      .width(20)
                      .height(20)
                      .textAlign(TextAlign.Center)
                      .backgroundColor('#00000080')
                      .borderRadius(10)
                      .margin(6)
                      .onClick(() => {
                        this.removeItem(item)
                      })
                  }
                }
              }
            }, (item: FootprintModel) => item.goodsId.toString())
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(10)
          .rowsGap(10)
          .padding(12)
        }
        .layoutWeight(1)
        .backgroundColor('#f5f5f5')

        if (!this.isEditMode) {
          Text('长按或点击右上角"清空"可管理足迹')
            .fontSize(11)
            .fontColor('#ccc')
            .padding(8)
            .onClick(() => {
              this.isEditMode = true
            })
        }
      }
    }
    .width('100%')
    .height('100%')
  }
}
