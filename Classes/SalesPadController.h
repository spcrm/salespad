//
//  DetailViewController.h
//  SalesPad
//
//  Created by SP on 3/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <sqlite3.h>
#import "LoginController.h"
#import "ZKSforce.h"
#import "User.h"
#import "CustomView.h"
#import "Metric.h"
#import "OpptyTableViewController.h"
#import "Currency.h"
#import "FiscalCalendar.h"
#import "Role.h"
#import "Database.h"
#import "SelectUserPopover.h"
#import "Reachability.h"
#import "NewChatViewController.h"

//#import <CorePlot/CorePlot.h>
#define VIEW_BYDATE 1
#define VIEW_BYUSER 2

typedef enum {
	SalesPadNoInternet = -1,
	SalesPadOffline,
	SalesPadOnline
} SalesPadOfflineMode;

@interface SalesPadController : UIViewController <NewChatterPostDelegate, ChatterDelegate,SelectUserPopoverDelegate,CustomViewDelegate, UISearchBarDelegate, UIPopoverControllerDelegate, UIWebViewDelegate, LoginDelegate, UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate> {
    
	User*           currentForecastUser;
	ZKUserInfo*		currentUser;
	NSDate			 *fromDate;
	NSDate			 *toDate;
	FiscalCalendar   *fiscalCalendar;
	NSDate			 *lastReviewedDate;
	NSDate			 *today;
	
    UIPopoverController *popoverControllerSelectUser;
	UIPopoverController *popoverControllerNewPost;

    UIToolbar *toolbar;
    
    NSManagedObject *detailItem;
    UILabel *detailDescriptionLabel;
	IBOutlet UIWebView *webView;
	IBOutlet UIWebView *summaryPerformance;
	
	Database *database;
	
	sqlite3_stmt *statement;
	sqlite3_stmt *stmt_byuser;
	sqlite3_stmt *stmt_bydate;
	sqlite3_stmt *stmt_dates;
	sqlite3_stmt *stmt_summary;
	
	NSString* viewBy;
	NSString* viewPeriod;
	
	IBOutlet UISegmentedControl* controlViewBy;
	IBOutlet UISearchBar*        searchBar;
	
	IBOutlet UIButton*			 buttonUser;
	IBOutlet UILabel*			 labelDates;
	SalesPadOfflineMode	isOffline;
	NSMutableArray*	searchLookAhead;
	
	IBOutlet CustomView* customView;
	IBOutlet UITableView* openDealsTable;
	IBOutlet UITableView* chatterTable;
	IBOutlet UIActivityIndicatorView* chatterbusy;
	//IBOutlet CPGraphHostingView* graphParent;
	OpptyTableViewController* openDealsTableController;
	OpptyChatterViewController *chatterViewController;
	LoginController           *loginController;
	
	//IBOutlet CPXYGraph *graph;
	//For adding decorations
	IBOutlet UIImageView *titleBar;
	IBOutlet UIButton    *offlineButton;
	IBOutlet UILabel     *dealTableTitleBar;
	IBOutlet UILabel     *chatterTitleBar;
	IBOutlet UIActivityIndicatorView* busy;
	IBOutlet UIActivityIndicatorView* busyForecastTableIndicator;
	IBOutlet UIActivityIndicatorView* busyDealTableIndicator;

	IBOutlet UILabel     *noDealsLabel;
	IBOutlet UILabel     *noForecastsLabel;
	IBOutlet UILabel     *noChatterLabel;
	
	//setup and config
	int		runonce;
	int     multicurrency;
	
	//Connected to the internet?
	Reachability  *hostReachable;
}

@property (nonatomic) int runonce;
@property (nonatomic) int multicurrency;

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) Database *database;
@property (nonatomic, retain) User *currentForecastUser;
@property (nonatomic, retain) ZKUserInfo *currentUser;
@property (nonatomic, retain) NSString *viewBy;
@property (nonatomic, retain) NSString *viewPeriod;
@property (nonatomic, retain) NSManagedObject *detailItem;
@property (nonatomic, retain) IBOutlet UILabel *detailDescriptionLabel;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UISegmentedControl *controlViewBy;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UIButton *buttonUser;
@property (nonatomic, retain) IBOutlet UILabel *labelDates;
@property (nonatomic, retain) IBOutlet UIWebView *summaryPerformance;
@property (nonatomic, retain) IBOutlet UITableView *openDealsTable;
@property (nonatomic, retain) IBOutlet UITableView *chatterTable;
@property (nonatomic, retain) OpptyTableViewController* openDealsTableController;
@property (nonatomic, retain) OpptyChatterViewController *chatterViewController;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* busy;
@property (nonatomic, retain) IBOutlet UIPopoverController* popoverControllerSelectUser;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* chatterbusy;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* busyForecastTableIndicator;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* busyDealTableIndicator;
@property (nonatomic, retain) IBOutlet UILabel     *noDealsLabel;
@property (nonatomic, retain) IBOutlet UILabel     *noForecastsLabel;
@property (nonatomic, retain) IBOutlet UILabel     *noChatterLabel;
@property (nonatomic, retain) Reachability* hostReachable;
@property (nonatomic, retain) LoginController *loginController;
@property (nonatomic, retain) IBOutlet UIPopoverController* popoverControllerNewPost;



@property (nonatomic, retain) IBOutlet UIImageView *titleBar;
@property (nonatomic, retain) IBOutlet UIButton *offlineButton;
@property (nonatomic, retain) IBOutlet UILabel *dealTableTitleBar;
@property (nonatomic, retain) IBOutlet UILabel *chatterTitleBar;

@property (nonatomic, retain) NSMutableArray* searchLookAhead;
@property (nonatomic, retain) IBOutlet CustomView* customView;
@property (nonatomic) SalesPadOfflineMode isOffline;
@property (nonatomic, copy) NSDate* fromDate;
@property (nonatomic, copy) NSDate* toDate;
@property (nonatomic, copy) NSDate* today;
@property (nonatomic, copy) NSDate* lastReviewedDate;
@property (nonatomic, retain) FiscalCalendar*   fiscalCalendar;


- (IBAction)changeViewBy:(id)sender;
- (IBAction)reviewedForecasts:(id)sender;
- (IBAction)selectUser:(id)sender;
-(IBAction) comment:(id)sender;
- (void) findNamesDBCallback:(NSString*) searchString;
- (void) loadForecastsFor:(User*) uid;
- (NSString*) direction:(double)lhs rhs:(double)rhs;
- (void) viewForecastFor:(User*)u startMonth:(NSDate*)startMonth endMonth:(NSDate*)endMonth viewBy:(int)viewBy;
- (Metric*) loadSummary:(User*)u startMonth:(NSDate*)startMonth endMonth:(NSDate*)endMonth snapshot:(SalesPadSnapshotType)snapshot;
- (void) updateSummary:(User*)u startMonth:(NSDate*)startMonth endMonth:(NSDate*)endMonth snapshot:(SalesPadSnapshotType)snapshot;
- (User*) loadCurrentUser;
- (User*) loadUser:(NSString*) uid;
- (void) syncHierarchy;
- (void) startSync; 
- (void) syncRoleHierarchy;
- (void) syncRoleHierarchyCallback:(ZKQueryResult *)result error:(NSError *)error context:(id)context;
- (void) syncOpportunities:(User*)u startDate:(NSDate*)s endDate:(NSDate*)e;
- (void) syncOpportunitiesCallback:(ZKQueryResult *)result error:(NSError *)error context:(id)context;
- (NSDate*) getDateFromInteger:(int) monthnumber;
- (void) updatePriorYearFor:(SalesPadSnapshotType)snapshot;
-(void) syncFiscalPeriod;
- (void) syncFiscalPeriodCallback:(ZKQueryResult*)result error:(NSError*)error context:(id)context;
- (void) setupDecorations;
- (void) loadConfig;
- (NSString*) updateTimestamp;

- (void) reachabilityChanged:(NSNotification *)notice;
- (void) goOnline;
- (void) goOffline;
- (IBAction)offlineButtonAction:(id) sender;
- (IBAction) reloadForecasts;

@end
