INSERT INTO spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text)
VALUES (
 '4326',
 'EPSG',
 '4326',
 'GEOGCS["WGS 84",DATUM["WGS_1984",SPHEROID["WGS 84",6378137,298.257223563,AUTHORITY["EPSG","7030"]],AUTHORITY["EPSG","6326"]],PRIMEM["Greenwich",0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.0174532925199433,AUTHORITY["EPSG","9122"]],AUTHORITY["EPSG","4326"]]',
 '+proj=longlat +datum=WGS84 +no_defs'
);

-- Do cached and uncached distance agree?
SELECT c, abs(ST_Distance(ply::geography, pt::geography) - _ST_DistanceUnCached(ply::geography, pt::geography)) < 0.01 FROM 
( VALUES
('geog_distance_cached_1a', 'POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))', 'POINT(5 5)'),
('geog_distance_cached_1b', 'POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))', 'POINT(5 5)'),
('geog_distance_cached_1c', 'POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))', 'POINT(5 5)'),
('geog_distance_cached_1e', 'POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))', 'POINT(5 5)'),
('geog_distance_cached_1f', 'POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))', 'POINT(5 5)'),
('geog_distance_cached_1g', 'POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))', 'POINT(5 5)'),
('geog_distance_cached_1h', 'POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))', 'POINT(5 5)')
) AS u(c,ply,pt);

-- Does tolerance based distance work cached? Inside tolerance
SELECT c, ST_DWithin(ply::geography, pt::geography, 3000) from 
( VALUES
('geog_dithin_cached_1a', 'POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))', 'POINT(10.01 5)'),
('geog_dithin_cached_1b', 'POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))', 'POINT(10.01 5)'),
('geog_dithin_cached_1c', 'POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))', 'POINT(10.01 5)')
) as p(c, ply, pt);

-- Does tolerance based distance work cached? Outside tolerance
SELECT c, ST_DWithin(ply::geography, pt::geography, 1000) from 
( VALUES
('geog_dithin_cached_2a', 'POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))', 'POINT(10.01 5)'),
('geog_dithin_cached_2b', 'POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))', 'POINT(10.01 5)'),
('geog_dithin_cached_2c', 'POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))', 'POINT(10.01 5)')
) as p(c, ply, pt);

-- Do things work when there's cache coherence on the point side but not the poly side?
SELECT c, ST_DWithin(ply::geography, pt::geography, 3000) from 
( VALUES
('geog_dithin_cached_3a', 'POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))', 'POINT(5 5)'),
('geog_dithin_cached_3b', 'POLYGON((1 1, 1 10, 10 10, 10 1, 1 1))', 'POINT(5 5)'),
('geog_dithin_cached_3c', 'POLYGON((2 2, 2 10, 10 10, 10 2, 2 2))', 'POINT(5 5)')
) as p(c, ply, pt);

-- Test a precision case near the south pole that came up during development.
WITH pt AS ( 
    SELECT point::geography FROM ( VALUES 
    ('0101000020E61000006C5B94D920EB4CC0A0FD481119B24FC0'),
    ('0101000020E610000097A8DE1AD8524CC09C8A54185B1050C0'),
    ('0101000020E61000008FC2F5285C4F4CC0E5ED08A7050F50C0'),
    ('0101000020E61000008FC2F5285C4F4CC0E5ED08A7050F50C0') ) AS p(point)
),
ply AS (
    SELECT polygon::geography FROM ( VALUES
    ('0106000020E610000001000000010300000001000000A10100005036E50AEF8E4FC0E3FC4D2844A443C000000000008046C000000000000047C033333333335346C000000000000047C066666666662646C000000000000047C09999999999F945C000000000000047C0CDCCCCCCCCCC45C000000000000047C00000000000A045C000000000000047C033333333337345C000000000000047C066666666664645C000000000000047C099999999991945C000000000000047C0CDCCCCCCCCEC44C000000000000047C00000000000C044C000000000000047C033333333339344C000000000000047C066666666666644C000000000000047C099999999993944C000000000000047C0CDCCCCCCCC0C44C000000000000047C00000000000E043C000000000000047C03333333333B343C000000000000047C066666666668643C000000000000047C099999999995943C000000000000047C0CDCCCCCCCC2C43C000000000000047C000000000000043C000000000000047C03333333333D342C000000000000047C06666666666A642C000000000000047C099999999997942C000000000000047C0CDCCCCCCCC4C42C000000000000047C000000000002042C000000000000047C03333333333F341C000000000000047C06666666666C641C000000000000047C099999999999941C000000000000047C0CDCCCCCCCC6C41C000000000000047C000000000004041C000000000000047C033333333331341C000000000000047C06666666666E640C000000000000047C09999999999B940C000000000000047C0CDCCCCCCCC8C40C000000000000047C000000000006040C000000000000047C033333333333340C000000000000047C066666666660640C000000000000047C03333333333B33FC000000000000047C09999999999593FC000000000000047C00000000000003FC000000000000047C06666666666A63EC000000000000047C0CCCCCCCCCC4C3EC000000000000047C03333333333F33DC000000000000047C09999999999993DC000000000000047C00000000000403DC000000000000047C06666666666E63CC000000000000047C0CCCCCCCCCC8C3CC000000000000047C03333333333333CC000000000000047C09999999999D93BC000000000000047C00000000000803BC000000000000047C06666666666263BC000000000000047C0CCCCCCCCCCCC3AC000000000000047C03333333333733AC000000000000047C09999999999193AC000000000000047C00000000000C039C000000000000047C066666666666639C000000000000047C0CCCCCCCCCC0C39C000000000000047C03333333333B338C000000000000047C099999999995938C000000000000047C000000000000038C000000000000047C06666666666A637C000000000000047C0CDCCCCCCCC4C37C000000000000047C03333333333F336C000000000000047C099999999999936C000000000000047C000000000004036C000000000000047C06666666666E635C000000000000047C0CDCCCCCCCC8C35C000000000000047C033333333333335C000000000000047C09999999999D934C000000000000047C000000000008034C000000000000047C066666666662634C000000000000047C0CDCCCCCCCCCC33C000000000000047C033333333337333C000000000000047C099999999991933C000000000000047C00000000000C032C000000000000047C066666666666632C000000000000047C0CDCCCCCCCC0C32C000000000000047C03333333333B331C000000000000047C099999999995931C000000000000047C000000000000031C000000000000047C06666666666A630C000000000000047C0CDCCCCCCCC4C30C000000000000047C06666666666E62FC000000000000047C03333333333332FC000000000000047C00000000000802EC000000000000047C0CCCCCCCCCCCC2DC000000000000047C09999999999192DC000000000000047C06666666666662CC000000000000047C03333333333B32BC000000000000047C00000000000002BC000000000000047C0CCCCCCCCCC4C2AC000000000000047C099999999999929C000000000000047C06666666666E628C000000000000047C033333333333328C000000000000047C000000000008027C000000000000047C0CDCCCCCCCCCC26C000000000000047C099999999991926C000000000000047C066666666666625C000000000000047C03333333333B324C000000000000047C000000000000024C000000000000047C000000000000024C03943F5FFFF7F56C000000000008052C03943F5FFFF7F56C000000000008052C00000000000004EC068774831407A52C00000000000004EC0B8ACC266807452C00000000000004EC020240B98C06E52C00000000000004EC0705985CD006952C00000000000004EC0D9D0CDFE406352C00000000000004EC029064834815D52C00000000000004EC0917D9065C15752C00000000000004EC0E1B20A9B015252C00000000000004EC0492A53CC414C52C00000000000004EC09A5FCD01824652C00000000000004EC002D71533C24052C00000000000004EC0520C9068023B52C00000000000004EC0BA83D899423552C00000000000004EC00AB952CF822F52C00000000000004EC072309B00C32952C00000000000004EC0C3651536032452C00000000000004EC02BDD5D67431E52C00000000000004EC09354A698831852C00000000000004EC0E38920CEC31252C00000000000004EC04B0169FF030D52C00000000000004EC09B36E334440752C00000000000004EC003AE2B66840152C00000000000004EC054E3A59BC4FB51C00000000000004EC0BC5AEECC04F651C00000000000004EC00C90680245F051C00000000000004EC07407B13385EA51C00000000000004EC0C43C2B69C5E451C00000000000004EC02DB4739A05DF51C00000000000004EC07DE9EDCF45D951C00000000000004EC0E560360186D351C00000000000004EC03596B036C6CD51C00000000000004EC09D0DF96706C851C00000000000004EC0EE42739D46C251C00000000000004EC056BABBCE86BC51C00000000000004EC0A6EF3504C7B651C00000000000004EC00E677E3507B151C00000000000004EC076DEC66647AB51C00000000000004EC0C613419C87A551C00000000000004EC02E8B89CDC79F51C00000000000004EC07FC00303089A51C00000000000004EC0E7374C34489451C00000000000004EC0376DC669888E51C00000000000004EC09FE40E9BC88851C00000000000004EC0EF1989D0088351C00000000000004EC05791D101497D51C00000000000004EC0A8C64B37897751C00000000000004EC0103E9468C97151C00000000000004EC060730E9E096C51C00000000000004EC0C8EA56CF496651C00000000000004EC01820D1048A6051C00000000000004EC081971936CA5A51C00000000000004EC0D1CC936B0A5551C00000000000004EC03944DC9C4A4F51C00000000000004EC0A1BB24CE8A4951C00000000000004EC0F1F09E03CB4351C00000000000004EC05968E7340B3E51C00000000000004EC0AA9D616A4B3851C00000000000004EC01215AA9B8B3251C00000000000004EC0624A24D1CB2C51C00000000000004EC0CAC16C020C2751C00000000000004EC01AF7E6374C2151C00000000000004EC0826E2F698C1B51C00000000000004EC0D3A3A99ECC1551C00000000000004EC03B1BF2CF0C1051C00000000000004EC08B506C054D0A51C00000000000004EC0F3C7B4368D0451C00000000000004EC043FD2E6CCDFE50C00000000000004EC0AB74779D0DF950C00000000000004EC0FCA9F1D24DF350C00000000000004EC064213A048EED50C00000000000004EC0CC988235CEE750C00000000000004EC01CCEFC6A0EE250C00000000000004EC08445459C4EDC50C00000000000004EC0D47ABFD18ED650C00000000000004EC0C2340C1F11D150C00000000000004EC0C2340C1F11D150C0FE7DC685032D4DC0C2340C1F11D150C0FE7DC685033D4CC0C2340C1F11D150C0713D0AD7A3304CC02AAC545051CB50C0703D0AD7A3304CC07AE1CE8591C550C0703D0AD7A3304CC0E25817B7D1BF50C0703D0AD7A3304CC0328E91EC11BA50C0703D0AD7A3304CC09A05DA1D52B450C0703D0AD7A3304CC0EB3A545392AE50C0703D0AD7A3304CC053B29C84D2A850C0703D0AD7A3304CC0A3E716BA12A350C0703D0AD7A3304CC00B5F5FEB529D50C0703D0AD7A3304CC05B94D920939750C0703D0AD7A3304CC0C30B2252D39150C0703D0AD7A3304CC014419C87138C50C0703D0AD7A3304CC07CB8E4B8538650C0703D0AD7A3304CC0CCED5EEE938050C0703D0AD7A3304CC03465A71FD47A50C0703D0AD7A3304CC0849A2155147550C0703D0AD7A3304CC0EC116A86546F50C0703D0AD7A3304CC03ECBF3E0EE6E50C0713D0AD7A3304CC0FF3EE3C2816E50C0A2EE0390DAB04BC0EC12D55B038550C01630815B77974BC05BCEA5B8AA9A50C0C173EFE1928F4BC0A5315A4755B550C00000000000804BC0014D840D4FD150C01899DB1896744BC05D05E7421B2A51C0B38EF4B3A2754BC0BB0F406A132751C068E89FE062C94AC03D6B1217DB2851C0413F9D3C76564AC09F268E97491D51C01E55A8C9E72D4AC014AE47E17A5051C05E770481DF154AC0DA531795F95E51C0ADA81CEE7E154AC033333333337351C0EACF7EA488084AC0DA835A1DCA8251C019479B994F014AC00473F4F8BDA551C0CB4A9352D0014AC0AD927EB12DFD51C0848FD2B6AB014AC07F11D9AC1FFF51C0D21D1F8887F249C01D4762388D1B52C06AE27899BCCA49C00AD7A3703D1252C08BAF2C87CCA049C0A323B9FC871A52C0ADCE20F4229449C056760B6E351352C0F866E5A8ED8449C024F83A04E91352C0DCDB8882745249C0F1F44A59863252C0DBCD42F1195049C01A97BBE09D4452C0EEEBC039236449C09A31BBDD014C52C0454B79083E6349C0A59421D8826352C004824AA6542849C04BABC6B71C6252C046216EF36B1449C0A4F55C4BED5D52C01CE7DB27EC0549C0D9BBF550916452C058CE39D3DFF648C0DD0E6844445C52C0937D46D8A6E648C098B4F347E26652C0F6FC1F1620C748C0AB37B412845D52C0D9A2BBDA40A948C048E17A14AE5F52C0D52137C30D9448C04B1A48BCE14B52C0BF901F3BB99848C0B26DAC1FF63552C0E4709CCA587B48C0287E8CB96B2652C0912CBBBB296948C0A59421D8822852C0D49AE61DA74048C0C009E0C1AA1452C0106734A8EC2E48C0A8D94D3ADB1452C004560E2DB21948C0687B4F40EE2452C06ECF3D35A8F047C089022269DC1552C0ADAC23FDACCD47C019B2158FE61652C07BC26DC89AB747C009B3BFA2910A52C095E70B6B74B447C01DF2857F47FF51C01D8AA7C3AF9A47C0F1248EE156F651C0E9482EFF219B47C07A45A6327BFE51C0711706D1FF8747C0A5315A4755FD51C000000000008047C0395BE5AE4AFB51C0CD6152D7356547C0182DF64DD0F451C00CC3EC0A226447C0B6CA5D95D5EA51C098E19A96B34A47C06ABC749318FA51C0E51E5C4B121247C0C1920612EFEE51C0780F2B37AC0847C09D2743FA12EA51C0653FE65EBBF546C01563AAAA61F351C0FA8271CBA2CB46C00775368966E151C08208CC9E5FC346C05DEF4806CAD651C03ECB98277C9C46C03760A12042E551C0FFF1B96EA57B46C073A7CF69710152C090A4FF40147346C03D5C1723B70152C0F46C567DAE6646C03505D78198E051C023DF008E985E46C08351499D80D451C037853A51B76646C09C46A4B789C751C0B515FBCBEE4546C09C33A2B437CF51C0BE82D9A95E3446C066E1462550F651C042CB5FC6B93046C09B6B3DE8FEF551C056212FB5EF0D46C075FBF6BFEDEB51C04E36D4DE96FF45C020578FA01DF251C0C967C3ABF6E845C05CA2C4F87AE651C0E5F21FD26FD745C0FD0978E3EEFB51C06CE3F49AC3BE45C09D11A5BDC1F951C00C11267B3AAB45C08A9DDFE643F051C037EE83E27DA645C0A922CB38FCEF51C0CCBE863B729645C008D5BC99070852C0865EDACB118745C088635DDC460952C01B09D91E624E45C01F85EB51B80652C07D96E7C1DD4D45C0A8188CB6CF0152C018135102513E45C00C7D0B46000852C0166646E4602945C06E2585C31C0352C039B0C167901345C0A499DD497AEF51C0BD1358A5991245C023DBF97E6AF251C0BEF15AAE230045C0EE7C3F355EF151C0F6FC1F1620E944C040529F3FC8F851C0BBF7CB82E4D344C0D27E5AFBF1F751C0F6D61B107CB444C0CA9C23938AF751C0B498EEF4A2B544C0624775BC1FF751C035958D13C7B644C0EA8B637FB1F651C040BEE654E8B744C0AADC49E43FF651C0298B1FA206B944C0AD7CCAF3CAF551C043D796E421BA44C0D6E6CDB652F551C0ECBDE6053ABB44C0532E8236D7F451C06B72E6EF4EBC44C07E585A7C58F451C08F13AC8C60BD44C01EB00D92D6F351C0DE7A8EC66EBE44C02712978151F351C01507278879BF44C0F9333455C9F251C0D96153BC80C044C015E364173EF251C08540374E84C144C0703EEAD2AFF151C0B21F3E2984C244C062E9C5921EF151C088F91C3980C344C0313839628AF051C083F6D36978C444C05856C44CF3EF51C0A018B0A76CC544C09366255E59EF51C0A5E04CDF5CC644C0AE9C57A2BCEE51C08AED95FD48C744C0495192251DEE51C09C95C8EF30C844C0760F48F47AED51C0747975A314C944C0739C251BD6EC51C060108206F4C944C061F910A72EEC51C0372E2A07CFCA44C0385F28A584EB51C066820194A5CB44C0E834C122D8EA51C01010F59B77CC44C0DDFF662D29EA51C0149F4C0E45CD44C0DA4EDAD277E951C0E725ACDA0DCE44C0669F0F21C4E851C0FB2B15F1D1CE44C0C53D2E260EE851C0B124E84191CF44C0A41F8FF055E751C09CC2E5BD4BD044C098B9BB8E9BE651C0F042305601D144C076CF6C0FDFE551C017B14CFCB1D144C0B73F898120E551C0192224A25DD244C0F9C924F45FE451C0E5E7043A04D344C0B2D07E769DE351C03EBCA3B6A5D344C047160118D9E251C039E31C0B42D444C095753EE812E251C01B45F52AD9D444C01596F1F64AE151C09D7F1B0A6BD544C0B79BFB5381E051C048EEE89CF7D544C096D2620FB6DF51C0F7A922D87ED644C0AA565139E9DE51C0497FFAB000D744C097B713E21ADE51C0FBDB0F1D7DD744C0BB98171A4BDD51C0FBB27012F4D744C0AC4DEAF179DC51C02D579A8765D844C03173377AA7DB51C0BC4C7A73D1D844C0FB84C7C3D3DA51C0FD106FCD37D944C027707EDFFED951C095D8488D98D944C0C8225ADE28D951C013444AABF3D944C08B1871D151D851C0B40A292049DA44C0ADE4F0C979D751C0529B0EE598DA44C061B91CD9A0D651C07AB398F3E2DA44C0D4EC4B10C7D551C076ECD94527DB44C0F97BE880ECD451C0633E5AD665DB44C0398B6D3C11D451C01F7917A09EDB44C04CE5655435D351C01FB3859ED1DB44C048786ADA58D251C018AE8FCDFEDB44C022D120E07BD151C05831972926DC44C0C89539779ED051C0F25975AF47DC44C0FEFD6EB1C0CF51C091E07A5C63DC44C02B4B83A0E2CE51C0EE54702E79DC44C03D3F3F5604CE51C0F24E962389DC44C0D69270E425CD51C07E95A53A93DC44C0EE6AE85C47CC51C0A93ACF7297DC44C00BCE79D168CB51C0C6ADBCCB95DC44C04F19F8538ACA51C0D7C28F458EDC44C06D7535F6ABC951C09FAFE2E080DC44C0CD4B01CACDC851C04CFEC79E6DDC44C000BC26E1EFC751C0B675CA8054DC44C09F116B4D12C751C029F7EC8835DC44C0DF3A8C2035C651C0DC51AAB910DC44C0F53F3F6C58C551C0FC0BF515E6DB44C073BB2E427CC451C0632137A1B5DB44C0D153F9B3A0C351C0F7B7515F7FDB44C04D3630D3C5C251C0CDC99C5443DB44C0459355B1EBC151C0F8C4E68501DB44C0451CDB5F12C151C0342174F8B9DA44C0DB8320F039C051C062EBFEB16CDA44C079FF717362BF51C0E546B6B819DA44C078CB06FB8BBE51C0F2E43D13C1D944C06DB1FF97B6BD51C0DC71ADC862D944C0F890655BE2BC51C088F88FE0FED844C03BEB27560FBC51C0E13BE36295D844C014711B993DBB51C09706175826D844C04F94F8346DBA51C02E710CC9B1D744C0F31B5A3A9EB951C04B1E15BF37D744C0C6BBBBB9D0B851C0976DF243B8D644C03FAF78C304B851C014A5D46133D644C0F757CA673AB751C01A115A23A9D544C0DADFC6B671B651C0141B8E9319D544C014DF5FC0AAB551C0FE56E8BD84D444C005066194E5B451C0E6874BAEEAD344C049CB6E4222B451C0629B04714BD344C0E91D05DA60B351C03E9CC912A7D244C0051C766AA1B251C04D9CB8A0FDD144C0D3CDE802E4B151C0CD9556284FD144C058E557B228B151C00E448EB79BD044C0C48290876FB051C0DCF3AE5CE3CF44C0ABFD3091B8AF51C0A54B6B2626CF44C034B3A7DD03AF51C06F0BD82364CE44C048D9317B51AE51C0DEC46A649DCD44C0FC56DA77A1AD51C05A8BF8F7D1CC44C032A278E1F3AC51C0709CB4EE01CC44C0A0A2AFC548AC51C0B9002F592DCB44C03F9AEC31A0AB51C03225534854CA44C05A136633FAAA51C0646D66CD76C944C02DD41AD756AA51C050BE06FA94C844C04CD8D029B6A951C0720229E0AEC744C0D34F143818A951C0DEA61792C4C644C075A4360E7DA851C0AF117122D6C544C082844DB8E4A751C0EE1126A4E3C444C0FDF331424FA751C02849782AEDC344C0B6637FB7BCA651C0B58EF8C8F2C244C0A5CE92232DA651C0FE4C8593F4C144C067DD8991A0A551C0EBD8489EF2C044C01010420C17A551C084C3B7FDECBF44C046EE579E90A451C006268FC6E3BE44C0C53D26520DA451C0AAE8D20DD7BD44C0473FC5318DA351C01B04CCE8C6BC44C0E1F1094710A351C0E0BD066DB3BB44C0E85C859B96A251C000E050B09CBA44C05AE0833820A251C0CAEBB7C882B944C0CF8B0C27ADA151C02F4887CC65B844C00B7CE06F3DA151C0B66B46D245B744C02E3F7A1BD1A051C03B02B7F022B644C0813F0D3268A051C0BA0ED33EFDB444C0E43485BB02A051C02C09CBD3D4B344C0FB9C85BFA09F51C0CBF803C7A9B244C0EB396945429F51C0D58A15307CB144C0E1974154E79E51C0FC25C8264CB044C03299D6F28F9E51C0ADFA12C319AF44C03D09A6273C9E51C076101A1DE5AD44C0EF35E3F8EB9D51C084502C4DAEAC44C0F98F766C9F9D51C0A08DC16B75AB44C09EB70C93849D51C08100BE8003AB44C05036E50AEF8E4FC0E3FC4D2844A443C0')
    ) as q(polygon)
)
SELECT 'geog_precision_savffir', _ST_DistanceUnCached(pt.point, ply.polygon), ST_Distance(pt.point, ply.polygon) FROM pt, ply;

-- Test another precision case near the north poly and over the dateline
WITH pt AS ( 
    SELECT point::geography FROM ( VALUES 
    ('0101000020E610000000000000004065400000000000804840'),
    ('0101000020E610000075C8CD70033965C02176A6D079315040') ) AS p(point)
),
ply AS (
    SELECT polygon::geography FROM ( VALUES
    ('0103000020E6100000010000004101000078A1B94E231F65C000000000000051400000000000C063C000000000000052400000000000C063C0000000000000524078A1B94E231F65C0000000000000514078A1B94E231F65C000000000008056400000000000A061C000000000008056400000000000A061C0EF940ED6FF7F56400000000000A061C0DD291DACFF7F56400000000000A061C0CBBE2B82FF7F56400000000000A061C0B9533A58FF7F56400000000000A061C0A8E8482EFF7F56400000000000A061C0967D5704FF7F56400000000000A061C072A774B0FE7F56400000000000A061C04FD1915CFE7F56400000000000A061C02BFBAE08FE7F56400000000000A061C0F6B9DA8AFD7F56400000000000A061C0C178060DFD7F56400000000000A061C079CC4065FC7F56400000000000A061C00F4A9869FB7F56400000000000A061C0A4C7EF6DFA7F56400000000000A061C0040473F4F87F56400000000000A061C052D50451F77F56400000000000A061C07DD0B359F57F56400000000000A061C0611F9DBAF27F56400000000000A061C00F2DB29DEF7F56400000000000A061C0642310AFEB7F56400000000000A061C06102B7EEE67F56400000000000A061C0E1F3C308E17F56400000000000A061C0AFB6627FD97F56400000000000A061C0DDB5847CD07F56400000000000A061C013DA722EC57F56400000000000A061C02C4D4A41B77F56400000000000A061C0CFF753E3A57F56400000000000A061C0B72DCA6C907F56400000000000A061C0776C04E2757F56400000000000A061C093C6681D557F56400000000000A061C05B0D897B2C7F56400000000000A061C01B12F758FA7E56400000000000A061C0B8239C16BC7E56400000000000A061C027FC523F6F7E56400000000000A061C0BD9179E40F7E56400000000000A061C0CFDA6D179A7D56400000000000A061C0F0332E1C087D56400000000000A061C07CB8E4B8537C56400000000000A061C0C53D963E747B56400000000000A061C08E40BCAE5F7A56400000000000A061C07F8CB96B097956400000000000A061C0FE65F7E4617756400000000000A061C0C9073D9B557556400000000000A061C0CDCCCCCCCC7256400000000000A061C07A01F6D1A96F56400000000000A061C053616C21C86B56400000000000A061C009A7052FFA6656400000000000A061C0F0332E1C086156400000000000A061C085471B47AC5956400000000000A061C0752497FF905056400000000000A061C08C84B69C4B4556400000000000A061C02C6519E2583756400000000000A061C02B357BA0152656400000000000A061C055C6BFCFB81056400000000000A061C0F988981249F655400000000000A061C08C321B6492D555400000000000A061C0ADC5A70018AD55400000000000A061C02254A9D9037B55400000000000A061C009E1D1C6113D55400000000000A061C0A0E5797077F054400000000000A061C0FA49B54FC79154400000000000A061C043959A3DD01C54400000000000A061C075EACA67798C53400000000000A061C00EE02D90A0DA52400000000000A061C000000000000052400000000000A061C000000000000052400000000000A061C00100000000004F400000000000A061C01730815B77274E408C45D3D9C99D61C04CAB21718F254E40C0120F289B9861C03EB324404D214E40745E6397A89061C0B9AAECBB221C4E406C3997E2AA8E61C09E465A2A6F274E4068666666667F61C0C9EA56CF49174E40F8D005F52D7661C01FF98381E72A4E408499B67F656261C01B69A9BC1D2D4E40C04351A04F6261C01CD82AC1E2284E40EC7C3F355E6661C0097250C24C0B4E40E8525C55F66161C001E31934F4FF4D406431B1F9B86161C0EDDD1FEF55FF4D407C4963B48E5961C06749809A5AF64D40703D0AD7A35661C0D60451F701F44D4080608E1EBF5561C0F22900C633EC4D40008750A5665561C048C49448A2E74D40205036E50A5461C0C481902C60E24D40283108AC1C4161C0C1E78711C2BB4D40B08009DCBA4061C0CA1F0C3CF7BA4D4010751F80D43E61C0029F1F4608B74D40A47EDE54A43E61C03CFC3559A3B64D405C3D27BD6F3361C00938842A359F4D40E85BE674593161C0F7D1A92B9F8D4D409820EA3E003061C019E76F42217E4D402883A3E4D53061C08833BF9A03744D40605E807D742E61C04E7FF62345744D40182B6A300D2961C06B82A8FB00804D40D0FBC6D79E2561C0C8F484251E844D4044DD0720B52261C0E46BCF2C09884D40DC9DB5DB2E2161C0AF47E17A148A4D40303D6189071F61C02A5C8FC2F58C4D40F8F719170E1C61C02259C0046E914D405031CEDF841A61C0AB2B9FE579944D401C649291B31261C077DB85E63A954D40A07A6B60AB0F61C03E963E7441A14D40247F30F0DC0F61C026E99AC937A34D402054A9D9030F61C04EB9C2BB5CA44D40C051F2EA1C0F61C0CE920035B5A84D409CF9D51C200F61C05B2A6F4738A94D40C86C9049460F61C05D8FC2F528B04D4008D3307C440F61C073BF4351A0BB4D40285C8FC2F50B61C03E61890794B94D40080C59DDEA0B61C030FA0AD28CB94D40D8166536C80B61C04C7155D977B94D400079AF5A990B61C005392861A6B94D40F836FDD98F0B61C0E8A4F78DAFB94D40D03FC1C58A0B61C0DA5A5F24B4B94D4058087250C20961C0650113B875BB4D401C5A643BDF0861C0C32FF5F3A6BE4D407862D68BA10761C0E627D53E1DC34D4020680586AC0761C03A5D16139BC74D40D02C0950530B61C07194BC3AC7CC4D4030EBC5504E0961C0988BF84ECCCE4D40CCAFE600C10861C07411DF8959CF4D40B81457957D0861C0EC8B84B69CCF4D400825CCB4FD0761C0F2EF332E1CD04D40703D0AD7A30761C023F8DF4A76D04D403837A6272C0661C0BD3AC780ECD14D40602D3E05C00261C05F2EE23B31D34D4018601F9DBA0161C057F146E691D34D409820EA3E000161C03AEE940ED6D34D406CB2463D440061C041C1C58A1AD44D4010FC6F253B0061C0C8F484251ED44D402CBCCB457CFE60C038328FFCC1D44D40C0BC00FBE8FB60C065AF777FBCD74D4080BC57AD4CFB60C0C7BFCFB870D84D40102DB29DEFF860C0BB490C022BDB4D40242D95B723F760C0E25D2EE23BDD4D402CE7525C55EF60C00B9DD7D825E64D40CC1E680586EB60C0EE9925016ADE4D400C022B8716E860C0B7B9313D61D94D40CC0182397AE760C0FFB7921D1BD94D40C095ECD808E760C0B1389CF9D5D44D40E47E87A240E560C0079E7B0F97D04D401C5036E50AE560C0013ACC9717D04D40C01C3D7E6FE460C03A2861A6EDCF4D40988F6B43C5E360C05665DF15C1CF4D40148733BF9AE360C0252367614FCF4D40D0A5B8AAECE060C040DEAB5626C84D40D4CA845FEAE060C09AB67F65A5C54D40901EBFB7E9E060C01B2FDD2406C54D40B05582C5E1E060C055E3A59BC4BC4D405014E81379E260C0537E52EDD3B94D40483D44A33BE360C08A07944DB9B64D40E8263108ACDF60C09A7CB3CD8DB14D4080F10C1AFAE060C04052448655AC4D40D8D825AAB7DE60C06B65C22FF5A34D40E874594C6CD660C01D5A643BDF9F4D40F82CCF83BBD560C063D68BA19C984D40B0683A3B19D260C046990D32C9904D407047382D78CF60C0CDE9B298D8904D4078978BF84ECE60C017139B8F6B8B4D4008B64AB038CC60C094DE37BEF6844D40303D618907CD60C069CBB914577D4D40140A117008CA60C0E644BB0A297B4D4054E3A59BC4CA60C0763C66A032764D40044CE0D6DDC960C025404D2D5B734D40A818E76F42C860C0FD6F253B366E4D40A41EA2D11DBF60C067F2CD3637624D40D0A92B9FE5BA60C07732384A5E5D4D4030B610E4A0B660C059FFE7305F4E4D40A0BE654E97B560C02CC1E270E64B4D4044813E9127B560C08A5E46B1DC4A4D40C09F1A2FDDB460C044FF04172B4A4D40DCD26A48DCB460C0284EEE77284A4D4028E3DF675CB360C04A29E8F692464D4048D74CBED9B160C05F9D6340F6424D4098395D1613AC60C09F7B0F971C374D40F00390DAC4AE60C0A80018CFA0314D40F8F719170EAB60C0AC730CC85E234D400C5EF415A4A860C01B4CC3F0111D4D4008E1D1C611A760C03208AC1C5A184D40E422BE13B3A660C08221AB5B3D174D404833164D67A660C0FCC6D79E59164D4070641EF983A560C073DC291DAC134D4020E527D53EA260C06B9F8EC70C004D40B0BAD573D29B60C0DEEA39E97DEB4C40F4D6C056099860C07884D38217D94C4064B48EAA269560C0D869A4A5F2CE4C4054C6BFCFB89160C081ECF5EE8FBF4C405CC47762D68B60C02AE8F692C6AC4C40446E861BF08760C0ADA8C1340C9B4C4060C8EA56CF8B60C096CFF23CB88B4C40D005F52D738160C07E5C1B2AC6854C40AC6EF59CF48360C088BF266BD46F4C40D8EBDD1FEF7B60C026CCB4FD2B674C402883A3E4D57C60C040A9F6E978604C40D03FC1C58A7B60C0448B6CE7FB594C40747632384A7B60C07D96E7C1DD554C40D0747632387B60C03815A930B6544C40F8B31F29227B60C074F4F8BD4D534C40D8868A71FE7A60C0FF7DC68503514C40600CE544BB7A60C0F88DAF3DB34C4C40C8D2872EA87960C046F0BF95EC4C4C40E04F8D976E7860C0A2B94E232D4D4C4054910A630B7860C08642041C424D4C40540E2DB29D7760C03ED00A0C594D4C40808B1535987660C005FF5BC98E4D4C40D09B8A54187560C036EA211ADD4D4C406891ED7C3F7460C019ADA3AA094E4C4050EDD3F1987260C059FFE7305F4E4C40446458C51B6F60C02EEC6987BF464C40280AF4893C6A60C0E46BCF2C09404C40E0AFC91AF56960C03A7AFCDEA63F4C408872A25D856960C0ADA8C1340C3F4C4018B2BAD5736960C043EC4CA1F33E4C4044088F368E6560C0C57762D68B394C40CCCCCCCCCC6260C0A4C7EF6DFA334C4058DDEA39E95E60C0613C8386FE314C4034164D67275E60C0709EEA909B314C40C8F99B50885D60C0FE2B2B4D4A314C40E07A14AE475D60C0D4D9C9E028314C4098F56228275C60C0EAEC647094304C40C0D84290835B60C0F246E6913F304C40981C774A075960C0CA1F0C3CF72E4C40900A630B415860C0B1AC3429052D4C40205ED72FD85760C0E44EE960FD2B4C40DC240681955760C0ECDD1FEF552B4C407C74EACA675760C0E6965643E22A4C40B04B546F0D5760C0CBBE2B82FF294C4034936FB6B95660C05B0D897B2C294C40285C8FC2F55560C0C9CD70033E274C40342905DD5E5560C08CA6B393C1254C4098728577B95460C07923F3C81F244C4044C02154A95460C01D9430D3F6234C40A82688BA0F5460C067834C3272224C4030815B77F35360C044FF04172B224C40E422BE13B35360C0DAEBDD1FEF214C40A47EDE54A45260C038A6272CF1204C403C1405FA445260C0079E7B0F97204C40C8681D554D5160C0B3632310AF1F4C4080F10C1AFA4E60C050AA7D3A1E1F4C405C33F9669B4E60C0DE0720B5891B4C409CC420B0724E60C03641D47D001A4C40C0FF56B2634E60C0B7D617096D194C40B46CAD2F124E60C092442FA358164C402891442FA34D60C0AF64C74620124C4090ED7C3F354B60C023F8DF4A76104C405CE15D2EE24760C0C7850321590C4C400CB08F4E5D4760C07177D66EBB0C4C40E097FA79534360C048FE60E0B90F4C40C8D2872EA84260C0EA263108AC0C4C4098395D16134260C052F2EA1C030A4C40902232ACE24160C029D027F224094C40B87EC16ED84160C094DE37BEF6084C40F00703CFBD4160C0EAB298D87C084C40DC9DB5DB2E4160C0DAEBDD1FEF054C40200C3CF71E4160C09AB67F65A5054C40686AD95A5F4060C067F2CD3637024C40A41EA2D11D4060C0A2629CBF09014C40C4724BAB214060C05D8FC2F528004C40F8B31F29224060C00FA14ACD1E004C409C16BCE82B4060C034F9669B1BFF4B40CC457C27664060C04DC3F01131F94B405C5A0D897B4060C0E6ED08A705F74B40DC0720B5894060C0B72DCA6C90F54B40BCD05CA7914060C0EA60FD9FC3F44B4054F146E6914060C07177D66EBBF44B40601A868F884060C07177D66EBBF44B409CF9D51C204060C07177D66EBBF44B409CF9D51C204060C0F20C1AFA27F44B406414CB2DAD4260C077BE9F1A2FE94B40B8533A58FF4360C06D5B94D920E74B40B05582C5E14460C0CBF8F71917E24B40F82CCF83BB4460C0174D672783DB4B40188BA6B3934360C0AC90F2936AD74B4004DD5ED2184460C00B2E56D460CA4B4044D3D9C9E04260C03AB4C876BEBF4B40EC5F5969524160C0E8FBA9F1D2B94B406414CB2DAD4060C05001309E41AB4B40900A630B413F60C0D205F52D73A64B40E4C281902C3F60C096B7239C16A44B4020020EA14A4360C0F870C971A7984B400035B56CAD4460C00BF4893C49924B40E0F3C308E14460C001E31934F48F4B402866BD18CA4560C0B3632310AF8B4B4048ACC5A7004660C0011DE6CB0B884B401881785DBF4860C07FA4880CAB7C4B40B46CAD2F124B60C0B7F3FDD478754B40480C022B874D60C0A553573ECB6F4B40C0D4CF9B8A4E60C0FF60E0B9F76C4B40889D29745E4F60C0F4716DA8186B4B40DC9DB5DB2E5260C0A96F99D365654B4000D9EBDD1F5460C0D678E92631644B4054AEF02E175560C0A81DFE9AAC614B40182FDD24065460C0E06C73637A5E4B403C3F8C101E5460C055E3A59BC45C4B408043A852B35360C0597380608E5A4B40044CE0D6DD9560C0CDCCCCCCCC544B406866666666DE60C01E03B2D7BB1B4B4000000000000061C00100000000004B400000000000E060C01E03B2D7BB5B4A400000000000F862C0132C0E677E614C4000000000002063C00100000000004C4000000000000064C00100000000C04A40F8B31F2922FA64C03433333333B34940F8B31F29221266C0B0C91AF51011494034333333332366401D03B2D7BB1B49402EE7525C555D64409A99999999D946400000000000E063404A63B48EAA0A494000000000002065400100000000004B40000000000040654003F1BA7EC1564B406766666666466540EACF7EA488684B4000000000008066400100000000004E4068666666668665C03433333333035040E8C6F484251F65C00000000000405040E8C6F484251F65C00000000000C0504078A1B94E231F65C00000000000005140')
    ) as q(polygon)
)
SELECT 'geog_precision_pazafir', _ST_DistanceUnCached(pt.point, ply.polygon), ST_Distance(pt.point, ply.polygon) FROM pt, ply;


-- Clean up spatial_ref_sys
DELETE FROM spatial_ref_sys WHERE srid = 4326;
    