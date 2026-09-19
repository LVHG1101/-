import preferences from '@ohos.data.preferences'
import { common } from '@kit.AbilityKit'

const PREF_NAME = 'secondhand_user_pref'
const KEY_TOKEN = 'token'
const KEY_USERNAME = 'username'
const KEY_NICKNAME = 'nickname'
const KEY_ROLE = 'role'

export class UserStore {
  private static store: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    UserStore.store = await preferences.getPreferences(context, PREF_NAME)
  }

  private static async getStore(): Promise<preferences.Preferences> {
    if (!UserStore.store) {
      throw new Error('UserStore 尚未初始化，请先在 EntryAbility 调用 UserStore.init(context)')
    }
    return UserStore.store
  }

  static async saveLogin(token: string, username: string, nickname: string, role: string): Promise<void> {
    const store = await UserStore.getStore()
    await store.put(KEY_TOKEN, token)
    await store.put(KEY_USERNAME, username)
    await store.put(KEY_NICKNAME, nickname)
    await store.put(KEY_ROLE, role)
    await store.flush()
  }

  static async getToken(): Promise<string> {
    if (!UserStore.store) {
      return ''
    }
    const store = await UserStore.getStore()
    return await store.get(KEY_TOKEN, '') as string
  }

  static async getUsername(): Promise<string> {
    if (!UserStore.store) {
      return ''
    }
    const store = await UserStore.getStore()
    return await store.get(KEY_USERNAME, '') as string
  }

  static async getNickname(): Promise<string> {
    if (!UserStore.store) {
      return ''
    }
    const store = await UserStore.getStore()
    return await store.get(KEY_NICKNAME, '') as string
  }

  static async getRole(): Promise<string> {
    if (!UserStore.store) {
      return 'user'
    }
    const store = await UserStore.getStore()
    return await store.get(KEY_ROLE, 'user') as string
  }

  /** 当前登录账号是否为管理员 */
  static async isAdmin(): Promise<boolean> {
    const loggedIn = await UserStore.isLoggedIn()
    if (!loggedIn) {
      return false
    }
    return (await UserStore.getRole()) === 'admin'
  }

  static async isLoggedIn(): Promise<boolean> {
    const token = await UserStore.getToken()
    return token !== null && token !== undefined && token !== ''
  }

  static async logout(): Promise<void> {
    const store = await UserStore.getStore()
    await store.delete(KEY_TOKEN)
    await store.delete(KEY_USERNAME)
    await store.delete(KEY_NICKNAME)
    await store.delete(KEY_ROLE)
    await store.flush()
  }

  /**
   * 广播「登录状态已变化」。
   * Tab 中的子组件不是 @Entry，收不到 onPageShow，只能靠 AppStorage 的变化触发刷新。
   * 登录页登录成功后、退出登录后调用。
   */
  static notifyLoginStateChanged(): void {
    const current: number | undefined = AppStorage.get<number>('loginTick')
    AppStorage.setOrCreate<number>('loginTick', (current === undefined ? 0 : current) + 1)
  }
}
