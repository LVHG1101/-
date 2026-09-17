import { http } from '@kit.NetworkKit'
import { ApiConfig } from '../api/ApiConfig'
import { UserStore } from './UserStore'

export class HttpUtil {
  static async get(path: string): Promise<string> {
    const req = http.createHttp()
    try {
      const resp = await req.request(ApiConfig.BASE_URL + path, {
        method: http.RequestMethod.GET,
        header: { 'Content-Type': 'application/json' },
        connectTimeout: 10000,
        readTimeout: 10000
      })
      return resp.result as string
    } finally {
      req.destroy()
    }
  }

  static async post(path: string, body: object): Promise<string> {
    const req = http.createHttp()
    try {
      const resp = await req.request(ApiConfig.BASE_URL + path, {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'application/json' },
        extraData: JSON.stringify(body),
        connectTimeout: 10000,
        readTimeout: 10000
      })
      return resp.result as string
    } finally {
      req.destroy()
    }
  }

  static async getWithAuth(path: string): Promise<string> {
    const token = await UserStore.getToken()
    const req = http.createHttp()
    try {
      const resp = await req.request(ApiConfig.BASE_URL + path, {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json',
          'Authorization': token ? 'Bearer ' + token : ''
        },
        connectTimeout: 10000,
        readTimeout: 10000
      })
      return resp.result as string
    } finally {
      req.destroy()
    }
  }

  static async postWithAuth(path: string, body: object): Promise<string> {
    const token = await UserStore.getToken()
    const req = http.createHttp()
    try {
      const resp = await req.request(ApiConfig.BASE_URL + path, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'Authorization': token ? 'Bearer ' + token : ''
        },
        extraData: JSON.stringify(body),
        connectTimeout: 10000,
        readTimeout: 10000
      })
      return resp.result as string
    } finally {
      req.destroy()
    }
  }
}
