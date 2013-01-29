//
//  NSObject+AssociativeObject.m
//  niupai
//
//  Created by Ryan Wang on 12-9-20.
//
//

#import "NSObject+AssociativeObject.h"
#import <objc/runtime.h>

@implementation NSObject (AssociativeObject)

static char associativeObjectsKey;

- (id)associativeObjectForKey: (NSString *)key {
    NSMutableDictionary *dict = objc_getAssociatedObject(self, &associativeObjectsKey);
    return [dict objectForKey: key];
}

- (void)setAssociativeObject: (id)object forKey: (NSString *)key {
    NSMutableDictionary *dict = objc_getAssociatedObject(self, &associativeObjectsKey);
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &associativeObjectsKey, dict, OBJC_ASSOCIATION_RETAIN);
    }
    
    if (object == nil) {
        [dict removeObjectForKey:key];
    } else {
        [dict setObject: object forKey: key];
    }
}

@end
