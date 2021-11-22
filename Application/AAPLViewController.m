/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implementation of the cross-platform view controller
*/

#import "AAPLViewController.h"
#if TARGET_IOS || TARGET_TVOS
#import "AAPLUIView.h"
#else
#import "AAPLNSView.h"
#endif
#import "AAPLRenderer.h"
#import <QuartzCore/CAMetalLayer.h>

@implementation AAPLViewController
{
    AAPLRenderer *_renderer;
    NSTimer *_timer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    id<MTLDevice> device = MTLCreateSystemDefaultDevice();

    AAPLView *view = (AAPLView *)self.view;

    // Set the device for the layer so the layer can create drawable textures that can be rendered to
    // on this device.
    view.metalLayer.device = device;

    // Set this class as the delegate to receive resize and render callbacks.
    view.delegate = self;

    view.metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm_sRGB;

    _renderer = [[AAPLRenderer alloc] initWithMetalDevice:device
                                      drawablePixelFormat:view.metalLayer.pixelFormat];
    
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(execute) userInfo:nil repeats:YES];
}

- (void) execute {
    NSWindow* window = [[[NSApplication sharedApplication] windows] objectAtIndex:0];
    double scaleFactorX = 0.5 + ((double)arc4random() / UINT32_MAX);
    double scaleFactorY = 0.5 + ((double)arc4random() / UINT32_MAX);
    NSRect frame = [window frame];
    CGSize frameSize = frame.size;
    frameSize.width *= scaleFactorX;
    frameSize.height *= scaleFactorY;
    frameSize.width = MAX(frameSize.width, 400);
    frameSize.height = MAX(frameSize.height, 400);
    frameSize.width = MIN(frameSize.width, 900);
    frameSize.height = MIN(frameSize.height, 900);
    [window setFrame:NSMakeRect(frame.origin.x, frame.origin.y, frameSize.width, frameSize.height) display:YES animate:YES];
}

- (void)viewWillDisappear {
    //reset timer
    if (_timer != nil) {
        [_timer invalidate];
        _timer = nil;
    }
}


- (void)drawableResize:(CGSize)size
{
    [_renderer drawableResize:size];
}

- (void)renderToMetalLayer:(nonnull CAMetalLayer *)layer
{
    [_renderer renderToMetalLayer:layer];
}

@end
