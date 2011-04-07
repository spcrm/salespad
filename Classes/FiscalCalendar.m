//
//  FiscalDate.m
//  SalesPad
//
//  Created by SP on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FiscalCalendar.h"


@implementation FiscalCalendar
@synthesize firstDayOfYear, calendar, today, lastDayOfYear, label, sfdc_formatter;

- (id)initWithFiscalStartDate:(NSDate*) date {
	self = [super init];
	if (self != nil) {
		[self setFirstDayOfYear:date];
		[self setCalendar:[NSCalendar currentCalendar]];
		[self setToday:[NSDate date]];
		[self setSfdc_formatter:[[[NSDateFormatter alloc] init] autorelease]];
		[[self sfdc_formatter] setDateFormat:@"yyyy-MM-dd"];
	}
	return self;
}


+ (NSDate*) lastDayOfMonth:(NSDate*) date {
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSRange range = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
	NSDateComponents *comps = [FiscalCalendar componentsFromDate:date];
	//NSLog(@"Number of days in %@ is %d", date, range.length);
	[comps setDay:range.length];
	return [calendar dateFromComponents:comps];
}

+ (NSDate*) firstDayOfMonth:(NSDate*) date {
	NSDateComponents* comps = [FiscalCalendar componentsFromDate:date];
	[comps setMonth:1];
	return [[NSCalendar currentCalendar] dateFromComponents:comps];	
}

- (NSDate*) dateFromSFDCDateString:(NSString*) text {
	if (text == nil) {
		return nil;
	}
	return [[self sfdc_formatter] dateFromString:text];
}

- (NSString*) stringFromSFDCDate:(NSDate*) date {
	if (date == nil) {
		return nil;
	}
	return [[self sfdc_formatter] stringFromDate:date];
}

+ (NSDateComponents*) componentsFromDate:(NSDate*) date {
	return [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
}

- (NSDate*) firstDayOfFiscalQuarter:(NSDate*) date {
	NSDateComponents *comp = [calendar components:NSMonthCalendarUnit 
															 fromDate:[self firstDayOfYear]
															   toDate:date
															  options:0];
	NSInteger fiscal_qtr = [comp month]/3;
	[comp setMonth:fiscal_qtr*3];
	return [calendar dateByAddingComponents:comp toDate:[self firstDayOfYear] options:0];	
}

- (NSDate*) lastDayOfFiscalQuarter:(NSDate*) date {
	NSDate *first_day = [self firstDayOfFiscalQuarter:date];
	NSDateComponents* comp = [[[NSDateComponents alloc]init] autorelease];
	[comp setMonth:3];
	NSDate *last_day = [calendar dateByAddingComponents:comp toDate:first_day options:0];
	return [FiscalCalendar lastDayOfMonth:last_day];
}

- (NSDate*) dateByAddingMonths:(NSInteger)months toDate:(NSDate*)date {
	NSDateComponents *comp = [[[NSDateComponents alloc]init] autorelease];
	[comp setMonth:months];
	return [calendar dateByAddingComponents:comp toDate:[self firstDayOfYear] options:0];	
}											  
	
- (NSInteger) monthIndex:(NSDate *)date {
	NSDateComponents *comps = [FiscalCalendar componentsFromDate:date];
	return [comps year]*100 + [comps month];
}

- (NSDate*) dateFromComponents:(NSDateComponents*) comps {
	return [[self calendar] dateFromComponents:comps];
}

- (NSInteger) fiscalYear {
	NSDateComponents* comps = [FiscalCalendar componentsFromDate:[self firstDayOfYear]];
	return [comps year]+1;
}

- (NSInteger) fiscalYearForDate:(NSDate*) date {
	NSDateComponents* comps = [FiscalCalendar componentsFromDate:date];
	NSInteger fy = [comps year];
	if ([comps month] > 1) {
		fy++;
	}
	return fy;
}

-(void) dealloc {
	[today release];
	[calendar release];
	[firstDayOfYear release];
	[super dealloc];
}
@end
