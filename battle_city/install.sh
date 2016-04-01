# protobuf
workspace=`pwd`
cd ../pbc/ && make && cd binding/lua53/ 
cp protobuf.lua ${workspace}/lualib/
cp pbc-lua53.c ${workspace}/luaclib/

cd ${workspace}/../lua-cjson && make
cp cjson.so ${workspace}/luaclib/
cp lua_cjson.c ${workspace}/luaclib/

cd ${workspace} && make

