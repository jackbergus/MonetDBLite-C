(: q6 'SELECT * FROM Assets ORDER BY Title' :)
import module namespace music = "http://www.cwi.nl/~boncz/music/opt/" at "http://www.cwi.nl/~boncz/music/opt/music.mil";
music:AssetSort("music.xml", 10000000000)
