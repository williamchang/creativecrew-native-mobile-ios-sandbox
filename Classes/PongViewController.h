/**
@file
    PongViewController.h
@brief
    Copyright 2008 Creative Crew. All rights reserved.
@author
    William Chang
@version
    0.1
@date
    - Created: 2008-08-13
    - Modified: 2008-08-23
    .
@note
    References:
    - General:
        - https://developer.apple.com/iphone/library/navigation/index.html
        - http://developer.apple.com/iphone/library/navigation/Frameworks/Media/OpenGLES/index.html
        .
    - Objective-C++:
        - http://www.cocoabuilder.com/archive/message/cocoa/2008/3/20/201886
        - http://cocoadev.com/index.pl?ObjectiveCPlusPlus
        - http://developer.apple.com/documentation/Cocoa/Conceptual/ObjectiveC/Articles/chapter_13_section_3.html
        - http://en.wikipedia.org/wiki/Forward_declaration
        .
    .
*/

#import <UIKit/UIKit.h>
#import "Texture2D.h"

// Simulation definition.
#define kFontName @"Arial"
#define kLabelFontSize 15

#define kUserNameDefaultKey @"userName" // NSString.
#define kHighScoresDefaultKey @"highScores" // NSArray of NSStrings.

#define kAccelerometerFrequency 100 // Hz.
#define kFilteringFactor 0.1 // For filtering out gravitational affects.

#define kRenderingFPS 60.0 // Hz.

#define kListenerDistance 1.0  // Used for creating a realistic sound field.

// Forward declaration.
@class PongView;
@class DebugDraw;

// Forward declaration using "struct" instead C++ "class" for Objective-C compatibility.
typedef struct b2World b2World;
typedef struct b2Body b2Body;
typedef struct b2PrismaticJoint b2PrismaticJoint;

// Texture list.
enum {
    kTexture_Title = 0,
    kTexture_Background,
    kTexture_Ball,
    kTexture_Player1Paddle,
    kTexture_Player1TouchPad,
    kTexture_Player1LabelScore,
    kTexture_Player2Paddle,
    kTexture_Player2TouchPad,
    kTexture_Player2LabelScore,
    kNumTextures
};

// Sound list.
enum {
    kSound_Bounce = 0,
    kSound_Start,
    kSound_Finish,
    kSound_Failure,
    kNumSounds
};

// State list.
typedef enum {
    kState_StandBy = 0,
    kState_Running,
    kState_Finish,
    kState_Failure
} State;

typedef struct	{
    GLfloat x, y;
} Vector2D;

@interface PongViewController : UIViewController {
@public
    IBOutlet PongView *glView;
    IBOutlet UIImageView *ivPlayer1Touchpad;
@protected
    Texture2D *_textures[kNumTextures];
    UInt32 _sounds[kNumSounds];
    
    BOOL _isFirstTap;
    NSTimer *_timer;
	State _state;
    CFTimeInterval _timeBegin;
    Vector2D _ballPosition;
    Vector2D _ballPositionVelocity;
    GLfloat _ballRotation;
    GLfloat _ballRotationVelocity;
    unsigned int _ballDirection;
    
    Vector2D _Player1Paddle;
    unsigned int _Player1Score;
    Texture2D *_Player1StatusScore;
    unsigned int _Player2Score;
    Texture2D *_Player2StatusScore;
@private
    b2World *_physicsWorld;
    GLfloat _physicsWorldTimeStep;
    GLint _physicsWorldIterationCount;
    
    // Debug lines.
    DebugDraw *_physicsDebugDraw;
    
    GLfloat _cameraOffsetX;
    GLfloat _cameraOffsetY;
    GLfloat _cameraOffsetZ;
    
    b2Body *bodyBall;
    b2Body *bodyPlayer1Paddle;
    b2PrismaticJoint *jointPlayer1Paddle;
    
    bool isFirstForces;
}

@property (nonatomic, retain) PongView *glView;
@property (nonatomic, retain) UIImageView *ivPlayer1Touchpad;

- (CGRect) getViewVirtualBounds;
- (void) transitionTo:(UIView *)view slideDirection:(int)style;
- (void) updateBall;
- (void) updatePlayer1;
- (void) updatePlayer2;
- (void) initRender;
- (void) setProjection2D;
- (void) setProjection3D;
- (void) start;
- (void) renderOneFrame;
- (void) reset;
- (void) save;

@end