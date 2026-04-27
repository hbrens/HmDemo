import { ImageMaskCanvas, MaskPoint } from '../components/ImageMaskCanvas';

@Entry
@Component
struct Index {
  private readonly demoImageResource: Resource = $r('app.media.demo_photo');
  private readonly demoMaskResource: Resource = $r('app.media.demo_road_mask_overlay');
  private readonly demoImagePixelWidth: number = 1200;
  private readonly demoImagePixelHeight: number = 1800;

  @State clickPoints: MaskPoint[] = [];

  build() {
    Column({ space: 16 }) {
      Column({ space: 6 }) {
        Text('Image Mask Demo')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111827')

        Text('????? mask ?? Canvas ???????????? mask')
          .fontSize(14)
          .fontColor('#6B7280')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      ImageMaskCanvas({
        imageResource: this.demoImageResource,
        maskResource: this.demoMaskResource,
        imagePixelWidth: this.demoImagePixelWidth,
        imagePixelHeight: this.demoImagePixelHeight,
        clickPoints: this.clickPoints
      })
        .width('100%')
        .layoutWeight(1)

      Row({ space: 12 }) {
        Text(`${this.clickPoints.length}`)
          .fontSize(14)
          .fontColor('#374151')
          .layoutWeight(1)

        Button('??')
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
