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
    - Modified: 2008-08-13
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


@interface PongViewController : UIViewController {
    IBOutlet UIImageView *ivPlayer1Paddle;
    IBOutlet UIImageView *ivPlayer2Paddle;
    
    IBOutlet UIImageView *ivPlayer1TouchPad;
}

@property (nonatomic, retain) UIImageView *ivPlayer1TouchPad;

@end
