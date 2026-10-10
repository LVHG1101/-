import { router } from '@kit.ArkUI'
import { CarbonApi, CarbonRecordModel } from '../api/CarbonApi'

@Entry
@Component
struct CarbonPoints {
  @State balance: number = 0
  @State records: CarbonRecordModel[] = []
  @State isLoading: boolean = true
  @State loadError: string = ''

  onPageShow(): void {
    this.load()
  }

  async load() {
    this.isLoading = true
    this.loadError = ''
    try {
      const res = await CarbonApi.my()
      if (res.code === 200) {
        this.balance = res.balance
        this.records = res.records ?? []
      } else {
        this.loadError = res.message || '加载失败'
      }
    } catch (e) {
      this.loadError = '加载失败，请确认已登录'
    } finally {
      this.isLoading = false
    }
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.back')).width(22).height(22)
          .onClick(() => { router.back() })
        Text('碳积分')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Blank().width(22)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      .backgroundColor('#fff')

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(40).height(40).color('#1A5FD6')
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else if (this.loadError !== '') {
        Column({ space: 12 }) {
          Text(this.loadError).fontSize(14).fontColor('#999')
          Button('重新加载').fontSize(13).height(34)
            .backgroundColor('#1A5FD6').fontColor('#fff').borderRadius(17)
            .onClick(() => { this.load() })
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 12 }) {
            Column({ space: 8 }) {
              Text('我的碳积分')
                .fontSize(13)
                .fontColor('#fff')
              Text(this.balance.toString())
                .fontSize(52)
                .fontWeight(FontWeight.Bold)
                .fontColor('#fff')
              Text('二手交易 · 低碳环保')
                .fontSize(12)
                .fontColor('#DFF5E4')
            }
            .width('100%')
            .padding({ top: 28, bottom: 28 })
            .backgroundColor('#2E9E5B')
            .borderRadius(12)

            Column({ space: 6 }) {
              Text('积分说明')
                .fontSize(15).fontWeight(FontWeight.Bold).fontColor('#333').width('100%')
              Text('· 每完成一笔二手订单，买卖双方各 +10 碳积分')
                .fontSize(12).fontColor('#666').width('100%')
              Text('· 碳积分可兑换环保好礼（功能即将上线）')
                .fontSize(12).fontColor('#666').width('100%')
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
            .padding(14)
            .backgroundColor('#fff')
            .borderRadius(10)

            Column({ space: 8 }) {
              Text('积分流水')
                .fontSize(15).fontWeight(FontWeight.Bold).fontColor('#333').width('100%')
              if (this.records.length === 0) {
                Text('暂无积分记录')
                  .fontSize(13).fontColor('#999').width('100%').padding({ top: 8, bottom: 8 })
              } else {
                ForEach(this.records, (r: CarbonRecordModel) => {
                  Column({ space: 4 }) {
                    Row() {
                      Text(r.reason)
                        .fontSize(13)
                        .fontColor('#333')
                        .layoutWeight(1)
                        .maxLines(2)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                      Text((r.delta > 0 ? '+' : '') + r.delta.toString())
                        .fontSize(16)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(r.delta > 0 ? '#2E9E5B' : '#D93025')
                        .margin({ left: 8 })
                    }
                    .width('100%')
                    Text(r.createTime)
                      .fontSize(10)
                      .fontColor('#ccc')
                      .width('100%')
                  }
                  .width('100%')
                  .padding({ top: 8, bottom: 8 })
                  .border({ width: { bottom: 1 }, color: '#F0F0F0' })
                }, (r: CarbonRecordModel) => r.id.toString())
              }
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
            .padding(14)
            .backgroundColor('#fff')
            .borderRadius(10)
          }
          .width('92%')
          .padding({ top: 12, bottom: 20 })
        }
        .layoutWeight(1)
        .backgroundColor('#f5f5f5')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}
