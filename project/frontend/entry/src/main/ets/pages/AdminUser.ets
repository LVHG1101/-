import { router } from '@kit.ArkUI'
import promptAction from '@ohos.promptAction'
import { CreditApi, AdminUserModel } from '../api/CreditApi'

function scoreColor(score: number): string {
  if (score >= 90) return '#2E9E5B'
  if (score >= 75) return '#1A5FD6'
  if (score >= 60) return '#e0620d'
  return '#D93025'
}

@Entry
@Component
struct AdminUser {
  @State list: AdminUserModel[] = []
  @State isLoading: boolean = true
  @State loadError: string = ''

  // 调整弹层
  @State editing: boolean = false
  @State editUserId: number = 0
  @State editName: string = ''
  @State formScore: string = '100'
  @State formReason: string = ''

  onPageShow(): void {
    this.load()
  }

  async load() {
    this.isLoading = true
    this.loadError = ''
    try {
      this.list = await CreditApi.users()
    } catch (e) {
      this.list = []
      this.loadError = '加载失败，请确认后端已启动且当前账号为管理员'
    } finally {
      this.isLoading = false
    }
  }

  openEdit(item: AdminUserModel) {
    this.editUserId = item.id
    this.editName = item.nickname ? item.nickname : item.username
    this.formScore = item.creditScore.toString()
    this.formReason = ''
    this.editing = true
  }

  async save() {
    const score = Number(this.formScore)
    if (isNaN(score) || score < 0 || score > 100) {
      promptAction.showToast({ message: '信誉分必须是 0~100 的整数' })
      return
    }
    try {
      const resp = await CreditApi.setScore(this.editUserId, Math.round(score),
        this.formReason.trim() ? this.formReason.trim() : '管理员手动调整')
      if (resp.code === 200) {
        promptAction.showToast({ message: '信誉分已更新' })
        this.editing = false
        this.load()
      } else {
        promptAction.showToast({ message: resp.message || '保存失败' })
      }
    } catch (e) {
      promptAction.showToast({ message: '网络请求失败' })
    }
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.back')).width(22).height(22)
          .onClick(() => { router.back() })
        Text('用户信誉管理')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Blank().width(22)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      .backgroundColor('#fff')

      if (this.editing) {
        Scroll() {
          Column({ space: 12 }) {
            Text('调整信誉分')
              .fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333').width('100%')
            Text('用户：' + this.editName)
              .fontSize(13).fontColor('#666').width('100%')

            TextInput({ placeholder: '信誉分（0~100）', text: this.formScore })
              .type(InputType.Number)
              .height(44).borderRadius(8).backgroundColor('#F5F5F5')
              .onChange((v: string) => { this.formScore = v })

            TextArea({ placeholder: '调整原因（会记入信誉流水）', text: this.formReason })
              .height(80).borderRadius(8).backgroundColor('#F5F5F5')
              .onChange((v: string) => { this.formReason = v })

            Text('提示：低于 60 分的用户将被禁止发布新商品，其已有商品会标注「低信誉卖家」。')
              .fontSize(11).fontColor('#999').width('100%')

            Row({ space: 12 }) {
              Button('取消')
                .layoutWeight(1).height(44)
                .backgroundColor('#F5F5F5').fontColor('#666').borderRadius(22)
                .onClick(() => { this.editing = false })
              Button('保存')
                .layoutWeight(1).height(44)
                .backgroundColor('#1A5FD6').fontColor('#fff').borderRadius(22)
                .onClick(() => { this.save() })
            }
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#fff')
          .borderRadius(10)
        }
        .layoutWeight(1)
        .padding(12)
        .backgroundColor('#f5f5f5')
      } else if (this.isLoading) {
        Column() { LoadingProgress().width(40).height(40).color('#1A5FD6') }
          .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else if (this.loadError !== '') {
        Column({ space: 12 }) {
          Text(this.loadError).fontSize(13).fontColor('#999').textAlign(TextAlign.Center)
          Button('重新加载').fontSize(13).height(34)
            .backgroundColor('#1A5FD6').fontColor('#fff').borderRadius(17)
            .onClick(() => { this.load() })
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center).padding(24)
      } else {
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.list, (item: AdminUserModel) => {
              Column({ space: 8 }) {
                Row() {
                  Column({ space: 3 }) {
                    Row({ space: 6 }) {
                      Text(item.nickname ? item.nickname : item.username)
                        .fontSize(15).fontWeight(FontWeight.Bold).fontColor('#333')
                      if (item.role === 'admin') {
                        Text('管理员')
                          .fontSize(10).fontColor('#fff')
                          .backgroundColor('#1A5FD6')
                          .padding({ left: 6, right: 6, top: 1, bottom: 1 })
                          .borderRadius(8)
                      }
                    }
                    Text('账号：' + item.username)
                      .fontSize(11).fontColor('#999')
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)

                  Column({ space: 2 }) {
                    Text(item.creditScore.toString())
                      .fontSize(22).fontWeight(FontWeight.Bold)
                      .fontColor(scoreColor(item.creditScore))
                    Text(item.creditLevel)
                      .fontSize(10).fontColor('#999')
                  }
                  .alignItems(HorizontalAlign.End)
                }
                .width('100%')

                if (item.lowCredit) {
                  Text('低信誉：禁止发布新商品，商品标注警告')
                    .fontSize(11)
                    .fontColor('#D93025')
                    .width('100%')
                    .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                    .backgroundColor('#FDECEA')
                    .borderRadius(6)
                }

                Row({ space: 10 }) {
                  Blank()
                  Button('调整信誉分')
                    .fontSize(12).height(32)
                    .backgroundColor('#EAF2FF').fontColor('#1A5FD6')
                    .borderRadius(16).padding({ left: 14, right: 14 })
                    .onClick(() => { this.openEdit(item) })
                }
                .width('100%')
              }
              .width('100%')
              .padding(14)
              .backgroundColor('#fff')
              .borderRadius(8)
            }, (item: AdminUserModel) => item.id.toString())
          }
          .padding(12)
        }
        .layoutWeight(1)
        .backgroundColor('#f5f5f5')
      }
    }
    .width('100%')
    .height('100%')
  }
}
