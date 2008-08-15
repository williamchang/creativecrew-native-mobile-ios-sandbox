#import "PongViewController.h"
#import "PongView.h"

@implementation PongViewController

@synthesize glView;

//---------------------------------------------------------------------
+ (void) initialize {
    if(self == [PongViewController class]) {
    }
}
//---------------------------------------------------------------------
- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Title displayed by the navigation controller.
        self.title = @"Pong";
	}
	return self;
}
//---------------------------------------------------------------------
/* Implement loadView if you want to create a view hierarchy programmatically. */
- (void) loadView {
    [super loadView];
    [[UIApplication sharedApplication] setStatusBarHidden:YES animated:NO];
    [self init];
}
//---------------------------------------------------------------------
/* If you need to do additional setup after loading the view, override viewDidLoad. */
- (void) viewDidLoad {
    [super viewDidLoad];
}
//---------------------------------------------------------------------
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
//---------------------------------------------------------------------
- (void) didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}
//---------------------------------------------------------------------
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self start];
}
//---------------------------------------------------------------------
- (void) transitionTo:(UIView *)view slideDirection:(int)style {/*
    [current_view resignFirstResponder];
    prev_view = current_view;
    current_view = view;
    [transition transition:style toView:view];
    [view becomeFirstResponder];*/
}
//---------------------------------------------------------------------
- (void) updateBall {
    CGRect bounds = [glView bounds];
    
    if(_ballDirection == 0) {
         _ballPosition.x -= _ballVelocity.x;
         _ballPosition.y -= _ballVelocity.y;
    } else if(_ballDirection == 1) {
        _ballPosition.x += _ballVelocity.x;
        _ballPosition.y -= _ballVelocity.y;
    } else if(_ballDirection == 2) {
        _ballPosition.x += _ballVelocity.x;
        _ballPosition.y += _ballVelocity.y;
    } else if(_ballDirection == 3) {
        _ballPosition.x -= _ballVelocity.x;
        _ballPosition.y += _ballVelocity.y;
    }
    
    if(_ballDirection == 0 && _ballPosition.x < 0) {
        _ballDirection = 1;
    } else if(_ballDirection == 0 && _ballPosition.y < 0) {
        _ballDirection = 3;
    } else if(_ballDirection == 1 && _ballPosition.y < 0) {
        _ballDirection = 2;
    } else if(_ballDirection == 1 && _ballPosition.x > bounds.size.width) {
        _ballDirection = 0;
    } else if(_ballDirection == 2 && _ballPosition.y > bounds.size.height) {
        _ballDirection = 1;
    } else if(_ballDirection == 2 && _ballPosition.x > bounds.size.width) {
        _ballDirection = 3;
    } else if(_ballDirection == 3 && _ballPosition.y > bounds.size.height) {
        _ballDirection = 0;
    } else if(_ballDirection == 3 && _ballPosition.x < 0) {
        _ballDirection = 2;
    }
}
//---------------------------------------------------------------------
- (void) updatePlayer1 {
}
//---------------------------------------------------------------------
- (void) updatePlayer2 {
}
//---------------------------------------------------------------------
- (void) init {
    // Declarations. 
    // For Sound: NSBundle *bundle = [NSBundle mainBundle];
    CGRect rect = [[UIScreen mainScreen] bounds];
    // Initialize.
    _isFirstTap = YES;

    // Initialize OpenGL projection matrix.
    glMatrixMode(GL_PROJECTION);
    glOrthof(0, rect.size.width, 0, rect.size.height, -1, 1);
    glMatrixMode(GL_MODELVIEW); // Make OpenGL matrix mode default to modelview.
    // Initialize OpenGL states.
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_TEXTURE_2D);
    glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);

    // Load and configure background texture.
    _textures[kTexture_Title] = [[Texture2D alloc] initWithImage:[UIImage imageNamed:@"title.png"]];
    glBindTexture(GL_TEXTURE_2D, [_textures[kTexture_Title] name]);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    // Load gameplay textures.
    _textures[kTexture_Ball] = [[Texture2D alloc] initWithImage:[UIImage imageNamed:@"ball.png"]];
    _textures[kTexture_Player1Paddle] = [[Texture2D alloc] initWithImage:[UIImage imageNamed:@"paddle.png"]];
    _textures[kTexture_Player1TouchPad] = [[Texture2D alloc] initWithImage:[UIImage imageNamed:@"touchpad.png"]];
    _textures[kTexture_Player2Paddle] = [[Texture2D alloc] initWithImage:[UIImage imageNamed:@"paddle.png"]];
    _textures[kTexture_Player2TouchPad] = [[Texture2D alloc] initWithImage:[UIImage imageNamed:@"touchpad.png"]];
    // Load label textures.
    _textures[kTexture_Player1LabelScore] = [[Texture2D alloc] initWithString:@"P1 Score:" dimensions:CGSizeMake(64, 32) alignment:UITextAlignmentLeft fontName:kFontName fontSize:kLabelFontSize];
    _textures[kTexture_Player2LabelScore] = [[Texture2D alloc] initWithString:@"P2 Score:" dimensions:CGSizeMake(64, 32) alignment:UITextAlignmentLeft fontName:kFontName fontSize:kLabelFontSize];

    // TODO: Implement sound.

    // Render the title frame.
    glDisable(GL_BLEND);
    [_textures[kTexture_Title] drawInRect:[glView bounds]];
    glEnable(GL_BLEND);

    // Swap the framebuffer.
    [glView swapBuffers];
}
//---------------------------------------------------------------------
- (void) start {
    if(_isFirstTap) {
        // Load and configure background texture. Replace the title screen with the background.
        _textures[kTexture_Background] = [[Texture2D alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
        glBindTexture(GL_TEXTURE_2D, [_textures[kTexture_Background] name]);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        // Reset.
        [self reset];
        _isFirstTap = NO;
    } else { // Either the user tapped to start a new game or the user successfully landed the rocket.
        // Stop rendering timer
        [_timer invalidate];
        _timer = nil;

        // In the lander was landed successfully, save the current score or start a new game
        if(_state == kState_Finish) {
            //[self saveScore];
        } else {
            //[self resetGame];
        }

    }
}
//---------------------------------------------------------------------
- (void) reset {
    CGRect bounds = [glView bounds];
    _state = kState_Running;
    _timeBegin = CFAbsoluteTimeGetCurrent();
    
    // Destroy dynamic textures.
    [_Player1StatusScore release];
    _Player1StatusScore = nil;
    [_Player2StatusScore release];
    _Player2StatusScore = nil;
    
    // Init.
    _Player1Score = 0;
    _Player2Score = 0;
    _ballPosition.x = bounds.size.width / 2;
    _ballPosition.y = bounds.size.height / 2;
    _ballVelocity.x = 2.0; // Pixels / 1 second.
    _ballVelocity.y = 2.0; // Pixels / 1 second.
    _ballDirection = 1;
    
    // Render a frame immediately.
    [self renderOneFrame];
    
    // Start rendering timer (loop).
    _timer = [NSTimer scheduledTimerWithTimeInterval:(1.0 / kRenderingFPS) target:self selector:@selector(renderOneFrame) userInfo:nil repeats:YES];
}
//---------------------------------------------------------------------
- (void) save {
}
//---------------------------------------------------------------------
- (void) renderOneFrame {
    CGRect bounds = [glView bounds];
    CFTimeInterval timeCurrent;
    float timeDifference;
    
	if(_state == kState_Running) {
        timeCurrent = CFAbsoluteTimeGetCurrent();
        timeDifference = timeCurrent - _timeBegin;
        
        // Update ball logic.
		[self updateBall];
        // Update player 1 logic.
		[self updatePlayer1];
        // Update player 2 logic.
		[self updatePlayer2];
    } else if(_state == kState_Failure) {
        // Stop rendering timer (loop).
        [_timer invalidate];
        _timer = nil;
    }
    
    // Draw background.
    glDisable(GL_BLEND);
    [_textures[kTexture_Background] drawInRect:bounds];
    glEnable(GL_BLEND);
    
    if(_state != kState_StandBy) {
        // Draw player 1 paddle.
        
        // Draw overlay player 1 status.
        _Player1StatusScore = [[Texture2D alloc] initWithString:[NSString stringWithFormat:@"%i", _Player1Score] dimensions:CGSizeMake(32, 32) alignment:UITextAlignmentCenter fontName:kFontName fontSize:kLabelFontSize];
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        [_textures[kTexture_Player1LabelScore] drawAtPoint:CGPointMake(64, 32)]; // Coordinates (0, 0) start at bottom left of screen.
        [_Player1StatusScore drawAtPoint:CGPointMake(96 + 4, 32)];
        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        
        // Draw player 2 paddle.
        
        // Draw overlay player 2 status.
        _Player2StatusScore = [[Texture2D alloc] initWithString:[NSString stringWithFormat:@"%i", _Player2Score] dimensions:CGSizeMake(32, 32) alignment:UITextAlignmentCenter fontName:kFontName fontSize:kLabelFontSize];
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        [_textures[kTexture_Player2LabelScore] drawAtPoint:CGPointMake(bounds.size.width - 96, bounds.size.height - 32)]; // Coordinates (0, 0) start at bottom left of screen.
         [_Player2StatusScore drawAtPoint:CGPointMake(bounds.size.width - 64 + 4, bounds.size.height - 32)];
        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        
        // Draw ball.
        glPushMatrix();
        glTranslatef(_ballPosition.x, _ballPosition.y, 0);
        [_textures[kTexture_Ball] drawAtPoint:CGPointZero];
        glPopMatrix();
    }
    
    // Swap the framebuffer.
	[glView swapBuffers];
}
//---------------------------------------------------------------------
- (void) dealloc {
    [_Player1StatusScore release];
    [_Player2StatusScore release];
    unsigned int i;for(i = 0;i < kNumTextures;i++) {[_textures[i] release];}
    [glView dealloc];
	[super dealloc];
}

@end