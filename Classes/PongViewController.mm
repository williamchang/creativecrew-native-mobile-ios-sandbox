#import "PongViewController.h"
#import "PongView.h"
#import <sys/time.h>
#import "glu.h"
#import "Box2D.h"
#import "DebugDraw.h"

// BEGIN: C++ binding layer. Private access level (visibility).
@interface PongViewController (hidden)
- (void) initPhysics;
- (void) updatePhysics;
- (b2Body *) createBodyStatic:(GLfloat)x with:(GLfloat)y width:(GLfloat)w height:(GLfloat)h;
@end
// END: C++ binding layer. Private access level (visibility).

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
    //TODO For Sound: NSBundle *bundle = [NSBundle mainBundle];
    
    // Initialize.
    _isFirstTap = YES;

    // Set camera.
    _cameraOffsetX = 0.0;
    _cameraOffsetY = 0.0;
    _cameraOffsetZ = 5.0;
    [self setProjection3D];
    
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
- (void) setProjection2D {
    CGRect rect = [[UIScreen mainScreen] bounds];
    
    // Initialize OpenGL projection matrix.
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrthof(0, rect.size.width, 0, rect.size.height, -10, 10); // Left, right, bottom, near, far.
    glMatrixMode(GL_MODELVIEW); // Make OpenGL matrix mode default to modelview.
    glLoadIdentity();
}
//---------------------------------------------------------------------
- (void) setProjection3D {
    CGRect rect = [[UIScreen mainScreen] bounds];
    GLfloat eyeZ = rect.size.height / 1.1566;
    eyeZ -= -200;
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective(60.0, (GLfloat)rect.size.width / (GLfloat)rect.size.height, 0.5, 1500.0); // Field of view, aspect, near, far.
    glMatrixMode(GL_MODELVIEW);	
    glLoadIdentity();

    gluLookAt(
        rect.size.width / 2, rect.size.height / 2, eyeZ, // Eye x, y, z.
        rect.size.width / 2, rect.size.height / 2, 0.0, // Look at x, y, z.
        0.0, 1.0, 0.0 // Up x, y, z.
    );
}
//---------------------------------------------------------------------
// C++ binding layer.
- (void) initPhysics {
    // Get objective c values.
    GLfloat canvasWidth = self.view.bounds.size.width;
    GLfloat canvasHeight = self.view.bounds.size.height;
    
    // Define the size of the world.
    b2AABB worldAABB;
    worldAABB.upperBound.Set(canvasWidth, canvasHeight);
    worldAABB.lowerBound.Set(-10.0, -10.0);
    
    // Define the gravity vector.
    b2Vec2 gravity;
    gravity.Set(0.0, -9.8);
    
    // Let rigid bodies sleep.
    bool isBodiesSleep = true;
    
    // Construct a world object.
    world = new b2World(worldAABB, gravity, isBodiesSleep);
    
    // Debugging.
    physicsDebugDraw = [[DebugDraw alloc] init];
    [physicsDebugDraw setPhyicsWorld:world];
    
    // Define the body shape.
    b2CircleDef bodyBallShapeDefine;
    // Set radius to circle.
    bodyBallShapeDefine.radius = 10.0;
    // Set the box density to be non-zero, so it will be dynamic.
    bodyBallShapeDefine.density = 1.0;
    // Set fricition (coulomb friction) range 0.0 - 1.0.
    bodyBallShapeDefine.friction = 0.1;
    // Set restitution (elastic) range 0.0 - 1.0.
    bodyBallShapeDefine.restitution = 1.0;
    
    // Define the rigid body.
    b2BodyDef bodyBallDefine;
    // Set position.
    bodyBallDefine.position.Set(canvasWidth / 2, canvasHeight / 2);
    
    // Create rigid body from definition.
    bodyBall = world->CreateBody(&bodyBallDefine);
    // Add the shape to the body.
    bodyBall->CreateShape(&bodyBallShapeDefine);
    // Dynamically compute the body's mass base on its shape.
    bodyBall->SetMassFromShapes();

     
     
    
    /*
    // Define the body shape.
    b2PolygonDef bodyPaddleShapeDefine;
    bodyPaddleShapeDefine.SetAsBox(0.32, 0.08);
    bodyPaddleShapeDefine.density = 1.0;
    
    // Define the rigid body.
    b2BodyDef bodyPaddleDefine;
    bodyPaddleDefine.position.Set(canvasWidth / 2, canvasHeight / 2);
    bodyPaddleDefine.fixedRotation = true;
    
    // Create rigid body from definition.
    bodyPlayer1Paddle = world->CreateBody(&bodyPaddleDefine);
    // Add the shape to the body.
    bodyPlayer1Paddle->CreateShape(&bodyPaddleShapeDefine);
    bodyPlayer1Paddle->SetMassFromShapes();
*/
    
    // Prepare for simulation. Typically we use a time step of 1/60 of a
    // second (60Hz) and 10 iterations. This provides a high quality simulation
    // in most game scenarios.
    worldTimeStep = 1.0 / kRenderingFPS;
    worldIterationCount = 10;
    
    isFirstForces = true;
    
    [self createBodyStatic:0 with:0 width:10.0 height:40.0]; // Center.
    
    [self createBodyStatic:0.0 with:canvasHeight width:canvasWidth height:10.0]; // Ceiling.
    //[self createBodyStatic:canvasWidth with:0.0 width:10.0 height:canvasHeight]; // Right wall.
    //[self createBodyStatic:-10.0 with:0.0 width:10.0 height:canvasHeight]; // Left wall.
    //[self createBodyStatic:0.0 with:-10.0 width:-10.0 height:10.0]; // Floor.
}
//---------------------------------------------------------------------
// C++ binding layer.
- (b2Body *) createBodyStatic:(GLfloat)x with:(GLfloat)y width:(GLfloat)w height:(GLfloat)h {
    // Define the body shape.
    b2PolygonDef bodyGenericShapeDefine;
    bodyGenericShapeDefine.SetAsBox(w, h);
    
    // Define the rigid body.
    b2BodyDef bodyGenericDefine;
    bodyGenericDefine.position.Set(x, y);
    
    // Create rigid body from definition.
    b2Body *bodyGeneric = world->CreateBody(&bodyGenericDefine);
    // Add the shape to the body.
    bodyGeneric->CreateShape(&bodyGenericShapeDefine);
    return bodyGeneric;
}
//---------------------------------------------------------------------
// C++ binding layer.
- (void) updatePhysics {
    GLuint flags = 0;
	flags += b2DebugDraw::e_shapeBit * 0; // Shape outlines.
	flags += b2DebugDraw::e_jointBit * 0; // Joint connectivity.
	flags += b2DebugDraw::e_coreShapeBit * 0; // Core shapes (for continuous collision).
	flags += b2DebugDraw::e_aabbBit * 1; // Broad-phase axis-aligned bounding boxes (AABBs), including the world AABB.
	flags += b2DebugDraw::e_obbBit * 0; // Polygon oriented bounding boxes (OBBs).
	flags += b2DebugDraw::e_pairBit * 0; // Broad-phase pairs (potential contacts).
	flags += b2DebugDraw::e_centerOfMassBit * 0; // Center of mass.
    [physicsDebugDraw setFlags:flags];
    
    // Clear viewport.
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    /* calculate "global" dt */
	[self calculateDeltaTime];
    
    glPushMatrix();
    [self showRenderFps];
    glPopMatrix();
    
    // Instruct the world to perform a single step of physics simulation.
    world->Step(worldTimeStep, worldIterationCount);
    
    // Get the position and angle of the body.
    _ballPosition.x = bodyBall->GetPosition().x;
    _ballPosition.y = bodyBall->GetPosition().y;
    _ballRotation = bodyBall->GetAngle();
    
    if(isFirstForces) {
        // First vector is where the body should end up and the second vector is the body's center or it will spin.
        //bodyBall->ApplyImpulse(b2Vec2(self.view.bounds.size.width / 2, self.view.bounds.size.height), bodyBall->GetWorldCenter());
        isFirstForces = false;
    }
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
        //ivPlayer1Touchpad.hidden = NO;
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
    /*
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
    */
    // Swap frame buffers.
    [glView swapBuffers];
}
//---------------------------------------------------------------------
- (void) showRenderFps {
	frames++;
	accumDt += dt;
    
	if(accumDt > 0.3)  {
        frameRate = frames / accumDt;
        frames = 0;
        accumDt = 0;
	}
    
	Texture2D *texture = [[Texture2D alloc] initWithString:[NSString stringWithFormat:@"%.2f", frameRate] dimensions:CGSizeMake(100,30) alignment:UITextAlignmentLeft fontName:@"Arial" fontSize:14];
	//glEnable(GL_TEXTURE_2D);
	//glEnableClientState(GL_VERTEX_ARRAY);
	//glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	[texture drawAtPoint:CGPointMake(60,20)];
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
	//glDisable(GL_TEXTURE_2D);
	//glDisableClientState(GL_VERTEX_ARRAY);
	//glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    
    [texture release];
}
//---------------------------------------------------------------------
- (void) calculateDeltaTime {
    struct timeval now;

    if(gettimeofday(&now, NULL) != 0) {
        NSException* myException = [NSException exceptionWithName:@"GetTimeOfDay" reason:@"GetTimeOfDay abnormal error" userInfo:nil];
        @throw myException;
    }
    // Get new delta time.
    dt = (now.tv_sec - lastUpdate.tv_sec) + (now.tv_usec - lastUpdate.tv_usec) / 1000000.0;
    lastUpdate = now;
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
//---------------------------------------------------------------------
@end