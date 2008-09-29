#import "PongViewController.h"
#import "PongView.h"
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
	if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
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
    self.view.multipleTouchEnabled = YES;
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
    
    // Pinch.
    if([touches count] == 2) {
        CGPoint touchPinchPoint1 = [[[touches allObjects] objectAtIndex:0] locationInView:self.view];
        CGPoint touchPinchPoint2 = [[[touches allObjects] objectAtIndex:1] locationInView:self.view];
        _touchesPinchDistanceBegan = [self distancePoints:touchPinchPoint1 toPoint:touchPinchPoint2];
    }
    // Zones.
    if([touch view] == ivPlayer1Touchpad) {
        GLfloat x = [touch locationInView:self.view].x / 16;
        GLfloat y = 3.0;
        [self player1Began:x with:y];
    } else if([touch view] == glView) {
        GLfloat x = [touch locationInView:self.view].x / 16;
        GLfloat y = -(([touch locationInView:self.view].y / 16) - 30.0);
        [_physicsDebugDraw pickBodyBegan:x with:y];
    }
}
//---------------------------------------------------------------------
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    
    // Pinch.
    if([touches count] == 2) {
        CGPoint touchPinchPoint1 = [[[touches allObjects] objectAtIndex:0] locationInView:self.view];
        CGPoint touchPinchPoint2 = [[[touches allObjects] objectAtIndex:1] locationInView:self.view];
        CGFloat touchesPinchDistanceMoved = [self distancePoints:touchPinchPoint1 toPoint:touchPinchPoint2];
        CGFloat touchesPinchRatio = touchesPinchDistanceMoved / _touchesPinchDistanceBegan;
        if(touchesPinchDistanceMoved > _touchesPinchDistanceLast) {
            // Zoom out.
            _statePinch = kStatePinch_Outward;
            glScalef(1.0 + -touchesPinchRatio / 60, 1.0 + -touchesPinchRatio / 60, 1.0);
            NSLog(@"Outward: %f, %f", touchesPinchDistanceMoved, touchesPinchRatio);
        } else {
            // Zoom in.
            _statePinch = kStatePinch_Inward;
            glScalef(1.0 + touchesPinchRatio / 20, 1.0 + touchesPinchRatio / 20, 1.0);
            NSLog(@"Inward: %f, %f", touchesPinchDistanceMoved, touchesPinchRatio);
        }
        _touchesPinchDistanceLast = touchesPinchDistanceMoved;
    }
    // Zones.
    if([touch view] == ivPlayer1Touchpad) {
        GLfloat x = [touch locationInView:self.view].x / 16;
        GLfloat y = 3.0;
        [self player1Moved:x with:y];
    } else if([touch view] == glView) {
        GLfloat x = [touch locationInView:self.view].x / 16;
        GLfloat y = -(([touch locationInView:self.view].y / 16) - 30.0);
        [_physicsDebugDraw pickBodyMoved:x with:y];
    }
}
//---------------------------------------------------------------------
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    
    // Zones.
    if([touch view] == ivPlayer1Touchpad) {
        [self player1Ended];
    } else if([touch view] == glView) {
        [self start];
        [_physicsDebugDraw pickBodyEnded];
    }
    
    // Reset or clear touches.
    _statePinch = kStatePinch_Null;
    _touchesPinchDistanceLast = -1.0;
}
//---------------------------------------------------------------------
- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touches cancelled.");
    
    // Reset or clear touches.
    _statePinch = kStatePinch_Null;
    _touchesPinchDistanceBegan = -1.0;
}
//---------------------------------------------------------------------
- (CGFloat) distancePoints:(CGPoint)from toPoint:(CGPoint)to {
    float x = to.x - from.x;
    float y = to.y - from.y;
    return sqrt(x * x + y * y);
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
- (CGRect) getViewVirtualBounds {
    // Apple iPhone fullscreen in portrait width 320px and height 480px.
    CGRect b = [[UIScreen mainScreen] bounds];
    //CGRect b = self.view.bounds;
    //CGRect b = self.glView.bounds;
    
    // Scale.
    b.size.width /= 16; // 20 units.
    b.size.height /= 16; // 30 units.
    
    return b;
}
//---------------------------------------------------------------------
- (void) player1Began:(GLfloat)x with:(GLfloat)y {
    if(_jointPlayer1Touchpad != NULL) {
        return;
    }
    
    if(isFirstPlayer1Touched) {
        x = _bodyPlayer1Paddle->GetWorldCenter().x;
        y = _bodyPlayer1Paddle->GetWorldCenter().y;
        isFirstPlayer1Touched = false;
    }
    
    // Get coordinates from input event.
    b2Vec2 p;
    p.Set(x, y);
    
    if(_bodyPlayer1Paddle) {
        b2MouseJointDef md;
        md.body1 = _physicsWorld->GetGroundBody();
        md.body2 = _bodyPlayer1Paddle;
        md.target = p;
        md.maxForce = 1000.0 * _bodyPlayer1Paddle->GetMass();
        _jointPlayer1Touchpad = (b2MouseJoint *)_physicsWorld->CreateJoint(&md);
		_bodyPlayer1Paddle->WakeUp();
    }
}
//---------------------------------------------------------------------
- (void) player1Moved:(GLfloat)x with:(GLfloat)y {
    if(_jointPlayer1Touchpad) {
        b2Vec2 p;
        p.Set(x, y);
        _jointPlayer1Touchpad->SetTarget(p);
    }
}
//---------------------------------------------------------------------
- (void) player1Ended {
    if(_jointPlayer1Touchpad) {
        _physicsWorld->DestroyJoint(_jointPlayer1Touchpad);
        _jointPlayer1Touchpad = NULL;
    }
    isFirstPlayer1Touched = true;
}
//---------------------------------------------------------------------
- (void) updateBall {
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
    _cameraOffsetZ = 0.0;
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
    CGRect boundsScreen = [[UIScreen mainScreen] bounds];
    glMatrixMode(GL_PROJECTION);
    glPushMatrix();
        glLoadIdentity();
        glOrthof(0, boundsScreen.size.width, 0, boundsScreen.size.height, -1.0, 1.0);
    
        glMatrixMode(GL_MODELVIEW);
        glPushMatrix();
            glLoadIdentity();
            glDisable(GL_BLEND);
            [_textures[kTexture_Title] drawInRect:boundsScreen];
            glEnable(GL_BLEND);
        glPopMatrix();

    glMatrixMode(GL_PROJECTION);
    glPopMatrix();
    
    // Default matrix mode.
    glMatrixMode(GL_MODELVIEW);
    
    // Swap the framebuffer.
    [glView swapBuffers];
}
//---------------------------------------------------------------------
- (void) setProjection2D {
    CGRect bounds = [[UIScreen mainScreen] bounds];
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrthof(0, bounds.size.width, 0, bounds.size.height, -1.0, 1.0); // Left, right, bottom, near, far.
}
//---------------------------------------------------------------------
- (void) setProjection3D {
    CGRect boundsScreen = [[UIScreen mainScreen] bounds];
    CGRect bounds = [self getViewVirtualBounds];
    GLfloat eyeZ = bounds.size.height / 1.1566;
    eyeZ += 0.0; // Positive: zoom out, negative: zoom in.
    
    //float factor = 1.0;
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrthof(0, boundsScreen.size.width, 0, boundsScreen.size.height, -100, 100);
    //glOrthof(-320 / factor, 320 / factor, -480 / factor, 480 / factor, -1.0, 1.0);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glScalef(16.0, 16.0, 1.0);
    
    /*
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective(60.0, (GLfloat)bounds.size.width / (GLfloat)bounds.size.height, 0.5, 1500.0); // Field of view, aspect, near, far.
    glMatrixMode(GL_MODELVIEW);	
    glLoadIdentity();

    gluLookAt(
        bounds.size.width / 2, bounds.size.height / 2, eyeZ, // Eye x, y, z.
        bounds.size.width / 2, bounds.size.height / 2, -100.0, // Look at x, y, z.
        0.0, 1.0, 0.0 // Up x, y, z.
    );
    */
}
//---------------------------------------------------------------------
// C++ binding layer.
- (void) initPhysics {
    // Get objective c values.
    GLfloat canvasWidth = [self getViewVirtualBounds].size.width;
    GLfloat canvasHeight = [self getViewVirtualBounds].size.height;
    
    // Define the size of the world.
    b2AABB worldAABB;
    worldAABB.upperBound.Set(canvasWidth, canvasHeight); // Extend to the top right of screen.
    worldAABB.lowerBound.Set(0.0, 0.0); // Coordinates (0, 0) start at bottom left of screen.
    
    // Define the gravity vector. Earth gravity -9.8 m/s^2.
    b2Vec2 gravity;
    gravity.Set(0.0, -0.8);
    
    // Let rigid bodies sleep.
    bool letBodiesSleep = true;
    
    // Construct a world object.
    _physicsWorld = new b2World(worldAABB, gravity, letBodiesSleep);
    
    // Debugging.
    _physicsDebugDraw = [[DebugDraw alloc] init];
    [_physicsDebugDraw setPhyicsWorld:_physicsWorld bounds:[self getViewVirtualBounds]];

    
    
    [self createBodyStatic:canvasWidth / 2 with:canvasHeight - 0.2 width:canvasWidth / 2 height:0.2]; // Ceiling.
    b2Body *bodyGround = [self createBodyStatic:canvasWidth / 2 with:0.2 width:canvasWidth / 2 height:0.2]; // Floor.

    [self createBodyStatic:0.2 with:canvasHeight / 2 width:0.2 height:(canvasHeight / 2) - 0.4]; // Left wall.
    [self createBodyStatic:canvasWidth - 0.2 with:canvasHeight / 2 width:0.2 height:(canvasHeight / 2) - 0.4]; // Right wall.
    
    
    // Define the body shape.
    b2CircleDef bodyBallShapeDefine;
    // Set radius to circle.
    bodyBallShapeDefine.radius = 1.0;
    // Set the box density to be non-zero, so it will be dynamic.
    bodyBallShapeDefine.density = 1.0;
    // Set fricition (coulomb friction) range 0.0 - 1.0.
    bodyBallShapeDefine.friction = 0.1;
    // Set restitution (elastic) range 0.0 - 1.0.
    bodyBallShapeDefine.restitution = 1.0;
    
    // Define the rigid body.
    b2BodyDef bodyBallDefine;
    // Set position.
    bodyBallDefine.position.Set(10.0, canvasHeight / 2);
    
    // Create rigid body from definition.
    _bodyBall = _physicsWorld->CreateBody(&bodyBallDefine);
    // Add the shape to the body.
    _bodyBall->CreateShape(&bodyBallShapeDefine);
    // Dynamically compute the body's mass base on its shape.
    _bodyBall->SetMassFromShapes();

     
    
    // Define the body shape.
    b2PolygonDef bodyPaddleShapeDefine;
    bodyPaddleShapeDefine.SetAsBox(1.5, 0.3);
    // Set the box density to be non-zero, so it will be dynamic.
    bodyPaddleShapeDefine.density = 0.4;
    
    // Define the rigid body.
    b2BodyDef bodyPaddleDefine;
    bodyPaddleDefine.position.Set(canvasWidth / 2, 5.0);
    bodyPaddleDefine.fixedRotation = true;
    
    // Create rigid body from definition.
    _bodyPlayer1Paddle = _physicsWorld->CreateBody(&bodyPaddleDefine);
    // Add the shape to the body.
    _bodyPlayer1Paddle->CreateShape(&bodyPaddleShapeDefine);
    _bodyPlayer1Paddle->SetMassFromShapes();

    // Define the joint.
    b2PrismaticJointDef jointPaddleDefine;
    jointPaddleDefine.Initialize(bodyGround, _bodyPlayer1Paddle, bodyGround->GetWorldCenter(), b2Vec2(1.0, 0.0));
    jointPaddleDefine.lowerTranslation = -8.0;
    jointPaddleDefine.upperTranslation = 8.0;
    jointPaddleDefine.enableLimit = true;
    jointPaddleDefine.maxMotorForce = 1000.0;
    jointPaddleDefine.motorSpeed = 4.0;
    jointPaddleDefine.enableMotor = false;
    
    // Create joint from definition.
    _jointPlayer1Paddle = (b2PrismaticJoint *)_physicsWorld->CreateJoint(&jointPaddleDefine);
    
    // Prepare for simulation. Typically we use a time step of 1/60 of a
    // second (60Hz) and 10 iterations. This provides a high quality simulation
    // in most game scenarios.
    _physicsWorldTimeStep = 1.0 / kRenderingFPS;
    _physicsWorldIterationCount = 10;
    
    isFirstPhysicsForced = true;
}
//---------------------------------------------------------------------
// C++ binding layer.
- (b2Body *) createBodyStatic:(GLfloat)x with:(GLfloat)y width:(GLfloat)w height:(GLfloat)h {
    // Define the body shape.
    b2PolygonDef bodyGenericShapeDefine;
    bodyGenericShapeDefine.SetAsBox(w, h);
    bodyGenericShapeDefine.density = 0.0;
    
    // Define the rigid body.
    b2BodyDef bodyGenericDefine;
    bodyGenericDefine.position.Set(x, y); // Position by center.
    
    // Create rigid body from definition.
    b2Body *bodyGeneric = _physicsWorld->CreateBody(&bodyGenericDefine);
    // Add the shape to the body.
    bodyGeneric->CreateShape(&bodyGenericShapeDefine);
    return bodyGeneric;
}
//---------------------------------------------------------------------
// C++ binding layer.
- (void) updatePhysics {
    // Set debug.
    GLuint flags = 0;
	flags += b2DebugDraw::e_shapeBit * 1; // Shape outlines.
	flags += b2DebugDraw::e_jointBit * 1; // Joint connectivity.
	flags += b2DebugDraw::e_coreShapeBit * 0; // Core shapes (for continuous collision).
	flags += b2DebugDraw::e_aabbBit * 0; // Broad-phase axis-aligned bounding boxes (AABBs), including the world AABB.
	flags += b2DebugDraw::e_obbBit * 0; // Polygon oriented bounding boxes (OBBs).
	flags += b2DebugDraw::e_pairBit * 0; // Broad-phase pairs (potential contacts).
	flags += b2DebugDraw::e_centerOfMassBit * 0; // Center of mass.
    [_physicsDebugDraw setPhysicsDebugFlags:flags];
    
    [_physicsDebugDraw frameStarted];
    
    // Instruct the world to perform a single step of physics simulation.
    _physicsWorld->Step(_physicsWorldTimeStep, _physicsWorldIterationCount);
    
    [_physicsDebugDraw frameEnded];
    
    // Get the position and angle of the body.
    _ballPosition.x = _bodyBall->GetPosition().x;
    _ballPosition.y = _bodyBall->GetPosition().y;
    _ballRotation = _bodyBall->GetAngle();
    
    if(isFirstPhysicsForced) {
        // First vector is where the body should end up and the second vector is the body's center or it will spin.
        _bodyBall->ApplyImpulse(b2Vec2(40.0, 40.0), _bodyBall->GetWorldCenter());
        isFirstPhysicsForced = false;
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
        ivPlayer1Touchpad.hidden = YES;
        isFirstPlayer1Touched = true;
        _isFirstTap = NO;
    } else { // Either the user tapped to start a new game or the user successfully landed the rocket.
        // Stop rendering timer
        //[_timer invalidate];
        //_timer = nil;

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
    CGRect bounds = [self getViewVirtualBounds];
    _state = kState_Running;
    _statePinch = kStatePinch_Null;
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
    CGRect bounds = [self getViewVirtualBounds];
    CFTimeInterval timeCurrent;
    float timeDifference;
    
	if(_state == kState_Running) {
        // Get time difference time.
        timeCurrent = CFAbsoluteTimeGetCurrent();
        timeDifference = timeCurrent - _timeBegin;
        // Update physics.
        [self updatePhysics];
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
    /*glDisable(GL_BLEND);
    [_textures[kTexture_Background] drawInRect:bounds];
    glEnable(GL_BLEND);*/
    
    if(_state != kState_StandBy) {
        // Draw player 1 paddle.
        /*glPushMatrix();
            glTranslatef(_Player1Paddle.x, 76, 0);
            [_textures[kTexture_Player1Paddle] drawAtPoint:CGPointZero];
        glPopMatrix();*/
        
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
        /*glPushMatrix();
            glTranslatef(_ballPosition.x, _ballPosition.y, 0);
            glRotatef(_ballRotation, 0.0, 0.0, 1.0);
            [_textures[kTexture_Ball] drawAtPoint:CGPointZero];
        glPopMatrix();*/
    }

    // Swap frame buffers.
    [glView swapBuffers];
}
//---------------------------------------------------------------------
- (void) dealloc {
    [_Player1StatusScore release];
    [_Player2StatusScore release];
    unsigned int i;for(i = 0;i < kNumTextures;i++) {[_textures[i] release];}
    
    delete _jointPlayer1Touchpad; // C++
    delete _jointPlayer1Paddle; // C++
    [_physicsDebugDraw release];
    delete _physicsWorld; // C++
    
    [_timer release];
    [ivPlayer1Touchpad release];
    [glView release];
    [super dealloc];
}
//---------------------------------------------------------------------
@end