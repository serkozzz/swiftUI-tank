#import "SafeKVC.h"

@implementation SafeKVC

+ (id _Nullable)valueForKey:(NSString *)key ofObject:(id)obj {
    @try {
        return [obj valueForKey:key];
    } @catch (NSException *exception) {
        // NSLog(@"SafeKVC caught exception for key %@ on %@: %@", key, obj, exception);
        return nil;
    }
}

+ (BOOL)setValue:(id _Nullable)value forKey:(NSString *)key ofObject:(id)obj {
    @try {
        [obj setValue:value forKey:key];
        return YES;
    } @catch (NSException *exception) {
        // NSLog(@"SafeKVC caught exception while setting key %@ on %@ with value %@: %@", key, obj, value, exception);
        return NO;
    }
}

@end
