/**
@file
    TictactoeGameView.h
@brief
    Copyright 2008 Creative Crew. All rights reserved.
@author
    William Chang
@version
    0.1
@date
    - Created: 2008-08-14
    - Modified: 2008-09-28
    .
@note
    References:
    - General:
        - https://developer.apple.com/iphone/library/navigation/index.html
        - http://developer.apple.com/iphone/library/navigation/Frameworks/Media/OpenGLES/index.html
        .
    - Quartz:
        - http://www.iphonedevcentral.org/tutorials.php?page=ViewTutorial&id=29&uid=30206100
        .
    .
*/

#import <UIKit/UIKit.h>


@interface TictactoeGameView : UIView {
@public
    IBOutlet UIImageView *ivDroppable1;
    IBOutlet UIImageView *ivDroppable2;
@private
    CGContextRef _cgContext;
    CGLayerRef _cgLayer;
}

- (void) drawBoard;

@end