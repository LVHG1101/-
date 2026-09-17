export class ApiConfig {
  // 模拟器：10.0.2.2 是模拟器访问「宿主机 localhost」的固定地址，后端跑在本机 8080 即可
  // 真机调试：改成电脑的局域网 IP（cmd 里执行 ipconfig 查看），并确保手机与电脑在同一 WiFi
  static readonly BASE_URL: string = 'http://10.0.2.2:8080'
}
