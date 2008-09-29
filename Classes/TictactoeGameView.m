#import "TictactoeGameView.h"

@implementation TictactoeGameView
//---------------------------------------------------------------------
- (id) initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		// Initialization code
        self.backgroundColor = [UIColor blackColor];
        NSLog(@"View: width:%f, height:%f",  self.bounds.size.width, self.bounds.size.height);
        
        // Init quartz.
        /*CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        _cgContext = CGBitmapContextCreate(NULL, self.bounds.size.width, self.bounds.size.height, 8, 4 * self.bounds.size.width, colorSpace, kCGImageAlphaPremultipliedFirst);
        CGColorSpaceRelease(colorSpace);
        _cgLayer = CGLayerCreateWithContext(_cgContext, self.bounds.size, NULL);*/
	}
	return self;
}
//---------------------------------------------------------------------
- (void) drawRect:(CGRect)rect {
	// Drawing code
    
    // Init quartz.
    /*CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGImageRef image = CGBitmapContextCreateImage(_cgContext);
    CGContextDrawImage(currentContext, self.bounds, image);
    CGImageRelease(image);
    CGContextDrawLayerInRect(currentContext, self.bounds, _cgLayer);*/
    
    [self drawBoard];
}
//---------------------------------------------------------------------
- (void) drawBoard {
    CGContextRef layerContext = UIGraphicsGetCurrentContext();
    
    // Style.
    CGContextSetRGBStrokeColor(layerContext, 1.0, 1.0, 1.0, 1.0);
    CGContextSetLineWidth(layerContext, 10.0);
    CGContextSetLineCap(layerContext, kCGLineCapRound);
    
    // Draw column 1.
    CGPoint lines1[] = {
        CGPointMake(106, 50),
        CGPointMake(106, 350)
    };
    CGContextAddLines(layerContext, lines1, sizeof(lines1) /  sizeof(lines1[0]));
    CGContextStrokePath(layerContext);
    
    // Draw column 2.
    CGPoint lines2[] = {
        CGPointMake(212, 50),
        CGPointMake(212, 350)
    };
    CGContextAddLines(layerContext, lines2, sizeof(lines2) /  sizeof(lines2[0]));
    CGContextStrokePath(layerContext);
    
    // Draw row 1.
    CGPoint lines3[] = {
        CGPointMake(20, 150),
        CGPointMake(300, 150)
    };
    CGContextAddLines(layerContext, lines3, sizeof(lines3) /  sizeof(lines3[0]));
    CGContextStrokePath(layerContext);
    
    // Draw row 2.
    CGPoint lines4[] = {
        CGPointMake(20, 250),
        CGPointMake(300, 250)
    };
    CGContextAddLines(layerContext, lines4, sizeof(lines4) /  sizeof(lines4[0]));
    CGContextStrokePath(layerContext);
}
//---------------------------------------------------------------------
- (void) dealloc {
    CGContextRelease(_cgContext);
    CGLayerRelease(_cgLayer);
	[super dealloc];
}
//---------------------------------------------------------------------
@end