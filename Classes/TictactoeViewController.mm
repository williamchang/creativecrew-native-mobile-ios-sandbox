#import "TictactoeViewController.h"
#import "TictactoeGameView.h"

@implementation TictactoeViewController
//---------------------------------------------------------------------
- (id) init {
    if(self = [super init]) {
        self.title = @"Tic Tac Toe";
    }
    return self;
}
//---------------------------------------------------------------------
- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Title displayed by the navigation controller.
        self.title = @"Tic Tac Toe";
	}
	return self;
}
//---------------------------------------------------------------------
/* Implement loadView if you want to create a view hierarchy programmatically. */
- (void) loadView {
    [super loadView];
    _rectContent = [[UIScreen mainScreen] bounds];
    
    // Init navigation bar.
    navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(_rectContent.origin.x, _rectContent.origin.y, _rectContent.size.width, 40.0)];
    navBar.barStyle = UIBarStyleDefault;
    navBar.delegate = self;
    
    // Init title navigation item.
    navItemTitle = [[UINavigationItem alloc] initWithTitle:self.title];
    [navBar pushNavigationItem:navItemTitle animated:YES];
    
    // Init main view.
    viewGame = [[TictactoeGameView alloc] initWithFrame:CGRectMake(_rectContent.origin.x, _rectContent.origin.y + navBar.bounds.size.height, _rectContent.size.width, _rectContent.size.height - navBar.bounds.size.height)];
    NSLog(@"View: y:%f, height:%f",  _rectContent.origin.y + navBar.bounds.size.height, _rectContent.size.height - navBar.bounds.size.height);
    
    // Add components to view.
    [self.view addSubview:navBar];
    [self.view addSubview:viewGame];
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
- (void) dealloc {
    [navItemTitle release];
    [navBar release];
    [viewGame release];
	[super dealloc];
}
//---------------------------------------------------------------------
@end