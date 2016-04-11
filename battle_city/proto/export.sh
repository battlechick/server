echo export protobuf
protoc -o Msg.pb Msg.proto
cp -f Msg.proto ClientProto/
cd ClientProto && svn ci -m ""
echo done.

