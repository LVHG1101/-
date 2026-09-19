export class ApiConfig {
  /**
   * 后端地址，三种运行环境的值不一样，改完必须重新编译：
   *   DevEco Previewer 预览器（跑在你电脑上） -> http://127.0.0.1:8080
   *   鸿蒙模拟器（NAT 把 10.0.2.2 映射到宿主机）-> http://10.0.2.2:8080
   *   真机（手机与电脑连同一个 WiFi）          -> http://<电脑局域网IP>:8080，用 ipconfig 查看
   */
  static readonly BASE_URL: string = 'http://127.0.0.1:8080'
}
