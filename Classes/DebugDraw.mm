#import "DebugDraw.h"
#import "Texture2D.h"
#import "Box2D.h"

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
        glColor4f(color.r, color.g, color.b, 1.0);
        glPointSize(size);
        _V[0] = p.x;
        _V[1] = p.y;
        glVertexPointer(2, GL_FLOAT, 0, _V);
        glEnableClientState(GL_VERTEX_ARRAY);
        glDrawArrays(GL_POINTS, 0, 1);
        glPointSize(1.0);
    }
    /** Draw a string of text using ellipsis operator. */
    void DrawString(int x, int y, const char *string, ...) {
        va_list args;
        va_start(args, string);
        
        Texture2D *texture = [[Texture2D alloc] initWithString:[NSString stringWithCString:args] dimensions:CGSizeMake(128, 32) alignment:UITextAlignmentLeft fontName:@"Arial" fontSize:14];
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        [texture drawAtPoint:CGPointMake(x, y)];
        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        
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

@implementation DebugDraw
//---------------------------------------------------------------------
- (id) init {
    if(self = [super init]) {
        _cpp = new CppDebugDraw();
    }
    return self;
}
//---------------------------------------------------------------------
- (void) setPhyicsWorld:(b2World *)w {
    _physicsWorld = w;
    _physicsWorld->SetDebugDraw(_cpp);
}
//---------------------------------------------------------------------
- (void) setFlags:(GLuint)f {
    _cpp->SetFlags(f);
}
//---------------------------------------------------------------------
- (void) dealloc {
    delete _cpp;
    delete _physicsWorld;
    [super dealloc];
}
//---------------------------------------------------------------------
@end