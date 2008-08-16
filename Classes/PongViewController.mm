#import "PongViewController.h"
#import "PongView.h"

// BEGIN: C++ binding layer.
#include "Box2D.h"
@interface PongViewController ()
    b2World *world;
    GLfloat worldTimeStep;
    GLint worldIterationCount;

    b2Body *bodyBox;
@end
// END: C++ binding layer.

@implementation PongViewController

@synthesize glView;
@synthesize ivPlayer1Touchpad;

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
    
    glView = [[PongView alloc] initWithFrame:self.view.frame];
    [self.view removeFromSuperview];
    self.view = glView;
    
    ivPlayer1Touchpad = [[UIImageView alloc] initWithFrame:CGRectMake(0, glView.bounds.size.height - 64, 320, 64)];
    ivPlayer1Touchpad.image = [UIImage imageNamed:@"touchpad.png"];
    ivPlayer1Touchpad.userInteractionEnabled = YES;
    ivPlayer1Touchpad.hidden = YES;
    [self.glView addSubview:ivPlayer1Touchpad];
    
    [self initRender];
    [self initPhysics];
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
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    if([touch view] == ivPlayer1Touchpad) {
        _Player1Paddle.x = [touch locationInView:self.view].x;
        _Player1Paddle.y = [touch locationInView:self.view].y;
        //NSLog(@"Breakpoint 1");
    }
}
//---------------------------------------------------------------------
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    if([touch view] == ivPlayer1Touchpad) {
        _Player1Paddle.x = [touch locationInView:self.view].x;
        _Player1Paddle.y = [touch locationInView:self.view].y;
    }
}
//---------------------------------------------------------------------
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    if([touch view] == glView) {
        [self start];
    }
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
    GLfloat wallTop = glView.bounds.size.height - 12;
    GLfloat wallRight = glView.bounds.size.width - 12;
    GLfloat wallBottom = 64 + 12;
    GLfloat wallLeft = 0 + 12;
    
    if(_ballDirection == 0) {
         _ballPosition.x -= _ballPositionVelocity.x;
         _ballPosition.y -= _ballPositionVelocity.y;
    } else if(_ballDirection == 1) {
        _ballPosition.x += _ballPositionVelocity.x;
        _ballPosition.y -= _ballPositionVelocity.y;
    } else if(_ballDirection == 2) {
        _ballPosition.x += _ballPositionVelocity.x;
        _ballPosition.y += _ballPositionVelocity.y;
    } else if(_ballDirection == 3) {
        _ballPosition.x -= _ballPositionVelocity.x;
        _ballPosition.y += _ballPositionVelocity.y;
    }
    
    if(_ballDirection == 0 && _ballPosition.x < wallLeft) {
        _ballDirection = 1;
    } else if(_ballDirection == 0 && _ballPosition.y < wallBottom) {
        _ballDirection = 3;
    } else if(_ballDirection == 1 && _ballPosition.y < wallBottom) {
        _ballDirection = 2;
    } else if(_ballDirection == 1 && _ballPosition.x > wallRight) {
        _ballDirection = 0;
    } else if(_ballDirection == 2 && _ballPosition.y > wallTop) {
        _ballDirection = 1;
    } else if(_ballDirection == 2 && _ballPosition.x > wallRight) {
        _ballDirection = 3;
    } else if(_ballDirection == 3 && _ballPosition.y > wallTop) {
        _ballDirection = 0;
    } else if(_ballDirection == 3 && _ballPosition.x < wallLeft) {
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
- (void) initRender {
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
    _textures[kTexture_Player2Paddle] = [[Texture2D alloc] initWithImage:[UIImage imageNamed:@"paddle.png"]];
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
// C++ binding layer.
- (void) initPhysics {
    // Get objective c values.
    GLfloat canvasWidth = self.view.bounds.size.width;
    GLfloat canvasHeight = self.view.bounds.size.height;
    
    // Define the size of the world.
    b2AABB worldAABB;
    worldAABB.upperBound.Set(500.0, 500.0);
    worldAABB.lowerBound.Set(-100.0, -100.0);
    
    // Define the gravity vector.
    b2Vec2 gravity(0.0, -10.0);
    
    // Let rigid bodies sleep.
    bool isBodiesSleep = true;
    
    // Construct a world object.
    world = new b2World(worldAABB, gravity, isBodiesSleep);
    
    // Define the ground body.
    b2BodyDef groundDefine;
    groundDefine.position.Set(76.0, 0.0);
    
    // Call the body factory which allocates memory for the ground body
	// from a pool and creates the ground box shape (also from a pool).
	// The body is also added to the world.
    b2Body *groundBody = world->CreateBody(&groundDefine);
    
    // Define the ground box shape.
    b2PolygonDef groundShapeDefine;
    
    // The extents are the half-widths of the box.
    groundShapeDefine.SetAsBox(canvasWidth, 76.0);

    // Add the ground shape to the ground body.
    groundBody->CreateShape(&groundShapeDefine);

    // Define the dynamic body. We set its position and call the body factory.
    b2BodyDef bodyBoxDefine;
    bodyBoxDefine.position.Set((canvasWidth / 2) + 50, canvasHeight / 2);
    bodyBox = world->CreateBody(&bodyBoxDefine);

    // Define another box shape for our dynamic body.
    b2PolygonDef bodyShapeDefine;
    bodyShapeDefine.SetAsBox(1.0, 1.0);

    // Set the box density to be non-zero, so it will be dynamic.
    bodyShapeDefine.density = 1.0;

    // Override the default friction.
    bodyShapeDefine.friction = 0.3;

    // Add the shape to the body.
    bodyBox->CreateShape(&bodyShapeDefine);

    // Now tell the dynamic body to compute it's mass properties base on its shape.
    bodyBox->SetMassFromShapes();

    // Prepare for simulation. Typically we use a time step of 1/60 of a
    // second (60Hz) and 10 iterations. This provides a high quality simulation
    // in most game scenarios.
    worldTimeStep = 1.0 / kRenderingFPS;
    worldIterationCount = 10;
}
//---------------------------------------------------------------------
// C++ binding layer.
- (void) updatePhysics {
    // Instruct the world to perform a single step of physics simulation.
    world->Step(worldTimeStep, worldIterationCount);
    
    // Get the position and angle of the body.
    _ballPosition.x = bodyBox->GetPosition().x;
    _ballPosition.y = bodyBox->GetPosition().y;
    _ballRotation = bodyBox->GetAngle();
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
        // Init.
        ivPlayer1Touchpad.hidden = NO;
        //[glView setBounds:CGRectMake(0, 0, 320, 380)];
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
    _Player1Paddle.x = bounds.size.width / 2;
    _Player1Paddle.y = 0.0;
    _Player1Score = 0;
    _Player2Score = 0;
    _ballPosition.x = bounds.size.width / 2;
    _ballPosition.y = bounds.size.height / 2;
    _ballPositionVelocity.x = 4.0; // Pixels / 1 second.
    _ballPositionVelocity.y = 4.0; // Pixels / 1 second.
    _ballRotation = 0.0;
    _ballRotationVelocity = 1.0;
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
        // Get time difference time.
        timeCurrent = CFAbsoluteTimeGetCurrent();
        timeDifference = timeCurrent - _timeBegin;
        // Update physics.
        [self updatePhysics];
        // Update ball logic.
		//[self updateBall];
        //_ballRotation += _ballRotationVelocity * timeDifference;
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
        glPushMatrix();
        glTranslatef(_Player1Paddle.x, 76, 0);
        [_textures[kTexture_Player1Paddle] drawAtPoint:CGPointZero];
        glPopMatrix();
        
        // Draw overlay player 1 status.
        _Player1StatusScore = [[Texture2D alloc] initWithString:[NSString stringWithFormat:@"%i", _Player1Score] dimensions:CGSizeMake(32, 32) alignment:UITextAlignmentCenter fontName:kFontName fontSize:kLabelFontSize];
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        [_textures[kTexture_Player1LabelScore] drawAtPoint:CGPointMake(64, 80)]; // Coordinates (0, 0) start at bottom left of screen.
        [_Player1StatusScore drawAtPoint:CGPointMake(96 + 4, 80)];
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
        glRotatef(_ballRotation, 0.0, 0.0, 1.0);
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
    delete world; // C++
    [ivPlayer1Touchpad release];
    [glView release];
	[super dealloc];
}

@end