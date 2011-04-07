//
//  Forecast.m
//  SalesPad
//
//  Created by SP on 3/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Forecast.h"


@implementation Forecast
@synthesize period, uid, forecastAmt,bestcaseAmt,pipelineAmt,closedAmt,priorYearAmt,fiscalyear;

- (id) initWithClosedFor:(NSString*)u period:(NSString*)p closed:(double)closed FY:(int)fy
{
	self = [super init];
	if (self != nil) {
		[self setUid:u];
		[self setPeriod:p];
		[self setClosedAmt:closed];
		[self setFiscalyear:fy];
	}
	return self;
}
						 

- (id) initWithForecast:(NSString*)u 
				 period:(NSString*)p 
			forecastAmt:(int)fc 
			bestcaseAmt:(int)bc 
			pipelineAmt:(int)pl 
			  closedAmt:(double)cl	
		   priorYearAmt:(int)py 
{
	self = [super init];
	if (!self) {
		return nil;
	}
	
	[self setUid:u];
	[self setPeriod:p];
	[self setForecastAmt:fc];
	[self setBestcaseAmt:bc];
	[self setPipelineAmt:pl];
	[self setClosedAmt:cl];
	[self setPriorYearAmt:py];
	
	return self;
}

- (void) dealloc {
	[uid release];
	[period release];
	[super dealloc];
}


@end
