//
//  Deal.m
//  SalesPad
//
//  Created by SP on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Deal.h"


@implementation Deal

@synthesize current, previous;

- (id) initWithDeals:(DealSnapshot*)curr previous:(DealSnapshot*)prev
{
	self = [super init];
	if(self != nil) {
		[self setCurrent:curr];
		[self setPrevious:prev];
	}
	return self;
}

- (DealSnapshot*) detail {
	if ([self current] == nil) {
		return [self previous];
	}
	return current;
}

#define max(a,b) a > b? a: b;

- (double) dealsizeanytime {
	double dealsize = 0;
	if ([self current]!= nil) {
		dealsize = [[self current] amount];
	}
	if ([self previous]!= nil) {
		dealsize = max(dealsize,[[self previous] amount]);
	}
	
	return dealsize;
}

- (void) dealloc {
	[current release];
	[previous release];
	[super dealloc];
}

- (NSComparisonResult)compare:(id)otherObject {
	double lhs, rhs;
	lhs = [self dealsizeanytime];
	rhs = [otherObject dealsizeanytime];
	if (lhs<rhs) {
		return NSOrderedDescending;
	} else if (lhs > rhs) {
		return NSOrderedAscending;
	}
    return NSOrderedSame;
}


- (DealMovement*) changes {
	DealMovement* change = [[[DealMovement alloc]init] autorelease];
	
	if (current == nil) {
		change.deleted = YES;
	} else if (previous == nil) {
		change.added = YES;
	}
	
	if (current!=nil && previous != nil) {
		if (![previous isclosed]) {
			if ([current isclosed]) {
				if ([current iswon]) {
					change.won = YES;
				} else {
					change.lost = YES;
				}
			} else if ([current probability] > [previous probability]) {
				change.progressed = YES; //good
			} else if ([current probability] < [previous probability]) {
				change.slipped = YES; //warning
			}
		 
			if ([current amount] > [previous amount]) {
				change.expanded = YES; //good
			} else if ([current amount] < [previous amount]) {
				change.contracted = YES; //warning
			}
		
			if ([[current closeDate] compare:[previous closeDate]] == NSOrderedDescending) {
				change.pushed = YES; //warning
			} else if ([[current closeDate] compare:[previous closeDate]] == NSOrderedAscending) {
				change.advanced = YES; //good
			}
		}
	}
	
	return change;
}
				
					
@end
