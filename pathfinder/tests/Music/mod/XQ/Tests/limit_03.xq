(: q3 'SELECT * FROM Assets WHERE TrackNr=9999999 LIMIT 100' :)
import module namespace music = "http://www.cwi.nl/~boncz/music/mod/" at "http://www.cwi.nl/~boncz/music/mod/music.xq";
music:AssetByTrackNr("music.xml", 9999999, 100) 
