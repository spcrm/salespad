//
//  Role.h
//  SalesPad
//
//  Created by SP on 3/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Role : NSObject {
		NSString*       rid;
		NSString*       pid;
		Role*           parent;
		BOOL            isLeaf;
};

@property(nonatomic,copy) NSString* rid;
@property(nonatomic,copy) NSString* pid;
@property(nonatomic,retain) Role* parent;
@property(nonatomic) BOOL isLeaf;

-(id) initWithId:(NSString*)rid parent:(NSString*)pid;
-(NSMutableArray*) path;
	
@end
