//
//  User.m
//  SalesPad
//
//  Created by SP on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "User.h"


@implementation User

@synthesize uid, mid, name, rid, db;

- (id) initWithUser:(NSString *)u name:(NSString *)n
{
	self = [super init];
	
	if (self) {
		[self setUid:u];
		[self setName:n];
		Database* database = [[Database alloc]init];
		[self setDb:database];
		[database release];
	}
	return self;
}

- (BOOL) cached:(SalesPadSnapshotType) timestamp {
	sqlite3_stmt *stmt;
	BOOL cached = NO;
	int count = 0;
	
	NSString *sql = [NSString stringWithFormat:@"SELECT count(*) FROM User WHERE Id='%@' AND snapshot=%d", [self uid], timestamp];
	sqlite3_prepare_v2([db database], [sql UTF8String], [sql length], &stmt, NULL);
	if (sqlite3_step(stmt) == SQLITE_ROW) {
		count = sqlite3_column_int(stmt, 0);
	}
	cached = count > 0;
	sqlite3_finalize(stmt);
	return cached;
}

- (BOOL) partialcached:(SalesPadSnapshotType) timestamp {
	sqlite3_stmt *stmt;
	BOOL cached = NO;
	int count = 0;
	
	NSString *sql = [NSString stringWithFormat:@"SELECT count(*) FROM Forecasts WHERE uid='%@' AND snapshot=%d", [self uid], timestamp];
	sqlite3_prepare_v2([db database], [sql UTF8String], [sql length], &stmt, NULL);
	if (sqlite3_step(stmt) == SQLITE_ROW) {
		count = sqlite3_column_int(stmt, 0);
	}
	cached = count > 0;
	sqlite3_finalize(stmt);
	return cached;
}
	
/*
- (void) setCached:(NSString*) timestamp snapshot:(SalesPadSnapshotType) snapshot {
	char* errmsg;
	NSString *sql = [NSString stringWithFormat:@"INSERT INTO User WHERE (Id,rid,LatestSnapshotDate,name,currentuser,snapshot) \
					 VALUES ('%@', '%@', '%@', '%@', 0, %d", 
					 [self uid], [self rid], timestamp, [self name], snapshot];
	NSAssert1(sqlite3_exec([db database], [sql UTF8String], NULL, NULL, &errmsg) == SQLITE_OK, @"FATAL DB error: %@", sql);
}
 */

- (void) setActive:(NSString*) timestamp snapshot:(SalesPadSnapshotType)snapshot {
	char* errmsg;
	NSString* sql = [NSString stringWithFormat:@"DELETE FROM User WHERE Id='%@' AND snapshot=%d", 
					 [self uid], snapshot];
	sqlite3_exec([db database], [sql UTF8String], NULL, NULL, &errmsg);
	assert(errmsg == nil);
	
	sql = [NSString stringWithFormat:@"UPDATE User SET currentuser=0"];
	sqlite3_exec([db database], [sql UTF8String], NULL, NULL, &errmsg);
	assert(errmsg == nil);
	
	sql = [NSString stringWithFormat:@"INSERT INTO User (Id,rid,LatestSnapshotDate,name,currentuser,snapshot) \
		   VALUES ('%@', '%@', '%@', '%@', 1, %d)", 
		   [self uid], [self rid], timestamp, [self name], snapshot];
	sqlite3_exec([db database], [sql UTF8String], NULL, NULL, &errmsg);
	assert(errmsg == nil);
}


- (void) dealloc
{
	[uid release];
	[name release];
	[rid release];
	[mid release];
	[db release];
	[super dealloc];
}
@end
