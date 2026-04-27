import { ImageMaskCanvas, MaskPoint } from '../components/ImageMaskCanvas';

@Entry
@Component
struct Index {
  private readonly demoImageResource: Resource = $r('app.media.demo_photo');
  private readonly demoImagePixelWidth: number = 1200;
  private readonly demoImagePixelHeight: number = 1800;

  @State clickPoints: MaskPoint[] = [];
  @State maskVersion: number = 0;
  @State statusText: string = 'Tap the image to pick a prompt point. The page will send it to a mock model service.';
  @State isSegmenting: boolean = false;
  private maskRequestSerial: number = 0;

  build() {
    Column({ space: 16 }) {
      Column({ space: 6 }) {
        Text('Image Mask Demo')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111827')

        Text(this.statusText)
          .fontSize(14)
          .fontColor('#6B7280')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      ImageMaskCanvas({
        imageResource: this.demoImageResource,
        maskVersion: this.maskVersion,
        imagePixelWidth: this.demoImagePixelWidth,
        imagePixelHeight: this.demoImagePixelHeight,
        clickPoints: this.clickPoints,
        onMaskRequest: (point: MaskPoint) => {
          this.requestMask(point);
        }
      })
        .width('100%')
        .layoutWeight(1)

      Row({ space: 12 }) {
        Text(this.getFooterText())
          .fontSize(14)
          .fontColor('#374151')
          .layoutWeight(1)

        Button('Reset')
          .enabled(this.clickPoints.length > 0 && !this.isSegmenting)
          .onClick(() => {
            this.resetDemo();
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

  private requestMask(point: MaskPoint): void {
    this.maskVersion = 0;
    this.isSegmenting = true;
    this.statusText = `Point received at (${Math.round(point.x)}, ${Math.round(point.y)}). Requesting mask...`;

    const requestSerial: number = ++this.maskRequestSerial;

    setTimeout(() => {
      if (requestSerial !== this.maskRequestSerial) {
        return;
      }
      this.maskVersion = requestSerial;
      this.isSegmenting = false;
      this.statusText = 'Mask returned. The child component renders the overlay after receiving it.';
    }, 600);
  }

  private resetDemo(): void {
    this.clickPoints = [];
    this.maskVersion = 0;
    this.isSegmenting = false;
    this.maskRequestSerial += 1;
    this.statusText = 'Tap the image to pick a prompt point. The page will send it to a mock model service.';
  }

  private getFooterText(): string {
    if (this.isSegmenting) {
      return `Sent ${this.clickPoints.length} point(s). Waiting for mask...`;
    }
    return this.maskVersion > 0 ? `Mask visible. Point count: ${this.clickPoints.length}` : `Point count: ${this.clickPoints.length}`;
  }
}
