//
//  DealMovement.h
//  SalesPad
//
//  Created by SP on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DealMovement:NSObject {
	BOOL deleted;
	BOOL added;
	BOOL won;
	BOOL lost;
	BOOL progressed;
	BOOL slipped;
	BOOL expanded;
	BOOL contracted;
	BOOL pushed;
	BOOL advanced;
};

@property (nonatomic) BOOL deleted;
@property (nonatomic) BOOL added;
@property (nonatomic) BOOL won;
@property (nonatomic) BOOL lost;
@property (nonatomic) BOOL progressed;
@property (nonatomic) BOOL slipped;
@property (nonatomic) BOOL expanded;
@property (nonatomic) BOOL contracted;
@property (nonatomic) BOOL pushed;
@property (nonatomic) BOOL advanced;

- (int) changed;

@end