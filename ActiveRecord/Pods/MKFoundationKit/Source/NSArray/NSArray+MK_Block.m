//
//  NSArray+MK_Block.m
//  MKFoundation
//
//  Created by Michal Konturek on 10/11/2013.
//  Copyright (c) 2013 Michal Konturek. All rights reserved.
//

#import "NSArray+MK_Block.h"

@implementation NSArray (MK_Block)

- (void)mk_apply:(void (^)(id item))block {
    if (!block) return;
    
    [self enumerateObjectsWithOptions:NSEnumerationConcurrent
                           usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj);
    }];
}

- (void)mk_each:(void (^)(id item))block {
    if (!block) return;
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj);
    }];
}

- (instancetype)mk_map:(id (^)(id item))block {
    if (!block) return [[self class] array];
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id value = block(obj) ? : [NSNull null];
        [result addObject:value];
    }];
    return result;
}

- (id)mk_match:(BOOL (^)(id item))block {
    if (!block) return self;
    
    __block id result = nil;
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (block(obj)) {
            result = obj;
            *stop = YES;
        }
    }];
    
    return result;
}

- (id)mk_reduce:(id (^)(id item, id aggregate))block {
    return [self mk_reduce:nil withBlock:block];
}

- (id)mk_reduce:(id)initial withBlock:(id (^)(id item, id aggregate))block {
    if (!block) return self;
    
    __block id result = initial;
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (!result) result = obj;
        else result = block(obj, result);
    }];
    
    return result;
}

- (instancetype)mk_reject:(BOOL (^)(id item))block {
    return [self mk_select:^BOOL(id item) {
        return (!block(item));
    }];
}

- (instancetype)mk_select:(BOOL (^)(id item))block {
    if (!block) return self;
    
    NSMutableArray *result = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (block(obj)) [result addObject:obj];
    }];
    return result;
}

- (BOOL)mk_all:(BOOL (^)(id item))block {
    if (!block) return YES;
    for (id item in self) {
        if (!block(item)) return NO;
    }
    return YES;
}

- (BOOL)mk_any:(BOOL (^)(id item))block {
    if (!block) return NO;
    for (id item in self) {
        if (block(item)) return YES;
    }
    return NO;
}

- (BOOL)mk_none:(BOOL (^)(id item))block {
    return ![self mk_any:block];
}

@end
