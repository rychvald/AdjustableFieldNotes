//
//  NSManagedObject+Serialization.h
//  Adjustable Field Notes
//
//  Parts of code from https://gist.github.com/nuthatch/5607405
//

@interface NSManagedObject (Serialization)

- (NSDictionary *) toDictionary;
- (void) populateFromDictionary:(NSDictionary *)dict;
+ (NSManagedObject *) createManagedObjectFromDictionary:(NSDictionary*)dict inContext:(NSManagedObjectContext*)context;
+ (NSData *)dataFromDictionary:(NSDictionary *)dictionary;
+ (NSDictionary *)dictionaryFromData:(NSData *)data;

@end