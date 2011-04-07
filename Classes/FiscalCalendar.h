//
//  FiscalDate.h
//  SalesPad
//
//  Created by SP on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FiscalCalendar : NSObject {
	NSDate* firstDayOfYear;
	NSDate* lastDayOfYear;
	NSString *label;
	NSCalendar* calendar;
	NSDate* today;
	NSDateFormatter* sfdc_formatter;
}
@property (nonatomic,copy) NSDate *firstDayOfYear;
@property (nonatomic,copy) NSDate *lastDayOfYear;
@property (nonatomic,copy) NSString *label;

@property (nonatomic,copy) NSCalendar *calendar;
@property (nonatomic,copy) NSDate *today;
@property (nonatomic,copy) NSDateFormatter *sfdc_formatter;

+ (NSDate*) lastDayOfMonth:(NSDate*) date;
+ (NSDate*) firstDayOfMonth:(NSDate*) date;
- (NSDate*) firstDayOfFiscalQuarter:(NSDate*) date;
- (NSDate*) lastDayOfFiscalQuarter:(NSDate*) date;
- (NSDate*) dateByAddingMonths:(NSInteger)months toDate:(NSDate*)date;
- (NSInteger) monthIndex:(NSDate*) date;
- (id)initWithFiscalStartDate:(NSDate*) date;
- (NSDate*) dateFromComponents:(NSDateComponents*) comps;
+ (NSDateComponents*) componentsFromDate:(NSDate*) date;
- (NSInteger) fiscalYear;
- (NSInteger) fiscalYearForDate:(NSDate*) date;
- (NSDate*) dateFromSFDCDateString:(NSString*) text;
- (NSString*) stringFromSFDCDate:(NSDate*) date;
@end
