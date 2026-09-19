import { router } from '@kit.ArkUI'
import promptAction from '@ohos.promptAction'
import { UserApi } from '../api/UserApi'

@Entry
@Component
struct Register {
  @State username: string = ''
  @State nickname: string = ''
  @State password: string = ''
  @State confirmPassword: string = ''
  @State isLoading: boolean = false

  async doRegister() {
    if (!this.username.trim()) {
      promptAction.showToast({ message: '请输入用户名' })
      return
    }
    if (!this.password.trim()) {
      promptAction.showToast({ message: '请输入密码' })
      return
    }
    if (this.password !== this.confirmPassword) {
      promptAction.showToast({ message: '两次输入的密码不一致' })
      return
    }

    this.isLoading = true
    try {
      const resp = await UserApi.register(this.username, this.password, this.nickname.trim())
      if (resp.code === 200) {
        // 把刚注册的账号带回登录页自动填好，避免用户以为「点了没反应」
        AppStorage.setOrCreate<string>('lastRegisteredUser', this.username)
        promptAction.showToast({ message: '注册成功，请登录' })
        router.back()
      } else {
        promptAction.showToast({ message: resp.message || '注册失败' })
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
        Text('注册账号')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#e0620d')
          .margin({ top: 30, bottom: 40 })

        TextInput({ placeholder: '请输入用户名' })
          .height(48)
          .borderRadius(8)
          .backgroundColor('#F5F5F5')
          .margin({ bottom: 16 })
          .onChange((v: string) => { this.username = v })

        TextInput({ placeholder: '请输入昵称（可留空）' })
          .height(48)
          .borderRadius(8)
          .backgroundColor('#F5F5F5')
          .margin({ bottom: 16 })
          .onChange((v: string) => { this.nickname = v })

        TextInput({ placeholder: '请输入密码' })
          .type(InputType.Password)
          .height(48)
          .borderRadius(8)
          .backgroundColor('#F5F5F5')
          .margin({ bottom: 16 })
          .onChange((v: string) => { this.password = v })

        TextInput({ placeholder: '请再次输入密码' })
          .type(InputType.Password)
          .height(48)
          .borderRadius(8)
          .backgroundColor('#F5F5F5')
          .margin({ bottom: 24 })
          .onChange((v: string) => { this.confirmPassword = v })

        Button(this.isLoading ? '注册中...' : '注册')
          .width('100%')
          .height(48)
          .backgroundColor('#e0620d')
          .fontColor('#fff')
          .borderRadius(24)
          .enabled(!this.isLoading)
          .onClick(() => { this.doRegister() })
      }
      .width('100%')
      .padding({ left: 32, right: 32 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#fff')
  }
}
