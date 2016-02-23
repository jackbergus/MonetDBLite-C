-- SRIDs are checked!
select 't1', st_asewkt(st_sharedpaths(
	ST_GeomFromText('LINESTRING(0 0, 10 0)', 10), 
	ST_GeomFromText('LINESTRING(0 0, 100 0)', 5)));

-- SRIDs are retained
select 't2', st_asewkt(st_sharedpaths(
	ST_GeomFromText('LINESTRING(0 0, 10 0)', 10), 
	ST_GeomFromText('LINESTRING(0 0, 10 0)', 10)));

-- Opposite direction
select 't3', st_asewkt(st_sharedpaths(
	ST_GeomFromText('LINESTRING(0 0, 10 0)'), 
	ST_GeomFromText('LINESTRING(10 0, 0 0)')));

-- Disjoint
select 't4', st_asewkt(st_sharedpaths(
	ST_GeomFromText('LINESTRING(0 0, 10 0)'), 
	ST_GeomFromText('LINESTRING(20 0, 30 0)')));

-- Mixed
select 't5', st_asewkt(st_sharedpaths(
	ST_GeomFromText('LINESTRING(0 0, 100 0)'), 
	ST_GeomFromText('LINESTRING(20 0, 30 0, 30 50, 80 0, 70 0)')));

-- bug #670
select 't6', st_sharedpaths(
  ST_WKBToSQL('0101000020E6100000F771D98DE33826C00000000000004440'),
  ST_WKBToSQL('0103000020E61000000100000021000000F771D98DE33820C00000000000004E409610DB16675620C00EC34AD715B54D407AF7FF56CFAD20C008E817B00C6D4D40A8B32666C03B21C017D34B39A92A4D40C096A1DAC5FA21C03309329378F04C4050BE087388E322C06D501336B7C04C401412394E16ED23C061A149F23A9D4C402C7E04EB3A0D25C0A86740E260874C40F471D98DE33826C00000000000804C40BC65AE308C6427C0A86740E260874C40D5D179CDB08428C060A149F23A9D4C409A25AAA83E8E29C06C501336B7C04C402A4D114101772AC03209329378F04C4043308CB506362BC016D34B39A92A4D4072ECB2C4F7C32BC007E817B00C6D4D4057D3D704601B2CC00DC34AD715B54D40F771D98DE3382CC0FFFFFFFFFFFF4D4059D3D704601B2CC0F13CB528EA4A4E4076ECB2C4F7C32BC0F717E84FF3924E4049308CB506362BC0E82CB4C656D54E40324D114101772AC0CCF6CD6C870F4F40A325AAA83E8E29C093AFECC9483F4F40DFD179CDB08428C09F5EB60DC5624F40C665AE308C6427C05898BF1D9F784F40FD71D98DE33826C00000000000804F40347E04EB3A0D25C05898BF1D9F784F401B12394E16ED23C0A05EB60DC5624F4056BE087388E322C094AFECC9483F4F40C496A1DAC5FA21C0CEF6CD6C870F4F40ABB32666C03B21C0EA2CB4C656D54E407CF7FF56CFAD20C0F917E84FF3924E409710DB16675620C0F33CB528EA4A4E40F771D98DE33820C00000000000004E40')
);

-- RT 1
select 't7', st_asewkt(st_sharedpaths(
	ST_GeomFromText('MULTILINESTRING((1 3,4 2,7 2,7 5),(13 10,14 7,11 6,15 5))'),
	ST_GeomFromText('LINESTRING(2 1,4 2,7 2,8 3,10 6,11 6,14 7,16 9)')));

-- RT 2
select 't8', st_asewkt(st_sharedpaths(
	ST_GeomFromText('MULTILINESTRING((1 3,4 2,7 2,7 5,13 10,14 7,11 6,15 5))'),
	ST_GeomFromText('LINESTRING(2 1,4 2,7 2,8 3,10 6,11 6,14 7,16 9)')));
