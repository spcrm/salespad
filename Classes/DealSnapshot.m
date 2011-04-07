//
//  Opportunity.m
//  SalesPad
//
//  Created by SP on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DealSnapshot.h"


@implementation DealSnapshot

@synthesize name,opptyId, snapshot, amount,closeDate,owner,stage,nextsteps,managerNotes,senotes,description,timestamp, iswon, isclosed, probability;

- (id) initWithName:(NSString*)n amount:(double)a closeDate:(NSDate*)d stage:(NSString*)s id:(NSString*)id
{
	self = [super init];
	if (self) {
		[self setName:n];
		[self setAmount:a];
		[self setCloseDate:d];
		[self setStage:s];
		[self setOpptyId:id];
	}
	return self;
}

- (void)dealloc 
{
	[opptyId release];
	[owner release];
	[stage release];
	[nextsteps release];
	[managerNotes release];
	[name release];
	[closeDate release];
	[senotes release];
	[description release];
	[timestamp release];
	[super dealloc];
}

- (BOOL) isSameAs:(DealSnapshot *)rhs 
{
	if ([[self opptyId] compare:[rhs opptyId]] == 0) {
		return YES;
	}
	return NO;
}

@end
