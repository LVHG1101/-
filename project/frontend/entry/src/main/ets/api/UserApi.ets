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

class LoginBody {
  username: string = ''
  password: string = ''
}

class RegisterBody {
  username: string = ''
  password: string = ''
  nickname: string = ''
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
}
