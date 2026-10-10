import { HttpUtil } from '../common/HttpUtil'
import { parseJson } from '../common/JsonHelper.js'

export class LoginResult {
  code: number = 0
  message: string = ''
  token: string = ''
  username: string = ''
  nickname: string = ''
  role: string = 'user'
}

export class ApiResult {
  code: number = 0
  message: string = ''
}

export class ProfileModel {
  username: string = ''
  nickname: string = ''
  role: string = 'user'
  creditScore: number = 100
  creditLevel: string = ''
  verified: boolean = false
  realName: string = ''
  idCard: string = ''
}

class ProfileResult {
  code: number = 0
  message: string = ''
  data: ProfileModel = new ProfileModel()
}

class LoginBody {
  username: string = ''
  password: string = ''
}

class RegisterBody {
  username: string = ''
  password: string = ''
  nickname: string = ''
}

class RealNameBody {
  realName: string = ''
  idCard: string = ''
}

export class UserApi {
  static async register(username: string, password: string, nickname: string): Promise<ApiResult> {
    const body = new RegisterBody()
    body.username = username
    body.password = password
    body.nickname = nickname
    const json = await HttpUtil.post('/user/register', body)
    return parseJson(json) as ApiResult
  }

  static async login(username: string, password: string): Promise<LoginResult> {
    const body = new LoginBody()
    body.username = username
    body.password = password
    const json = await HttpUtil.post('/user/login', body)
    return parseJson(json) as LoginResult
  }

  static async info(): Promise<ProfileModel | null> {
    const json = await HttpUtil.getWithAuth('/user/info')
    const result = parseJson(json) as ProfileResult
    if (result.code !== 200) {
      return null
    }
    return result.data ?? null
  }

  static async realName(realName: string, idCard: string): Promise<ApiResult> {
    const body = new RealNameBody()
    body.realName = realName
    body.idCard = idCard
    const json = await HttpUtil.postWithAuth('/user/realname', body)
    return parseJson(json) as ApiResult
  }
}
