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
#import "Texture2D.h"

@class PongView;

// Simulation definition.
#define kFontName @"Arial"
#define kLabelFontSize 14

#define kUserNameDefaultKey @"userName" // NSString.
#define kHighScoresDefaultKey @"highScores" // NSArray of NSStrings.

#define kInitialVelocity 100 // Pixels / 1 second. 

#define kAccelerometerFrequency 100 // Hz.
#define kFilteringFactor 0.1 // For filtering out gravitational affects.

#define kRenderingFPS 30.0 // Hz.

#define kListenerDistance 1.0  // Used for creating a realistic sound field.

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
@protected
    Texture2D *_textures[kNumTextures];
    UInt32 _sounds[kNumSounds];
    
    BOOL _isFirstTap;
    NSTimer *_timer;
	State _state;
    CFTimeInterval _timeBegin;
    Vector2D _ballPosition;
    Vector2D _ballVelocity;
    
    unsigned int _Player1Score;
    unsigned int _Player2Score;
}

@property (nonatomic, retain) PongView *glView;

- (void) transitionTo:(UIView *)view slideDirection:(int)style;
- (void) init;
- (void) start;
- (void) renderOneFrame;
- (void) reset;
- (void) save;

@end