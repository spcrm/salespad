//
//  Currency.m
//  SalesPad
//
//  Created by SP on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Currency.h"


@implementation Currency

+ (NSString*) currencyToString:(double) value 
{
	NSNumberFormatter *nF = [[[NSNumberFormatter alloc]init] autorelease];
	[nF setNumberStyle:NSNumberFormatterCurrencyStyle];
	[nF setMaximumFractionDigits:0];
	NSString* postfix = @"";
	if (value >= 10000) {
		postfix = @"K";
		value = value/1000;
	}
	if(value >= 10000) {
		postfix = @"M";
		value = value/1000;
	}
	if (value >= 10000) {
		postfix = @"B";
		value = value/1000;
	}
	return [[nF stringFromNumber:[NSNumber numberWithDouble:value]] stringByAppendingString:postfix]; 
}

- (void)dealloc {
    [super dealloc];
}


@end
