

#import <Foundation/Foundation.h>

@interface ZKDeletedObject : NSObject {
    NSString *Id;
    NSDate *deletedDate;
}

@property (readonly) NSString *Id;
@property (readonly) NSDate *deletedDate;

- (ZKDeletedObject *)initWithId:(NSString *)objectId deletedDate:(NSDate *)date;

@end
