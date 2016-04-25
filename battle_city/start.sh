
cd ExcelData
svn up
python export.py UnitProto UnitProto.xls ../proto/ ../data/
python export.py SceneProto SceneProto.xls ../proto/ ../data/
cd ..

cd data 
svn up 
cd ..

cd proto && ./export.sh && cd ..
cd ../skynet
./skynet ../battle_city/config/master.cfg
./skynet ../battle_city/config/login.cfg
./skynet ../battle_city/config/battlemng.cfg

