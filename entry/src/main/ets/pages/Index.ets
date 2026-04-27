import { ImageMaskCanvas, MaskPoint } from '../components/ImageMaskCanvas';

@Entry
@Component
struct Index {
  @State imageResource: Resource = $r('app.media.demo_photo');
  @State clickPoints: MaskPoint[] = [];

  build() {
    Column({ space: 16 }) {
      Column({ space: 6 }) {
        Text('Image Mask Demo')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111827')

        Text('点击图片，模拟后端返回二值 mask 并绘制到 Canvas 覆盖层')
          .fontSize(14)
          .fontColor('#6B7280')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      ImageMaskCanvas({
        imageResource: this.imageResource,
        clickPoints: this.clickPoints
      })
        .width('100%')
        .layoutWeight(1)

      Row({ space: 12 }) {
        Text(`点击坐标：${this.clickPoints.length}`)
          .fontSize(14)
          .fontColor('#374151')
          .layoutWeight(1)

        Button('清空')
          .enabled(this.clickPoints.length > 0)
          .onClick(() => {
            this.clickPoints = [];
          })
      }
      .width('100%')
      .height(44)
    }
    .width('100%')
    .height('100%')
    .padding(20)
    .backgroundColor('#F3F4F6')
  }
}
