//
// Implementation of GLU functions
//

#ifndef __glu_H__
#define __glu_H__

#import <OpenGLES/ES1/gl.h>

void gluLookAt(GLfloat eyeX, GLfloat eyeY, GLfloat eyeZ, GLfloat lookAtX, GLfloat lookAtY, GLfloat lookAtZ, GLfloat upX, GLfloat upY, GLfloat upZ);
void gluPerspective(GLfloat fovy, GLfloat aspect, GLfloat zNear, GLfloat zFar);

#endif // #ifndef __glu_H__
