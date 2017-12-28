# OCLeveldb
一个支持iOS 的键值数据库，Objective-C接口，fork自[Objective-LevelDB](https://github.com/matehat/Objective-LevelDB) 。

做了以下修改：

- 更新[leveldb](https://github.com/google/leveldb)库，目前版本是`1.20`。因为leveldb已经足够稳定，所以编译好了静态库，不再依赖源码。
- 将Objective-C层的接口转换成ARC的
- 调整`common.h`头文件名称，避免有其他头文件重名
- 提供Carthage支持

## 安装

- 手动安装

  把**OCLeveldb**目录下面的代码拷贝到工程里

- Carthage

    添加`github 'calvingit/OCLeveldb'`到`Cartfile`。注意，因为leveldb编译后的`libleveldb.a`**不支持bitcode**，所以framework也不支持bitcode。

## leveldb编译脚本

把官方的Makefile里面的 **i686** 和 **armv7s**去掉，这两个CPU架构没什么用了。

然后运行命令：`sudo CXXFLAGS=-stdlib=libc++ make PLATFORM=IOS`

默认会在根目录`/`下生成很多文件，所以需要添加管理员权限`sudo`。

编译完成之后，记得把根目录`/`的东西删除掉。

## 使用方法
以后为[Objective-LevelDB](https://github.com/matehat/Objective-LevelDB)原文
#### Creating/Opening a database file on disk

```objective-c
LevelDB *ldb = [LevelDB databaseInLibraryWithName:@"test.ldb"];
```

##### Setup Encoder/Decoder blocks

By default, any object you store will be encoded and decoded using `NSKeyedArchiver`/`NSKeyedUnarchiver`. You can customize this by providing `encoder` and `decoder` blocks, like this:

```objective-c
ldb.encoder = ^ NSData * (LevelDBKey *key, id object) {
  // return some data, given an object
}
ldb.decoder = ^ id (LevelDBKey *key, NSData * data) {
  // return an object, given some data
}
```

#####  NSMutableDictionary-like API

```objective-c
ldb[@"string_test"] = @"laval"; // same as:
[ldb setObject:@"laval" forKey:@"string_test"];

NSLog(@"String Value: %@", ldb[@"string_test"]); // same as:
NSLog(@"String Value: %@", [ldb objectForKey:@"string_test"]);

[ldb setObject:@{@"key1" : @"val1", @"key2" : @"val2"} forKey:@"dict_test"];
NSLog(@"Dictionary Value: %@", [ldb objectForKey:@"dict_test"]);

```
All available methods can be found in its [header file](https://github.com/matehat/Objective-LevelDB/blob/master/Classes/LevelDB.h) (documented).

##### Enumeration

```objective-c
[ldb enumerateKeysAndObjectsUsingBlock:^(LevelDBKey *key, id value, BOOL *stop) {
    // This step is necessary since the key could be a string or raw data (use NSDataFromLevelDBKey in that case)
    NSString *keyString = NSStringFromLevelDBKey(key); // Assumes UTF-8 encoding
    // Do something clever
}];

// Enumerate with options
[ldb enumerateKeysAndObjectsBackward:TRUE
                              lazily:TRUE       // Block below will have a block(void) instead of id argument for value
                       startingAtKey:someKey    // Start iteration there (NSString or NSData)
                 filteredByPredicate:predicate  // Only iterate over values matching NSPredicate
                           andPrefix:prefix     // Only iterate over keys prefixed with something 
                          usingBlock:^(LevelDBKey *key, void(^valueGetter)(void), BOOL *stop) {
                             
    NSString *keyString = NSStringFromLevelDBKey(key);
    
    // If we had wanted the value directly instead of a valueGetter block, we would've set the 
    // above 'lazily' argument to FALSE
    id value = valueGetter();
}]
```
More iteration methods are available, just have a look at the [header section](https://github.com/matehat/Objective-LevelDB/blob/master/Classes/LevelDB.h)

##### Snapshots, NSDictionary-like API (immutable)

A snapshot is a readonly interface to the database, permanently reflecting the state of 
the database when it was created, even if the database changes afterwards.

```objective-c
LDBSnapshot *snap = [ldb newSnapshot]; // You get ownership of this variable, so in non-ARC projects,
                                       // you'll need to release/autorelease it eventually
[ldb removeObjectForKey:@"string_test"];

// The result of these calls will reflect the state of ldb when the snapshot was taken
NSLog(@"String Value: %@", [snap objectForKey:@"string_test"]);
NSLog(@"Dictionary Value: %@", [ldb objectForKey:@"dict_test"]);
```

All available methods can be found in its [header file](https://github.com/matehat/Objective-LevelDB/blob/master/Classes/LDBSnapshot.h)

##### Write batches, atomic sets of updates

Write batches are a mutable proxy to a `LevelDB` database, accumulating updates
without applying them, until you do using `-[LDBWritebatch apply]`

```objective-c
LDBWritebatch *wb = [ldb newWritebatch];
[wb setObject:@{ @"foo" : @"bar" } forKey: @"another_test"];
[wb removeObjectForKey:@"dict_test"];

// Those changes aren't yet applied to ldb
// To apply them in batch, 
[wb apply];
```

All available methods can be found in its [header file](https://github.com/matehat/Objective-LevelDB/blob/master/Classes/LDBWriteBatch.h)

##### LevelDB options

```objective-c
// The following values are the default
LevelDBOptions options = [LevelDB makeOptions];
options.createIfMissing = true;
options.errorIfExists   = false;
options.paranoidCheck   = false;
options.compression     = true;
options.filterPolicy    = 0;      // Size in bits per key, allocated for a bloom filter, used in testing presence of key
options.cacheSize       = 0;      // Size in bytes, allocated for a LRU cache used for speeding up lookups

// Then, you can provide it when initializing a db instance.
LevelDB *ldb = [LevelDB databaseInLibraryWithName:@"test.ldb" andOptions:options];
```

##### Per-request options

```objective-c
db.safe = true; // Make sure to data was actually written to disk before returning from write operations.
[ldb setObject:@"laval" forKey:@"string_test"];
[ldb setObject:[NSDictionary dictionaryWithObjectsAndKeys:@"val1", @"key1", @"val2", @"key2", nil] forKey:@"dict_test"];
db.safe = false; // Switch back to default

db.useCache = false; // Do not use DB cache when reading data (default to true);
```

##### Concurrency

As [Google's documentation states][2], updates and reads from a leveldb instance do not require external synchronization
to be thread-safe. Write batches do, and we've taken care of it, by isolating every `LDBWritebatch` it inside a serial dispatch 
queue, and making every request dispatch *synchronously* to it. So use it from wherever you want, it'll just work.

However, if you are using something like JSONKit for encoding data to JSON in the database, and you are clever enough to 
preallocate a `JSONDecoder` instance for all data decoding, beware that this particular object is *not* thread-safe, and you will
need to take care of it manually.
