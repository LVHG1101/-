import { router } from '@kit.ArkUI'
import { UserApi, ProfileModel } from '../api/UserApi'

@Entry
@Component
struct Profile {
  @State profile: ProfileModel | null = null
  @State isLoading: boolean = true
  @State loadError: string = ''

  onPageShow(): void {
    this.load()
  }

  async load() {
    this.isLoading = true
    this.loadError = ''
    try {
      this.profile = await UserApi.info()
      if (!this.profile) {
        this.loadError = '请先登录'
      }
    } catch (e) {
      this.loadError = '加载失败，请确认后端已启动并已登录'
    } finally {
      this.isLoading = false
    }
  }

  @Builder
  infoRow(label: string, value: string) {
    Row() {
      Text(label).fontSize(14).fontColor('#999').width(90)
      Text(value).fontSize(14).fontColor('#333').layoutWeight(1)
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.back')).width(22).height(22)
          .onClick(() => { router.back() })
        Text('个人资料')
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
      } else if (this.profile) {
        Column({ space: 12 }) {
          Column({ space: 10 }) {
            Image($r('app.media.my')).width(64).height(64).borderRadius(32)
            Text(this.profile.nickname || this.profile.username)
              .fontSize(20).fontWeight(FontWeight.Bold).fontColor('#333')
            Text(this.profile.role === 'admin' ? '管理员' : '普通用户')
              .fontSize(12).fontColor('#fff')
              .padding({ left: 10, right: 10, top: 3, bottom: 3 })
              .backgroundColor('#1A5FD6').borderRadius(11)
          }
          .width('100%')
          .padding({ top: 24, bottom: 24 })
          .backgroundColor('#fff')
          .borderRadius(10)

          Column() {
            this.infoRow('账号', this.profile.username)
            Divider().color('#F0F0F0')
            this.infoRow('昵称', this.profile.nickname || '-')
            Divider().color('#F0F0F0')
            this.infoRow('信誉分', this.profile.creditScore + ' 分（' + this.profile.creditLevel + '）')
            Divider().color('#F0F0F0')
            this.infoRow('实名认证', this.profile.verified ? '已认证' : '未认证')
            Divider().color('#F0F0F0')
            this.infoRow('真实姓名', this.profile.realName || '-')
            Divider().color('#F0F0F0')
            this.infoRow('身份证号', this.profile.idCard || '-')
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
          .backgroundColor('#fff')
          .borderRadius(10)
        }
        .width('92%')
        .padding({ top: 12 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}
