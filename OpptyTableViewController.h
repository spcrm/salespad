//
//  TopOpptyListTableViewController.h
//  SalesPad
//
//  Created by SP on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZKSforce.h"
#import "User.h"
#import <sqlite3.h>
#import "DealDetailController.h"
#import "OpptyChatterViewController.h"
#import "Deal.h"
#import "Database.h"

@interface OpptyTableViewController : UITableViewController <DealDetailDelegate> {
	User            *currentForecastUser;
	NSDate			*startDate;
	NSDate			*endDate;
	NSMutableArray  *deals;
	sqlite3_stmt	*stmt_select;
	UIImage         *thumbsupimage;
	UIImage         *thumbsdownimage;
	
	OpptyChatterViewController *dealChatterViewController;
	DealDetailController       *dealDetailViewController;
	UIPopoverController        *popoverController;
	int             haveCurrentSnapshot;
}

@property (nonatomic, copy) User* currentForecastUser;
@property (nonatomic, copy) NSDate* startDate;
@property (nonatomic, copy) NSDate* endDate;
@property (nonatomic, copy) NSMutableArray *deals;
@property (nonatomic, copy) UIImage *thumbsupimage;
@property (nonatomic, copy) UIImage *thumbsdownimage;
@property (nonatomic, copy) IBOutlet UIPopoverController* popoverController;
@property (nonatomic) int haveCurrentSnapshot;


@property (nonatomic, retain) OpptyChatterViewController  *dealChatterViewController;
@property (nonatomic, retain) DealDetailController        *dealDetailViewController;

- (IBAction)loadDetails:(id)sender;
- (void) loadOpportunitiesFromDB:(User*)u startDate:(NSDate*)s endDate:(NSDate*)e snapshot:(SalesPadSnapshotType)currentd	previousSnapshot:(SalesPadSnapshotType) previousd;
- (id) initWithUser:(User*)u startDate:(NSDate*)s endDate:(NSDate*)e;
- (DealSnapshot*) getRow:(sqlite3_stmt*) stmt;
- (void) clearDeals;

@end
