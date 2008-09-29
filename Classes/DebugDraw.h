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
    - Modified: 2008-09-28
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
#import <sys/time.h>
#import "EAGLView.h"

// Forward declaration using "struct" instead C++ "class" for Objective-C compatibility.
typedef struct CppDebugDraw CppDebugDraw;
typedef struct CppDebugWrapper CppDebugWrapper;
typedef struct b2World b2World;
typedef struct b2MouseJoint b2MouseJoint;

@interface DebugDraw : NSObject {
@private
    CppDebugWrapper *_cppDebugWrapper;
    CppDebugDraw *_cppDebugDraw;
    b2World *_physicsWorld;
    CGRect _physicsWorldBounds;
    
    GLfloat _x;
    GLfloat _y;
    
    // Last time the main loop was updated.
	struct timeval _timeLast;
	// Delta time since last tick to main loop.
	GLfloat _deltaTime;
    // Debug render fps (frames per second).
	GLint _frameCount;
	GLfloat _deltaTimeCount;
	GLfloat _frameRate;
    
    // Pick.
    b2MouseJoint *_jointPicker;
}

- (void) setPhyicsWorld:(b2World *)w bounds:(CGRect)b;
- (void) setPhysicsDebugFlags:(GLuint)f;
- (void) calculateDeltaTime;
- (void) showFps;
- (void) setCoordinates:(GLfloat)x with:(GLfloat)y;
- (void) showCoordinates;
- (void) pickBodyBegan:(GLfloat)x with:(GLfloat)y;
- (void) pickBodyMoved:(GLfloat)x with:(GLfloat)y;
- (void) pickBodyEnded;
- (BOOL) frameStarted;
- (BOOL) frameEnded;

@end