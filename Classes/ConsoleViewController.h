/**
@file
    ConsoleViewController.h
@brief
    Copyright 2008 Creative Crew. All rights reserved.
@author
    William Chang
@version
    0.1
@date
    - Created: 2008-08-07
    - Modified: 2008-08-13
    .
@note
    References:
    - General:
        - https://developer.apple.com/iphone/library/navigation/index.html
        .
    .
*/

#import <UIKit/UIKit.h>

#define kAnimationKey @"transitionViewAnimation"
#define kShowAnimationkey @"showAnimation"
#define kHideAnimationKey @"hideAnimation"

@interface ConsoleViewController : UIViewController {
    IBOutlet UITextField *txtInput;
    IBOutlet UIButton *btnInput;
    IBOutlet UITextView *tvOutput;
}

@property (nonatomic, retain) UITextField *txtInput;
@property (nonatomic, retain) UIButton *btnInput;
@property (nonatomic, retain) UITextView *tvOutput;

- (IBAction) onExecute:(id)sender;
- (IBAction) onSwitchControllers:(id)sender;
- (BOOL) parseRequest:(NSString *)strInput;
- (BOOL) executeRequest:(NSString *)strCommand;
- (BOOL) outputRequest:(NSString *)strInput;
- (BOOL) outputResponse:(NSString *)strInput;

@end