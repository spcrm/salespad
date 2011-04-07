//
//  Database.m
//  SalesPad
//
//  Created by SP on 3/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Database.h"

@implementation Database

static sqlite3 *db = nil;

- (sqlite3*) database {
	if (db == nil) {
		NSString *path = [self createEditableCopyOfDatabaseIfNeeded];
		if (path!=nil) {
		   myAssert(sqlite3_open([path UTF8String], &db) == SQLITE_OK, 
					 @"Fatal error: cannot open database : %@", path);
		   /* const char* key = [@"BIGSecret" UTF8String];
		   sqlite3_key(db, key, strlen(key)); */
		}
	}
	return db;
}

- (NSString*)createEditableCopyOfDatabaseIfNeeded {
	//does it already exist?
	BOOL success;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"salespad.sqlite"];
	success = [fileManager fileExistsAtPath:writableDBPath];
	if (!success) {
		//file does not exist copy the default database over.
		NSString *defaultDBPath = [[NSBundle mainBundle] pathForResource:@"salespad" ofType:@"sqlite"];
		success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
		if (!success) {
			myAssert(0, @"Failed to create writable database file because %@.", [error localizedDescription]);
		}
	}
	return writableDBPath;
}

- (void) dealloc {
	[super dealloc];
}
@end
