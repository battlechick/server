
cd ../skynet
./skynet ../battle_city/config/stop.cfg
cd -

cd ./log/pid
if [ -f "master.pid" ];then
    pid=`cat master.pid`
    echo "force stop master"

    kill -9 $pid
fi
if [ -f "login.pid" ];then
    pid=`cat master.pid`
    echo "force stop login"

    kill -9 $pid
fi
if [ -f "battlemng.pid" ];then
    pid=`cat battlemng.pid`
    echo "force stop battle"

    kill -9 $pid
fi
rm *
cd -
