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

#import "ZKMessageEnvelope.h"
#import "ZKMessageElement.h"

#define DEFAULT_NAMESPACE_URI @"urn:partner.soap.sforce.com"

@implementation ZKMessageEnvelope

@synthesize primaryNamespaceUri;

+ (ZKMessageEnvelope *)envelopeWithSessionId:(NSString *)sessionId clientId:(NSString *)clientId;
{
    ZKMessageEnvelope *envelope = [[[ZKMessageEnvelope alloc] init] autorelease];
    if (sessionId)
    {
        [envelope addSessionHeader:sessionId];
    }
    if (clientId)
    {
        [envelope addCallOptions:clientId];
    }
         
    return envelope;
}

- (id)initWithPrimaryNamespaceUri:(NSString *)uri
{
    if (self = [self init])
    {
        self.primaryNamespaceUri = uri;
    }
    return self;
}

- (id)init
{
    if (self = [super init])
    {
        headerElements = [[NSMutableArray array] retain];
        bodyElements = [[NSMutableArray array] retain];
        self.primaryNamespaceUri = DEFAULT_NAMESPACE_URI;
    }
    return self;
}

- (void)dealloc
{
    [headerElements release];
    [bodyElements release];
    [super dealloc];
}

#pragma mark Properties

- (NSArray *)headerElements
{
    return [NSArray arrayWithArray:headerElements];
}

- (NSArray *)bodyElements
{
    return [NSArray arrayWithArray:bodyElements];
}

#pragma mark  Methods

- (void)addSessionHeader:(NSString *)sessionId
{
    ZKMessageElement *sessionHeaderElement = [ZKMessageElement elementWithName:@"SessionHeader" value:nil];
    [sessionHeaderElement addChildElement:[ZKMessageElement elementWithName:@"sessionId" value:sessionId]];
    [self addHeaderElement:sessionHeaderElement];
}

- (void)addCallOptions:(NSString *)clientId
{
    ZKMessageElement *sessionHeaderElement = [ZKMessageElement elementWithName:@"CallOptions" value:nil];
    [sessionHeaderElement addChildElement:[ZKMessageElement elementWithName:@"client" value:clientId]];
    [self addHeaderElement:sessionHeaderElement];
}

- (void)addEmailHeader
{
    ZKMessageElement *sessionHeaderElement = [ZKMessageElement elementWithName:@"EmailHeader" value:nil];
    [sessionHeaderElement addChildElement:[ZKMessageElement elementWithName:@"triggerUserEmail" value:@"true"]];
    [self addHeaderElement:sessionHeaderElement];
}

- (void)addHeaderElement:(ZKMessageElement *)element
{
    [headerElements addObject:element];
}

- (void)addBodyElement:(ZKMessageElement *)element
{
    [bodyElements addObject:element];
}

- (void)addBodyElementNamed:(NSString *)elementName withChildNamed:(NSString *)childElementName value:(id)childValue
{
    ZKMessageElement *childElement = [ZKMessageElement elementWithName:childElementName value:childValue];
    ZKMessageElement *bodyElement = [ZKMessageElement elementWithName:elementName value:nil];
    [bodyElement addChildElement:childElement];
    [self addBodyElement:bodyElement];
}

- (void)addUpdatesMostRecentlyUsedHeader
{
    ZKMessageElement *sessionMruHeaderElement = [ZKMessageElement elementWithName:@"MruHeader" value:nil];
    [sessionMruHeaderElement addChildElement:[ZKMessageElement elementWithName:@"updateMru" value:@"true"]];
    [self addHeaderElement:sessionMruHeaderElement];
}

- (NSString *)stringRepresentation
{
    NSMutableString *finalString = [NSMutableString stringWithCapacity:100];
    [finalString appendFormat:@"<s:Envelope xmlns:s='http://schemas.xmlsoap.org/soap/envelope/' xmlns='%@'>\n", self.primaryNamespaceUri];
    
    // Let's get the headers in here.
    [finalString appendFormat:@"\t<s:Header>\n"];
    for (ZKMessageElement *element in headerElements)
    {
        [finalString appendFormat:@"\t%@\n", [element stringRepresentation]];
    }
    [finalString appendFormat:@"\t</s:Header>\n"];
    
    // Time for some body action.
    [finalString appendFormat:@"\t<s:Body>\n"];
    for (ZKMessageElement *element in bodyElements)
    {
        [finalString appendFormat:@"\t%@\n", [element stringRepresentation]];
    }
    [finalString appendFormat:@"\t</s:Body>\n"];
    
    [finalString appendFormat:@"</s:Envelope>\n"];
    
    return finalString;
}




@end
