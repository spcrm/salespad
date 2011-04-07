//
//  User.h
//  SalesPad
//
//  Created by SP on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Database.h"

@interface User : NSObject {
	NSString* uid;
	NSString* mid;
	NSString* rid;
	NSString* name;
	Database* db;
}

@property (nonatomic,copy) NSString* uid;
@property (nonatomic,copy) NSString* mid;
@property (nonatomic,copy) NSString* name;
@property (nonatomic,copy) NSString* rid;
@property (nonatomic,retain) Database* db;

- (id) initWithUser:(NSString*)u name:(NSString*)n; 
- (BOOL) cached:(SalesPadSnapshotType) snapshot;
- (BOOL) partialcached:(SalesPadSnapshotType) timestamp;
/*
- (void) setCached:(NSString*) timestamp snapshot:(SalesPadSnapshotType) snapshot;
 */
- (void) setActive:(NSString*) timestamp snapshot:(SalesPadSnapshotType) snapshot;
@end
