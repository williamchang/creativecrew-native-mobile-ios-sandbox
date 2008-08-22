/**
@file
    DebugDraw.h
@brief
    Copyright 2008 Creative Crew. All rights reserved.
@author
    William Chang
@version
    0.1
@date
    - Created: 2008-08-20
    - Modified: 2008-08-21
    .
@note
    References:
    - General:
        - http://www.cocoabuilder.com/archive/message/cocoa/2008/3/20/201886
        - http://cocoadev.com/index.pl?ObjectiveCPlusPlus
        - http://developer.apple.com/documentation/Cocoa/Conceptual/ObjectiveC/Articles/chapter_13_section_3.html
        - http://en.wikipedia.org/wiki/Forward_declaration
        .
    .
*/

#import <UIKit/UIKit.h>
#import "EAGLView.h"

// Forward declaration using "struct" instead C++ "class" for Objective-C compatibility.
typedef struct CppDebugDraw CppDebugDraw;
typedef struct b2World b2World;

@interface DebugDraw : NSObject {
@private
    CppDebugDraw *_cpp;
    b2World *_physicsWorld;
}

- (void) setPhyicsWorld:(b2World *)w;
- (void) setFlags:(GLuint)f;

@end