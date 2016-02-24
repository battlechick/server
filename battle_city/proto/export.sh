echo export protobuf
protoc -o msg.pb msg.proto
cp -f msg.proto client_proto/
echo done.

