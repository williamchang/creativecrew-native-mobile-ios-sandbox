#import "PongViewController.h"

@implementation PongViewController

@synthesize ivPlayer1Paddle;

//---------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}
//---------------------------------------------------------------------
/* Implement loadView if you want to create a view hierarchy programmatically. */
- (void)loadView {
    [super loadView];
    tvOutput.text = @"";
}
//---------------------------------------------------------------------
/* If you need to do additional setup after loading the view, override viewDidLoad. */
- (void)viewDidLoad {
    [super viewDidLoad];
}
//---------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
//---------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}
//---------------------------------------------------------------------
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
}
//---------------------------------------------------------------------
- (void)dealloc {
	[super dealloc];
}


@end
