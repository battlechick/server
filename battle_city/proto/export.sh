echo export protobuf

protoc -o Msg.pb Msg.proto
cp -f Msg.proto ClientProto/

protoc -o UnitProto.pb UnitProto.proto
cp -f UnitProto.proto ClientProto/

protoc -o SceneProto.pb SceneProto.proto
cp -f SceneProto.proto ClientProto/


cd ClientProto && svn ci -m ""
echo done.

