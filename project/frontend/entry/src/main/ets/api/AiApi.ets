import { HttpUtil } from '../common/HttpUtil'
import { parseJson } from '../common/JsonHelper.js'

class AiAppraiseData {
  price: number = 0
  priceRange: string = ''
  title: string = ''
  description: string = ''
  analysis: string = ''
}

class AiResult {
  code: number = 0
  message: string = ''
  data: AiAppraiseData = new AiAppraiseData()
}

class AppraiseBody {
  name: string = ''
  description: string = ''
  quality: string = ''
}

export class AiApi {
  /** AI 智能估价 + 标题/描述生成 */
  static async appraise(name: string, description: string, quality: string): Promise<AiAppraiseData | null> {
    const body = new AppraiseBody()
    body.name = name
    body.description = description
    body.quality = quality
    const json = await HttpUtil.postLong('/ai/appraise', body)
    const result = parseJson(json) as AiResult
    if (result.code !== 200) {
      return null
    }
    return result.data ?? null
  }
}
