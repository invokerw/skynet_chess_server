# open_poker_server
开源棋牌服务器框架，使用skynet

网络协议使用pbc版的protobuf

数据库使用mongodb

客户端代码地址: https://github.com/yuanfengyun/chess

房卡类的麻将服务器地址：https://github.com/yuanfengyun/mj_server

房卡类的麻将客户端地址：https://github.com/yuanfengyun/mj_client


服务器编译步骤:

1、下载源码

    git clone https://github.com/yuanfengyun/chess_server.git

2、初始化submodule

    cd chess_server

    git submodule init

    git submodule update

3、编译skynet

    cd skynet

    git submodule init

    git submodule update

    make linux

4、编译pbc

    cd ../3rd/pbc

    make

    cd binding

    cd lua53

    修改一下Makefile文件，设置lua.h的路径

    make

    将protobuf.lua复制到根目录的lualib目录

    protobuf.so文件复制到根目录的luaclib目录

5、编译proto文件

    回到根目录

    make

6、运行

    . run.sh
