// Copyright (c) 2010 Rick Fillion
//
// Permission is hereby granted, free of charge, to any person obtaining a 
// copy of this software and associated documentation files (the "Software"), 
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense, 
// and/or sell copies of the Software, and to permit persons to whom the 
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included 
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN 
// THE SOFTWARE.
//

#import "ZKEmailMessage.h"

@interface ZKEmailMessage (Private)

- (NSString *)_priorityStringForValue:(ZKEmailMessagePriority)priority;
- (ZKEmailMessagePriority)_priorityValueForName:(NSString *)name;

@end


@implementation ZKEmailMessage

- (id)init
{
    if (self = [super initWithType:@"SingleEmailMessage"])
    {
        self.bccSender = NO;
        self.priority = ZKEmailMessagePriorityNormal;
        self.subject = @"No Subject";
        self.useSignature = YES;
        self.targetObjectId = @"";
        self.plainTextBody = @"";
    }
    return self;
}

- (BOOL)bccSender
{
    return [super boolValue:@"bccSender"];;
}

- (void)setBccSender:(BOOL)bccSender
{
    [super setFieldValue:bccSender?@"true":@"false" field:@"bccSender"];
}

- (ZKEmailMessagePriority)priority
{
    return [self _priorityValueForName:[super fieldValue:@"emailPriority"]];
}

- (void)setPriority:(ZKEmailMessagePriority)newPriority
{
    if (newPriority == ZKEmailMessagePriorityLow || newPriority == ZKEmailMessagePriorityNormal || newPriority == ZKEmailMessagePriorityHigh)
    {
        [super setFieldValue:[self _priorityStringForValue:newPriority] field:@"emailPriority"];
    }
    else {
        NSLog(@"can't set priority to %d, not a valid value.", newPriority);
    }
}

- (NSString *)subject
{
    return [super fieldValue:@"subject"];
}

- (void)setSubject:(NSString *)subject
{
    [super setFieldValue:subject field:@"subject"];
}

- (BOOL)useSignature
{
    return [super boolValue:@"useSignature"];;
}

- (void)setUseSignature:(BOOL)useSignature
{
    [super setFieldValue:useSignature?@"true":@"false" field:@"useSignature"];
}

- (NSString *)targetObjectId
{
    return [super fieldValue:@"targetObjectId"];
}

- (void)setTargetObjectId:(NSString *)targetObjectId
{
    [super setFieldValue:targetObjectId field:@"targetObjectId"];
}

- (NSString *)plainTextBody
{
    return [super fieldValue:@"plainTextBody"];
}

- (void)setPlainTextBody:(NSString *)plainTextBody
{
    [super setFieldValue:plainTextBody field:@"plainTextBody"];
}


#pragma mark Private

- (NSString *)_priorityStringForValue:(ZKEmailMessagePriority)priority
{
    NSArray *names = [NSArray arrayWithObjects:@"Lowest", @"Low", @"Normal", @"High", @"Highest", nil];
    return [names objectAtIndex:priority];
}

- (ZKEmailMessagePriority)_priorityValueForName:(NSString *)name
{
    NSArray *names = [NSArray arrayWithObjects:@"Lowest", @"Low", @"Normal", @"High", @"Highest", nil];
    return [names indexOfObject:name];
}

@end
