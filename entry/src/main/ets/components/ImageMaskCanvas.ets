import { image } from '@kit.ImageKit';

export interface MaskPoint {
  x: number;
  y: number;
}

export type MaskRequestCallback = (point: MaskPoint) => void;

@Component
export struct ImageMaskCanvas {
  @Prop imageResource: Resource;
  @Prop @Watch('drawScene') maskVersion: number;
  @Prop imagePixelWidth: number;
  @Prop imagePixelHeight: number;
  @Link @Watch('drawScene') clickPoints: MaskPoint[];
  onMaskRequest: MaskRequestCallback = () => {};

  private readonly demoMaskResource: Resource = $r('app.media.demo_road_mask_overlay');

  private readonly contextSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private readonly canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.contextSettings);
  private maskPixelMap?: image.PixelMap;
  private isMaskLoading: boolean = false;
  private canvasWidth: number = 0;
  private canvasHeight: number = 0;
  private isCanvasReady: boolean = false;

  async aboutToAppear(): Promise<void> {
    this.drawScene();
  }

  build() {
    Stack() {
      Image(this.imageResource)
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      Canvas(this.canvasContext)
        .width('100%')
        .height('100%')
        .onReady(() => {
          this.isCanvasReady = true;
          this.drawScene();
        })
        .onAreaChange((_, newArea: Area) => {
          this.canvasWidth = Number(newArea.width);
          this.canvasHeight = Number(newArea.height);
          this.drawScene();
        })
        .onClick((event: ClickEvent) => {
          const point: MaskPoint = {
            x: event.x,
            y: event.y
          };
          this.clickPoints = [...this.clickPoints, point];
          this.onMaskRequest(point);
          this.drawScene();
        })
    }
      .width('100%')
      .height('100%')
      .clip(true)
      .borderRadius(20)
      .backgroundColor('#111827')
  }

  private async loadMaskResource(): Promise<void> {
    if (this.isMaskLoading) {
      return;
    }

    this.isMaskLoading = true;
    try {
      this.maskPixelMap = await this.loadPixelMap(this.demoMaskResource);
      this.drawScene();
    } finally {
      this.isMaskLoading = false;
    }
  }

  private async loadPixelMap(resource: Resource): Promise<image.PixelMap> {
    const hostContext = this.getUIContext().getHostContext();
    const mediaContent = await hostContext?.resourceManager?.getMediaContent({
      bundleName: resource.bundleName,
      moduleName: resource.moduleName,
      id: resource.id
    });

    if (!mediaContent) {
      throw new Error('Failed to load media content.');
    }

    const imageSource = image.createImageSource(mediaContent.buffer.slice(0, mediaContent.byteLength));
    const pixelMap = await imageSource.createPixelMap({ desiredPixelFormat: image.PixelMapFormat.RGBA_8888 });
    imageSource.release();
    return pixelMap;
  }

  private drawScene(): void {
    if (!this.isCanvasReady || this.canvasWidth <= 0 || this.canvasHeight <= 0) {
      return;
    }

    this.ensureMaskResourceLoaded();

    this.canvasContext.clearRect(0, 0, this.canvasWidth, this.canvasHeight);

    if (this.maskPixelMap) {
      this.drawOverlayBitmap(this.maskPixelMap);
    }

    this.clickPoints.forEach((point: MaskPoint, index: number) => {
      this.drawClickMarker(point, index + 1);
    });
  }

  private ensureMaskResourceLoaded(): void {
    if (this.maskVersion <= 0) {
      if (this.maskPixelMap) {
        this.maskPixelMap = undefined;
      }
      return;
    }

    if (this.maskPixelMap || this.isMaskLoading) {
      return;
    }

    this.loadMaskResource();
  }

  private drawOverlayBitmap(bitmap?: image.PixelMap): void {
    if (!bitmap) {
      return;
    }

    const imageRect: ImageRenderRect = this.getCoverRenderRect();
    this.canvasContext.drawImage(bitmap, imageRect.x, imageRect.y, imageRect.width, imageRect.height);
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

  private getCoverRenderRect(): ImageRenderRect {
    const scale: number = Math.max(this.canvasWidth / this.imagePixelWidth, this.canvasHeight / this.imagePixelHeight);
    const width: number = this.imagePixelWidth * scale;
    const height: number = this.imagePixelHeight * scale;

    return {
      x: (this.canvasWidth - width) / 2,
      y: (this.canvasHeight - height) / 2,
      width,
      height
    };
  }
}

interface ImageRenderRect {
  x: number;
  y: number;
  width: number;
  height: number;
}
