//
//  TopOpptyListTableViewController.m
//  SalesPad
//
//  Created by SP on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OpptyTableViewController.h"
#import "OpptyTableCell.h"
#import "Deal.h"
#import "Currency.h"
#import "DealDetailController.h"

@implementation OpptyTableViewController

@synthesize currentForecastUser, startDate, endDate, deals, dealChatterViewController;
@synthesize thumbsupimage, thumbsdownimage, popoverController,dealDetailViewController, haveCurrentSnapshot;
#pragma mark -
#pragma mark Initialization

- (id) initWithUser:(User*)u startDate:(NSDate*)s endDate:(NSDate*)e
{
	self = [super init];
	if (self) {
		[self setCurrentForecastUser:u];
		[self setStartDate:s];
		[self setEndDate:e];
		deals = [[NSMutableArray alloc]init];
		[self setThumbsupimage:[UIImage imageNamed:@"thumbsup.jpg"]];
		[self setThumbsdownimage:[UIImage imageNamed:@"thumbsdown.jpg"]];
	}
	return self;
}

- (void) clearDeals {
	[deals removeAllObjects];
	[[self tableView] reloadData];
}

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
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


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [deals count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"OpptyTableCell";
    
    OpptyTableCell *cell = (OpptyTableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if (cell == nil) {
		NSArray *topLevelObjects = [[NSBundle mainBundle] 
									loadNibNamed:@"OpptyTableCell" owner:nil options:nil];
		
		for (id currentObject in topLevelObjects) {
			if ([currentObject isKindOfClass:[UITableViewCell class]]) {
				cell = (OpptyTableCell*) currentObject;
				break;
			}
		}
    }
	
	int i = [indexPath  row];
	Deal* d = [[self deals] objectAtIndex:i];

    // Configure the cell...
    [[cell name] setText:[[d detail] name]];
    [[cell date] setText:[[[d detail] closeDate] description]];
	[[cell owner] setText:[[[d detail] owner] name]];
    [[cell stage] setText:[[d detail] stage]];
	[[cell detail] setTag:i];
	double amount = [[d detail] amount];
    [[cell amount] setText:[Currency currencyToString:amount]];
	
	if ([[d changes] changed] == 0 || [self haveCurrentSnapshot] == 0) {
		[[cell name] setTextColor:[UIColor blackColor]];
		[[cell thumb] setImage:nil];
	}else if ([[d changes] changed] > 0) {
		[[cell thumb] setImage:thumbsupimage];
		//label the oppty in green
		[[cell name] setTextColor:[UIColor colorWithRed:74.0/255.0 green:150.0/255.0 blue:107.0/255.0 alpha:1.0]];
	} else {
		[[cell thumb] setImage:thumbsdownimage];
		//label the oppty in red.
		[[cell name] setTextColor:[UIColor colorWithRed:207.0/255.0 green:89.0/255.0 blue:59.0/255.0 alpha:1.0]];		
	}

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {  
	return 50;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Deal* oppty = [[self deals] objectAtIndex:indexPath.row];
	[[self dealChatterViewController] setDeal:oppty];
	[[self dealChatterViewController] loadChatter];
	[[[self dealChatterViewController] tableView] reloadData];

}

- (IBAction)loadDetails:(id)sender {
	int i = [sender tag];
	Deal* oppty = [[self deals] objectAtIndex:i];
	
	if (dealDetailViewController == nil) {
		DealDetailController *vc = [[DealDetailController alloc] init];
		[vc setDelegate:self];
		[vc setDeal:oppty];
		[self setDealDetailViewController:vc];
		[vc release];
	}
	[[self dealDetailViewController] setDeal:oppty];

	if (popoverController == nil) {
		popoverController = [[UIPopoverController alloc]initWithContentViewController:[self dealDetailViewController]];
	} else {
		[popoverController setContentViewController:[self dealDetailViewController]];
	}
	[dealDetailViewController showDeal];
	
	popoverController.popoverContentSize = CGSizeMake(600, 800);
	CGRect r = [[sender superview] frame];
	r.origin.x = -r.size.width;
	r.origin.y = -r.size.height/2;
	[self.popoverController presentPopoverFromRect:r inView:sender permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];	
}

- (void) reviewedDeal {
	[[self popoverController ]dismissPopoverAnimated:YES];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	[popoverController release];
	self.popoverController = nil;
	
	[dealDetailViewController release];
	self.dealDetailViewController = nil;
	
	[dealChatterViewController release];
	self.dealChatterViewController = nil;
}


- (void)dealloc {
	[popoverController release];
	[thumbsupimage release];
	[thumbsdownimage release];
	[currentForecastUser release];
	[startDate release];
	[endDate release];
	[deals release];
	[dealChatterViewController release];
    [dealDetailViewController release];
	[super dealloc];
}


#pragma mark -
#pragma mark databaseoperations
- (void) loadOpportunitiesFromDB:(User*)u startDate:(NSDate*)s endDate:(NSDate*)e snapshot:(SalesPadSnapshotType)currentd	previousSnapshot:(SalesPadSnapshotType) previousd
{
	NSDateFormatter *date_formatter = [[[NSDateFormatter alloc] init] autorelease];
	[date_formatter setDateFormat:@"yyyy-MM-dd"];
	[deals removeAllObjects];
	Database* db = [[[Database alloc]init] autorelease];
	
	//Do we have a current snapshot? IF not then do not show "diff".
	NSString *qry = [NSString stringWithFormat:@"SELECT count(*) FROM user WHERE snapshot=%d AND id='%@'", currentd, [u uid]];
	sqlite3_stmt *stmt;
	myAssert(sqlite3_prepare_v2([db database], [qry UTF8String], [qry length], &stmt, NULL) == SQLITE_OK, @"FATAL DB error: %@", qry);
	int havecurrentsnapshot = 0;
	if (sqlite3_step(stmt) == SQLITE_ROW) {
		//have a current snapshot?
		havecurrentsnapshot = sqlite3_column_int(stmt, 0);
	}
	sqlite3_finalize(stmt);
	[self setHaveCurrentSnapshot:havecurrentsnapshot];
	
	if (!stmt_select) {
		qry = [NSString stringWithFormat:@"SELECT deals.id,deals.name,closedate,stage,amount,ownername,nextsteps,notes,senotes,description,isclosed,iswon,updated,probability,ownerid,snapshot FROM deals,roles \
						 WHERE julianday(closedate) BETWEEN julianday(?1) AND julianday(?2) AND (snapshot=?3 OR snapshot=?4) \
						 AND deals.roleid=roles.id AND ?5 IN (lvl0,lvl1,lvl2,lvl3,lvl4,lvl5,lvl6,lvl7,lvl8,lvl9,lvl10,lvl11,lvl12) \
													ORDER BY deals.id ASC, snapshot DESC" ];
		
		//NSLog(@"DEAL Filter: %@", qry);
		myAssert(sqlite3_prepare_v2([db database], [qry UTF8String], -1, &stmt_select, NULL) == SQLITE_OK, @"FATAL DB error: %@", qry);
	}
	
	NSString* start_date = [date_formatter stringFromDate:s];
	NSString* end_date = [date_formatter stringFromDate:e];
	NSString* rid = [u rid];
	
	sqlite3_bind_text(stmt_select, 1, [start_date UTF8String], [start_date length], SQLITE_STATIC);
	sqlite3_bind_text(stmt_select, 2, [end_date UTF8String], [end_date length], SQLITE_STATIC);
	sqlite3_bind_int(stmt_select, 3, currentd);
	sqlite3_bind_int(stmt_select, 4, previousd);
	sqlite3_bind_text(stmt_select, 5, [rid UTF8String], [rid length], SQLITE_STATIC);

	DealSnapshot* current = nil;
	DealSnapshot* previous = nil;
	current = [self getRow:stmt_select];
	
	while (current != nil) {
		Deal* d = nil;
		previous = [self getRow:stmt_select];
		
		if ([current isSameAs:previous]) {
			d = [[Deal alloc] initWithDeals:current previous:previous];
			current = [self getRow:stmt_select];
		} else {
			if ([current snapshot] == currentd) {
				//New deal - add in only if this is open.
				if ([current isclosed] == 0) {
					d = [[Deal alloc] initWithDeals:current previous:nil];
				}
			} else {
				d = [[Deal alloc] initWithDeals:nil previous:current];
			}
			current = previous;
		}
		if (d != nil) {
			[[self deals] addObject:d];
			[d release];
		}
	}
	
	[[self deals] sortUsingSelector:@selector(compare:)];	
	sqlite3_reset(stmt_select);
	sqlite3_clear_bindings(stmt_select);
	[[self tableView] reloadData];
}

	
- (DealSnapshot*) getRow:(sqlite3_stmt*) stmt {
	NSDateFormatter *date_formatter = [[[NSDateFormatter alloc] init] autorelease];
	[date_formatter setDateFormat:@"yyyy-MM-dd"];
	DealSnapshot* o= nil;
	
	if (sqlite3_step(stmt_select) == SQLITE_ROW) {
		const char* id = (const char*)sqlite3_column_text(stmt_select, 0);
		const char* stage = (const char*)sqlite3_column_text(stmt_select, 3);
		const char* closedate = (const char*)sqlite3_column_text(stmt_select, 2);
		const char* name = (const char*)sqlite3_column_text(stmt_select, 1);
		const char* next = (const char*)sqlite3_column_text(stmt_select, 6);
		const char* notes = (const char*)sqlite3_column_text(stmt_select, 7);	
		const char* senotes = (const char*)sqlite3_column_text(stmt_select, 8);		
		const char* desc = (const char*)sqlite3_column_text(stmt_select, 9);	
		const int closed = sqlite3_column_int(stmt_select, 10);	
		const int won = sqlite3_column_int(stmt_select, 11);	
		const char* updated = (const char*)sqlite3_column_text(stmt_select, 12);
		const double amount = sqlite3_column_double(stmt_select, 4);
		const char* owner = (const char*)sqlite3_column_text(stmt_select, 5);
		const char* ownerid = (const char*)sqlite3_column_text(stmt_select, 14);
		const double probability = sqlite3_column_double(stmt_select, 13);
		const int snapshot = sqlite3_column_int(stmt_select, 15);

		NSString* n = [[[NSString alloc]initWithUTF8String:name] autorelease];
		NSDate* d = [date_formatter dateFromString:[[[NSString alloc] initWithUTF8String:closedate] autorelease]];
		NSString* s =  [[[NSString alloc]initWithUTF8String:stage] autorelease];
		NSString* i = [[[NSString alloc]initWithUTF8String:id] autorelease];
		NSString* timestamp = [[[NSString alloc]initWithUTF8String:updated] autorelease];
		NSString* sowner = [[[NSString alloc]initWithUTF8String:owner] autorelease];
		NSString* sownerid = [[[NSString alloc]initWithUTF8String:ownerid] autorelease];

		
		o = [[[DealSnapshot alloc] initWithName:n amount:amount closeDate:d stage:s id:i] autorelease];
		
		if(next!=NULL) {
			NSString* nx = [[[NSString alloc]initWithUTF8String:next] autorelease];
			[o setNextsteps:nx];
		}
		if (notes!=NULL) {
			NSString* no = [[[NSString alloc]initWithUTF8String:notes] autorelease];
			[o setManagerNotes:no];
		}
		
		
		if (senotes!=NULL) {
			NSString* se = [[[NSString alloc]initWithUTF8String:senotes] autorelease];
			[o setSenotes:se];
		}
		
		if (desc!=NULL) {
			NSString* de = [[[NSString alloc]initWithUTF8String:desc] autorelease];
			[o setDescription:de];
		}		
		
		[o setProbability:probability];
		[o setOwner:[[[User alloc] initWithUser:sownerid name:sowner] autorelease]];
		[o setTimestamp:timestamp];
		[o setSnapshot:snapshot];
		[o setIswon:won];
		[o setIsclosed:closed];
	}
	return o;
}

@end

