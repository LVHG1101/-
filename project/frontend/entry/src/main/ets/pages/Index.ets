import { buildHomeTab } from '../tabs/HomeTab'
import { buildCategoryTab } from '../tabs/CategoryTab'
import { buildServiceTab } from '../tabs/ServiceTab'
import { buildCartTab } from '../tabs/CartTab'
import { buildMyTab } from '../tabs/my/MyTab'

@Entry
@Component
struct Index {
  @State currTabIndex: number = 0;
  @Provide
  private navPathStack: NavPathStack = new NavPathStack();

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
          buildServiceTab()
        }.tabBar(this.buildTabBar($r('app.string.tab_bar_service'), 2))

        TabContent() {
          buildCartTab()
        }.tabBar(this.buildTabBar($r('app.string.tab_bar_cart'), 3))

        TabContent() {
          buildMyTab()
        }.tabBar(this.buildTabBar($r('app.string.tab_bar_my'), 4))
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
