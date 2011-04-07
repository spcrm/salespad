//
//  Deal.h
//  SalesPad
//
//  Created by SP on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DealSnapshot.h"
#import "DealMovement.h"

@interface Deal : NSObject {
	DealSnapshot* current;
	DealSnapshot* previous;
}

@property (nonatomic,retain) DealSnapshot* current;
@property (nonatomic,retain) DealSnapshot* previous;

- (id) initWithDeals:(DealSnapshot*)current previous:(DealSnapshot*)previous;
- (DealSnapshot*) detail;
- (double) dealsizeanytime;
- (NSComparisonResult)compare:(id)otherObject;
- (DealMovement*) changes;

@end
