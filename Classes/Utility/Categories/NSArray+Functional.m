//
//  NSArray+Functional.m
//  FLEX
//
//  Created by Tanner Bennett on 9/25/19.
//  Copyright © 2019 Flipboard. All rights reserved.
//

#import "NSArray+Functional.h"

#define FLEXArrayClassIsMutable(me) ([[self class] isSubclassOfClass:[NSMutableArray class]])

@implementation NSArray (Functional)

- (__kindof NSArray *)flex_mapped:(id (^)(id, NSUInteger))mapFunc {
    NSMutableArray *map = [NSMutableArray new];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id ret = mapFunc(obj, idx);
        if (ret) {
            [map addObject:ret];
        }
    }];

    if (self.count < 2048 && !FLEXArrayClassIsMutable(self)) {
        return map.copy;
    }

    return map;
}

- (__kindof NSArray *)flex_flatmapped:(NSArray *(^)(id, NSUInteger))block {
    NSMutableArray *array = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray *toAdd = block(obj, idx);
        if (toAdd) {
            [array addObjectsFromArray:toAdd];
        }
    }];

    if (array.count < 2048 && !FLEXArrayClassIsMutable(self)) {
        return array.copy;
    }

    return array;
}

- (NSArray *)flex_filtered:(BOOL (^)(id, NSUInteger))filterFunc {
    return [self flex_mapped:^id(id obj, NSUInteger idx) {
        return filterFunc(obj, idx) ? obj : nil;
    }];
}

- (void)flex_forEach:(void(^)(id, NSUInteger))block {
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj, idx);
    }];
}

+ (__kindof NSArray *)flex_forEachUpTo:(NSUInteger)bound map:(id(^)(NSUInteger))block {
    NSMutableArray *array = [NSMutableArray new];
    for (NSUInteger i = 0; i < bound; i++) {
        id obj = block(i);
        if (obj) {
            [array addObject:obj];
        }
    }

    // For performance reasons, don't copy large arrays
    if (bound < 2048 && !FLEXArrayClassIsMutable(self)) {
        return array.copy;
    }

    return array;
}

- (instancetype)sortedUsingSelector:(SEL)selector {
    if (FLEXArrayClassIsMutable(self)) {
        NSMutableArray *me = (id)self;
        [me sortUsingSelector:selector];
        return me;
    } else {
        return [self sortedArrayUsingSelector:selector];
    }
}

@end