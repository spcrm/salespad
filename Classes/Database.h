//
//  Database.h
//  SalesPad
//
//  Created by SP on 3/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

#define myAssert(condition, format, variable) if (!(condition)) { NSLog(format, variable); assert(1==0); }
typedef enum {
	SnapshotCurrent = 2,
	SnapshotCheckpoint = 1,
	SnapshotNone = 0
} SalesPadSnapshotType;

@interface Database : NSObject {
}

- (sqlite3*) database;
- (NSString*)createEditableCopyOfDatabaseIfNeeded;
@end
