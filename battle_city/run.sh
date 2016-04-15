config=$1

cd ExcelData
svn up
python export.py UnitProto UnitProto.xls ../proto/ ../data/
cd ..

cd data 
svn up 
cd ..

cd proto && ./export.sh && cd ..
cd ../skynet
./skynet ../battle_city/config/${config}.cfg

