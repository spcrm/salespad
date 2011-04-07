//
//  ChatterFeed.m
//  SalesPad
//
//  Created by SP on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChatterFeed.h"


@implementation ChatterFeed

@synthesize body, cid, author, photourl, date, pid, fid;

-(id) initWithContent:(NSString*)body cid:(NSString*)cid author:(NSString*)name photourl:(NSString*)photo created:(NSString*)date
{
	self = [super init];
	if (self != nil) {
		[self setBody:body];
		[self setCid:cid];
		[self setAuthor:name];
		[self setPhotourl:photo];
		[self setDate:date];
		[self setPid:nil];
		[self setFid:nil];
	}
	return self;
}

-(void) dealloc 
{
	[body release];
	[cid release];
	[pid release];
	[fid release];
	[author release];
	[photourl release];
	[date release];
	[super dealloc];
}

@end
