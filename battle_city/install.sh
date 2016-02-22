# protobuf
workspace=`pwd`
cd ../pbc/ && make && cd binding/lua53/ 
cp protobuf.lua ${workspace}/lualib/
cp pbc-lua53.c ${workspace}/luaclib/

cd ${workspace} && make
