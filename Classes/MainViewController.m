#import "MainViewController.h"
#import "AppDelegate.h"

@implementation MainViewController

@synthesize lblCompany;

//---------------------------------------------------------------------
- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Title displayed by the navigation controller.
        self.title = @"Creative Crew";
    }
    return self;
}
//---------------------------------------------------------------------
/* Implement loadView if you want to create a view hierarchy programmatically. */
- (void) loadView {
    [super loadView];
    lblCompany.text = self.title;
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
/* Prepares the receiver for service after it has been loaded from an Interface Builder archive, or nib file. */
- (void) awakeFromNib {}
//---------------------------------------------------------------------
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self switchControllers];
}
//---------------------------------------------------------------------
- (void) switchControllers {
	AppDelegate *dlgt = (AppDelegate *)[UIApplication sharedApplication].delegate;
	[dlgt flipToBack];
}
//---------------------------------------------------------------------
- (void) dealloc {
    [lblCompany release];
    [super dealloc];
}
//---------------------------------------------------------------------
@end