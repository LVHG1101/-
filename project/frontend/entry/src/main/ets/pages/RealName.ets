import { router } from '@kit.ArkUI'
import promptAction from '@ohos.promptAction'
import { UserApi } from '../api/UserApi'

@Entry
@Component
struct RealName {
  @State realName: string = ''
  @State idCard: string = ''
  @State verified: boolean = false
  @State maskedName: string = ''
  @State maskedIdCard: string = ''
  @State isSubmitting: boolean = false
  @State isLoading: boolean = true

  onPageShow(): void {
    this.load()
  }

  async load() {
    this.isLoading = true
    try {
      const p = await UserApi.info()
      if (p) {
        this.verified = p.verified
        this.maskedName = p.realName || ''
        this.maskedIdCard = p.idCard || ''
      }
    } catch (e) {
    } finally {
      this.isLoading = false
    }
  }

  async submit() {
    if (!this.realName.trim() || !this.idCard.trim()) {
      promptAction.showToast({ message: '请填写姓名和身份证号' })
      return
    }
    this.isSubmitting = true
    try {
      const resp = await UserApi.realName(this.realName.trim(), this.idCard.trim())
      promptAction.showToast({ message: resp.code === 200 ? '认证成功' : (resp.message || '认证失败') })
      if (resp.code === 200) {
        this.realName = ''
        this.idCard = ''
        await this.load()
      }
    } catch (e) {
      promptAction.showToast({ message: '网络请求失败' })
    } finally {
      this.isSubmitting = false
    }
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.back')).width(22).height(22)
          .onClick(() => { router.back() })
        Text('实名认证')
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
      } else if (this.verified) {
        Column({ space: 16 }) {
          Column({ space: 8 }) {
            Text('✅').fontSize(48)
            Text('已实名认证').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#2E9E5B')
          }
          .width('100%')
          .padding({ top: 40, bottom: 20 })

          Column({ space: 4 }) {
            Text('真实姓名：' + this.maskedName).fontSize(14).fontColor('#333').width('100%')
            Text('身份证号：' + this.maskedIdCard).fontSize(14).fontColor('#333').width('100%')
            Text('信息已加密脱敏展示').fontSize(11).fontColor('#999').width('100%').margin({ top: 6 })
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')
          .padding(16)
          .backgroundColor('#fff')
          .borderRadius(10)
        }
        .width('92%')
        .padding({ top: 12 })
      } else {
        Column({ space: 12 }) {
          Column({ space: 6 }) {
            Text('真实姓名').fontSize(14).fontColor('#333').width('100%')
            TextInput({ placeholder: '请输入真实姓名' })
              .height(44).fontSize(14)
              .onChange((v: string) => { this.realName = v })
          }
          .width('100%').padding(14).backgroundColor('#fff').borderRadius(10)

          Column({ space: 6 }) {
            Text('身份证号').fontSize(14).fontColor('#333').width('100%')
            TextInput({ placeholder: '请输入18位身份证号' })
              .height(44).fontSize(14).maxLength(18)
              .onChange((v: string) => { this.idCard = v })
          }
          .width('100%').padding(14).backgroundColor('#fff').borderRadius(10)

          Text('实名认证后发布商品将展示「已认证」标识，提升交易信任度。')
            .fontSize(12).fontColor('#999').width('100%')

          Button(this.isSubmitting ? '提交中...' : '提交认证')
            .width('100%').height(46)
            .fontColor('#fff').backgroundColor('#1A5FD6').borderRadius(23)
            .enabled(!this.isSubmitting)
            .margin({ top: 8 })
            .onClick(() => { this.submit() })
        }
        .width('92%')
        .padding({ top: 16 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}
