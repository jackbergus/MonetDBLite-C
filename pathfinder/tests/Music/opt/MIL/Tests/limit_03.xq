(: q3 'SELECT * FROM Assets WHERE TrackNr=9999999 LIMIT 100' :)
import module namespace music = "http://www.cwi.nl/~boncz/music/opt/" at "http://www.cwi.nl/~boncz/music/opt/music.mil";
music:AssetByTrackNr9999999("music.xml", 100) 
