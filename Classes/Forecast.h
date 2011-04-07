//
//  Forecast.h
//  SalesPad
//
//  Created by SP on 3/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Forecast : NSObject {
	int forecastAmt;
	int bestcaseAmt;
	int pipelineAmt;
	double closedAmt;
	int priorYearAmt;
	NSString *uid;
	NSString *period;
	int	fiscalyear;
}

@property (nonatomic,copy) NSString *uid;
@property (nonatomic,copy) NSString *period;
@property (nonatomic) int forecastAmt;
@property (nonatomic) int bestcaseAmt;
@property (nonatomic) int pipelineAmt;
@property (nonatomic) int priorYearAmt;
@property (nonatomic) int fiscalyear;
@property (nonatomic) double closedAmt;

- (id) initWithForecast:(NSString*)uid 
				 period:(NSString*)period 
			forecastAmt:(int)fc 
			bestcaseAmt:(int)bc 
			pipelineAmt:(int)pl 
			  closedAmt:(double)cl	
		   priorYearAmt:(int)py;

- (id) initWithClosedFor:(NSString*)uid period:(NSString*)period closed:(double)closed FY:(int)fy; 
@end
