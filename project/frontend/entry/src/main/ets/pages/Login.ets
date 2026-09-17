import { router } from '@kit.ArkUI'
import promptAction from '@ohos.promptAction'
import { UserApi } from '../api/UserApi'
import { UserStore } from '../common/UserStore'

@Entry
@Component
struct Login {
  @State username: string = ''
  @State password: string = ''
  @State isLoading: boolean = false

  async doLogin() {
    if (!this.username.trim()) {
      promptAction.showToast({ message: '请输入用户名' })
      return
    }
    if (!this.password.trim()) {
      promptAction.showToast({ message: '请输入密码' })
      return
    }

    this.isLoading = true
    try {
      const resp = await UserApi.login(this.username, this.password)
      if (resp.code === 200) {
        const token = resp.token || ''
        const nickname = resp.nickname || this.username
        await UserStore.saveLogin(token, this.username, nickname)
        promptAction.showToast({ message: '登录成功' })
        router.back()
      } else {
        promptAction.showToast({ message: resp.message || '登录失败' })
      }
    } catch (e) {
      promptAction.showToast({ message: '网络请求失败，请检查后端地址是否正确' })
    } finally {
      this.isLoading = false
    }
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.back')).width(24).height(24)
          .onClick(() => { router.back() })
      }
      .width('100%')
      .padding({ left: 16, top: 16 })

      Column() {
        Text('二手交易平台')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#e0620d')
          .margin({ top: 40, bottom: 50 })

        TextInput({ placeholder: '请输入用户名' })
          .height(48)
          .borderRadius(8)
          .backgroundColor('#F5F5F5')
          .margin({ bottom: 16 })
          .onChange((v: string) => { this.username = v })

        TextInput({ placeholder: '请输入密码' })
          .type(InputType.Password)
          .height(48)
          .borderRadius(8)
          .backgroundColor('#F5F5F5')
          .margin({ bottom: 24 })
          .onChange((v: string) => { this.password = v })

        Button(this.isLoading ? '登录中...' : '登录')
          .width('100%')
          .height(48)
          .backgroundColor('#e0620d')
          .fontColor('#fff')
          .borderRadius(24)
          .enabled(!this.isLoading)
          .onClick(() => { this.doLogin() })

        Row() {
          Text('还没有账号？').fontSize(14).fontColor('#999')
          Text('立即注册')
            .fontSize(14)
            .fontColor('#e0620d')
            .margin({ left: 4 })
            .onClick(() => {
              router.pushUrl({ url: 'pages/Register' })
            })
        }
        .margin({ top: 16 })
      }
      .width('100%')
      .padding({ left: 32, right: 32 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#fff')
  }
}
