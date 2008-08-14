/**
@file
    PongView.h
@brief
    Copyright 2008 Creative Crew. All rights reserved.
@author
    William Chang
@version
    0.1
@date
    - Created: 2008-08-14
    - Modified: 2008-08-14
    .
@note
    References:
    - General:
        - https://developer.apple.com/iphone/library/navigation/index.html
        - http://developer.apple.com/iphone/library/navigation/Frameworks/Media/OpenGLES/index.html
        .
    .
*/

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@class PongView;

@protocol PongViewDelegate <NSObject>
- (void) didResizeEAGLSurfaceForView:(PongView *)view; // Called whenever the EAGL surface has been resized.
@end

@interface PongView : UIView {
@private
    NSString *_format;
    GLuint _depthFormat;
    BOOL _autoresize;
    EAGLContext *_context;
    GLuint _framebuffer;
    GLuint _renderbuffer;
    GLuint _depthBuffer;
    CGSize _size;
    BOOL _hasBeenCurrent;
    id<PongViewDelegate> _delegate;
}

@property (readonly) GLuint framebuffer;
@property (readonly) NSString *pixelFormat;
@property (readonly) GLuint depthFormat;
@property (readonly) EAGLContext *context;
@property BOOL autoresizesSurface; //NO by default - Set to YES to have the EAGL surface automatically resized when the view bounds change, otherwise the EAGL surface contents is rendered scaled
@property (readonly, nonatomic) CGSize surfaceSize;
@property (assign) id<PongViewDelegate> delegate;

- (id) initWithCoder:(NSCoder *)coder;
- (BOOL) _createSurface;
- (void) _destroySurface;
- (void) setCurrentContext;
- (BOOL) isCurrentContext;
- (void) clearCurrentContext;
- (void) swapBuffers;
- (CGPoint) convertPointFromViewToSurface:(CGPoint)point;
- (CGRect) convertRectFromViewToSurface:(CGRect)rect;
 
@end