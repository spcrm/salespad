//
//  OpptyDetailViewController.m
//  SalesPad
//
//  Created by SP on 3/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OpptyChatterViewController.h"
#import "ChatterCell.h"
#import "ZKSforce.h"
#import "NewChatViewController.h"

@implementation OpptyChatterViewController

@synthesize deal, chatterfeed, delegate, postChatterController, postChatterPopupController;

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
    return [chatterfeed count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"ChatterCell";
    
    ChatterCell *cell = (ChatterCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if (cell == nil) {
		NSArray *topLevelObjects = [[NSBundle mainBundle] 
									loadNibNamed:@"ChatterCell" owner:nil options:nil];
		
		for (id currentObject in topLevelObjects) {
			if ([currentObject isKindOfClass:[UITableViewCell class]]) {
				cell = (ChatterCell*) currentObject;
				break;
			}
		}
    }
	
	ChatterFeed* f = [[self chatterfeed] objectAtIndex:indexPath.row];
	[cell setfeed:f];
	[[cell respond] setTag:indexPath.row];
	return cell;
}

- (CGFloat) tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	ChatterFeed *feed = [[self chatterfeed] objectAtIndex:indexPath.row];
	UIFont      *font = [UIFont systemFontOfSize:10.0];
	CGSize      constrainedToSize = CGSizeMake( tableView.frame.size.width, MAXFLOAT);
	CGSize size = [[feed body] sizeWithFont:font constrainedToSize:constrainedToSize lineBreakMode:UILineBreakModeWordWrap];
	return size.height + 30;
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

/*
 * add a new comment.
 */
- (void) postChatter:(NSString*)pid body:(NSString*)body {
	ZKSObject *post;
	
	if (pid == nil) {
		post = [ZKSObject withType:@"FeedPost"];
		[post setFieldValue:[[deal detail] opptyId] field:@"ParentId"];
		[post setFieldValue:body field:@"Body"];
	} else {
		post = [ZKSObject withType:@"FeedComment"];
		[post setFieldValue:pid field:@"FeedItemId"];
		[post setFieldValue:body field:@"CommentBody"];
	}
	[[ZKServerSwitchboard switchboard] create:[NSArray arrayWithObject:post] target:self selector:@selector(postChatterCallback:error:context:) context:nil];
}

- (void)postChatterCallback:(ZKSaveResult *)result error:(NSError *)error context:(id)context
{
	if (error) {
		NSLog(@"ERROR: %Q", error);
	} else {
		[self loadChatter];
	}

}

- (void)clearFeeds {
	[chatterfeed removeAllObjects];
	[[self tableView] reloadData];
}
	
/*
 * Load the feed.
 */
- (void) loadChatter {
	[chatterfeed removeAllObjects];
	[[self tableView] reloadData];
	
	//NSLog(@"Loading chatter for: %@", [[deal detail] opptyId]);
	[[self delegate] chatterloading:-1];
		//get the forecasts
	NSString* query = [NSString stringWithFormat:@"SELECT Id, Type, CreatedById, CreatedDate, CreatedBy.name, \
								ParentId, Parent.Name,\
								FeedPost.Body, FeedPost.Title, FeedPost.LinkUrl,\
							(SELECT Id, CommentBody, CreatedDate, \
									CreatedBy.Name \
									FROM FeedComments ORDER BY CreatedDate) \
							FROM OpportunityFeed \
					   WHERE ParentID = '%@' AND Type <> 'TrackedChange' ORDER BY CreatedDate DESC LIMIT 20", [[deal detail] opptyId]];
	
	//NSLog(@"Loading sql: %@",query);
	[[ZKServerSwitchboard switchboard] query:query target:self selector:@selector(loadChatterCallback:error:context:) context:nil];
}

- (void)loadChatterCallback:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
	NSArray* a = [result records];
	
	if (chatterfeed == nil) {
		chatterfeed = [[NSMutableArray alloc]init];
	} else {
		[chatterfeed removeAllObjects];
	}

	if (error == nil) {
		NSDateFormatter *month_name_formatter = [[[NSDateFormatter alloc] init] autorelease];
		[month_name_formatter setDateFormat:@"MMM"];
	
		for (ZKSObject* r in a) {
			//NSLog(@"Roleid: %@", r);
			NSString* fid = [r fieldValue:@"Id"];
			NSString* name = [[r fieldValue:@"CreatedBy"] fieldValue:@"Name"];
			NSString* photo = nil; //[[r fieldValue:@"CreatedBy"] fieldValue:@"FullPhotoUrl"];
			NSString* body = [[r fieldValue:@"FeedPost"] fieldValue:@"Body"];
			NSString* date = [r fieldValue:@"CreatedDate"];

			ZKQueryResult* comments = [r fieldValue:@"FeedComments"];
			if (body != nil) {
				ChatterFeed* f = [[ChatterFeed alloc] initWithContent:body cid:fid author:name photourl:photo created:date];
				[f setPid:[[deal detail] opptyId]];
				[[self chatterfeed] addObject:f];
				[f release];
				
				//also put in the feed comments.
				for (ZKSObject* c in [comments records]) {
					//NSLog(@"Comment: %@", c);
					NSString* cid = [c fieldValue:@"Id"];
					NSString* name = [[c fieldValue:@"CreatedBy"] fieldValue:@"Name"];
					NSString* photo = nil; //[[r fieldValue:@"CreatedBy"] fieldValue:@"FullPhotoUrl"];
					NSString* body = [c fieldValue:@"CommentBody"];
					NSString* date = [c fieldValue:@"CreatedDate"];
					ChatterFeed* f = [[ChatterFeed alloc] initWithContent:body cid:cid author:name photourl:photo created:date];
					[f setFid:fid]; //Comment on.
					[f setPid:[[deal detail] opptyId]];
					[[self chatterfeed] addObject:f];
					[f release];					
				}
			}
		}
	} else {
		NSLog(@"SFDC Error: %@", error);
	}
	[[self tableView] reloadData];
	[[self delegate] chatterloading:[[self chatterfeed]count]];
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
	ChatterFeed* f = [[self chatterfeed] objectAtIndex:indexPath.row];

	return (NSInteger) ([f fid] != nil)? 1: 0;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
	 */
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
	[chatterfeed release];
	self.chatterfeed = nil;
	
	[postChatterController release];
	self.postChatterController = nil;
	
	[postChatterPopupController release];
	self.postChatterPopupController = nil;
}


- (void)dealloc {
	
	[chatterfeed release];
	[delegate release];
	[deal release];
	[postChatterPopupController release];
	[postChatterController release];
    [super dealloc];
}

- (IBAction) postComment:(id) sender {
	if (postChatterController == nil) {
		postChatterController = [[NewChatViewController alloc]init];
	}
	
	if (postChatterPopupController == nil) {
		postChatterPopupController = [[UIPopoverController alloc]initWithContentViewController:postChatterController];
	}

	[postChatterController setDelegate:self];
	ChatterFeed *f = [chatterfeed objectAtIndex:[sender tag]];
	NSString *fid;
	if([f fid] == nil) {
		fid = [f cid];
	} else {
		fid = [f fid];
	}

	[postChatterController setEntity:fid];
	postChatterPopupController.popoverContentSize = CGSizeMake(435, 126);
	CGRect r = [sender frame];
	r.origin.y = 0;
	r.origin.x = 0;
	[[self postChatterPopupController] presentPopoverFromRect:r inView:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];	
}

- (void) post:(NSString*)pid body:(NSString*)body {
	[self postChatter:pid body:body];
	[postChatterPopupController dismissPopoverAnimated:YES];
}

@end

