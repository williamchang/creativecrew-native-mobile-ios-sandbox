/**
@file
    MainViewController.h
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


@interface MainViewController : UIViewController {
    IBOutlet UILabel *lblCompany;
    IBOutlet UIButton *btnCompany;
}

@property (nonatomic, retain) UILabel *lblCompany;
@property (nonatomic, retain) UIButton *btnCompany;

- (IBAction)switchControllers:(id)sender;

@end
