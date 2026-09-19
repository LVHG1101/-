import { router } from '@kit.ArkUI'
import { CreditApi, CreditRecordModel } from '../api/CreditApi'

function levelColor(score: number): string {
  if (score >= 90) return '#2E9E5B'
  if (score >= 75) return '#1A5FD6'
  if (score >= 60) return '#e0620d'
  return '#D93025'
}

@Entry
@Component
struct Credit {
  @State score: number = 100
  @State level: string = ''
  @State lowCredit: boolean = false
  @State threshold: number = 60
  @State records: CreditRecordModel[] = []
  @State isLoading: boolean = true
  @State loadError: string = ''

  onPageShow(): void {
    this.load()
  }

  async load() {
    this.isLoading = true
    this.loadError = ''
    try {
      const res = await CreditApi.my()
      if (res.code === 200) {
        this.score = res.score
        this.level = res.level
        this.lowCredit = res.lowCredit
        this.threshold = res.threshold
        this.records = res.records ?? []
      } else {
        this.loadError = res.message || '加载失败'
      }
    } catch (e) {
      this.loadError = '加载失败，请确认后端已启动并已登录'
    } finally {
      this.isLoading = false
    }
  }

  sourceLabel(source: string): string {
    return source === 'ADMIN' ? '管理员调整' : '系统判定'
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.back')).width(22).height(22)
          .onClick(() => { router.back() })
        Text('我的信用')
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
          Text(this.loadError).fontSize(14).fontColor('#999').textAlign(TextAlign.Center)
          Button('重新加载').fontSize(13).height(34)
            .backgroundColor('#1A5FD6').fontColor('#fff').borderRadius(17)
            .onClick(() => { this.load() })
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center).padding(24)
      } else {
        Scroll() {
          Column({ space: 12 }) {
            // 分数卡片
            Column({ space: 8 }) {
              Text('当前信誉分')
                .fontSize(13)
                .fontColor('#fff')
              Text(this.score.toString())
                .fontSize(52)
                .fontWeight(FontWeight.Bold)
                .fontColor('#fff')
              Text('等级：' + this.level)
                .fontSize(14)
                .fontColor('#fff')
                .padding({ left: 12, right: 12, top: 3, bottom: 3 })
                .backgroundColor('rgba(255,255,255,0.25)')
                .borderRadius(12)
            }
            .width('100%')
            .padding({ top: 26, bottom: 26 })
            .backgroundColor(levelColor(this.score))
            .borderRadius(12)

            if (this.lowCredit) {
              Column({ space: 4 }) {
                Text('信誉分不足，部分功能受限')
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#D93025')
                  .width('100%')
                Text('低于 ' + this.threshold + ' 分将无法发布新商品，已发布的商品会向其他用户标注「低信誉卖家」。')
                  .fontSize(12)
                  .fontColor('#8A4B00')
                  .width('100%')
              }
              .alignItems(HorizontalAlign.Start)
              .width('100%')
              .padding(14)
              .backgroundColor('#FFF3E8')
              .borderRadius(10)
            }

            // 规则说明
            Column({ space: 6 }) {
              Text('信誉分规则')
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333')
                .width('100%')
              Text('· 初始 100 分，范围 0~100')
                .fontSize(12).fontColor('#666').width('100%')
              Text('· 售后成立（商品与描述不符）：卖家 -10 分')
                .fontSize(12).fontColor('#666').width('100%')
              Text('· 售后申请被驳回：申请人 -5 分')
                .fontSize(12).fontColor('#666').width('100%')
              Text('· 订单交易完成：买卖双方各 +2 分')
                .fontSize(12).fontColor('#666').width('100%')
              Text('· 管理员可手动调整分值')
                .fontSize(12).fontColor('#666').width('100%')
              Text('· 低于 ' + this.threshold + ' 分：禁止发布新商品，商品标注低信誉')
                .fontSize(12).fontColor('#666').width('100%')
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
            .padding(14)
            .backgroundColor('#fff')
            .borderRadius(10)

            // 变动明细
            Column({ space: 8 }) {
              Text('信誉变动明细')
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333')
                .width('100%')

              if (this.records.length === 0) {
                Text('暂无变动记录')
                  .fontSize(13).fontColor('#999').width('100%').padding({ top: 8, bottom: 8 })
              } else {
                ForEach(this.records, (r: CreditRecordModel) => {
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

                    Row() {
                      Text(this.sourceLabel(r.source) + (r.operator ? '（' + r.operator + '）' : ''))
                        .fontSize(11)
                        .fontColor('#999')
                      Blank()
                      Text(r.scoreBefore.toString() + ' → ' + r.scoreAfter.toString())
                        .fontSize(11)
                        .fontColor('#999')
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
                }, (r: CreditRecordModel) => r.id.toString())
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
  }
}
