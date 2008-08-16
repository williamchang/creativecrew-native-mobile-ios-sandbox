/*

File: EAGLView.h
Abstract: Convenience class that wraps the CAEAGLLayer from CoreAnimation into a
UIView subclass.

Version: 1.7

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
("Apple") in consideration of your agreement to the following terms, and your
use, installation, modification or redistribution of this Apple software
constitutes acceptance of these terms.  If you do not agree with these terms,
please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject
to these terms, Apple grants you a personal, non-exclusive license, under
Apple's copyrights in this original Apple software (the "Apple Software"), to
use, reproduce, modify and redistribute the Apple Software, with or without
modifications, in source and/or binary forms; provided that if you redistribute
the Apple Software in its entirety and without modifications, you must retain
this notice and the following text and disclaimers in all such redistributions
of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may be used
to endorse or promote products derived from the Apple Software without specific
prior written permission from Apple.  Except as expressly stated in this notice,
no other rights or licenses, express or implied, are granted by Apple herein,
including but not limited to any patent rights that may be infringed by your
derivative works or by other works in which the Apple Software may be
incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2008 Apple Inc. All Rights Reserved.

*/

#import <QuartzCore/CAEAGLLayer.h>
#import "EAGLView.h"

@implementation EAGLView

@synthesize delegate = _delegate;
@synthesize autoresizesSurface = _autoresize;
@synthesize surfaceSize = _size;
@synthesize framebuffer = _framebuffer;
@synthesize pixelFormat = _format;
@synthesize depthFormat = _depthFormat;
@synthesize context = _context;

//---------------------------------------------------------------------
// Must implement this class method when using OpenGL.
+ (Class) layerClass {
    return [CAEAGLLayer class];
}
//---------------------------------------------------------------------
- (id) init {
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)[self layer];
    
    [eaglLayer setDrawableProperties:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGB565, kEAGLDrawablePropertyColorFormat, nil]];
    _format = kEAGLColorFormatRGB565;
    _depthFormat = 0;
    
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    if(_context == nil) {
        [self release];
        return nil;
    }
    
    if(![self _createSurface]) {
        [self release];
        return nil;
    }
    
    return self;
}
//---------------------------------------------------------------------
// The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id) initWithCoder:(NSCoder *)coder {
    if((self = [super initWithCoder:coder])) {
        return [self init];
    }
    return self;
}
//---------------------------------------------------------------------
- (void) layoutSubviews {
    CGRect bounds = [self bounds];
    
    if(_autoresize && ((roundf(bounds.size.width) != _size.width) || (roundf(bounds.size.height) != _size.height))) {
        [self _destroySurface];
#if __DEBUG__
        REPORT_ERROR(@"Resizing surface from %fx%f to %fx%f", _size.width, _size.height, roundf(bounds.size.width), roundf(bounds.size.height));
#endif
        [self _createSurface];
    }
}
//---------------------------------------------------------------------
- (BOOL) _createSurface {
    CAEAGLLayer *eaglLayer = (CAEAGLLayer*)[self layer];
    CGSize newSize;
    GLuint oldRenderbuffer;
    GLuint oldFramebuffer;
    
    if(![EAGLContext setCurrentContext:_context]) {
        return NO;
    }
    
    newSize = [eaglLayer bounds].size;
    newSize.width = roundf(newSize.width);
    newSize.height = roundf(newSize.height);
    
    glGetIntegerv(GL_RENDERBUFFER_BINDING_OES, (GLint *) &oldRenderbuffer);
    glGetIntegerv(GL_FRAMEBUFFER_BINDING_OES, (GLint *) &oldFramebuffer);
    
    glGenRenderbuffersOES(1, &_renderbuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, _renderbuffer);
    
    if(![_context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:eaglLayer]) {
        glDeleteRenderbuffersOES(1, &_renderbuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_BINDING_OES, oldRenderbuffer);
        return NO;
    }
    
    glGenFramebuffersOES(1, &_framebuffer);
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, _framebuffer);
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, _renderbuffer);
    if(_depthFormat) {
        glGenRenderbuffersOES(1, &_depthBuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, _depthBuffer);
        glRenderbufferStorageOES(GL_RENDERBUFFER_OES, _depthFormat, newSize.width, newSize.height);
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, _depthBuffer);
    }
    
    _size = newSize;
    if(!_hasBeenCurrent) {
        glViewport(0, 0, newSize.width, newSize.height);
        glScissor(0, 0, newSize.width, newSize.height);
        _hasBeenCurrent = YES;
    }
    else {
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, oldFramebuffer);
    }
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, oldRenderbuffer);
    
    [_delegate didResizeEAGLSurfaceForView:self];
    
    return YES;
}
//---------------------------------------------------------------------
- (void) _destroySurface {
    EAGLContext *oldContext = [EAGLContext currentContext];
    
    if(oldContext != _context) {
        [EAGLContext setCurrentContext:_context];
    }
    
    if(_depthFormat) {
        glDeleteRenderbuffersOES(1, &_depthBuffer);
        _depthBuffer = 0;
    }
    
    glDeleteRenderbuffersOES(1, &_renderbuffer);
    _renderbuffer = 0;
    
    glDeleteFramebuffersOES(1, &_framebuffer);
    _framebuffer = 0;
    
    if(oldContext != _context) {
        [EAGLContext setCurrentContext:oldContext];
    }
}
//---------------------------------------------------------------------
- (void) setAutoresizesEAGLSurface:(BOOL)autoresizesEAGLSurface; {
    _autoresize = autoresizesEAGLSurface;
    if(_autoresize) {
        [self layoutSubviews];
    }
}
//---------------------------------------------------------------------
- (void) setCurrentContext {
    if(![EAGLContext setCurrentContext:_context]) {
        printf("Failed to set current context %p in %s\n", _context, __FUNCTION__);
    }
}
//---------------------------------------------------------------------
- (BOOL) isCurrentContext {
    return ([EAGLContext currentContext] == _context ? YES : NO);
}
//---------------------------------------------------------------------
- (void) clearCurrentContext {
    if(![EAGLContext setCurrentContext:nil]) {
        printf("Failed to clear current context in %s\n", __FUNCTION__);
    }
}
//---------------------------------------------------------------------
- (void) swapBuffers {
    EAGLContext *oldContext = [EAGLContext currentContext];
    GLuint oldRenderbuffer;
    
    if(oldContext != _context) {
        [EAGLContext setCurrentContext:_context];
    }
    glGetIntegerv(GL_RENDERBUFFER_BINDING_OES, (GLint *) &oldRenderbuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, _renderbuffer);
    if(![_context presentRenderbuffer:GL_RENDERBUFFER_OES]) {
        printf("Failed to swap renderbuffer in %s\n", __FUNCTION__);
    }
    if(oldContext != _context) {
        [EAGLContext setCurrentContext:oldContext];
    }
}
//---------------------------------------------------------------------
- (CGPoint) convertPointFromViewToSurface:(CGPoint)point {
    CGRect bounds = [self bounds];
    return CGPointMake((point.x - bounds.origin.x) / bounds.size.width * _size.width, (point.y - bounds.origin.y) / bounds.size.height * _size.height);
}
//---------------------------------------------------------------------
- (CGRect) convertRectFromViewToSurface:(CGRect)rect {
    CGRect bounds = [self bounds];
    return CGRectMake((rect.origin.x - bounds.origin.x) / bounds.size.width * _size.width, (rect.origin.y - bounds.origin.y) / bounds.size.height * _size.height, rect.size.width / bounds.size.width * _size.width, rect.size.height / bounds.size.height * _size.height);
}
//---------------------------------------------------------------------
- (void) dealloc {
    [self _destroySurface];
    [_context release];_context = nil;
	[super dealloc];
}

@end