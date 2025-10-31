#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SafeKVC : NSObject
+ (id _Nullable)valueForKey:(NSString *)key ofObject:(id)obj;
+ (BOOL)setValue:(id _Nullable)value forKey:(NSString *)key ofObject:(id)obj;
@end

NS_ASSUME_NONNULL_END
