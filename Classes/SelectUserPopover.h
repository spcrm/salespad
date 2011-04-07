//
//  SelectUserPopover.h
//  SalesPad
//
//  Created by SP on 3/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "Database.h"

@protocol SelectUserPopoverDelegate <NSObject>
- (void) switchUser:(User*)u;
@end

@interface SelectUserPopover : UITableViewController {
	id <SelectUserPopoverDelegate> delegate;
	NSMutableArray* users;
	User* foruser;
	NSMutableArray* sections;
}

@property (nonatomic,retain) NSMutableArray* users;
@property (nonatomic,retain) NSMutableArray* sections;

@property (nonatomic,retain) User* foruser;
@property (nonatomic, assign) id <SelectUserPopoverDelegate> delegate;


@end
