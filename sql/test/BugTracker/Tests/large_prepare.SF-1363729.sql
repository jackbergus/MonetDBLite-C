START TRANSACTION;
create table foo (clickTime time,long1 bigint,long2 bigint,long3 bigint,long4 bigint,long5 bigint,long6 bigint,long7 bigint,long8 bigint,long9 bigint,long10 bigint,long11 bigint,long12 bigint,long13 bigint,long14 bigint,long15 bigint,long16 bigint,long17 bigint,long18 bigint,long19 bigint,long20 bigint,long21 bigint,long22 bigint,long23 bigint,long24 bigint,long25 bigint,long26 bigint,long27 bigint,long28 bigint,long29 bigint,long30 bigint,long31 bigint,long32 bigint,long33 bigint,long34 bigint);

PREPARE insert into foo values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);

exec 0(time '12:12:12', 6021938018913874944, 7909540736630212608, 5804504770669764608, 5731640460629998592, 862374748439479296, 4118786240046083072, 5736585692206052352, 4180956383130519552, 4431348585717823488, 1687909604323355648, 7376783045669721088, 6515523872365652992, 1715453341893179392, 627721492047376384, 8331839817029594112, 7977041363446006784, 3801764841538480128, 1446801246901456896, 7532895413276706816, 4715259018010967040, 5954047085661367296, 2677611782788034560, 4159344106040219648, 5295979755028414464, 4288751348846951424, 5935314607102821376, 1154335402415802368, 2620740421044021248, 6505497079060329472, 3480814257727680512, 6653356907163571200, 1246123775073920000, 7227784505536452608, 7143603808078267392);
