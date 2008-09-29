/**
@file
    AppDelegate.h
@brief
    Copyright 2008 Creative Crew. All rights reserved.
@author
    William Chang
@version
    0.1
@date
    - Created: 2008-08-04
    - Modified: 2008-08-20
    .
@note
    References:
    - General:
        - https://developer.apple.com/iphone/library/navigation/index.html
        .
    .
*/

#import <UIKit/UIKit.h>

@class MainViewController;
@class ConsoleViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
@public
    IBOutlet UIWindow *window;
    IBOutlet MainViewController *vcMain;
    IBOutlet ConsoleViewController *vcConsole;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) MainViewController *vcMain;
@property (nonatomic, retain) ConsoleViewController *vcConsole;

- (void) flipToBack;
- (void) flipToFront;

@end