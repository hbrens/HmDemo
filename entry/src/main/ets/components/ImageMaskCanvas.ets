export interface MaskPoint {
  x: number;
  y: number;
}

@Component
export struct ImageMaskCanvas {
  @Prop imageResource: Resource = $r('app.media.demo_photo');
  @Prop maskOverlayResource: Resource = $r('app.media.demo_road_mask_overlay');
  @Link @Watch('drawMasks') clickPoints: MaskPoint[];

  private readonly contextSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private readonly canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.contextSettings);
  private canvasWidth: number = 0;
  private canvasHeight: number = 0;
  private isCanvasReady: boolean = false;

  build() {
    Stack() {
      Image(this.imageResource)
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      if (this.clickPoints.length > 0) {
        Image(this.maskOverlayResource)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
      }

      Canvas(this.canvasContext)
        .width('100%')
        .height('100%')
        .hitTestBehavior(HitTestMode.Transparent)
        .onReady(() => {
          this.isCanvasReady = true;
          this.drawMasks();
        })
        .onAreaChange((_, newArea: Area) => {
          this.canvasWidth = Number(newArea.width);
          this.canvasHeight = Number(newArea.height);
          this.drawMasks();
        })
    }
    .width('100%')
    .height('100%')
    .clip(true)
    .borderRadius(20)
    .backgroundColor('#111827')
    .onClick((event: ClickEvent) => {
      this.clickPoints = [
        ...this.clickPoints,
        {
          x: event.x,
          y: event.y
        }
      ];
      this.drawMasks();
    })
  }

  private drawMasks(): void {
    if (!this.isCanvasReady || this.canvasWidth <= 0 || this.canvasHeight <= 0) {
      return;
    }

    this.canvasContext.clearRect(0, 0, this.canvasWidth, this.canvasHeight);

    this.clickPoints.forEach((point: MaskPoint, index: number) => {
      this.drawClickMarker(point, index + 1);
    });
  }

  private drawClickMarker(point: MaskPoint, order: number): void {
    this.canvasContext.beginPath();
    this.canvasContext.arc(point.x, point.y, 7, 0, Math.PI * 2);
    this.canvasContext.fillStyle = '#FFFFFF';
    this.canvasContext.fill();
    this.canvasContext.lineWidth = 3;
    this.canvasContext.strokeStyle = '#111827';
    this.canvasContext.stroke();

    this.canvasContext.font = '14px sans-serif';
    this.canvasContext.fillStyle = '#FFFFFF';
    this.canvasContext.fillText(`${order}`, point.x + 12, point.y - 10);
  }
}
