//
//  SelectUserPopover.m
//  SalesPad
//
//  Created by SP on 3/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SelectUserPopover.h"


@implementation SelectUserPopover
@synthesize users, foruser, delegate, sections;

#pragma mark -
#pragma mark Initialization

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


- (void)viewDidLoad {
    [super viewDidLoad];
	if ([self users] == nil) {
		NSMutableArray* m = [[NSMutableArray alloc] init];
		[self setUsers:m];
		[m release];
		m = [[NSMutableArray alloc] init];
		[self setSections:m];
		[m release];
	}
	[[self users] removeAllObjects];
	[[self sections] removeAllObjects];
	
	[sections addObject:[NSNumber numberWithInt:0]];
	
	Database* db = [[[Database alloc]init] autorelease];
	sqlite3_stmt *stmt;
	User* u = [[[User alloc] initWithUser:nil name:@"My Forecast"] autorelease];
	[users addObject:u];
	[sections addObject:[NSNumber numberWithInt:[users count]]];
	
	//load managers manager
	NSString *sql = [NSString stringWithFormat:@"SELECT DISTINCT p.uid,p.name,p.rid FROM forecasts p JOIN forecasts c ON c.mid=p.uid WHERE c.uid='%@' ORDER BY p.name ASC, p.uid ASC", [[self foruser] uid]];
	assert(sqlite3_prepare_v2([db database], [sql UTF8String], [sql length], &stmt, NULL) == SQLITE_OK);
	while (sqlite3_step(stmt) == SQLITE_ROW) {
		const char* cuid = (const char*) sqlite3_column_text(stmt, 0);
		if (cuid != nil) {
			const char* cname = (const char*) sqlite3_column_text(stmt, 1);
			const char* crid = (const char*) sqlite3_column_text(stmt, 2);
			NSString* uid = [[[NSString alloc] initWithUTF8String:cuid] autorelease];
			NSString* name = [[[NSString alloc] initWithUTF8String:cname] autorelease];
			NSString* rid = [[[NSString alloc] initWithUTF8String:crid] autorelease];
			User* u = [[[User alloc] initWithUser:uid name:name] autorelease];
			[u setRid:rid];
			[users addObject:u];
		}
	}
	[sections addObject:[NSNumber numberWithInt:[users count]]];
	sqlite3_finalize(stmt);	

	//load managers siblings.
	sql = [NSString stringWithFormat:@"SELECT DISTINCT p.uid,p.name,p.rid FROM forecasts p JOIN forecasts c ON c.mid=p.mid WHERE c.uid='%@' ORDER BY p.name ASC, p.uid ASC", [[self foruser] uid]];
	assert(sqlite3_prepare_v2([db database], [sql UTF8String], [sql length], &stmt, NULL) == SQLITE_OK);
	while (sqlite3_step(stmt) == SQLITE_ROW) {
		const char* cuid = (const char*) sqlite3_column_text(stmt, 0);
		if (cuid != nil) {
			const char* cname = (const char*) sqlite3_column_text(stmt, 1);
			const char* crid = (const char*) sqlite3_column_text(stmt, 2);
			NSString* uid = [[[NSString alloc] initWithUTF8String:cuid] autorelease];
			NSString* name = [[[NSString alloc] initWithUTF8String:cname] autorelease];
			NSString* rid = [[[NSString alloc] initWithUTF8String:crid] autorelease];
			User* u = [[[User alloc] initWithUser:uid name:name] autorelease];
			[u setRid:rid];
			[users addObject:u];
		}
	}
	[sections addObject:[NSNumber numberWithInt:[users count]]];
	sqlite3_finalize(stmt);	
	
	//Load managers directs
	sql = [NSString stringWithFormat:@"SELECT DISTINCT uid,name,rid FROM forecasts WHERE mid='%@' ORDER BY name ASC, uid ASC", [[self foruser] uid]];
	assert(sqlite3_prepare_v2([db database], [sql UTF8String], [sql length], &stmt, NULL) == SQLITE_OK);
	
	while (sqlite3_step(stmt) == SQLITE_ROW) {
		const char* cuid = (const char*) sqlite3_column_text(stmt, 0);
		if (cuid != nil) {
			const char* cname = (const char*) sqlite3_column_text(stmt, 1);
			const char* crid = (const char*) sqlite3_column_text(stmt, 2);
			NSString* uid = [[[NSString alloc] initWithUTF8String:cuid] autorelease];
			NSString* name = [[[NSString alloc] initWithUTF8String:cname] autorelease];
			NSString* rid = [[[NSString alloc] initWithUTF8String:crid] autorelease];
			User* u = [[[User alloc] initWithUser:uid name:name] autorelease];
			[u setRid:rid];
			[users addObject:u];
		}
	}
	[sections addObject:[NSNumber numberWithInt:[users count]]];
	sqlite3_finalize(stmt);
}


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
    return 4;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	int count = [[sections objectAtIndex:section+1]intValue] - [[sections objectAtIndex:section] intValue];
    return count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	int index = [[sections objectAtIndex:indexPath.section] intValue] + indexPath.row;
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    [[cell textLabel] setText:[[[self users] objectAtIndex:index] name]];
    return cell;
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


- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (NSInteger) [[[self indentlevel] objectAtIndex:indexPath.row] intValue];
}
*/

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int index = [[sections objectAtIndex:indexPath.section] intValue] + indexPath.row;
	[[self delegate] switchUser:[[self users] objectAtIndex:index]];
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
	[users release];
	[sections release];
	self.sections = nil;
	self.users = nil;
}


- (void)dealloc {
	[users release];
	[foruser release];
	[sections release];
	[delegate release];
    [super dealloc];
}


@end

