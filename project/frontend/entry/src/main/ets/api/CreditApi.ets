import { HttpUtil } from '../common/HttpUtil'
import { parseJson } from '../common/JsonHelper.js'

/** 信誉分变动流水 */
export class CreditRecordModel {
  id: number = 0
  userId: number = 0
  username: string = ''
  delta: number = 0
  scoreBefore: number = 0
  scoreAfter: number = 0
  reason: string = ''
  source: string = ''
  operator: string = ''
  createTime: string = ''
}

/** 管理端用户列表条目 */
export class AdminUserModel {
  id: number = 0
  username: string = ''
  nickname: string = ''
  role: string = ''
  creditScore: number = 100
  creditLevel: string = ''
  lowCredit: boolean = false
}

class MyCreditResult {
  code: number = 0
  message: string = ''
  score: number = 100
  level: string = ''
  lowCredit: boolean = false
  threshold: number = 60
  records: CreditRecordModel[] = []
}

class UserListResult {
  code: number = 0
  message: string = ''
  data: AdminUserModel[] = []
}

class ApiResult {
  code: number = 0
  message: string = ''
}

class SetScoreBody {
  userId: number = 0
  score: number = 100
  reason: string = ''
}

export class CreditApi {
  /** 我的信誉分与变动明细 */
  static async my(): Promise<MyCreditResult> {
    const json = await HttpUtil.getWithAuth('/user/credit')
    return parseJson(json) as MyCreditResult
  }

  /** 管理端：用户列表（含信誉分） */
  static async users(): Promise<AdminUserModel[]> {
    const json = await HttpUtil.getWithAuth('/admin/users')
    const result = parseJson(json) as UserListResult
    if (result.code !== 200) {
      return []
    }
    return result.data ?? []
  }

  /** 管理端：手动设定某用户信誉分 */
  static async setScore(userId: number, score: number, reason: string): Promise<ApiResult> {
    const body = new SetScoreBody()
    body.userId = userId
    body.score = score
    body.reason = reason
    const json = await HttpUtil.postWithAuth('/admin/credit/set', body)
    return parseJson(json) as ApiResult
  }
}
