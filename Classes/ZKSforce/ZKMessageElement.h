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


#import <Foundation/Foundation.h>

enum _ZKMessageElementType
{
    ZKMessageElementTypePartner = 0,
    ZKMessageElementTypeEnterprise = 1,
    ZKMessageElementTypeApex = 2
};
typedef NSUInteger ZKMessageElementType;


@interface ZKMessageElement : NSObject {
    NSString *name;
    id value;
    NSMutableDictionary *attributes;
    NSMutableArray *childElements;
    ZKMessageElementType type;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, retain) id value;
@property (nonatomic, readonly) NSArray *childElements;
@property (nonatomic, assign) ZKMessageElementType type;

+ (ZKMessageElement *)elementWithName:(NSString *)aName value:(id)aValue;

- (id)initWithName:(NSString *)aName value:(id)aValue;

- (void)addAttribute:(NSString *)attributeName value:(NSString *)aValue;
- (void)addChildElement:(ZKMessageElement *)element;

- (NSString *)stringRepresentation;

@end
