#import "ConsoleViewController.h"
#import "AppDelegate.h"

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
    [txt resignFirstResponder];
    if(txt == txtInput) {
        [txtInput resignFirstResponder];
        [self parseRequest:txtInput.text];
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
    NSInteger i = 0;
    NSArray *aryParameters = [strInput componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    for(NSString *p in aryParameters) {
        if(i == 0) {
            [self outputResponse:[@"" stringByAppendingFormat:@"Command \"%@\" not found.", p]];
        }
        i++;
    }
    return YES;
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