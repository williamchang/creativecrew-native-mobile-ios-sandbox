#import "AppDelegate.h"
#import "MainViewController.h"
#import "ConsoleViewController.h"

@implementation AppDelegate

@synthesize window;
@synthesize vcMain;
@synthesize vcConsole;

//---------------------------------------------------------------------
/** Start application (similar to main method) after launching is finish. */
- (void) applicationDidFinishLaunching:(UIApplication *)application {	

    // TODO: Create and configure the navigation and view controllers.

    // Add view controller to window's subview.
    MainViewController *vc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    self.vcMain = vc;
    [vc release];
    [self.window addSubview:vcMain.view];

    // Show window. Make the receiver the main window and displays it in front of other windows.
    [self.window makeKeyAndVisible];
}
//---------------------------------------------------------------------
- (void) flipToBack {
    ConsoleViewController *vc = [[ConsoleViewController alloc] initWithNibName:@"ConsoleViewController" bundle:nil];
    self.vcConsole = vc;
    [vc release];

    [UIView beginAnimations:nil	context:NULL];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.window cache:YES];
    [vcMain.view removeFromSuperview];
    [self.window addSubview:vcConsole.view];
    [UIView commitAnimations];
}
//---------------------------------------------------------------------
- (void) flipToFront {
    [UIView beginAnimations:nil	context:NULL];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.window cache:YES];
    [vcConsole.view removeFromSuperview];
    [self.window addSubview:vcMain.view];
    [UIView commitAnimations];
    
    [vcConsole release];
    vcConsole = nil;
}
//---------------------------------------------------------------------
- (void) dealloc {
    [vcConsole release];
    [vcMain release];
    [window release];
    [super dealloc];
}
//---------------------------------------------------------------------
@end