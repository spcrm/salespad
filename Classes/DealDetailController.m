    //
//  DealDetail.m
//  SalesPad
//
//  Created by SP on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DealDetailController.h"
#import "Currency.h"


@implementation DealDetailController;
@synthesize browser, deal, titlebar, delegate;

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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self showDeal];
}

-(void)showDeal {
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];;
	[formatter setDateFormat:@"yyyy-MM-dd"];

	NSMutableString *html = [[[NSMutableString alloc] initWithString:@""] autorelease];
	[[self titlebar] setTitle:[[deal detail] name]];
	if ([deal current] != nil && [deal previous] != nil) {
		[html appendFormat:@"<html><head><link href=""salespad.css"" rel=""stylesheet"" type=""text/css"" /><title>Deal Details</title></head> \
		 <body><TABLE cellspacing=""0"" id=""dealtable""><TR><TH class=""topleft label"">Field</TH><TH class=""equal"">New Value (%@)</TH><TH class=""equal"">Old Value (%@)</TH></TR>",
		 [[deal current] timestamp], [[deal previous] timestamp]];
		NSString *row = @"nochange";
		
		row = ([[[deal current]name] compare:[[deal previous]name]] != NSOrderedSame)? @"highlight": @"nohighlight";
		[html appendFormat:@"<TR class=""%@""><TH class=""spec"">Name</TH><TD>%@</TD><TD>%@</TD></TR>", row, [[deal current]name], [[deal previous]name]];

		row = ([[[[deal current]owner]name] compare:[[[deal previous]owner]name]] != NSOrderedSame)? @"highlight": @"nohighlight";
		[html appendFormat:@"<TR class=""%@""><TH class=""spec"">Owner</TH><TD>%@</TD><TD>%@</TD></TR>", row, [[[deal current]owner]name], [[[deal previous]owner]name]];
		
		row = ([[[deal current]closeDate] compare:[[deal previous]closeDate]] != NSOrderedSame)? @"highlight": @"nohighlight";
		[html appendFormat:@"<TR class=""%@""><TH class=""spec"">Close Date</TH><TD>%@</TD><TD>%@</TD></TR>", row, [formatter stringFromDate:[[deal current]closeDate]], [formatter stringFromDate:[[deal previous]closeDate]]];

		row = ([[[deal current]stage] compare:[[deal previous]stage]] != NSOrderedSame)? @"highlight": @"nohighlight";		
		[html appendFormat:@"<TR class=""%@""><TH class=""spec"">Stage</TH><TD>%@</TD><TD>%@</TD></TR>", row, [[deal current]stage], [[deal previous]stage]];

		row = ([[deal current]probability] != [[deal previous]probability])? @"highlight": @"nohighlight";
		[html appendFormat:@"<TR class=""%@""><TH class=""spec"">Probability</TH><TD>%.1f%%</TD><TD>%0.1f%%</TD></TR>", row, [[deal current]probability], [[deal previous]probability]];

		row = ([[deal current]amount] != [[deal previous]amount])? @"highlight": @"nohighlight";
		[html appendFormat:@"<TR class=""%@""><TH class=""spec"">Amount</TH><TD>%@</TD><TD>%@</TD></TR>", row, [Currency currencyToString:[[deal current]amount]], [Currency currencyToString:[[deal previous]amount]]];

		row = ([[[deal current]description] compare:[[deal previous]description]] != NSOrderedSame)? @"highlight": @"nohighlight";
		[html appendFormat:@"<TR class=""%@""><TH class=""spec"">Description</TH><TD>%@</TD><TD>%@</TD></TR>", row, [[deal current]description], [[deal previous]description]];
		
		row = ([[[deal current]nextsteps] compare:[[deal previous]nextsteps]] != NSOrderedSame)? @"highlight": @"nohighlight";
		[html appendFormat:@"<TR class=""%@""><TH class=""spec"">Next Steps</TH><TD>%@</TD><TD>%@</TD></TR>", row, [[deal current]nextsteps], [[deal previous]nextsteps]];

		[html appendString:@"</table></body></html>"];
	} else {
		if ([deal current] != nil) {
			[html appendFormat:@"<html><head><link href=""salespad.css"" rel=""stylesheet"" type=""text/css"" /><title>Deal Details</title></head> \
			 <body><TABLE cellspacing=""0"" id=""dealtable""><TR><TH class=""topleft label"">Field</TH><TH class=""wide"">New Value (%@)</TH></TR>",
			 [[deal current] timestamp]];
			[html appendFormat:@"<TR><TH class=""spec"">Name</TH><TD>%@</TD></TR>", [[deal current]name]];
			[html appendFormat:@"<TR><TH class=""spec"">Owner</TH><TD>%@</TD></TR>", [[[deal current]owner]name]];
			[html appendFormat:@"<TR><TH class=""spec"">Close Date</TH><TD>%@</TD></TR>", [formatter stringFromDate:[[deal current]closeDate]]];
			[html appendFormat:@"<TR><TH class=""spec"">Stage</TH><TD>%@</TD></TR>", [[deal current]stage]];
			[html appendFormat:@"<TR><TH class=""spec"">Probability</TH><TD>%.1f%%</TD></TR>", [[deal current]probability]];
			[html appendFormat:@"<TR><TH class=""spec"">Amount</TH><TD>%@</TD></TR>", [Currency currencyToString:[[deal current]amount]]];
			[html appendFormat:@"<TR><TH class=""spec"">Description</TH><TD>%@</TD></TR>", [[deal current]description]];
			[html appendFormat:@"<TR><TH class=""spec"">Next Steps</TH><TD>%@</TD></TR>", [[deal current]nextsteps]];
			[html appendString:@"</table></body></html>"];
		} else {
			[html appendFormat:@"<html><head><link href=""salespad.css"" rel=""stylesheet"" type=""text/css"" /><title>Deal Details</title></head> \
			 <body><TABLE cellspacing=""0"" id=""dealtable""><TR><TH class=""topleft label"">Field</TH><TH class=""wide"">Old Value (%@)</TH></TR>",
			 [[deal previous] timestamp]];
			[html appendFormat:@"<TR><TH class=""spec"">Name</TH><TD>%@</TD></TR>", [[deal previous]name]];
			[html appendFormat:@"<TR><TH class=""spec"">Owner</TH><TD>%@</TD></TR>", [[[deal previous]owner]name]];
			[html appendFormat:@"<TR><TH class=""spec"">Close Date</TH><TD>%@</TD></TR>", [formatter stringFromDate:[[deal previous]closeDate]]];
			[html appendFormat:@"<TR><TH class=""spec"">Stage</TH><TD>%@</TD></TR>", [[deal previous]stage]];
			[html appendFormat:@"<TR><TH class=""spec"">Probability</TH><TD>%.1f%%</TD></TR>", [[deal previous]probability]];
			[html appendFormat:@"<TR><TH class=""spec"">Amount</TH><TD>%@</TD></TR>", [Currency currencyToString:[[deal previous]amount]]];
			[html appendFormat:@"<TR><TH class=""spec"">Description</TH><TD>%@</TD></TR>", [[deal previous]description]];
			[html appendFormat:@"<TR><TH class=""spec"">Next Steps</TH><TD>%@</TD></TR>", [[deal previous]nextsteps]];
			[html appendString:@"</table></body></html>"];
		}
	}

	NSString *path = [[NSBundle mainBundle] bundlePath];
	NSURL    *baseURL = [NSURL fileURLWithPath:path];
	
	[browser loadHTMLString:html baseURL:baseURL];	
}

#pragma mark -
#pragma mark webview

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webview 
{
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

- (IBAction) closeDeal {
	[[self delegate] reviewedDeal];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	[browser release];
	self.browser = nil;
	
	[titlebar release];
	self.titlebar = nil;
}

- (void)dealloc {
	[browser release];
	[titlebar release];
	[deal release];
	[delegate release];
    [super dealloc];
}


@end
