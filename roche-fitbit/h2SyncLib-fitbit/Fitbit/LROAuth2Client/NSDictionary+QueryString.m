//
//  NSDictionary+QueryString.m
//  demo-pod
//
//  Created by Jason Chuang on 3/18/19.
//  Copyright © 2019 Jason Chuang. All rights reserved.
//

#import "NSDictionary+QueryString.h"
#import "NSString+QueryString.h"

@implementation NSDictionary (QueryString)

+ (NSDictionary *)dictionaryWithFormEncodedString:(NSString *)encodedString
{
    NSMutableDictionary* result = [NSMutableDictionary dictionary];
    NSArray* pairs = [encodedString componentsSeparatedByString:@"&"];
    
    for (NSString* kvp in pairs)
    {
        if ([kvp length] == 0)
            continue;
        
        NSRange pos = [kvp rangeOfString:@"="];
        NSString *key;
        NSString *val;
        
        if (pos.location == NSNotFound)
        {
            key = [kvp stringByUnescapingFromURLQuery];
            val = @"";
        }
        else
        {
            key = [[kvp substringToIndex:pos.location] stringByUnescapingFromURLQuery];
            val = [[kvp substringFromIndex:pos.location + pos.length] stringByUnescapingFromURLQuery];
        }
        
        if (!key || !val)
            continue; // I'm sure this will bite my arse one day
        
        [result setObject:val forKey:key];
    }
    return result;
}

- (NSString *)stringWithFormEncodedComponents
{
    NSMutableArray* arguments = [NSMutableArray arrayWithCapacity:[self count]];
    for (NSString* key in self)
    {
        [arguments addObject:[NSString stringWithFormat:@"%@=%@",
                              [key stringByEscapingForURLQuery],
                              [[[self objectForKey:key] description] stringByEscapingForURLQuery]]];
    }
    
    return [arguments componentsJoinedByString:@"&"];
}

@end
