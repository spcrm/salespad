//
//  Opportunity.h
//  SalesPad
//
//  Created by SP on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "User.h"

@interface DealSnapshot : NSObject {
	NSString* name;
	NSString* opptyId;
	double	  amount;
	NSDate*   closeDate;
	User*	  owner;
	NSString* stage;
	NSString* nextsteps;
	NSString* managerNotes;
	NSString* senotes;
	NSString* description;
	NSString* timestamp;
	int       isclosed;
	int       iswon;
	double    probability;
	int		  snapshot;
}

@property (nonatomic) int	  isclosed;
@property (nonatomic) int	  iswon;
@property (nonatomic) int	  snapshot;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* opptyId;
@property (nonatomic) double	  amount;
@property (nonatomic) double	  probability;
@property (nonatomic, copy) NSDate*   closeDate;
@property (nonatomic, retain) User*	  owner;
@property (nonatomic, copy) NSString* stage;
@property (nonatomic, copy) NSString* nextsteps;
@property (nonatomic, copy) NSString* managerNotes;
@property (nonatomic, copy) NSString* senotes;
@property (nonatomic, copy) NSString* description;
@property (nonatomic, copy) NSString* timestamp;


- (id) initWithName:(NSString*)name amount:(double)amount closeDate:(NSDate*)closeDate stage:(NSString*)stage id:(NSString*)id;
- (BOOL) isSameAs:(DealSnapshot*) rhs;
@end
