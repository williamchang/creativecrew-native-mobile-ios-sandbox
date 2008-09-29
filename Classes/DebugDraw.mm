#import "DebugDraw.h"
#import "Texture2D.h"
#import "Box2D.h"

#define kMaxContactPoints 2048

enum ContactState {
    e_contactAdded,
    e_contactPersisted,
    e_contactRemoved,
};

struct ContactPoint {
    b2Shape *shape1;
    b2Shape *shape2;
    b2Vec2 normal;
    b2Vec2 position;
    b2Vec2 velocity;
    b2ContactID id;
    ContactState state;
};

/** Intermediate class for Objective-C, a C++ wrapper. */
class CppDebugWrapper {
public:
    /** Default constructor. */
    CppDebugWrapper() {}
    /** Default destructor. */
    virtual ~CppDebugWrapper() {}
    
    ContactPoint points[kMaxContactPoints];
    GLint pointCount;
};

/** This class implements debug drawing callbacks that are invoked inside b2World::Step. */
class CppDebugDraw : public b2DebugDraw {
public:
    /** Default constructor. */
    CppDebugDraw() {_fillShapes = false;}
    /** Default destructor. */
    virtual ~CppDebugDraw() {}
    /** Draw a closed polygon provided in CCW order. */
    void DrawPolygon(const b2Vec2 *vertices, int32 vertexCount, const b2Color &color) {
        glColor4f(color.r, color.g, color.b, 1.0);
        for(GLint i = 0, j = 0;i < vertexCount;i++) {
            _V[j]  = vertices[i].x;
            _V[j+1]= vertices[i].y;
            j += 2;
        }
        glVertexPointer(2, GL_FLOAT, 0, _V);
        glEnableClientState(GL_VERTEX_ARRAY); 
        glDrawArrays(GL_LINE_LOOP, 0, vertexCount);
    }
    /** Draw a solid closed polygon provided in CCW order. */
    void DrawSolidPolygon(const b2Vec2 *vertices, int32 vertexCount, const b2Color &color) {
        GLint i, j;
        if(_fillShapes) {
            glEnable(GL_BLEND);
            glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            glColor4f(0.5 * color.r, 0.5 * color.g, 0.5 * color.b, 0.5);
            for (i = 0, j = 0; i < vertexCount;i++) {
                _V[j]  = vertices[i].x;
                _V[j+1]= vertices[i].y;
                j+=2;
            }
            glVertexPointer(2, GL_FLOAT, 0, _V);
            glEnableClientState(GL_VERTEX_ARRAY); 
            glDrawArrays(GL_TRIANGLE_FAN, 0, vertexCount);
            glDisable(GL_BLEND);
        }
        glColor4f(color.r, color.g, color.b, 1.0);
        for(i = 0, j = 0;i < vertexCount;i++) {
            _V[j]  = vertices[i].x;
            _V[j+1] = vertices[i].y;
            j += 2;
        }
        glVertexPointer(2, GL_FLOAT, 0, _V);
        glEnableClientState(GL_VERTEX_ARRAY);
        glDrawArrays(GL_LINE_LOOP, 0, vertexCount);
    }
    /** Draw a circle. */
    void DrawCircle(const b2Vec2 &center, float32 radius, const b2Color &color) {
        const GLint k_segments = 16;
        const GLfloat k_increment = 2.0 * b2_pi / (GLfloat)k_segments;
        GLfloat theta = 0.0;
        glColor4f(color.r, color.g, color.b, 1.0);
        for(GLint i = 0, j = 0;i < k_segments; i++, j += 2) {
            _V[j] = center.x + radius * cosf(theta);
            _V[j + 1] = center.x  + radius * sinf(theta);
            theta += k_increment;
        }
        glVertexPointer(2, GL_FLOAT, 0, _V);
        glEnableClientState(GL_VERTEX_ARRAY);
        glDrawArrays(GL_LINE_LOOP, 0, k_segments);
    }
    /** Draw a solid circle. */
    void DrawSolidCircle(const b2Vec2 &center, float32 radius, const b2Vec2 &axis, const b2Color &color) {
        const GLint k_segments = 16;
        const GLfloat k_increment = 2.0 * b2_pi / (GLfloat)k_segments;
        GLfloat theta = 0.0;
        if(_fillShapes) {
            glEnable(GL_BLEND);
            glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            glColor4f(0.5 * color.r, 0.5 * color.g, 0.5 * color.b, 0.5);
            for(GLint i = 0, j = 0;i < k_segments;i++, j += 2) {
                _V[j] = center.x + radius * cosf(theta);
                _V[j+1] = center.y + radius * sinf(theta);
                theta += k_increment;
            }
            glVertexPointer(2, GL_FLOAT, 0, _V);
            glEnableClientState(GL_VERTEX_ARRAY); 
            glDrawArrays(GL_TRIANGLE_FAN, 0, k_segments);
            glDisable(GL_BLEND);
            theta = 0.0;
        }
        glColor4f(color.r, color.g, color.b, 1.0);
        for(GLint i = 0, j = 0; i < k_segments; i++, j += 2) {
            _V[j] = center.x + radius * cosf(theta);
            _V[j + 1] = center.y + radius * sinf(theta);
            theta += k_increment;
        }
        glVertexPointer(2, GL_FLOAT, 0, _V);
        glEnableClientState(GL_VERTEX_ARRAY); 
        glDrawArrays(GL_LINE_LOOP, 0, k_segments);

        b2Vec2 p = center + radius * axis;
        _V[0] = center.x;
        _V[1] = center.y;
        _V[2] = center.x + radius * axis.x ;
        _V[3] = center.y  + radius * axis.y;
        glVertexPointer(2, GL_FLOAT, 0, _V);
        glEnableClientState(GL_VERTEX_ARRAY);
        glDrawArrays(GL_LINES, 0, 2);
    }
    /** Draw a line segment. */
    void DrawSegment(const b2Vec2 &p1, const b2Vec2 &p2, const b2Color &color) {
        glColor4f(color.r, color.g, color.b, 1.0);
        _V[0] = p1.x;
        _V[1] = p1.y;
        _V[2] = p2.x;
        _V[3] = p2.y;
        glVertexPointer(2, GL_FLOAT, 0, _V);
        glEnableClientState(GL_VERTEX_ARRAY);
        glDrawArrays(GL_LINES, 0, 2);
    }
    /**
     * Draw a transform. Choose your own length scale.
     * @param xf a transform.
     */
    void DrawXForm(const b2XForm &xf) {
        b2Vec2 p1 = xf.position, p2;
        const float32 k_axisScale = 0.4;
        glColor4f(0.0, 1.0, 0.0, 1.0);
        _V[0] = p1.x;
        _V[1] = p1.y;
        p2 = p1 + k_axisScale * xf.R.col1;
        _V[2] = p2.x;
        _V[3] = p2.y;
        glColor4f(0.0f, 1.0f, 0.0f, 1.0);
        _V[4] = p1.x;
        _V[5] = p1.y;
        p2 = p1 + k_axisScale * xf.R.col2;
        _V[6] = p2.x;
        _V[7] = p2.y;
        glVertexPointer(2, GL_FLOAT, 0, _V);
        glDrawArrays(GL_LINES, 0, 4);
    }
    /** Draw a point. */
    void DrawPoint(const b2Vec2& p, float32 size, const b2Color& color) {
        glPointSize(size);
        glColor4f(color.r, color.g, color.b, 1.0);
        _V[0] = p.x;
        _V[1] = p.y;
        glVertexPointer(2, GL_FLOAT, 0, _V);
        glEnableClientState(GL_VERTEX_ARRAY);
        glDrawArrays(GL_POINTS, 0, 1);
    }
    /** Draw a string of text using ellipsis operator. */
    void DrawString(int x, int y, const char *string, ...) {
        va_list args;
        va_start(args, string);
        
        Texture2D *texture = [[Texture2D alloc] initWithString:[NSString stringWithCString:args] dimensions:CGSizeMake(128, 32) alignment:UITextAlignmentLeft fontName:@"Arial" fontSize:15];
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        [texture drawAtPoint:CGPointMake(x, y)];
        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        [texture release];
        
        va_end(args);        
    }
    /** Draw a box. */
    void DrawAABB(b2AABB *aabb, const b2Color &color) {
        _V[0] = aabb->lowerBound.x;
        _V[1] = aabb->lowerBound.y;
        _V[2] = aabb->upperBound.x;
        _V[3] = aabb->lowerBound.y;
        _V[4] = aabb->upperBound.x;
        _V[5] = aabb->upperBound.y;
        _V[6] = aabb->lowerBound.x;
        _V[7] = aabb->upperBound.y;
        glColor4f(color.r, color.g, color.b, 1.0);
        glVertexPointer(2, GL_FLOAT, 0, _V);
        glEnableClientState(GL_VERTEX_ARRAY);
        glDrawArrays(GL_LINE_LOOP, 0, 4);
    }
protected:
    bool _fillShapes;
    GLfloat _V[256];
};

/** This class implements collision callbacks. */
class CppContactListener : public b2ContactListener {
public:
    /** Called when a contact point is added. This includes the geometry and the forces. */
    void Add(const b2ContactPoint* point) {
        if(m->pointCount == kMaxContactPoints) {
            return;
        }

        ContactPoint *cp = m->points + m->pointCount;
        cp->shape1 = point->shape1;
        cp->shape2 = point->shape2;
        cp->position = point->position;
        cp->normal = point->normal;
        cp->id = point->id;
        cp->state = e_contactAdded;

        m->pointCount++;
    }
    /** Called when a contact point persists. This includes the geometry and the forces. */
    void Persist(const b2ContactPoint* point) {
        if(m->pointCount == kMaxContactPoints) {
            return;
        }
        
        ContactPoint *cp = m->points + m->pointCount;
        cp->shape1 = point->shape1;
        cp->shape2 = point->shape2;
        cp->position = point->position;
        cp->normal = point->normal;
        cp->id = point->id;
        cp->state = e_contactPersisted;

        m->pointCount++;
    }
    /** Called when a contact point is removed. This includes the last computed geometry and forces. */
    void Remove(const b2ContactPoint* point) {
        if(m->pointCount == kMaxContactPoints) {
            return;
        }
        
        ContactPoint *cp = m->points + m->pointCount;
        cp->shape1 = point->shape1;
        cp->shape2 = point->shape2;
        cp->position = point->position;
        cp->normal = point->normal;
        cp->id = point->id;
        cp->state = e_contactRemoved;
        
        m->pointCount++;
    }
    
    CppDebugWrapper *m;
};

@implementation DebugDraw
//---------------------------------------------------------------------
- (id) init {
    if(self = [super init]) {
        _cppDebugWrapper = new CppDebugWrapper();
        _cppDebugDraw = new CppDebugDraw();
        _x = 0.0;
        _y = 0.0;
        _jointPicker = NULL;
    }
    return self;
}
//---------------------------------------------------------------------
- (void) setPhyicsWorld:(b2World *)w bounds:(CGRect)b {
    _physicsWorld = w;
    _physicsWorld->SetDebugDraw(_cppDebugDraw);
    CppContactListener *contactListener = new CppContactListener();
    contactListener->m = _cppDebugWrapper;
    _physicsWorld->SetContactListener(contactListener);
    
    _physicsWorldBounds = b;
}
//---------------------------------------------------------------------
- (void) setPhysicsDebugFlags:(GLuint)f {
    _cppDebugDraw->SetFlags(f);
}
//---------------------------------------------------------------------
- (void) calculateDeltaTime {
    struct timeval timeNow;
    
    if(gettimeofday(&timeNow, NULL) != 0) {
        NSException* myException = [NSException exceptionWithName:@"GetTimeOfDay" reason:@"GetTimeOfDay abnormal error" userInfo:nil];
        @throw myException;
    }
    // Get new delta time.
    _deltaTime = (timeNow.tv_sec - _timeLast.tv_sec) + (timeNow.tv_usec - _timeLast.tv_usec) / 1000000.0;
    _timeLast = timeNow;
}
//---------------------------------------------------------------------
- (void) showFps {
	_frameCount++;
	_deltaTimeCount += _deltaTime;
    
	if(_deltaTimeCount > 0.3)  {
        _frameRate = _frameCount / _deltaTimeCount;
        _frameCount = 0;
        _deltaTimeCount = 0;
	}
    
    CGSize textureSize = CGSizeMake(40, 14);
    CGPoint texturePoint = CGPointMake(textureSize.width / 2, textureSize.height / 2);
	Texture2D *texture = [[Texture2D alloc] initWithString:[NSString stringWithFormat:@"%.2f", _frameRate] dimensions:textureSize alignment:UITextAlignmentLeft fontName:@"Arial" fontSize:15];
	
    glMatrixMode(GL_PROJECTION);
    glPushMatrix();
        glOrthof(0, _physicsWorldBounds.size.width, 0, _physicsWorldBounds.size.height, -1.0, 1.0);

        glMatrixMode(GL_MODELVIEW);
        glPushMatrix();
            glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            glColor4f(1.0, 0.0, 0.0, 1.0);
            [texture drawAtPoint:CGPointMake(texturePoint.x + 8, texturePoint.y + 16)];
            glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        glPopMatrix();
        
    glMatrixMode(GL_PROJECTION);
    glPopMatrix();
    glMatrixMode(GL_MODELVIEW);
    
    //glEnable(GL_TEXTURE_2D);
	//glEnableClientState(GL_VERTEX_ARRAY);
	//glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    /*
    glPushMatrix();
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glScalef(0.1, 0.1, 1.0);
    glColor4f(1.0, 0.0, 0.0, 1.0);
    [texture drawAtPoint:CGPointMake(30, 15)];
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glPopMatrix();
    */
	//glDisable(GL_TEXTURE_2D);
	//glDisableClientState(GL_VERTEX_ARRAY);
	//glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    
    [texture release];
}
//---------------------------------------------------------------------
- (void) setCoordinates:(GLfloat)x with:(GLfloat)y {
    _x = x;
    _y = y;
}
//---------------------------------------------------------------------
- (void) showCoordinates {
    CGSize textureSize = CGSizeMake(136, 14);
    CGPoint texturePoint = CGPointMake(textureSize.width / 2, textureSize.height / 2);
    Texture2D *texture = [[Texture2D alloc] initWithString:[NSString stringWithFormat:@"(X:%.2f Y:%.2f)", _x, _y] dimensions:textureSize alignment:UITextAlignmentLeft fontName:@"Arial" fontSize:15];
    
    glMatrixMode(GL_PROJECTION);
    glPushMatrix();
        glOrthof(0, _physicsWorldBounds.size.width, 0, _physicsWorldBounds.size.height, -1.0, 1.0);

        glMatrixMode(GL_MODELVIEW);
        glPushMatrix();
            glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            glColor4f(0.0, 0.0, 1.0, 1.0);
            [texture drawAtPoint:CGPointMake(texturePoint.x + 8, texturePoint.y + 32)];
            glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        glPopMatrix();
    glMatrixMode(GL_PROJECTION);
    glPopMatrix();
    glMatrixMode(GL_MODELVIEW);
    
    [texture release];
}
//---------------------------------------------------------------------
- (void) pickBodyBegan:(GLfloat)x with:(GLfloat)y {
    if(_jointPicker != NULL) {
        return;
    }
    
    // Get coordinates from input event.
    b2Vec2 p;
    p.Set(x, y);
    
    // Set coordinates.
    [self setCoordinates:x with:y];
    
    // Create a small box.
    b2AABB aabb;
    b2Vec2 d;
    d.Set(0.001, 0.001);
    aabb.lowerBound = p - d;
    aabb.upperBound = p + d;
    
    // Query the world for overlapping shapes.
	const GLint k_maxCount = 10;
	b2Shape *shapes[k_maxCount];
	int32 count = _physicsWorld->Query(aabb, shapes, k_maxCount);
	b2Body *body = NULL;
	for(GLint i = 0;i < count;i++) {
        b2Body* shapeBody = shapes[i]->GetBody();
        if(shapeBody->IsStatic() == false && shapeBody->GetMass() > 0.0) {
            bool inside = shapes[i]->TestPoint(shapeBody->GetXForm(), p);
            if(inside) {
                body = shapes[i]->GetBody();
                break;
            }
        }
	}
    
    if(body) {
        b2MouseJointDef md;
        md.body1 = _physicsWorld->GetGroundBody();
        md.body2 = body;
        md.target = p;
        md.maxForce = 1000.0 * body->GetMass();
        _jointPicker = (b2MouseJoint *)_physicsWorld->CreateJoint(&md);
		body->WakeUp();
    }
}
//---------------------------------------------------------------------
- (void) pickBodyMoved:(GLfloat)x with:(GLfloat)y {
    if(_jointPicker) {
        b2Vec2 p;
        p.Set(x, y);
        _jointPicker->SetTarget(p);
    }
}
//---------------------------------------------------------------------
- (void) pickBodyEnded {
    if(_jointPicker) {
        _physicsWorld->DestroyJoint(_jointPicker);
        _jointPicker = NULL;
    }
}
//---------------------------------------------------------------------
- (BOOL) frameStarted {
    // Clear viewport.
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Globally calculate delta time.
	[self calculateDeltaTime];
    
    // Show frames per second.
    [self showFps];
    
    // Show coordinates.
    [self showCoordinates];
    
    // Show picker.
    if(_jointPicker) {
        b2Body *body = _jointPicker->GetBody2();
        b2Vec2 p1 = body->GetWorldPoint(_jointPicker->m_localAnchor);
        b2Vec2 p2 = _jointPicker->m_target;

        glPointSize(4.0);
        GLfloat _V[4];
        glColor4f(0.0, 1.0, 0.0, 1.0);
        _V[0] = p1.x; _V[1] = p1.y;
        _V[2] = p2.x; _V[3] = p2.y;
        glVertexPointer(2, GL_FLOAT, 0, _V);
        glEnableClientState(GL_VERTEX_ARRAY);
        glDrawArrays(GL_POINTS, 0, 2);
        
        glPointSize(1.0);
        glColor4f(0.8, 0.8, 0.8, 1.0);
        _V[0] = p1.x; _V[1] = p1.y;
        _V[2] = p2.x; _V[3] = p2.y;
        glVertexPointer(2, GL_FLOAT, 0, _V);
        glEnableClientState(GL_VERTEX_ARRAY);
        glDrawArrays(GL_LINES, 0, 2);
    }
    
    // Empty contact points from previous frame.
    _cppDebugWrapper->pointCount = 0;

    return YES;
}
//---------------------------------------------------------------------
- (BOOL) frameEnded {
    // Show contact points.
    for(GLint i = 0;i < _cppDebugWrapper->pointCount;i++) {
        ContactPoint *point = _cppDebugWrapper->points + i;
        
        if(point->state == 0) { // Add
            _cppDebugDraw->DrawPoint(point->position, 10.0, b2Color(0.3, 0.95, 0.3));
        } else if (point->state == 1) { // Persist
            _cppDebugDraw->DrawPoint(point->position, 5.0, b2Color(0.3, 0.3, 0.95));
        } else { // Remove
            _cppDebugDraw->DrawPoint(point->position, 10.0, b2Color(0.95, 0.3, 0.3));
        }
    }
    
    return YES;
}
//---------------------------------------------------------------------
- (void) dealloc {
    delete _jointPicker;
    delete _cppDebugDraw;
    delete _cppDebugWrapper;
    delete _physicsWorld;
    [super dealloc];
}
//---------------------------------------------------------------------
@end