//
//  DetailViewController.m
//  SalesPad
//
//  Created by SP on 3/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SalesPadController.h"
#import "LoginController.h"
#import "ZKSforce.h"
#import "User.h"
#import "Forecast.h"
#import "NewChatViewController.h"

/**
 * TBD:
 *   1. ipad app does not quit when backgrounded so enable way to "fetch new data".
 *   have button to "lock" forecast - this should copy today's snapshot to "yesterday" and leave as is.
 *   when I click on fetch new data - I should get new data from sfdc and compare to "locked" data.
 *   all comparisons are always on "locked data". Locked data could be from different snapshot dates for different 
 *   hierarchy levels so keep a "locked" state field and the snapshot date field.
 *
 *   2. have a page to show "person" stats - like the "NFL" stats for players. For each person show:
 *       - photo
 *       - name, manager name
 *       - YTD attainment
 *       - pipeline coverage of remaining year quota.
 *       - growth forecast over last year.
 *       - top 10 deals won, top 10 deals lost, top 10 open deals.
 *       - next 30 day deals
 *       - chatter feed
 */

#define myAssert(condition, format, variable) if (!(condition)) { NSLog(format, variable); assert(1==0); }

@interface SalesPadController ()
//@property (nonatomic, retain) UIPopoverController *popoverController;
- (void)configureView;
@end


@implementation SalesPadController

@synthesize toolbar, detailItem, detailDescriptionLabel, controlViewBy, searchBar, openDealsTable, chatterViewController;
@synthesize webView, viewBy, viewPeriod, searchLookAhead, currentForecastUser, isOffline, currentUser, customView, buttonUser, labelDates, summaryPerformance;
@synthesize openDealsTableController, titleBar, chatterTable, dealTableTitleBar, fromDate, toDate, fiscalCalendar, lastReviewedDate, today;
@synthesize runonce, database, busy, multicurrency,popoverControllerSelectUser, chatterTitleBar, chatterbusy, offlineButton, popoverControllerNewPost;
@synthesize busyDealTableIndicator, busyForecastTableIndicator, noDealsLabel, noForecastsLabel, noChatterLabel, hostReachable, loginController;
#pragma mark -
#pragma mark initialize
+ (void)initialize{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *pathForSettings = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithContentsOfFile:pathForSettings];
    [defaults registerDefaults:appDefaults];
}

- (IBAction)changeViewBy:(id)sender {
	switch(controlViewBy.selectedSegmentIndex) {
			case 0:
			[self setViewBy:@"Period"];
			break;
			case 1:
			[self setViewBy:@"User"];
			break;
	}
	[self viewForecastFor:currentForecastUser startMonth:[self fromDate] endMonth:[self toDate] viewBy:controlViewBy.selectedSegmentIndex+1];
}


#pragma mark -
#pragma mark Managing the detail item


- (void)configureView {
    // Update the user interface for the detail item.
	[self setViewBy:@"User"];
	[self viewForecastFor:currentForecastUser startMonth:[self fromDate] endMonth:[self toDate] viewBy:controlViewBy.selectedSegmentIndex+1];
}

- (NSDate*) getDateFromInteger:(int) monthnumber
{
	NSDateFormatter *month_name_formatter = [[[NSDateFormatter alloc] init] autorelease];
	[month_name_formatter setDateFormat:@"yyyyMMdd"];
	return [month_name_formatter dateFromString:[NSString stringWithFormat:@"%d01",monthnumber]];
}	

- (NSString*) formatDate:(int) monthnumber
{
	NSDateFormatter *month_name_formatter = [[[NSDateFormatter alloc] init] autorelease];
	[month_name_formatter setDateFormat:@"MMM-yyyy"];
	NSDateFormatter* sfdc_date_formatter = [[[NSDateFormatter alloc] init] autorelease];
	[sfdc_date_formatter setDateFormat:@"yyyyMMdd"];
	return [month_name_formatter stringFromDate:[sfdc_date_formatter dateFromString:[NSString stringWithFormat:@"%d01",monthnumber]]];
}

	
/**
 * Load the forecasts into the local cache. When done update the table.
 **/
- (void) viewForecastFor:(User*)u startMonth:(NSDate*)startMonth endMonth:(NSDate*)endMonth viewBy:(int)viewBy {

	[[self noForecastsLabel] setHidden:NO];
	[[self noDealsLabel] setHidden:NO];
	[[self noChatterLabel] setHidden:NO];
	
	//TBD Clear out the views
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
	[summaryPerformance loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
	[chatterViewController clearFeeds];
	[openDealsTableController clearDeals];
	 
	
	//Check input parameters.
	if (u == nil || startMonth == nil || endMonth == nil) {
		return; 
	}
	
	//Check if already cached if so get it - else go out and get it.
	if (![u cached:SnapshotCurrent]) {
		if ([self isOffline] == SalesPadOnline) {
			NSLog(@"Forecasts not available for %@ - reloading.", u);
			[self loadForecastsFor:u];
			return;
		} else { 
			//do we have partial snapshot??
			if (![u partialcached:SnapshotCurrent]) {
				NSLog(@"Forecasts not available for in offline mode %@", u);
				[[[[UIAlertView alloc] initWithTitle:@"Forecasts"
											 message:[NSString stringWithFormat:@"Donot have forecasts for %@ in offline mode", [u name]]
											delegate:nil 
								   cancelButtonTitle:NSLocalizedString(@"OK", nil)
								   otherButtonTitles:nil] autorelease] show];
				return;
			}
		}
	}
	
	int start_month = [[self fiscalCalendar] monthIndex:startMonth];
	int end_month   = [[self fiscalCalendar] monthIndex:endMonth];
	
	NSString* uid = [u uid];
	[[self buttonUser] setTitle:[u name] forState:UIControlStateNormal];
	[[self labelDates] setText:[NSString stringWithFormat:@"%@ - %@", [self formatDate:start_month], [self formatDate:end_month]]];
	
	//Use stored dates to get this
	//tricky - Max date stored is latest date, previous date is the snapshot date.
	//Get the latest snapshot date.
	if (!stmt_dates) {
		NSString *qry = [NSString stringWithFormat:@"SELECT DISTINCT snapshot FROM forecasts WHERE uid=?1 ORDER BY snapshot DESC LIMIT 2"];
		myAssert (sqlite3_prepare_v2([database database], [qry UTF8String], -1, &stmt_dates, NULL) == SQLITE_OK, @"FATAL DB error %@", qry);
	}

	int current_snapshot = SnapshotNone;
	int previous_snapshot = SnapshotNone;

	sqlite3_bind_text(stmt_dates, 1, [uid UTF8String], [uid length], SQLITE_STATIC);
	if (sqlite3_step(stmt_dates) == SQLITE_ROW) {
		current_snapshot = sqlite3_column_int(stmt_dates, 0);
		if (sqlite3_step(stmt_dates) == SQLITE_ROW) {
			previous_snapshot = sqlite3_column_int(stmt_dates, 0);
		}
	}
	sqlite3_reset(stmt_dates);
	
	if (current_snapshot == SnapshotNone) {
		//Nothing in database - need to go get forecasts
		NSLog(@"No forecasts available in offline for: %@", uid);
		if ([self isOffline] == SalesPadOnline) {
			[self loadForecastsFor:u];
		} else {
			[[[[UIAlertView alloc] initWithTitle:@"Forecasts"
										 message:[NSString stringWithFormat:@"Cannot find forecasts for %@ in offline mode", [u name]]
										delegate:nil 
							   cancelButtonTitle:NSLocalizedString(@"OK", nil)
							   otherButtonTitles:nil] autorelease] show];
		}

		return;
	}

	if (previous_snapshot == SnapshotNone) {
		previous_snapshot = current_snapshot;
	}
	
	[self updatePriorYearFor:current_snapshot];
	
	//UI
	//Pick a user and period (e.g. Carl Schachter, QTR)
	//view by report OR view by subperiod (Steve/Joachim/... OR Feb/Mar/Apr ....)
	//Now get the snapshot..
	//i want to see all 12 months for me or any of my directs.
	//Select who..make it easy to select my directs. The query above works...
	
	//i want to see all my directs for a month, a quarter or the year. 
	//Select Full Year and year, Full QTR and quarter, Full month and month.
	//make it easy to scroll from period to period.
	//select f.uid,sum(f.quota) ... where f.mid='?3' AND f.month='' f.quarter='' f.year='' GROUP BY f.uid
	if (!stmt_bydate) {
		NSString *qry = [NSString stringWithFormat:@"SELECT f.monthname, f.quota, f.forecast, f.closed, f.pipeline, f.prioryear, h.forecast, h.closed, h.pipeline, h.month from forecasts f join forecasts h ON f.uid=h.uid AND f.month=h.month WHERE f.snapshot=?1 AND h.snapshot=?2 AND f.uid=?3 AND f.month>=?4 AND f.month<=?5 ORDER BY f.month ASC"];
		myAssert(sqlite3_prepare_v2([database database], [qry UTF8String], -1, &stmt_bydate, NULL) == SQLITE_OK, @"FATAL DB error %@", qry);
		
		qry = [NSString stringWithFormat:@"SELECT f.name, sum(f.quota), sum(f.forecast), sum(f.closed), sum(f.pipeline), sum(f.prioryear), sum(h.forecast), sum(h.closed), sum(h.pipeline),f.uid from forecasts f join forecasts h ON f.uid=h.uid AND f.month=h.month AND f.snapshot=?1 AND h.snapshot=?2 AND (f.mid=?3 OR f.uid=?3) AND f.month>=?4 AND f.month<=?5 GROUP BY f.name,f.uid ORDER BY f.uid ASC"];
		myAssert(sqlite3_prepare_v2([database database], [qry UTF8String], -1, &stmt_byuser, NULL) == SQLITE_OK, @"FATAL DB error %@", qry);
	}
	
	if (viewBy == VIEW_BYDATE) {
		statement = stmt_bydate;
	} else {
		statement = stmt_byuser;
	}
		
	sqlite3_bind_int(statement, 1, current_snapshot);
	sqlite3_bind_int(statement, 2, previous_snapshot);
	sqlite3_bind_text(statement, 3, [uid UTF8String], [uid length], SQLITE_STATIC);
	sqlite3_bind_int(statement, 4, start_month);
	sqlite3_bind_int(statement, 5, end_month);
	
		
	NSMutableString *html = [[[NSMutableString alloc] initWithString:@""] autorelease];
	[html appendFormat:@"<html><head><link href=""salespad.css"" rel=""stylesheet"" type=""text/css"" /><title>Your Forecast</title></head><body><TABLE cellspacing=""0"" id=""mytable""><TR><TH class=""topleft"">%@</TH><TH>Quota</TH><TH>Forecast</TH><TH>Closed</TH><TH>Pipeline</TH><TH>Prior Year</TH><TH>Attainment</TH><TH>Growth</TH><TH class=""topright"">Coverage</TH></TR>",
	 [self viewBy]];
	
	int i = 0;
	while (sqlite3_step(statement) == SQLITE_ROW) {
		i++;
		const char* cname = (const char*)sqlite3_column_text(statement, 0);
		const char* cid = (const char*)sqlite3_column_text(statement, 9);
		NSString* first_column = [[[NSString alloc]initWithUTF8String:cname] autorelease];
		NSString* first_column_id = [[[NSString alloc]initWithUTF8String:cid]autorelease];
		double quota =  sqlite3_column_int(statement, 1);
		double forecast = sqlite3_column_int(statement, 2);
		double closed =  sqlite3_column_int(statement, 3);
		double pipeline =  sqlite3_column_int(statement, 4);
		double prioryear = sqlite3_column_int(statement, 5);
		double hforecast = sqlite3_column_double(statement, 6);
		double hclosed = sqlite3_column_double(statement, 7);
		double hpipeline = sqlite3_column_double(statement, 8);
		
		float forecast_growth = (((float)forecast)/((float)prioryear)-1)*100;
		float attainment = ((float)forecast)/((float)quota)*100;
		float coverage = ((float)pipeline)/((float)(forecast - closed));
		
		NSString *forecastChange = @"nohistory";
		NSString *closedChange = @"nohistory";
		NSString *pipelineChange = @"nohistory";
		
		if (current_snapshot != previous_snapshot) {
			forecastChange = [self direction:forecast rhs:hforecast];
			closedChange = [self direction:closed rhs:hclosed];
			pipelineChange = [self direction:pipeline rhs:hpipeline];
		}
		
		[html appendFormat:@"<TR><TH class=""spec""><A HREF=""#%@"">%@</A></TH><TD>%@</TD><TD class=""%@"">%@</TD><TD class=""%@"">%@</TD><TD class=""%@"">%@</TD><TD>%@</TD><TD>%.1f%%</TD><TD>%.1f%%</TD><TD>%.1fx</TD></TR>",
		 first_column_id,
		 first_column, 
		 [Currency currencyToString:quota],
		 forecastChange,
		 [Currency currencyToString:forecast],
		 closedChange,
		 [Currency currencyToString:closed],
		 pipelineChange,
		 [Currency currencyToString:pipeline],
		 [Currency currencyToString:prioryear],
		 attainment,forecast_growth,coverage];
	}
	[html appendString:@"</TABLE></BODY></HTML>"];
	sqlite3_reset(statement);
	
	NSString *path = [[NSBundle mainBundle] bundlePath];
	NSURL    *baseURL = [NSURL fileURLWithPath:path];
	
	[webView loadHTMLString:html baseURL:baseURL];
	[self updateSummary:u startMonth:startMonth endMonth:endMonth snapshot:current_snapshot];
	[[self openDealsTableController] loadOpportunitiesFromDB:u startDate:startMonth endDate:endMonth snapshot:current_snapshot previousSnapshot:previous_snapshot];
	
	if (i > 0) {
		[[self noForecastsLabel] setHidden:YES];
	}
	
	if ([[[self openDealsTableController] deals] count] > 0) {
		[[self noDealsLabel] setHidden:YES];
	}
}


-(void) updateSummary:(User*)u startMonth:(NSDate*)startMonth endMonth:(NSDate*)endMonth snapshot:(SalesPadSnapshotType)snapshot 
{
	//Current Month
	NSDate* end_date = [[self fiscalCalendar] today];
	NSDate* start_date = [FiscalCalendar firstDayOfMonth:end_date];
	Metric  *currentMonth = [self loadSummary:u startMonth:end_date endMonth:end_date snapshot:snapshot];
	
	//Current Fiscal Quarter
	start_date = [[self fiscalCalendar] firstDayOfFiscalQuarter:start_date];
	Metric *currentQuarter = [self loadSummary:u startMonth:start_date endMonth:end_date snapshot:snapshot];

	//Current Fiscal Year
	start_date = [[self fiscalCalendar] firstDayOfYear];
	Metric *currentYear = [self loadSummary:u startMonth:start_date endMonth:end_date snapshot:snapshot];

	//Period Looking at
	Metric *currentPeriod = [self loadSummary:u startMonth:startMonth endMonth:endMonth snapshot:snapshot];
	
	//Load the summary into the page.
	NSMutableString *html = [[[NSMutableString alloc] initWithString:@""] autorelease];
	[html appendFormat:@"<html><head><link href=""salespad.css"" rel=""stylesheet"" type=""text/css"" /><title>Your Forecast</title></head><body><TABLE cellspacing=""0"" id=""myperformance""><TR><TH>Metric</TH><TH>MTD</TH><TH>QTD</TH><TH>YTD</TH><TH>Period</TH></TR>",
	 [self viewBy]];

	[html appendFormat:@"<TR><TH class=""spec"">Commit</TH><TD>%@</TD><TD>%@</TD><TD>%@</TD><TD>%@</TD></TR>",
	 [Currency currencyToString:[currentMonth forecast]],[Currency currencyToString:[currentQuarter forecast]],[Currency currencyToString:[currentYear forecast]],[Currency currencyToString:[currentPeriod forecast]]];
	[html appendFormat:@"<TR><TH class=""spec"">Closed</TH><TD>%@</TD><TD>%@</TD><TD>%@</TD><TD>%@</TD></TR>",
	 [Currency currencyToString:[currentMonth closed]],[Currency currencyToString:[currentQuarter closed]],[Currency currencyToString:[currentYear closed]],[Currency currencyToString:[currentPeriod closed]]];
	[html appendFormat:@"<TR><TH class=""spec"">Attainment</TH><TD>%.1f%%</TD><TD>%.1f%%</TD><TD>%.1f%%</TD><TD>%.1f%%</TD></TR>",
	 [currentMonth attainment],[currentQuarter attainment],[currentYear attainment],[currentPeriod attainment]];
	[html appendFormat:@"<TR><TH class=""spec"">Growth</TH><TD>%.1f%%</TD><TD>%.1f%%</TD><TD>%.1f%%</TD><TD>%.1f%%</TD></TR>",
	 [currentMonth growth],[currentQuarter growth],[currentYear growth],[currentPeriod growth]];
	[html appendFormat:@"<TR><TH class=""spec"">Pipeline</TH><TD>%@</TD><TD>%@</TD><TD>%@</TD><TD>%@</TD></TR>",
	 [Currency currencyToString:[currentMonth pipeline]],[Currency currencyToString:[currentQuarter pipeline]],[Currency currencyToString:[currentYear pipeline]],[Currency currencyToString:[currentPeriod pipeline]]];
	[html appendFormat:@"<TR><TH class=""spec"">Coverage</TH><TD>%.1fx</TD><TD>%.1fx</TD><TD>%.1fx</TD><TD>%.1fx</TD></TR>",
	 [currentMonth coverage],[currentQuarter coverage],[currentYear coverage],[currentPeriod coverage]];
	[html appendString:@"</TABLE></BODY></HTML>"];
	
	NSString *path = [[NSBundle mainBundle] bundlePath];
	NSURL    *baseURL = [NSURL fileURLWithPath:path];
	
	[summaryPerformance loadHTMLString:html baseURL:baseURL];
	
	[currentYear release];
	[currentPeriod release];
	[currentMonth release];
	[currentQuarter release];
}

- (Metric*) loadSummary:(User*)u startMonth:(NSDate*)startMonth endMonth:(NSDate*)endMonth snapshot:(SalesPadSnapshotType)snapshot
{
	int start_month = [[self fiscalCalendar] monthIndex:startMonth];
	int end_month = [[self fiscalCalendar] monthIndex:endMonth];
	
	NSString* uid = [u uid];
	if (!stmt_summary) {
		NSString *qry = [NSString stringWithFormat:@"SELECT sum(f.quota), sum(f.forecast), sum(f.closed), sum(f.pipeline), sum(f.prioryear) from forecasts f WHERE f.snapshot=?1 AND f.uid=?2 AND f.month>=?3 AND f.month<=?4"];
		if (sqlite3_prepare_v2([database database], [qry UTF8String], -1, &stmt_summary, NULL) != SQLITE_OK) {
			NSLog(@"query error: %@", qry);
			return nil;
		}
	}
	
	sqlite3_bind_int(stmt_summary, 1, snapshot);
	sqlite3_bind_text(stmt_summary, 2, [uid UTF8String], [uid length], SQLITE_STATIC);
	sqlite3_bind_int(stmt_summary, 3, start_month);
	sqlite3_bind_int(stmt_summary, 4, end_month);
	
	Metric* metric;
	
	if (sqlite3_step(stmt_summary) == SQLITE_ROW) {
		double quota =  sqlite3_column_int(stmt_summary, 0);
		double forecast = sqlite3_column_int(stmt_summary, 1);
		double closed =  sqlite3_column_int(stmt_summary, 2);
		double pipeline =  sqlite3_column_int(stmt_summary, 3);
		double prioryear = sqlite3_column_int(stmt_summary, 4);
		
		//NSLog(@"quota: %f, forecast %f, closed %f, pipeline %f, prioryear %f", quota, forecast, closed, pipeline, prioryear);
		metric = [[Metric alloc] initWithQuota:quota forecast:forecast bestcase:0.0f pipeline:pipeline closed:closed prioryear:prioryear];
	}
	sqlite3_reset(stmt_summary);
	return metric;
}


- (NSString*) direction:(double)lhs rhs:(double)rhs
{
	if (lhs<rhs) {
		return @"lower";
	} else if (lhs>rhs) {
		return @"higher";
	} else {
		return @"same";
	}

}

#pragma mark -
#pragma mark Rotation support

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if (interfaceOrientation == UIInterfaceOrientationPortrait) {
		return YES;
	}
	else {
		return NO;
	}
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
}

- (void) setupDecorations {
	//setup some decorations here.
	[[titleBar layer] setMasksToBounds:YES];
	[[titleBar layer] setCornerRadius:5.0];
	
	[[chatterTable layer] setMasksToBounds:YES];
	[[chatterTable layer] setCornerRadius:5.0];
	
	[[chatterTitleBar layer] setMasksToBounds:YES];
	[[chatterTitleBar layer] setCornerRadius:5.0];
	
	[[dealTableTitleBar layer] setMasksToBounds:YES];
	[[dealTableTitleBar layer] setCornerRadius:5.0];
	
	[[webView layer] setMasksToBounds:YES];
	[[webView layer] setCornerRadius:5.0];
	
	[[summaryPerformance layer] setMasksToBounds:YES];
	[[summaryPerformance layer] setCornerRadius:5.0];
	
	[[openDealsTable layer] setMasksToBounds:YES];
	[[openDealsTable layer] setCornerRadius:5.0];
	
	[[self customView] setForCalendar:fiscalCalendar];
	
	[noForecastsLabel setHidden:YES];
	[noDealsLabel setHidden:YES];
	[noChatterLabel setHidden:YES];
}

- (void) loadConfig {
	//Fiscal start and end date set.	
	
	//load configuration settings.
	//if this is the first time - must sync and setup the data.
	[self setRunonce:[[NSUserDefaults standardUserDefaults] integerForKey:@"runonce"]];
	[self setMulticurrency:1];
	[self setDatabase:[[Database alloc]init]];
	if (runonce == 0) {
		NSLog(@"Wait for setup to complete");
	}
	
	//Fiscal period start and end
	NSDate *start_date = [[NSUserDefaults standardUserDefaults]objectForKey:@"FiscalStartDate"];
	NSDate *end_date   = [[NSUserDefaults standardUserDefaults]objectForKey:@"FiscalEndDate"];
	[self setFromDate:start_date];
	[self setToDate:end_date];
	FiscalCalendar *calendar = [[FiscalCalendar alloc]initWithFiscalStartDate:start_date];
	[self setFiscalCalendar:calendar];
	
	//when were the forecasts last reviewed? All comparions are based on this date.
	[self setLastReviewedDate:[[NSUserDefaults standardUserDefaults]objectForKey:@"LastReviewedDate"]];
	[self setToday:[NSDate date]];
}

#pragma mark -
#pragma mark View lifecycle


 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	
	//Check and setup for network connectivity.
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
	hostReachable = [[Reachability reachabilityWithHostName:@"login.salesforce.com"] retain];
	[hostReachable startNotifier];
	
	//setup layout & configuration.
	[self loadConfig];
	[self setupDecorations];

	[[self customView] setDelegate:self];
	openDealsTableController = [[OpptyTableViewController alloc]initWithUser:[self currentForecastUser] startDate:[NSDate date] endDate:[NSDate date]];
	[openDealsTable setDelegate:openDealsTableController];
	[openDealsTable setDataSource:openDealsTableController];
	[openDealsTableController setTableView:openDealsTable];
	[openDealsTableController setView:openDealsTable];
	
	chatterViewController = [[OpptyChatterViewController alloc]init];
	[chatterViewController setDelegate:self];
	[openDealsTableController setDealChatterViewController:chatterViewController];
	[chatterTable setDelegate:chatterViewController];
	[chatterTable setDataSource:chatterViewController];
	[chatterViewController setTableView:chatterTable];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
- (void) goOffline {
	[self setIsOffline:SalesPadOffline];
	[[self offlineButton] setImage:[UIImage imageNamed:@"offline1.png"] forState:UIControlStateNormal];
	[self configureView];
}

- (void)goOnline {
	//if we are not connected notify user and work offline
	//NetworkStatus netStatus          = [hostReachable currentReachabilityStatus];
	BOOL          connectionRequired = [hostReachable connectionRequired];
	if (!connectionRequired) {
		if ([self loginController] == nil) {
			LoginController* vc = [[LoginController alloc] initWithNibName:@"LoginView"
																 bundle:nil];
			[self setLoginController:vc];
			[vc release];
		}
		[[self loginController] setModalPresentationStyle:UIModalPresentationFormSheet];
		[[self loginController] setDelegate:self];
		[self presentModalViewController:[self loginController] animated:YES];
	} else {
		[[[[UIAlertView alloc] initWithTitle:@"salesforce.com"
									 message:@"Cannot connect to salesforce.com - working offline." 
									delegate:nil 
						   cancelButtonTitle:NSLocalizedString(@"OK", nil)
						   otherButtonTitles:nil] autorelease] show];
		NSLog(@"No network available - work offline");
		[self setCurrentForecastUser:[self loadCurrentUser]];
		[self goOffline];
	}	
}


- (IBAction) reloadForecasts {
	if ([self isOffline] == SalesPadOnline) {
		NSString *qry = [NSString stringWithFormat:@"DELETE FROM forecasts where snapshot=%d", SnapshotCurrent];
		myAssert(sqlite3_exec([database database], [qry UTF8String], NULL, NULL, NULL) == SQLITE_OK, @"FATAL DB Error: %@", qry);
		qry = [NSString stringWithFormat:@"DELETE FROM user where snapshot=%d", SnapshotCurrent];
		myAssert(sqlite3_exec([database database], [qry UTF8String], NULL, NULL, NULL) == SQLITE_OK, @"FATAL DB Error: %@", qry);
		qry = [NSString stringWithFormat:@"DELETE FROM deals where snapshot=%d", SnapshotCurrent];
		myAssert(sqlite3_exec([database database], [qry UTF8String], NULL, NULL, NULL) == SQLITE_OK, @"FATAL DB Error: %@", qry);
	
		[self startSync];
	} else {
		[[[[UIAlertView alloc] initWithTitle:@"Refresh"
									 message:@"Cannot reload in offline mode. Connect to Salesforce.com first." 
									delegate:nil 
						   cancelButtonTitle:NSLocalizedString(@"OK", nil)
						   otherButtonTitles:nil] autorelease] show];
	}
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self goOnline];
}

/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
		
	[popoverControllerNewPost release];
	self.popoverControllerNewPost = nil;
	
	[loginController release];
	self.loginController = nil;
	
    [popoverControllerSelectUser release];
    self.popoverControllerSelectUser = nil;

	[toolbar release];
	self.toolbar = nil;
	
	[detailDescriptionLabel release];
	self.detailDescriptionLabel = nil;
	
	[buttonUser release];
	self.buttonUser = nil;
	
	[labelDates release];
	self.labelDates = nil;
	
	[customView release];
	self.customView = nil;
	
	[busyForecastTableIndicator release];
	self.busyForecastTableIndicator = nil;
	
	[busyDealTableIndicator release];
	self.busyDealTableIndicator = nil;
	
	[noForecastsLabel release];
	self.noForecastsLabel = nil;
	
	[noDealsLabel release];
	self.noDealsLabel = nil;
	
	[noChatterLabel release];
	self.noChatterLabel = nil;
	
	[offlineButton release];
	self.offlineButton = nil;
	
	[chatterViewController release];
	self.chatterViewController = nil;
	
	[database release];
	self.database = nil;
	
	[fiscalCalendar release];
	self.fiscalCalendar = nil;
	
	[fromDate release];
	[toDate release];
	self.fromDate = nil;
	self.toDate = nil;
	
	[hostReachable release];
	self.hostReachable = nil;
	
	[openDealsTableController release];
	self.openDealsTableController = nil;
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
	
	if (stmt_bydate) {
		sqlite3_finalize(stmt_bydate);
		stmt_bydate = nil;
	}
	if (stmt_byuser) {
		sqlite3_finalize(stmt_byuser);
		stmt_byuser = nil;
	}
	if (stmt_dates) {
		sqlite3_finalize(stmt_dates);
		stmt_dates = nil;
	}
	if (stmt_summary) {
		sqlite3_finalize(stmt_summary);
		stmt_dates = nil;
	}
}

- (void)dealloc {
	[openDealsTableController release];
	[popoverControllerNewPost release];
	[loginController release];
    [popoverControllerSelectUser release];
    [toolbar release];
	[detailItem release];
	[detailDescriptionLabel release];
	[buttonUser release];
	[labelDates release];
	[customView release];
	[busyForecastTableIndicator release];
	[busyDealTableIndicator release];
	[noForecastsLabel release];
	[noDealsLabel release];
	[noChatterLabel release];
	[hostReachable release];
	[offlineButton release];
	[chatterViewController release];
	sqlite3_finalize(stmt_bydate);
	sqlite3_finalize(stmt_byuser);
	sqlite3_finalize(stmt_dates);
    
	[super dealloc];
}	

#pragma mark -
#pragma mark webview

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSURL *url = request.URL;
	if ([url fragment] != nil) {
		//is this view by user?
		//[self viewForecastFor:currentForecastUser startMonth:[self fromDate] endMonth:[self toDate] viewBy:controlViewBy.selectedSegmentIndex+1];

		if (controlViewBy.selectedSegmentIndex == VIEW_BYUSER-1) {
			User* u = [self loadUser:[url fragment]];
			if (u != nil) {
				[self setCurrentForecastUser:u];
				[controlViewBy setSelectedSegmentIndex:VIEW_BYDATE-1];
			}
		}
		return NO;
	}
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webview 
{
	//int content_height = [[webview stringByEvaluatingJavaScriptFromString: @"document.body.offsetHeight"] integerValue];
	//CGRect rect = webview.frame;
	//rect.size.height = content_height;
	//[webview setFrame:rect];
}

#pragma mark -
#pragma mark LoginController
- (void) loginSuccess:(LoginController*)lc  user:(ZKUserInfo*) user {
	[lc dismissModalViewControllerAnimated:YES];
	[self setIsOffline:SalesPadOnline];
	[[self offlineButton] setImage:[UIImage imageNamed:@"online1.png"] forState:UIControlStateNormal];
	[self setCurrentUser:user];
	User* u = [[[User alloc] initWithUser:[user userId] name:[user fullName]] autorelease];
	[u setRid:[user roleId]];
	[self setCurrentForecastUser:u];
	[self reloadForecasts];
}

- (void)queryResult:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    if (result && !error)
    {
        //NSLog(@"We got back %i results", [[result records] count]);
		NSArray* a = [result records];
		for (ZKSObject* r in a) {
			//NSLog(@"Record: %@", [r fieldValue:@"Name"]);
		}
	}
    else if (error)
    {
        NSLog(@"handle error");
    }
}


- (void) loginCancel:(LoginController*)lc {
	//dismiss the login and exit
	[lc dismissModalViewControllerAnimated:YES];
	[self setCurrentForecastUser:[self loadCurrentUser]];
	[self goOffline];
}

#pragma mark -
#pragma mark search

- (void)searchBarTextDidEndEditing:(UISearchBar *)sb 
{
	NSLog(@"Search for: %@", [sb text]);
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)sb 
{
	NSLog(@"Searching for: %@", [sb text]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
	// Return the number of sections.
	return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	// Return the number of rows in the section.
	return [searchLookAhead count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"CellIdentifier";
	
	// Dequeue or create a cell of the appropriate type.
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	if (tableView == openDealsTable) {
		cell.textLabel.text=@"Tis is for other row";
	} else {
		// Configure the cell.
		cell.textLabel.text = [[searchLookAhead objectAtIndex:indexPath.row] name];
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (tableView == openDealsTable) {
		return;
	}
	[self.searchDisplayController setActive:NO];
	[self loadForecastsFor:[searchLookAhead objectAtIndex:indexPath.row]];	
}

#pragma mark -
#pragma mark forecast loading
- (void) loadForecastsFor:(User*) uid 
{
	[self setCurrentForecastUser:uid];
	if ([self isOffline] != SalesPadOnline) {
		[self viewForecastFor:currentForecastUser startMonth:[self fromDate] endMonth:[self toDate] viewBy:controlViewBy.selectedSegmentIndex+1];
	} else {
		[[self busyForecastTableIndicator] startAnimating];
		NSLog(@"Loading forecast for: %@", uid);
		//get the forecasts
		NSString* query = [NSString stringWithFormat:@"select Owner.name, Owner.userroleid, StartDate, OwnerId, ManagerId, Quota, Closed, Pipeline, Commit, Upside from RevenueForecast WHERE (StartDate = THIS_FISCAL_YEAR OR StartDate = LAST_FISCAL_YEAR) and (OwnerId='%@' OR ManagerId='%@')",
					   [uid uid], [uid uid]];
		//NSLog(@"Loading sql: %@",query);
		[[ZKServerSwitchboard switchboard] query:query target:self selector:@selector(loadForecastsForCallback:error:context:) context:nil];
	}
}

- (void)loadForecastsForCallback:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
	char* errorMessage;
	NSString* timestamp = [self updateTimestamp];
	[[self busyForecastTableIndicator] stopAnimating];
	
	sqlite3_exec([database database], "BEGIN TRANSACTION", NULL, NULL, &errorMessage);
	sqlite3_stmt* insert_stmt;
	//Delete the existing data if any.
	NSString* delete_sql = [NSString stringWithFormat:@"DELETE FROM forecasts WHERE (uid='%@' OR mid='%@') AND snapshot=%d",
							[[self currentForecastUser] uid], [[self currentForecastUser] uid], SnapshotCurrent];
	sqlite3_exec([database database], [delete_sql UTF8String], NULL, NULL, &errorMessage);
	
	NSString* qry = @"INSERT INTO forecasts (uid, mid, month, monthname, year, quota, forecast, closed, pipeline, prioryear, updated, name, rid, snapshot) \
	VALUES (?1,?2,?3,?4,?5,?6,?7,?8,?9,?10,?11,?12,?13,?14)";
	
	myAssert(sqlite3_prepare_v2([database database], [qry UTF8String], -1, &insert_stmt, NULL) == SQLITE_OK, @"FATAL DB error %@", qry);
    if (result && !error)
    {
		NSArray* a = [result records];
		
		NSDateFormatter *month_name_formatter = [[[NSDateFormatter alloc] init] autorelease];
		[month_name_formatter setDateFormat:@"MMM"];
		
		for (ZKSObject* r in a) {
			//NSLog(@"Roleid: %@", r);
			NSString* date = [r fieldValue:@"StartDate"];
			NSString* name = [[r fieldValue:@"Owner"] fieldValue:@"Name"];
			NSString* uid = [r fieldValue:@"OwnerId"];
			NSString* mid = [r fieldValue:@"ManagerId"];
			NSString* rid = [[r fieldValue:@"Owner"] fieldValue:@"UserRoleId"];
			double quota = [r doubleValue:@"Quota"];
			double forecast = [r doubleValue:@"Commit"];
			double closed = [r doubleValue:@"Closed"];
			double pipeline = [r doubleValue:@"Pipeline"];
			double prioryear = 0.0f;
			
			NSDate* month = [[self fiscalCalendar] dateFromSFDCDateString:date];
			NSString* month_name = [month_name_formatter stringFromDate:month];
			int month_number = [[self fiscalCalendar] monthIndex:month];
			int year = [[self fiscalCalendar] fiscalYearForDate:month];
			//NSLog(@"Date: %@, Fiscal Year: %d, Month number: %d", month, year, month_number); 
			
			//Also insert into table.
			sqlite3_bind_text(insert_stmt, 1, [uid UTF8String],  [uid length],  SQLITE_STATIC);
			sqlite3_bind_text(insert_stmt, 2, [mid UTF8String],  [mid length],  SQLITE_STATIC);
			sqlite3_bind_int(insert_stmt, 3, month_number);
			sqlite3_bind_text(insert_stmt, 4, [month_name UTF8String],  [month_name length],  SQLITE_STATIC);
			sqlite3_bind_int(insert_stmt, 5, year);
			sqlite3_bind_double(insert_stmt, 6, quota);
			sqlite3_bind_double(insert_stmt, 7, forecast);
			sqlite3_bind_double(insert_stmt, 8, closed);
			sqlite3_bind_double(insert_stmt, 9, pipeline);
			sqlite3_bind_double(insert_stmt, 10, prioryear);
			sqlite3_bind_text(insert_stmt, 11, [timestamp UTF8String], [timestamp length], SQLITE_STATIC);
			sqlite3_bind_text(insert_stmt, 12, [name UTF8String],  [name length],  SQLITE_STATIC);
			sqlite3_bind_text(insert_stmt, 13, [rid UTF8String], [rid length], SQLITE_STATIC);
			sqlite3_bind_int(insert_stmt, 14, SnapshotCurrent);
			int ret = sqlite3_step(insert_stmt);
			if (ret != SQLITE_DONE)
			{
				NSLog(@"Cannot insert: %s", sqlite3_errmsg([database database]));
			}
			sqlite3_reset(insert_stmt);
		}
		
		sqlite3_exec([database database], "COMMIT TRANSACTION", NULL, NULL, &errorMessage);
		sqlite3_finalize(insert_stmt);
		
		if ([a count] > 0){
			[[self currentForecastUser] setActive:[self updateTimestamp] snapshot:SnapshotCurrent];
			[self viewForecastFor:currentForecastUser startMonth:[self fromDate] endMonth:[self toDate] viewBy:controlViewBy.selectedSegmentIndex+1];
		} else {
			NSLog(@"Cannot find any forecasts for %@", [self currentForecastUser]);
			[[[[UIAlertView alloc] initWithTitle:@"Forecasts"
										 message:[NSString stringWithFormat:@"Cannot find forecasts for %@ in salesforce.com", [currentForecastUser name]]
										delegate:nil 
							   cancelButtonTitle:NSLocalizedString(@"OK", nil)
							   otherButtonTitles:nil] autorelease] show];
		}
	}
    else if (error)
    {
        NSLog(@"SOQL Error: %@", error);
    }
}

- (void) updatePriorYearFor:(SalesPadSnapshotType) snapshot{
	//Update the prior year numbers. tricky..
	sqlite3_stmt* stmt;
	char* errorMessage;
	
	NSMutableArray* pyvals = [[NSMutableArray alloc]init];
	NSString* qry = @"SELECT cy.uid,cy.monthname,cy.year,py.closed FROM forecasts cy,forecasts py WHERE cy.uid=py.uid AND cy.monthname=py.monthname AND cy.year=py.year+1 AND cy.snapshot=py.snapshot and cy.snapshot=?1";
	myAssert(sqlite3_prepare_v2([database database], [qry UTF8String], [qry length], &stmt, NULL) == SQLITE_OK, @"FATAL DB error %@", qry);
	
	sqlite3_bind_int(stmt, 1, snapshot);
	while (sqlite3_step(stmt) == SQLITE_ROW) {
		const char* cuid = (const char*)sqlite3_column_text(stmt, 0);
		const char* cmonth = (const char*)sqlite3_column_text(stmt, 1);
		const int   cfy = sqlite3_column_int(stmt, 2);
		const double cclosed = sqlite3_column_double(stmt, 3);
		
		NSString* uid = [[[NSString alloc] initWithUTF8String:cuid] autorelease];
		NSString* month = [[[NSString alloc] initWithUTF8String:cmonth] autorelease];
		Forecast* f = [[Forecast alloc] initWithClosedFor:uid period:month closed:cclosed FY:cfy];
		[pyvals addObject:f];
		[f release];
	}
	sqlite3_finalize(stmt);
	
	//now update the current one.
	sqlite3_exec([database database], "BEGIN TRANSACTION", NULL, NULL, &errorMessage);
	qry = @"UPDATE forecasts SET prioryear=?1 WHERE uid=?2 AND monthname=?3 AND year=?4 AND snapshot=?5";
	myAssert(sqlite3_prepare_v2([database database], [qry UTF8String], [qry length], &stmt, NULL) == SQLITE_OK, @"FATAL DB error %@", qry);
	for(Forecast* f in pyvals) {
		NSString* uid = [f uid];
		NSString* month = [f period];
		int		  year = [f fiscalyear];
		double	  closed = [f closedAmt];
		
		sqlite3_bind_double(stmt, 1, closed);
		sqlite3_bind_text(stmt, 2, [uid UTF8String], [uid length], SQLITE_STATIC);
		sqlite3_bind_text(stmt, 3, [month UTF8String], [month length], SQLITE_STATIC);
		sqlite3_bind_int(stmt, 4, year);
		sqlite3_bind_int(stmt, 5, snapshot);
		
		sqlite3_step(stmt);
		sqlite3_reset(stmt);
	}
	sqlite3_exec([database database], "COMMIT TRANSACTION", NULL, NULL, &errorMessage);
	sqlite3_finalize(stmt);
	[pyvals release];
}

#pragma mark -
#pragma mark search forecast user names

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
	//if we are online then get it from SFDC - else look in local cache.
	if ([self isOffline] != SalesPadOnline) {
		[self findNamesDBCallback:searchString];
	} else {
		NSString *queryString=[NSString stringWithFormat:@"select Id,Name,UserRoleId from User where isactive=true and ForecastEnabled=true and name like '%%%@%%' limit 10",searchString];
		[[ZKServerSwitchboard switchboard] query:queryString target:self selector:@selector(findNamesCallback:error:context:) context:nil];
	}
	return NO;
}

- (void) findNamesDBCallback:(NSString*) searchString
{
	sqlite3_stmt* stmt;
	NSString *qry = [NSString stringWithFormat:@"SELECT DISTINCT name,uid,rid from Forecasts WHERE Name like '%%%@%%' LIMIT 10", searchString];
	myAssert(sqlite3_prepare_v2([database database], [qry UTF8String], [qry length], &stmt, NULL) == SQLITE_OK, @"FATAL DB error %@", qry);
	
	[searchLookAhead removeAllObjects];
	if (!searchLookAhead) {
		searchLookAhead = [[NSMutableArray alloc]init];
	}
	
	while (sqlite3_step(stmt) == SQLITE_ROW) {
		const char* n = (const char*)sqlite3_column_text(stmt, 0);
		const char* i = (const char*)sqlite3_column_text(stmt, 1);
		const char* r = (const char*)sqlite3_column_text(stmt, 2);
		
		NSString* name = [[[NSString alloc]initWithUTF8String:n] autorelease];
		NSString* uid = [[[NSString alloc]initWithUTF8String:i] autorelease];
		NSString* rid = [[[NSString alloc]initWithUTF8String:r] autorelease];
		
		User* u = [[[User alloc]initWithUser:uid name:name] autorelease];
		[u setRid:rid];
		[searchLookAhead addObject:u];
	}
	sqlite3_reset(stmt);
	sqlite3_finalize(stmt);
	
	[self.searchDisplayController.searchResultsTableView reloadData];
}
	

- (void)findNamesCallback:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    if (result && !error)
    {
		[searchLookAhead removeAllObjects];
		if(!searchLookAhead){
			searchLookAhead = [[NSMutableArray alloc]init];
		}
        //NSLog(@"We got back %i results", [[result records] count]);
		NSArray* a = [result records];
		for (ZKSObject* r in a) {
			User* u = [[[User alloc]initWithUser:[r fieldValue:@"Id"] name:[r fieldValue:@"Name"]] autorelease];
			[u setRid:[r fieldValue:@"UserRoleId"]];
			[searchLookAhead addObject:u];
		}
		[self.searchDisplayController.searchResultsTableView reloadData];
	}
    else if (error)
    {
        NSLog(@"SOQL Error findNamesCallback: %@", error);
    }
}

- (void)modifiedRange:(int)startTab endTab:(int)endTab
{
	NSDate* date;
	date = [[self fiscalCalendar]firstDayOfYear];
	[self setFromDate:[[self fiscalCalendar] dateByAddingMonths:startTab toDate:date]];
	date = [[self fiscalCalendar] dateByAddingMonths:endTab toDate:date];
	[self setToDate:[FiscalCalendar lastDayOfMonth:date]];
	[self viewForecastFor:currentForecastUser startMonth:[self fromDate] endMonth:[self toDate] viewBy:controlViewBy.selectedSegmentIndex+1];
}

-(User*) loadUser:(NSString*) uid
{
	sqlite3_stmt* user_stmt;
	NSString *qry = @"SELECT DISTINCT uid,name,rid from forecasts WHERE uid=?1";
	myAssert(sqlite3_prepare_v2([database database], [qry UTF8String], -1, &user_stmt, NULL) == SQLITE_OK, @"FATAL DB error %@", qry);
	
	sqlite3_bind_text(user_stmt, 1, [uid UTF8String], [uid length], SQLITE_STATIC);
	
	User* u = nil;
	if (sqlite3_step(user_stmt) == SQLITE_ROW) {
		const char* cid = (const char*)sqlite3_column_text(user_stmt, 0);
		const char* cname = (const char*)sqlite3_column_text(user_stmt, 1);
		const char* crid = (const char*)sqlite3_column_text(user_stmt, 2);
		
		NSString* id = [[[NSString alloc]initWithUTF8String:cid] autorelease];
		NSString* name = [[[NSString alloc]initWithUTF8String:cname] autorelease];
		NSString* rid = [[[NSString alloc]initWithUTF8String:crid] autorelease];
		
		u = [[[User alloc] initWithUser:id name:name] autorelease];
		[u setRid:rid];
	}
	sqlite3_reset(user_stmt);
	sqlite3_finalize(user_stmt);
	
	return u;	
}

-(User*) loadCurrentUser
{
	sqlite3_stmt* user_stmt;
	NSString *qry = @"SELECT id,name,rid from user WHERE currentuser=1";
	
	myAssert(sqlite3_prepare_v2([database database], [qry UTF8String], [qry length], &user_stmt, NULL) == SQLITE_OK, @"FATAL DB error %@", qry); 	
	User* u = nil;
	if (sqlite3_step(user_stmt) == SQLITE_ROW) {
		const char* cid = (const char*)sqlite3_column_text(user_stmt, 0);
		const char* cname = (const char*)sqlite3_column_text(user_stmt, 1);
		const char* crid = (const char*)sqlite3_column_text(user_stmt, 2);
		
		NSString* id = [[[NSString alloc]initWithUTF8String:cid] autorelease];
		NSString* name = [[[NSString alloc]initWithUTF8String:cname] autorelease];
		NSString* rid = [[[NSString alloc]initWithUTF8String:crid] autorelease];
		
		u = [[[User alloc] initWithUser:id name:name] autorelease];
		[u setRid:rid];
	}
	sqlite3_reset(user_stmt);
	sqlite3_finalize(user_stmt);
	
	return u;
}

- (void) notify:(NSString*) message {
	
}

#pragma mark -
#pragma mark Roles
- (void) startSync
{
	NSLog(@"Starting Synchronization");
	[self syncFiscalPeriod];
}

- (void) syncHierarchy
{
	[[self busyDealTableIndicator] startAnimating];
	NSString* rid = [[self currentForecastUser] rid];
	NSString* query = [NSString stringWithFormat:@"select UserRole__c,Level_0_UserRole__c,Level_1_UserRole__c,Level_2_UserRole__c,\
					   Level_3_UserRole__c,Level_4_UserRole__c,Level_5_UserRole__c,Level_6_UserRole__c,Level_7_UserRole__c,\
					   Level_8_UserRole__c,Level_9_UserRole__c,Level_10_UserRole__c,Level_11_UserRole__c,Level_12_UserRole__c \
					   FROM Role_Hierarchy__c WHERE (Level_0_UserRole__c='%@' OR Level_1_UserRole__c='%@' \
					   OR Level_2_UserRole__c='%@' OR Level_3_UserRole__c='%@' OR Level_4_UserRole__c='%@' \
					   OR Level_5_UserRole__c='%@' OR Level_6_UserRole__c='%@' OR Level_7_UserRole__c='%@' \
					   OR Level_8_UserRole__c='%@' OR Level_9_UserRole__c='%@' OR Level_10_UserRole__c='%@' \
					   OR Level_11_UserRole__c='%@' OR Level_12_UserRole__c='%@') \
					   AND (Invalid_As_Of__c > TODAY OR Invalid_As_Of__c=null)",
					   rid, rid, rid, rid, rid, rid, rid, rid, rid, rid, rid, rid, rid];
	//NSLog(@"ROLEID SOQL: %@", query);
	[[ZKServerSwitchboard switchboard] query:query target:self selector:@selector(syncHierarchyCallback:error:context:) context:nil];
}

- (void) syncHierarchyCallback:(ZKQueryResult*)result error:(NSError*)error context:(id)context
{
	[[self busyDealTableIndicator] stopAnimating];
	char* errorMessage;
	sqlite3_exec([database database], "BEGIN TRANSACTION", NULL, NULL, &errorMessage);
	sqlite3_stmt* insert_stmt;
	//Delete the existing rows.
	NSString *qry = @"DELETE FROM roles";
	myAssert(sqlite3_exec([database database], [qry UTF8String], NULL, NULL, &errorMessage) == SQLITE_OK, @"FATAL DB error %@", qry);
	
	qry = @"INSERT INTO roles (id, lvl0, lvl1, lvl2, lvl3, lvl4, lvl5, lvl6, lvl7, lvl8, lvl9, lvl10, lvl11, lvl12) \
	VALUES (?1,?2,?3,?4,?5,?6,?7,?8,?9,?10,?11,?12,?13,?14)";
	myAssert(sqlite3_prepare_v2([database database], [qry UTF8String], -1, &insert_stmt, NULL) == SQLITE_OK, @"FATAL DB error %@", qry);	
	
	NSArray* column_names = [[NSArray alloc]initWithObjects:@"Level_0_UserRole__c", @"Level_1_UserRole__c", @"Level_2_UserRole__c",
							 @"Level_3_UserRole__c",@"Level_4_UserRole__c", @"Level_5_UserRole__c", @"Level_6_UserRole__c",
							 @"Level_7_UserRole__c", @"Level_8_UserRole__c", @"Level_9_UserRole__c", @"Level_10_UserRole__c",
							 @"Level_11_UserRole__c", @"Level_12_UserRole__c",nil];
	if (result && !error)
	{
		NSArray* a = [result records];
		
		for (ZKSObject* r in a) {
			NSString* rid = [r fieldValue:@"UserRole__c"];
			//NSLog(@"INSERT INTO roles (id, lvl0, lvl1, lvl2, lvl3, lvl4, lvl5, lvl6, lvl7, lvl8, lvl9, lvl10, lvl11, lvl12) VALUES ('%@',",rid);
			sqlite3_bind_text(insert_stmt, 1, [rid UTF8String],  [rid length],  SQLITE_STATIC);
			for (int i=0; i<[column_names count]; i++) {
				NSString* cid = [r fieldValue:[column_names objectAtIndex:i]];
				sqlite3_bind_text(insert_stmt, i+2, [cid UTF8String], [cid length], SQLITE_STATIC);
				//NSLog(@"'%@',",cid);
			}
			//NSLog(@");");
			
			if (sqlite3_step(insert_stmt) != SQLITE_DONE){
				NSLog(@"Cannot insert: %s", insert_stmt);
			}
			sqlite3_reset(insert_stmt);
		}
		sqlite3_exec([database database], "COMMIT TRANSACTION", NULL, NULL, &errorMessage);
		sqlite3_finalize(insert_stmt);
		[self syncOpportunities:[self currentForecastUser] startDate:nil endDate:nil];		
	}
	else if (error)
	{
		NSLog(@"SOQL Error: syncHierarchyCallback - %@", error);
	}
}
#pragma mark -
#pragma mark data helpers
- (NSString*) updateTimestamp {
	return [[self fiscalCalendar] stringFromSFDCDate:[self today]];
}
	
#pragma mark -
#pragma mark Opportunities
- (void) syncOpportunities:(User*)u startDate:(NSDate*)s endDate:(NSDate*)e
{
	[[self busyDealTableIndicator] startAnimating];
	NSLog(@"Sync Opportunities");
	NSMutableArray*  rids = [[NSMutableArray alloc]init];
	
	//Get all the roles.
	sqlite3_stmt* stmt;
	NSString* qry = @"SELECT id FROM roles";
	myAssert(sqlite3_prepare_v2([database database], [qry UTF8String], [qry length], &stmt, NULL) == SQLITE_OK, @"FATAL DB error %@", qry);
	
	while (sqlite3_step(stmt) != SQLITE_DONE) {
		const char* cid = (const char*)sqlite3_column_text(stmt, 0);
		if (cid!=NULL) {
			NSString* roleid = [[[NSString alloc]initWithUTF8String:cid] autorelease];
			[rids addObject:roleid];
		}
	}
	sqlite3_reset(stmt);
	sqlite3_finalize(stmt);
	
	//Grab a hardcoded limit of 500 deals.
	NSArray*  exclude_stages = [[NSArray alloc] initWithObjects:@"01 - Identifying an Opportunity", @"Dead - Duplicate", @"Dead - Webstore",nil];
	//NSArray*  custom_fields  = [[NSArray alloc] initWithObjects:@"Next_Steps__c",@"Owner_Manager_Name__c",@"Manager_Notes__c",@"SE_Comments__c",nil];
	
	if (multicurrency) { //currency conversion is supported & SFDC ORG.
		qry = [NSString stringWithFormat:@"select Id,Name,convertCurrency(Amount),Probability,StageName,CloseDate,Type,IsWon,IsClosed,\
					   ForecastCategory,OwnerId,Owner.name,Owner.UserRoleId,Description,NextStep \
					   from Opportunity WHERE Owner.UserRoleId in ('%@') AND CloseDate >= THIS_MONTH AND (CloseDate = THIS_FISCAL_YEAR OR CloseDate <= NEXT_90_DAYS) \
					   AND StageName NOT IN ('%@') AND Amount > 0 \
					   ORDER BY Amount DESC LIMIT %d", [rids componentsJoinedByString:@"','"],[exclude_stages componentsJoinedByString:@"','"],500];
	} else { //
		qry = [NSString stringWithFormat:@"select Id,Name,Amount,Probability,StageName,CloseDate,Type,IsWon,IsClosed,\
				 ForecastCategory,OwnerId,Owner.name,Owner.UserRoleId,Description,NextStep \
				 from Opportunity WHERE Owner.UserRoleId in ('%@') AND CloseDate >= THIS_MONTH AND (CloseDate = THIS_FISCAL_YEAR OR CloseDate <= NEXT_90_DAYS) \
				 AND StageName NOT IN ('%@') AND Amount > 0 \
				 ORDER BY Amount DESC LIMIT %d", [rids componentsJoinedByString:@"','"],[exclude_stages componentsJoinedByString:@"','"],500];
	}
	[rids release];
	[exclude_stages release];
	
	//NSLog(@"OPPORTUNITY SOQL: %@",qry);
	[[ZKServerSwitchboard switchboard] query:qry target:self selector:@selector(syncOpportunitiesCallback:error:context:) context:nil];
}

- (void)syncOpportunitiesCallback:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
	[[self busyDealTableIndicator] stopAnimating];
	NSLog(@"Sync Opportunities - Done");
	char* errorMessage;
	sqlite3_exec([database database], "BEGIN TRANSACTION", NULL, NULL, &errorMessage);
	
	NSString* qry = [NSString stringWithFormat:@"DELETE FROM deals WHERE snapshot=%d", SnapshotCurrent];
	myAssert(sqlite3_exec([database database], [qry UTF8String], NULL, NULL, &errorMessage) == SQLITE_OK, @"FATAL DB error %s", errorMessage);
	
	sqlite3_stmt* insert_stmt;
	qry = @"INSERT INTO deals (id, name, amount, probability, stage, closedate, type, iswon, isclosed, forecastcategory, ownerid, ownername, \
		nextsteps, manager, notes, roleid, updated, senotes, description, snapshot) VALUES (?1,?2,?3,?4,?5,?6,?7,?8,?9,?10,?11,?12,?13,?14,?15,?16,?17,?18,?19,?20)";
		
	myAssert(sqlite3_prepare_v2([database database], [qry UTF8String], -1, &insert_stmt, NULL) == SQLITE_OK, @"FATAL DB error %@", qry);
	if (result && !error)
	{
		NSArray* a = [result records];
		
		NSDateFormatter *month_name_formatter = [[[NSDateFormatter alloc] init] autorelease];
		[month_name_formatter setDateFormat:@"MMM"];
		
		for (ZKSObject* r in a) {
			//NSLog(@"Fields: %@",r);
			NSString *id = [r fieldValue:@"Id"];
			NSString *name = [r fieldValue:@"Name"];
			double   amount = [r doubleValue:@"Amount"];
			double   probability = [r doubleValue:@"Probability"];
			NSString *stage = [r fieldValue:@"StageName"];
			NSDate   *date = [r dateValue:@"CloseDate"];
			NSString *type = [r fieldValue:@"Type"];
			int      iswon  = [r boolValue:@"IsWon"]?1:0;
			int      isclosed  = [r boolValue:@"IsClosed"]?1:0;
			NSString *forecastcategory = [r fieldValue:@"ForecastCategory"];
			NSString *ownerid  = [r fieldValue:@"OwnerId"];
			ZKSObject* owner = [r fieldValue:@"Owner"];
			NSString *ownername = [owner fieldValue:@"Name"];
			NSString *roleid = [owner fieldValue:@"UserRoleId"];
			NSString *nextsteps = [r fieldValue:@"NextStep"];
			NSString *manager = [r fieldValue:@"Owner_Manager_Name__c"];
			NSString *notes = [r fieldValue:@"Manager_Notes__c"];
			NSString *updated = [self updateTimestamp];
			NSString *closedate = [[self fiscalCalendar] stringFromSFDCDate:date];
			NSString *senotes = [r fieldValue:@"SE_Comments__c"];
			NSString *description = [r fieldValue:@"Description"];
			
			//Also insert into table.
			if (id != nil) 
				sqlite3_bind_text(insert_stmt, 1, [id UTF8String],  [id length],  SQLITE_STATIC);
			if (name != nil)
				sqlite3_bind_text(insert_stmt, 2, [name UTF8String],  [name length],  SQLITE_STATIC);
			
			sqlite3_bind_double(insert_stmt, 3, amount);
			sqlite3_bind_double(insert_stmt, 4, probability);
			
			if (stage != nil)
				sqlite3_bind_text(insert_stmt, 5, [stage UTF8String],  [stage length],  SQLITE_STATIC);
			
			if (closedate != nil)
				sqlite3_bind_text(insert_stmt, 6, [closedate UTF8String],  [closedate length],  SQLITE_STATIC);
			
			if (type != nil)
				sqlite3_bind_text(insert_stmt, 7, [type UTF8String],[type length],  SQLITE_STATIC);
			
			sqlite3_bind_int(insert_stmt, 8, iswon);
			sqlite3_bind_int(insert_stmt, 9, isclosed);

			if (forecastcategory != nil) 
				sqlite3_bind_text(insert_stmt, 10, [forecastcategory UTF8String],  [forecastcategory length],  SQLITE_STATIC);
			
			if (ownerid != nil) 
				sqlite3_bind_text(insert_stmt, 11, [ownerid UTF8String],  [ownerid length],  SQLITE_STATIC);
			
			if (ownername != nil)
			sqlite3_bind_text(insert_stmt, 12, [ownername UTF8String],  [ownername length],  SQLITE_STATIC);
			
			if (nextsteps != nil)
				sqlite3_bind_text(insert_stmt, 13, [nextsteps UTF8String],  [nextsteps length],  SQLITE_STATIC);
			
			if (manager != nil) 
				sqlite3_bind_text(insert_stmt, 14, [manager UTF8String],  [manager length],  SQLITE_STATIC);
			
			if (notes != nil)
				sqlite3_bind_text(insert_stmt, 15, [notes UTF8String],  [notes length],  SQLITE_STATIC);
			
			if (roleid != nil)
				sqlite3_bind_text(insert_stmt, 16, [roleid UTF8String],  [roleid length],  SQLITE_STATIC);

			sqlite3_bind_text(insert_stmt, 17, [updated UTF8String],  [updated length],  SQLITE_STATIC);
			
			if (senotes != nil)
				sqlite3_bind_text(insert_stmt, 18, [senotes UTF8String],  [senotes length],  SQLITE_STATIC);			

			if (description != nil)
				sqlite3_bind_text(insert_stmt, 19, [description UTF8String],  [description length],  SQLITE_STATIC);

			sqlite3_bind_int(insert_stmt, 20, SnapshotCurrent);
			
			if (sqlite3_step(insert_stmt) != SQLITE_DONE)
			{
				NSLog(@"Cannot insert: %s", insert_stmt);
			}
			sqlite3_clear_bindings(insert_stmt);
			sqlite3_reset(insert_stmt);
		}
		sqlite3_exec([database database], "COMMIT TRANSACTION", NULL, NULL, &errorMessage);
		sqlite3_finalize(insert_stmt);
		
		//now have run once - save in system
		[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"runonce"];
		[self configureView];
	}
	else if (error)
	{
		NSLog(@"error returned on sync opportunities: %@", error);
		NSString* errormsg = [[error userInfo] valueForKey:@"faultstring"];
		if([errormsg rangeOfString:@"currency"].length > 0 && [self multicurrency] == 1) {
			NSLog(@"Doesn't support currency conversion - lets do without");
			[self setMulticurrency:0];
			[self syncOpportunities:[self currentForecastUser] startDate:nil endDate:nil];
		}
	}
}

#pragma mark -
#pragma mark role hierarchy
- (void) syncRoleHierarchy
{	
	[[self busyForecastTableIndicator] startAnimating];
	NSLog(@"Sync Role Hierarchy");
	//NSString* query = [NSString stringWithFormat:@"select Id,ParentRoleId FROM UserRole WHERE ForecastUserId<>''"];
	NSString* query = [NSString stringWithFormat:@"select UserRoleId,UserRole.ParentRoleId FROM User WHERE ForecastEnabled=TRUE AND IsActive=TRUE ORDER BY UserRoleId"];

	//NSLog(@"ROLEID SOQL: %@", query);
	[[ZKServerSwitchboard switchboard] query:query target:self selector:@selector(syncRoleHierarchyCallback:error:context:) context:nil];
}

- (void) syncRoleHierarchyCallback:(ZKQueryResult*)result error:(NSError*)error context:(id)context
{	
	NSLog(@"Sync Role Hierarchy - Done");
	[[self busyForecastTableIndicator] stopAnimating];
	char* errorMessage;
	sqlite3_exec([database database], "BEGIN TRANSACTION", NULL, NULL, &errorMessage);
	sqlite3_stmt* insert_stmt = NULL;
	//Delete the existing rows.
	NSString *qry = @"DELETE FROM roles";
	myAssert(sqlite3_exec([database database], [qry UTF8String], NULL, NULL, &errorMessage) == SQLITE_OK, @"FATAL DB error %@", qry);
	
	//Rebuild the role hierachy table.
	if (result && !error) {
		NSMutableDictionary* role_tree = [[NSMutableDictionary alloc]init];
		NSArray* a = [result records];
		NSString* previous = nil;
		//Load role table into memory
		
		for (ZKSObject* r in a) {
			//NSLog(@"Record: %@", r);
			NSString* rid = [r fieldValue:@"UserRoleId"];
			NSString* pid = [[r fieldValue:@"UserRole"] fieldValue:@"ParentRoleId"];
			if ([rid compare:previous] != 0) {
				Role *n = [[[Role alloc]initWithId:rid parent:pid] autorelease];
				[role_tree setValue:n forKey:rid];
				previous = [[[NSString alloc]initWithString:rid] autorelease]; 
			}
		}
		
		//find the parents and link to it for each node.
		for(NSString *key in role_tree) {
			Role* r = [role_tree valueForKey:key];
			//NSLog(@"id: %@, pid: %@", [r rid], [r pid]);
			Role *parent = [role_tree valueForKey:[r pid]];
			[r setParent:parent];
		}
		
		//Flatten the tree and write it to the database.
		//flatten to database.
		qry = @"INSERT INTO roles (id, lvl0, lvl1, lvl2, lvl3, lvl4, lvl5, lvl6, lvl7, lvl8, lvl9, lvl10, lvl11, lvl12) VALUES (?1,?2,?3,?4,?5,?6,?7,?8,?9,?10,?11,?12,?13,?14)";
		myAssert(sqlite3_prepare_v2([database database], [qry UTF8String], -1, &insert_stmt, NULL) == SQLITE_OK, @"FATAL DB error %@", qry);

		for (NSString* rid in role_tree) {
			int   myteam = 0;
			//Only keep the roles that I am part of.			
			Role* r = [role_tree valueForKey:rid];
			sqlite3_bind_text(insert_stmt, 1, [rid UTF8String],  [rid length],  SQLITE_STATIC);

			int  i=2;
			for(NSString* p in [r path]) {
				if ([p compare:[[self currentForecastUser] rid]] == 0) {
					myteam = 1;
				}
				sqlite3_bind_text(insert_stmt, i, [p UTF8String], [p length], SQLITE_STATIC);
				i++;
			}
			
			if (myteam > 0) {
				if (sqlite3_step(insert_stmt) != SQLITE_DONE){
					NSLog(@"Cannot insert: %s", insert_stmt);
				}
			}
			sqlite3_reset(insert_stmt);			
		}		
		sqlite3_exec([database database], "COMMIT TRANSACTION", NULL, NULL, &errorMessage);
		sqlite3_finalize(insert_stmt);
		[role_tree release];
		[self syncOpportunities:[self currentForecastUser] startDate:nil endDate:nil];		
	}
	else if (error)
	{
		NSLog(@"Error from SFDC: %@", error);
	}	
}

#pragma mark -
#pragma mark fiscalperiod
-(void) syncFiscalPeriod
{
	NSString* query;
	NSLog(@"Sync fiscal period");
	query = [NSString stringWithFormat:@"select StartDate,EndDate,Name FROM FiscalYearSettings WHERE StartDate <= TODAY AND EndDate >= TODAY"];
	//NSLog(@"FISCAL DATE SOQL: %@",query);
	[[ZKServerSwitchboard switchboard] query:query target:self selector:@selector(syncFiscalPeriodCallback:error:context:) context:nil];
	
}


- (void) syncFiscalPeriodCallback:(ZKQueryResult*)result error:(NSError*)error context:(id)context
{	
	NSLog(@"Sync fiscal period - Done");
	if (!error) {
		NSArray* a = [result records];
		
		//Load role table into memory
		if ([a count]>0) {
			ZKSObject *r = [a objectAtIndex:0];
			NSDate* sdate = [[self fiscalCalendar] dateFromSFDCDateString:[r fieldValue:@"StartDate"]];
			NSDate* edate = [[self fiscalCalendar] dateFromSFDCDateString:[r fieldValue:@"EndDate"]];
			//NSString* label = [r fieldValue:@"Name"];
			[[NSUserDefaults standardUserDefaults] setObject:sdate forKey:@"FiscalStartDate"];
			[[NSUserDefaults standardUserDefaults] setObject:edate forKey:@"FiscalEndDate"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			[fiscalCalendar setFirstDayOfYear:sdate];
			[self setFromDate:sdate];
			[self setToDate:edate];
			[[self customView] setForCalendar:fiscalCalendar];
			[self syncRoleHierarchy];
		} else {
			NSLog(@"Fatal - no Fiscal data available in ORG");
		}
	} else {
		NSLog(@"error returned on fiscal date check: %@", error);
	}
}
			
#pragma mark -
#pragma mark reviewed forecasts
- (IBAction)reviewedForecasts:(id)sender {

	[[NSUserDefaults standardUserDefaults] setObject:[fiscalCalendar today] forKey:@"LastReviewedDate"];
	//delete the previous snapshot and save the current date as snapshot. Remove all closed deals from snapshot - only interested
	//in tracking pipeline.
	NSString *qry = [NSString stringWithFormat:@"DELETE FROM deals where snapshot=%d OR isclosed=1", SnapshotCheckpoint];
	myAssert(sqlite3_exec([database database], [qry UTF8String], NULL, NULL, NULL) == SQLITE_OK, @"FATAL DB Error: %@", qry);
	
	qry = [NSString stringWithFormat:@"DELETE from deals_tmp"];
	myAssert(sqlite3_exec([database database], [qry UTF8String], NULL, NULL, NULL) == SQLITE_OK, @"FATAL DB Error: %@", qry);

	qry = [NSString stringWithFormat:@"INSERT INTO deals_tmp SELECT * FROM deals"];
	myAssert(sqlite3_exec([database database], [qry UTF8String], NULL, NULL, NULL) == SQLITE_OK, @"FATAL DB Error: %@", qry);

	qry = [NSString stringWithFormat:@"UPDATE deals_tmp SET snapshot=%d", SnapshotCheckpoint];
	myAssert(sqlite3_exec([database database], [qry UTF8String], NULL, NULL, NULL) == SQLITE_OK, @"FATAL DB Error: %@", qry);

	qry = [NSString stringWithFormat:@"INSERT INTO deals SELECT * FROM deals_tmp"];
	myAssert(sqlite3_exec([database database], [qry UTF8String], NULL, NULL, NULL) == SQLITE_OK, @"FATAL DB Error: %@", qry);
		
	qry = [NSString stringWithFormat:@"DELETE FROM forecasts where snapshot=%d", SnapshotCheckpoint];
	myAssert(sqlite3_exec([database database], [qry UTF8String], NULL, NULL, NULL) == SQLITE_OK, @"FATAL DB Error: %@", qry);

	qry = [NSString stringWithFormat:@"DELETE from forecasts_tmp"];
	myAssert(sqlite3_exec([database database], [qry UTF8String], NULL, NULL, NULL) == SQLITE_OK, @"FATAL DB Error: %@", qry);

	qry = [NSString stringWithFormat:@"INSERT INTO forecasts_tmp SELECT * FROM forecasts"];
	myAssert(sqlite3_exec([database database], [qry UTF8String], NULL, NULL, NULL) == SQLITE_OK, @"FATAL DB Error: %@", qry);
	
	qry = [NSString stringWithFormat:@"UPDATE forecasts_tmp SET snapshot=%d", SnapshotCheckpoint];
	myAssert(sqlite3_exec([database database], [qry UTF8String], NULL, NULL, NULL) == SQLITE_OK, @"FATAL DB Error: %@", qry);
	
	qry = [NSString stringWithFormat:@"INSERT INTO forecasts SELECT * FROM forecasts_tmp"];
	myAssert(sqlite3_exec([database database], [qry UTF8String], NULL, NULL, NULL) == SQLITE_OK, @"FATAL DB Error: %@", qry);
	
	
	/*	
	qry = [NSString stringWithFormat:@"DELETE FROM user", SnapshotCheckpoint];
	myAssert(sqlite3_exec([database database], [qry UTF8String], NULL, NULL, NULL) == SQLITE_OK, @"FATAL DB Error: %@", qry);

	qry = [NSString stringWithFormat:@"UPDATE deals set snapshot=%d WHERE snapshot=%d", SnapshotCheckpoint, SnapshotCurrent];
	myAssert(sqlite3_exec([database database], [qry UTF8String], NULL, NULL, NULL) == SQLITE_OK, @"FATAL DB Error: %@", qry);
	
	qry = [NSString stringWithFormat:@"UPDATE forecasts set snapshot=%d WHERE snapshot=%d", SnapshotCheckpoint, SnapshotCurrent];
	myAssert(sqlite3_exec([database database], [qry UTF8String], NULL, NULL, NULL) == SQLITE_OK, @"FATAL DB Error: %@", qry);
    */
	
	[[[[UIAlertView alloc] initWithTitle:@"Lock Forecasts"
								 message:@"Current forecasts and deal pipeline were saved. Future runs show changes from this snapshot." 
								delegate:nil 
					   cancelButtonTitle:NSLocalizedString(@"OK", nil)
					   otherButtonTitles:nil] autorelease] show];
}

#pragma mark -
#pragma mark user select 

- (IBAction)selectUser:(id)sender {
	SelectUserPopover* vc = [[SelectUserPopover alloc]initWithStyle:UITableViewStyleGrouped];
	[vc setForuser:[self currentForecastUser]];
	vc.delegate = self;
	popoverControllerSelectUser = [[UIPopoverController alloc]initWithContentViewController:vc];
	popoverControllerSelectUser.delegate = self;
	[vc release];
	CGRect r = [sender frame];
	r.origin.y = 0;
	r.origin.x = 0;
	[self.popoverControllerSelectUser presentPopoverFromRect:r inView:sender permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
}

- (void) switchUser:(User *)u {
	[[self popoverControllerSelectUser] dismissPopoverAnimated:YES];
	if ([u uid] == nil) {
		[self loadForecastsFor:[self loadCurrentUser]];
	} else {
		[self loadForecastsFor:u];	
	}
}

#pragma mark -
#pragma mark chatter helpers

-(IBAction) comment:(id)sender {
	NewChatViewController* vc = [[[NewChatViewController alloc]init] autorelease];
	UIPopoverController* popover = [[UIPopoverController alloc]initWithContentViewController:vc];
	popover.popoverContentSize = CGSizeMake(435, 126);
	[vc setDelegate:self];
	[self setPopoverControllerNewPost:popover];
	[vc setEntity:nil];
	[vc release];
	[popover release];
	CGRect r = [sender frame];
	r.origin.y = 0;
	r.origin.x = 0;
	[[self popoverControllerNewPost] presentPopoverFromRect:r inView:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];	
}

- (void) post:(NSString*)pid body:(NSString*)body {
	[[openDealsTableController dealChatterViewController] postChatter:pid body:body];
	[[self popoverControllerNewPost] dismissPopoverAnimated:YES];
}


-(void) chatterloading:(int)count {
	if (count < 0) {
		[[self chatterViewController] clearFeeds];
		[[self chatterbusy] startAnimating];
		[[self noChatterLabel] setHidden:NO];
	} else {
		[[self chatterbusy] stopAnimating];
	}
	
	if (count>0) {
		[[self noChatterLabel] setHidden:YES];
	}
}

#pragma mark -
#pragma mark connectivity checks

- (void) reachabilityChanged: (NSNotification* )note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	
	NetworkStatus netStatus          = [curReach currentReachabilityStatus];
	BOOL          connectionRequired = [curReach connectionRequired];
	
	if (netStatus == NotReachable || connectionRequired) {
		
		[[[[UIAlertView alloc] initWithTitle:@"Connection lost"
									 message:@"Connection to Salesforce.com was lost. Working in offline mode now." 
									delegate:nil 
						   cancelButtonTitle:NSLocalizedString(@"OK", nil)
						   otherButtonTitles:nil] autorelease] show];
		
		NSLog(@"Log we are going offline - no connection available.");
		[self setIsOffline:SalesPadNoInternet];
		[[self offlineButton] setImage:[UIImage imageNamed:@"nointernet.png"] forState:UIControlStateNormal];
	} else {
		NSLog(@"Log ready to go online if needed");
		if ([self isOffline] != SalesPadOnline) {
			[self setIsOffline:SalesPadOffline];
			[[self offlineButton] setImage:[UIImage imageNamed:@"offline1.png"] forState:UIControlStateNormal];
		}
		//Notify the user and allow to go online when ready.
		//If not logged in then login again.
		//kick of the sync process.
		//[self startSync];
	}
}

- (IBAction) offlineButtonAction:(id) sender {
	switch ([self isOffline]) {
		case SalesPadNoInternet:
			return;
			break;
		case SalesPadOnline:
			//go off line
			[self setIsOffline:SalesPadOffline];
			[[self offlineButton] setImage:[UIImage imageNamed:@"offline1.png"] forState:UIControlStateNormal];			
			break;
	
		case SalesPadOffline:
			[self goOnline];
			break;
			
		default:
			break;
	}
				
}

@end
