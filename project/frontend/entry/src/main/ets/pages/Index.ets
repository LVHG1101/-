import { buildHomeTab } from '../tabs/HomeTab'
import { buildCategoryTab } from '../tabs/CategoryTab'
import { buildPublishTab } from '../tabs/PublishTab'
import { buildServiceTab } from '../tabs/ServiceTab'
import { buildCartTab } from '../tabs/CartTab'
import { buildMyTab } from '../tabs/my/MyTab'

@Entry
@Component
struct Index {
  @StorageLink('currTabIndex') currTabIndex: number = 0;
  @Provide
  private navPathStack: NavPathStack = new NavPathStack();

  /**
   * Index 是 @Entry 页面，从子页面返回时只有它会收到 onPageShow。
   * 这里把事件广播出去，让 Tab 里的子组件也能知道「页面又可见了」并刷新数据。
   */
  onPageShow(): void {
    const tick: number | undefined = AppStorage.get<number>('pageShowTick')
    AppStorage.setOrCreate<number>('pageShowTick', (tick === undefined ? 0 : tick) + 1)
  }

  @Builder
  buildTabBar(txt: Resource, idx: number) {
    Column({ space: 4 }) {
      Text(txt)
        .fontSize(14)
        .fontWeight(this.currTabIndex === idx ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.currTabIndex === idx ? $r('app.color.tab_bar_selected_font_color') :
          $r('app.color.tab_bar_def_font_color'))
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 8, bottom: 8 })
  }

  build() {
    Navigation(this.navPathStack) {
      Tabs({ index: this.currTabIndex }) {
        TabContent() {
          buildHomeTab()
        }.tabBar(this.buildTabBar($r('app.string.tab_bar_home'), 0))

        TabContent() {
          buildCategoryTab()
        }.tabBar(this.buildTabBar($r('app.string.tab_bar_category'), 1))

        TabContent() {
          buildPublishTab()
        }.tabBar(this.buildTabBar($r('app.string.tab_bar_publish'), 2))

        TabContent() {
          buildServiceTab()
        }.tabBar(this.buildTabBar($r('app.string.tab_bar_service'), 3))

        TabContent() {
          buildCartTab()
        }.tabBar(this.buildTabBar($r('app.string.tab_bar_cart'), 4))

        TabContent() {
          buildMyTab()
        }.tabBar(this.buildTabBar($r('app.string.tab_bar_my'), 5))
      }
      .width('100%')
      .height('100%')
      .barPosition(BarPosition.End)
      .onChange((index: number) => {
        this.currTabIndex = index;
      })
    }
    .hideToolBar(true)
    .hideTitleBar(true)
  }
}
