export interface MaskPoint {
  x: number;
  y: number;
}

@Component
export struct ImageMaskCanvas {
  @Prop imageResource: Resource = $r('app.media.demo_photo');
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
      this.drawBinaryMask(point, index);
      this.drawClickMarker(point, index + 1);
    });
  }

  private drawBinaryMask(point: MaskPoint, index: number): void {
    const maskWidth: number = 150;
    const maskHeight: number = 110;
    const pixelSize: number = 2;
    const startX: number = Math.max(0, Math.min(point.x - maskWidth / 2, this.canvasWidth - maskWidth));
    const startY: number = Math.max(0, Math.min(point.y - maskHeight / 2, this.canvasHeight - maskHeight));
    const colorOffset: number = index % 3;
    const fillColor: string = colorOffset === 0 ? 'rgba(0, 160, 255, 0.36)' :
      colorOffset === 1 ? 'rgba(255, 220, 80, 0.36)' : 'rgba(255, 120, 255, 0.36)';

    this.canvasContext.fillStyle = fillColor;

    for (let row = 0; row < maskHeight; row += pixelSize) {
      for (let col = 0; col < maskWidth; col += pixelSize) {
        const normalizedX: number = (col - maskWidth / 2) / (maskWidth * 0.35);
        const normalizedY: number = (row - maskHeight / 2) / (maskHeight * 0.36);
        const wave: number = Math.sin(col * 0.13 + index) * 0.18 + Math.cos(row * 0.17) * 0.12;
        const isMaskPixel: boolean = normalizedX * normalizedX + normalizedY * normalizedY + wave <= 1;

        if (isMaskPixel) {
          this.canvasContext.fillRect(startX + col, startY + row, pixelSize, pixelSize);
        }
      }
    }
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
