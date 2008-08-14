#import "ConsoleViewController.h"
#import "AppDelegate.h"
#import "PongViewController.h"
#import "TictactoeViewController.h"

@implementation ConsoleViewController

@synthesize txtInput;
@synthesize btnInput;
@synthesize tvOutput;

//---------------------------------------------------------------------
- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Title displayed by the navigation controller.
        self.title = @"Console";
    }
    return self;
}
//---------------------------------------------------------------------
/* Implement loadView if you want to create a view hierarchy programmatically. */
- (void) loadView {
    [super loadView];
    tvOutput.text = @"";
}
//---------------------------------------------------------------------
/* If you need to do additional setup after loading the view, override viewDidLoad. */
- (void) viewDidLoad {
    [super viewDidLoad];
}
//---------------------------------------------------------------------
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
//---------------------------------------------------------------------
- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}
//---------------------------------------------------------------------
- (void) awakeFromNib {}
//---------------------------------------------------------------------
- (BOOL) textFieldShouldReturn:(UITextField *)txt {
    if(txt == txtInput) {
        [self parseRequest:txtInput.text];
        txtInput.text = @"";
    } else {
        [txt resignFirstResponder];
    }
    return YES;
}
//---------------------------------------------------------------------
- (IBAction) onExecute:(id)sender {
    [txtInput resignFirstResponder];
    [self parseRequest:txtInput.text];
}
//---------------------------------------------------------------------
- (IBAction) onSwitchControllers:(id)sender {
    AppDelegate *dlgt = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [dlgt flipToFront];
}
//---------------------------------------------------------------------
- (BOOL) parseRequest:(NSString *)strInput {
    if([strInput length] <= 0) {
        return NO;
    }
    [self outputRequest:txtInput.text];
    NSArray *aryParameters = [strInput componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *command = [aryParameters objectAtIndex:0];
    /*
    NSInteger i = 0;
    for(NSString *p in aryParameters) {
        if(i == 0) {
            [self outputResponse:[@"" stringByAppendingFormat:@"Command \"%@\" not found.", p]];
        }
        i++;
    }
    */
    if([@"pong" caseInsensitiveCompare:command] == 0) {
        [self outputResponse:[@"" stringByAppendingFormat:@"Command \"%@\" executed.", command]];
        
        AppDelegate *dlgt = (AppDelegate *)[UIApplication sharedApplication].delegate;
        //MainViewController *vc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
        PongViewController *vc = [[PongViewController alloc] initWithNibName:@"PongViewController" bundle:nil];
        
        [UIView beginAnimations:nil	context:NULL];
        [UIView setAnimationDuration:1.0];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:dlgt.window cache:YES];
        [self.view removeFromSuperview];
        [dlgt.window addSubview:vc.view];
        [UIView commitAnimations];
        
        return YES;
    } else if([@"tictactoe" caseInsensitiveCompare:command] == 0) {
        [self outputResponse:[@"" stringByAppendingFormat:@"Command \"%@\" executed.", command]];
        
        //AppDelegate *dlgt = (AppDelegate *)[UIApplication sharedApplication].delegate;
        //TictactoeViewController *vc = [[TictactoeViewController alloc] initWithNibName:@"TictactoeViewController" bundle:nil];
        
        return YES;
    } else {
        [self outputResponse:[@"" stringByAppendingFormat:@"Command \"%@\" not found.", command]];
    }
    return NO;
}
//---------------------------------------------------------------------
- (BOOL) executeRequest:(NSString *)strCommand {
    return YES;
}
//---------------------------------------------------------------------
- (BOOL) outputRequest:(NSString *)strInput {
    tvOutput.text = [@"" stringByAppendingFormat:@"$ %@\n%@", strInput, tvOutput.text];
    return YES;
}
//---------------------------------------------------------------------
- (BOOL) outputResponse:(NSString *)strInput {
    tvOutput.text = [@"" stringByAppendingFormat:@"%@\n%@", strInput, tvOutput.text];
    return YES;
}
//---------------------------------------------------------------------
- (void) dealloc {
    [txtInput release];
    [btnInput release];
    [tvOutput release];
	[super dealloc];
}

@end