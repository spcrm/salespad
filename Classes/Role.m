//
//  Role.m
//  SalesPad
//
//  Created by SP on 3/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Role.h"


@implementation Role
@synthesize rid,pid,isLeaf,parent;

/* if we are to keep track of children. 
- (NSMutableArray*) family {
	NSMutableArray* f = [[NSMutableArray alloc]init];
	for(Node* n in [self children]) {
		[f addObjectsFromArray:[n family]];
	}
	return f;
}*/

-(id) initWithId:(NSString*)r parent:(NSString*)p
{
	self = [super init];
	if (self) {
		[self setIsLeaf:NO];
		[self setPid:p];
		[self setRid:r];
		[self setParent:nil];
	}
	return self;
}

- (NSMutableArray*) path {
	NSMutableArray* p = [[[NSMutableArray alloc]init] autorelease];
	Role* n = self;
	while(n != nil) {
		[p addObject:[n rid]];
		n = [n parent];
	}
	return p;
}

-(void) dealloc  {
	[rid release];
	[pid release];
	[parent release];
	[super dealloc];
}

@end
