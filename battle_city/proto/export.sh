echo export protobuf

protoc -o Msg.pb Msg.proto
cp -f Msg.proto ClientProto/

protoc -o UnitProto.pb UnitProto.proto
cp -f UnitProto.proto ClientProto/


cd ClientProto && svn ci -m ""
echo done.

