config=$1

cd proto && ./export.sh && cd ..
cd ../skynet
./skynet ../battle_city/config/${config}.cfg

