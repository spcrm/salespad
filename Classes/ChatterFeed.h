//
//  ChatterFeed.h
//  SalesPad
//
//  Created by SP on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatterFeed : NSObject {
	NSString* body;
	NSString* cid;
	NSString* date;
	NSString* author;
	NSString* photourl;
	NSString* pid;
	NSString* fid;
}

@property (nonatomic,copy) NSString *body;
@property (nonatomic,copy) NSString *cid;
@property (nonatomic,copy) NSString *date;
@property (nonatomic,copy) NSString *author;
@property (nonatomic,copy) NSString *photourl;
@property (nonatomic,copy) NSString *pid;
@property (nonatomic,copy) NSString *fid;

-(id) initWithContent:(NSString*)body cid:(NSString*)cid author:(NSString*)name photourl:(NSString*)photo created:(NSString*)date;

@end
