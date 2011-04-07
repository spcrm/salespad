//
//  DealMovement.m
//  SalesPad
//
//  Created by SP on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DealMovement.h"

@implementation DealMovement
@synthesize deleted,added,won,lost,progressed,slipped,expanded,contracted,pushed, advanced;

- (id) init {
	self = [super init];
	if (self) {
		deleted = NO;
		lost = NO;
		slipped = NO;
		contracted = NO;
		pushed = NO;
		added = NO;
		won = NO;
		progressed = NO;
		expanded = NO;
		advanced = NO;
	}
	return self;
}
- (int) changed {
	if (deleted | lost | slipped | contracted | pushed) {
		return -1;
	}
	
	if (added | won | progressed | expanded | advanced) {
		return 1;
	}
	
	return 0;
}
@end
