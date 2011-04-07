//
//  Metric.h
//  SalesPad
//
//  Created by SP on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Metric : NSObject {
	double forecast;
	double quota;
	double bestcase;
	double closed;
	double prioryear;
	double pipeline;
}

@property (nonatomic) double forecast;
@property (nonatomic) double quota;
@property (nonatomic) double bestcase;
@property (nonatomic) double closed;
@property (nonatomic) double prioryear;
@property (nonatomic) double pipeline;

- (id) initWithQuota:(double)q forecast:(double)f bestcase:(double)b pipeline:(double)p closed:(double)c prioryear:(double)py;

- (double) coverage;
- (double) attainment;
- (double) growth;

@end
