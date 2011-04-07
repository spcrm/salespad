//
//  Metric.m
//  SalesPad
//
//  Created by SP on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Metric.h"


@implementation Metric

@synthesize forecast, quota, bestcase, closed, pipeline, prioryear;

- (id) initWithQuota:(double)q forecast:(double)f bestcase:(double)b pipeline:(double)p closed:(double)c prioryear:(double)py
{
	self = [super init];
	if (self) {
		[self setForecast:f];
		[self setQuota:q];
		[self setBestcase:b];
		[self setPipeline:p];
		[self setClosed:c];
		[self setPrioryear:py];
	}
	return self;
}

- (double) coverage
{
	return pipeline/(forecast-closed);
}

- (double) growth
{
	return (forecast/prioryear - 1)*100;
}

- (double) attainment
{
	return (forecast/quota)*100;
}

- (void) dealloc
{
	[super dealloc];
}

@end
