    //
//  LoginController.m
//  SalesPad
//
//  Created by SP on 3/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginController.h"
#import "ZKSforce.h"
#import "ZKLoginResult.h"
#import <QuartzCore/QuartzCore.h>

@implementation LoginController
@synthesize username, password, isloggedin, delegate, busyView, passwordcell, usernamecell, logintable;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[logintable setBackgroundColor:[UIColor clearColor]];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	[username release];
	self.username = nil;
	[password release];
	self.password = nil;
	
	[usernamecell release];
	self.usernamecell = nil;
	[passwordcell release];
	self.passwordcell = nil;
	
	[logintable release];
	self.logintable = nil;
	
	[busyView release];
	self.busyView = nil;
}


- (void)dealloc {
	[username release];
	[password release];
	[delegate release];
	[busyView release];
	[passwordcell release];
	[usernamecell release];
	[logintable release];
    [super dealloc];
}


- (void)doLoginCallback:(ZKLoginResult *)result error:(NSError*)error {
	if (result && !error) {
		[[self delegate] loginSuccess:self user:[result userInfo]];
	}
	else if (error) {
		[[[[UIAlertView alloc] initWithTitle:[error localizedDescription]
														message:[[error userInfo] valueForKey:@"faultstring"] 
													   delegate:nil 
											  cancelButtonTitle:NSLocalizedString(@"OK", nil)
											  otherButtonTitles:nil] autorelease] show];
		//NSLog(@"Error: %@, %@", [error localizedDescription], [[error userInfo] valueForKey:@"faultstring"]);
	}
	[[self busyView] stopAnimating];
}

- (IBAction)doLogin:(id)sender {
	//NSLog(@"Logging in %@ with %@", [[self username] text], [[self password] text]);
	[[self busyView] startAnimating]; 
	[[ZKServerSwitchboard switchboard] 
	 loginWithUsername:[[self username]text] 
	 password:[[self password] text] 
	 target:self 
	 selector:@selector(doLoginCallback:error:)];
}

- (IBAction)doOffline:(id)sender {
	NSLog(@"Working offline");
	[[self delegate] loginCancel:self];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return usernamecell;
    }
    return passwordcell;
}
@end
