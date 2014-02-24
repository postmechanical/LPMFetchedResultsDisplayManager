// LPMCellConfiguration.m
//
// Copyright (c) 2014 Lonely Planet Publications Pty. Ltd. (http://lonelyplanet.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "LPMCellConfiguration.h"

#define notSupportedMessage "This initializer is not supported by this class; please use 'initWithClass:identifier:configurationBlock:' instead."

@interface LPMCellConfiguration()

@property (strong, readwrite, nonatomic) Class cellClass;
@property (strong, readwrite, nonatomic) NSString *cellIdentifier;
@property (copy, readwrite) void(^cellConfigurationBlock)(UITableViewCell*, NSManagedObject*);

@end

@implementation LPMCellConfiguration

#pragma -
#pragma Allowed Initializer
#pragma -

- (instancetype)initWithClass:(Class)cellClass
                   identifier:(NSString*)cellIdentifier
           configurationBlock:(void(^)(UITableViewCell*, NSManagedObject*))cellConfigurationBlock
{
    if (self = [super init])
    {
        NSAssert(cellClass, @"'cellClass' must not be nil.");
        _cellClass = cellClass;
        
        NSAssert(cellClass, @"'cellIdentifier' must not be nil.");
        _cellIdentifier = cellIdentifier;
        
        NSAssert(cellConfigurationBlock, @"'cellConfigurationBlock' must not be nil.");
        _cellConfigurationBlock = cellConfigurationBlock;
    }
    
    return self;
}

#pragma -
#pragma Disallowed Initializers
#pragma -

- (instancetype)init __attribute__((unavailable(notSupportedMessage)))
{
    NSAssert(false,[NSString stringWithCString:notSupportedMessage encoding:NSUTF8StringEncoding]);
    return nil;
}

+ (instancetype)new __attribute__((unavailable(notSupportedMessage)))
{
    NSAssert(false,[NSString stringWithCString:notSupportedMessage encoding:NSUTF8StringEncoding]);
    return nil;
}

@end
