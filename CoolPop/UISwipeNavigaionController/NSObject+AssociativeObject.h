//
//  NSObject+AssociativeObject.h
//  niupai
//
//  Created by Ryan Wang on 12-9-20.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (AssociativeObject)

- (id)associativeObjectForKey: (NSString *)key;
- (void)setAssociativeObject: (id)object forKey: (NSString *)key;

@end
