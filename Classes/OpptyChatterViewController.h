//
//  OpptyDetailViewController.h
//  SalesPad
//
//  Created by SP on 3/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Deal.h"
#import "ZKSforce.h"
#import "NewChatViewController.h"

@protocol ChatterDelegate<NSObject>
- (void) chatterloading:(int) isloading;
@end

@interface OpptyChatterViewController : UITableViewController <NewChatterPostDelegate> {
	Deal           *deal;
	NSMutableArray *chatterfeed;
	NewChatViewController *postChatterController;
	UIPopoverController   *postChatterPopupController;
	id <ChatterDelegate> delegate;
}

@property (nonatomic,retain) Deal           *deal;
@property (nonatomic,retain) NSMutableArray *chatterfeed;
@property (nonatomic,retain) id <ChatterDelegate> delegate;
@property (nonatomic,retain) NewChatViewController *postChatterController;
@property (nonatomic,retain) UIPopoverController   *postChatterPopupController;


- (void) loadChatter;
- (void) loadChatterCallback:(ZKQueryResult *)result error:(NSError *)error context:(id)context;
- (void) postChatter:(NSString*)pid body:(NSString*)body;
- (void) postChatterCallback:(ZKSaveResult *)result error:(NSError *)error context:(id)context;
- (void) clearFeeds;
- (IBAction) postComment:(id) sender;

@end
