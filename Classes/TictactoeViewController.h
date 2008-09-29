/**
@file
    TictactoeViewController.h
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
    .
*/

#import <UIKit/UIKit.h>

@class TictactoeGameView;

@interface TictactoeViewController : UIViewController {
@public
    UINavigationBar *navBar;
    UINavigationItem *navItemTitle;
@protected
    TictactoeGameView *viewGame;
@private
    CGRect _rectContent;
}

@end