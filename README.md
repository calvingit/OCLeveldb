# leveldb-iOS
 iOS 平台编译好的[leveldb](https://github.com/google/leveldb.git) library

# Architectures

支持 : armv7, i386,  x86_64,  arm64

# 编译脚本

把官方的Makefile里面的 i686 和 armv7s去掉，这两个CPU架构没什么用了。

然后运行命令：`sudo CXXFLAGS=-stdlib=libc++ make PLATFORM=IOS`

默认会在根目录`/`下生成很多文件，所以需要添加管理员权限`sudo`。

编译完成之后，记得把根目录`/`的东西删除掉。