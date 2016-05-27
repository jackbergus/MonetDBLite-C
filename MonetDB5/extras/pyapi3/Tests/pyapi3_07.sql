# A more complex aggregation, perform a quantile using MonetDB/Python
# Also perform two aggregations in the same SELECT() statement, which could potentially fail
START TRANSACTION;

CREATE TABLE rval(val double);
INSERT INTO rval VALUES (33078.94),(38306.16),(15479.68),(34616.68),(28974.00),(44842.88),(63066.32),(86083.65),(70822.15),(39620.34),(3581.56),(52411.80),(35032.14),(39819.00),(25179.60),(31387.20),(68864.50),(53697.73),(17273.04),(12423.15),(84904.50),(46245.92),(74398.68),(55806.45),(7216.50),(26963.72),(40995.52),(3091.16),(5393.68),(46642.64),(6978.84),(39224.92),(34948.80),(8803.10),(49780.56),(20768.41),(24817.98),(8558.10),(33708.00),(44788.54),(13026.23),(42317.50),(42877.74),(45516.80),(74029.62),(48691.20),(69449.25),(45538.29),(63681.20),(49288.36),(46194.72),(58892.42),(57788.48),(52982.88),(68665.20),(30837.66),(52933.66),(26050.42),(37545.27),(37916.72),(78670.80),(5069.36),(21910.92),(10159.55),(48887.96),(23784.30),(33001.13),(4925.01),(84764.66),(84721.88),(26424.60),(40541.31),(46006.50),(63853.40),(54433.44),(55447.68),(29539.20),(3279.00),(72225.30),(25852.69),(9761.92),(20974.98),(1186.00),(14182.41),(50996.73),(30371.88),(30631.75),(3330.36),(61348.50),(49876.20),(57583.11),(47574.50),(38862.87),(58554.90),(24241.36),(61777.05),(39272.24),(29739.92),(1424.37),(14056.42),(17667.10),(11111.00),(7988.00),(77983.50),(48755.52),(33803.00),(40540.06),(67135.62),(18357.08),(52442.32),(93186.24),(45513.00),(15085.32),(41628.33),(46658.20),(28227.75),(22373.25),(9740.88),(46777.62),(29630.67),(38598.40),(47242.36),(73538.82),(57043.44),(50636.19),(48018.20),(41729.04),(34418.12),(1669.60),(16003.26),(62322.24),(28972.62),(18229.77),(39843.06),(45808.20),(74526.00),(4776.44),(25027.38),(69465.21),(39268.16),(41418.63),(33784.02),(22208.40),(45455.76),(17000.50),(27539.40),(48872.95),(38958.92),(44976.18),(21248.40),(12623.52),(48456.53),(31864.14),(38709.66),(34374.34),(30788.20),(26558.22),(68214.24),(39220.94),(57690.52),(19399.76),(3743.56),(61118.48),(12037.35),(33592.32),(7211.60),(22305.96),(25063.00),(28497.04),(47132.88),(39444.76),(42504.00),(43901.71),(52431.30),(29793.28),(5327.19),(50876.74),(19232.55),(97305.67),(50888.52),(67556.08),(21002.41),(66152.27),(9737.92),(45266.20),(42240.42),(28499.76),(31851.80),(22761.90),(4113.80),(26827.50),(41892.75),(12593.97),(23601.90),(41692.79),(31584.81),(1162.13),(24581.70),(50557.68),(14573.92),(29228.16),(26422.20),(11039.10),(61845.63),(47987.94),(56021.17),(29743.55),(22762.65),(78736.71),(8743.52),(22919.74),(35858.75),(21946.82),(1758.75),(55096.14),(26785.60),(23407.65),(59909.50),(47205.18),(87033.00),(60417.30),(17712.48),(36585.36),(68247.37),(20780.16),(72293.40),(4368.28),(5048.64),(4954.74),(54045.90),(39999.12),(57563.28),(16359.36),(54527.00),(4612.16),(50506.16),(40497.45),(55633.95),(3275.00),(62271.36),(23611.70),(24647.94),(25438.32),(3973.14),(34715.20),(29666.13),(37526.16),(4633.17),(61040.76),(54487.23),(72980.38),(6737.88),(1639.66),(71792.16),(10537.76),(10466.00),(26247.68),(69668.84),(65707.00),(51539.67),(28694.16),(82917.20),(49276.80),(8702.47),(15191.04),(49803.60),(69189.30),(35341.55),(41014.25),(58557.24),(26162.36),(24300.22),(45071.04),(4206.75),(6161.46),(96189.50),(33442.76),(30380.13),(38319.44),(83811.64),(47582.32),(31451.60),(45458.00),(79747.01),(77990.85),(39096.80),(72959.64),(54077.10),(71292.55),(33738.76),(13612.68),(91891.50),(43783.78),(94266.69),(50914.08),(21660.38),(57531.35),(45742.75),(12089.64),(89009.80),(71153.76),(23553.66), (51117.50),(2430.32),(8974.35),(30804.82),(32940.18),(23333.71),(49281.00),(13164.32),(37906.56),(22226.26),(11219.56),(22654.06),(40026.27),(33059.13),(37762.14),(15062.64),(28890.42),(32644.20),(20702.24),(22704.57),(50481.25),(24130.92),(74332.32),(34994.40),(13903.60),(37066.40),(3393.24),(7106.65),(60810.00),(25331.58),(10594.62),(47961.16),(67620.22),(6671.45),(68735.45),(82977.85),(71660.02),(32957.25),(6531.55),(45613.71),(48299.64),(59234.57),(15327.20),(9595.08),(26325.86),(46616.59),(40406.86),(14641.32),(81496.82),(9854.73),(74760.66),(25000.78),(40092.96),(66561.50),(11785.62),(22900.50),(62308.44),(21610.26),(50298.43),(55688.25),(4360.44),(76683.36),(38428.60),(60203.99),(61073.68),(37865.62),(39313.44),(32447.36),(52241.38),(49518.40),(43200.40),(24502.80),(22918.86),(55768.00),(48964.95),(52551.30),(28648.44),(27872.52),(70064.40),(14974.30),(35662.19),(56936.54),(66119.62),(10207.12),(17033.28),(14601.44),(9956.59),(58890.58),(41845.83),(19267.04),(66923.38),(1731.60),(84878.64),(79274.80),(25084.56),(35617.92),(80592.96),(48576.46),(72112.80),(3875.70),(11901.70),(24776.82),(73027.76),(53982.18),(20065.50),(13895.75),(31471.68),(24777.06),(41614.50),(37370.08),(26223.00),(65776.62),(19999.44),(76255.49),(3745.60),(49739.81),(1522.61),(4011.81),(63684.39),(59516.16),(29323.80),(23093.25),(16811.81),(8758.95),(37327.40),(69144.30),(23938.92),(44553.18),(51571.60),(71556.03),(1725.63),(29452.25),(16625.70),(87388.96),(28378.25),(51781.41),(7655.60),(73945.00),(36857.45),(11514.88),(43648.48),(13128.00),(4252.08),(5444.43),(36553.22),(72858.66),(9694.60),(38342.40),(69306.00),(3120.90),(42477.27),(47097.00),(54400.92),(1315.31),(45823.12),(2854.66),(55803.15),(51422.36),(55572.34),(68914.35),(37382.40),(34163.64),(48573.36),(80042.34),(55848.32),(70855.65),(12243.33),(33009.90),(26681.16),(25848.36),(75757.50),(10967.44),(48747.50),(48075.52),(1730.75),(40962.78),(10505.28),(56678.44),(38891.67),(15703.36),(38537.42),(12828.60),(64891.19),(68377.05),(71720.50),(21955.34),(54577.92),(17706.60),(61107.50),(68268.40),(41993.16),(51239.88),(54694.40),(30655.56),(63255.18),(5891.91),(64142.40),(92632.77),(3815.88),(19473.86),(51520.65),(51084.00),(16196.50),(8877.00),(13861.44),(3381.32),(24665.60),(52501.24),(25411.89),(54177.64),(6834.66),(71705.08),(10710.80),(38682.86),(15073.85),(35360.00),(58071.68),(47521.50),(18509.92),(40557.44),(29322.45),(11000.61),(21844.90),(32601.81),(31470.60),(36100.57),(21740.64),(83298.18),(18930.40),(64056.72),(72838.08),(1786.62),(52647.10),(37067.86),(44081.55),(18205.33),(3783.54),(85571.49),(5849.52),(33782.22),(28732.96),(83153.40),(73555.20),(4075.05),(3118.80),(8138.46),(36137.01),(26610.78),(37466.10),(49742.40),(29889.36),(50739.50),(38667.24),(16253.82),(65617.64),(33014.07),(14326.72),(24261.00),(28796.80),(3725.70),(11921.64),(10257.78),(5750.05),(45446.00), (17588.06),(58853.60),(27971.45),(10656.90),(57346.77),(9374.70),(75804.08),(32063.08),(5650.40),(36435.63),(38164.41),(26169.46),(72684.80),(18133.22),(46942.00),(38766.30),(8015.42),(79163.91),(41580.42),(53114.76),(1580.56),(63082.93),(44242.16),(46610.19),(17501.51),(34650.49),(46800.00),(26907.09),(94122.14),(21262.12),(32346.86),(17101.32),(53950.65),(8463.00),(48213.90),(63123.45),(1665.71),(60231.21),(7667.45),(47083.12),(61605.74),(42095.20),(1343.32),(33195.69),(21542.74),(9350.64),(3321.18),(7818.72),(23729.79),(92777.76),(68780.65),(20628.02),(33899.40),(70624.32),(49982.04),(97996.57),(42286.00),(40538.52),(78557.40),(33675.30),(1855.72),(45802.40),(35634.75),(76995.54),(33051.46),(45376.52),(80431.20),(32047.74),(53601.60),(74377.03),(67130.56),(13289.65),(60034.04),(10733.80),(44480.16),(41852.91),(52757.68),(67084.38),(56923.11),(58016.58),(52183.53),(41796.86),(24143.22),(11522.70),(53651.39),(1195.16),(34378.08),(49889.56),(29115.56),(73990.00),(47481.69),(8943.55),(27596.10),(78630.21),(13981.14),(63693.70),(42942.02),(36193.03),(7695.28),(1613.47),(48589.10),(36581.62),(26664.60),(74965.28),(15522.21),(35092.80),(42672.35),(30629.04),(37608.58),(44624.58),(12651.65),(62202.56),(61484.28),(54567.04),(1355.30),(28151.50),(26465.80),(35057.22),(28908.96),(83643.36),(25207.36),(19820.35),(14386.41),(72228.40),(18485.32),(55067.52),(43474.55),(31031.37),(47745.52),(29422.58),(2945.94),(25120.85),(62466.36),(9058.70),(65549.52),(10062.50),(6880.86),(23481.00),(19418.70),(50449.20),(48316.94),(45184.66),(13452.39),(26625.75),(17861.28),(35334.39),(90564.80),(3251.18),(25135.65),(84078.34),(35755.00),(86053.12),(30387.37),(17123.99),(22126.44),(31965.76),(12708.60),(37397.62),(4504.24),(45836.93),(21105.36),(42308.40),(51347.52),(47500.50),(15723.60),(76500.49),(36033.90),(21341.10),(37137.45),(41796.83),(25098.75),(43206.24),(46047.38),(30043.50),(34571.28),(30748.96),(45840.00),(82004.44),(33820.50),(46099.17),(3397.24),(47778.90),(69223.67),(91977.59),(58750.90),(52786.47),(62121.24),(7434.76),(42396.51),(45894.50),(21585.84),(36288.86),(26472.88),(10679.13),(14117.74),(25970.91),(69998.25),(9920.20),(39624.90),(14292.50),(63817.32),(6285.60),(32489.24),(71009.25),(43079.12),(9855.00),(48978.29),(70433.58),(4318.11),(36108.34),(15791.36),(73106.88),(2448.14),(22662.24),(30877.35),(37857.40), (50969.02),(32624.97),(34558.94),(13755.30),(25223.31),(40277.79),(17861.64),(65988.00),(15936.10),(14997.29),(64064.00),(51966.96),(52805.72),(36718.20),(20805.19),(8295.84),(37582.86),(56486.10),(3653.30),(54522.60),(24802.89),(33404.00),(37328.80),(13225.32),(40546.22),(1463.46),(34791.02),(5409.20),(85437.38),(88036.83),(56408.64),(13472.20),(33003.00),(14060.86),(26438.31),(63469.35),(26018.16),(1593.53),(50892.26),(14837.85),(40720.32),(16219.50),(42050.58),(43666.56),(6762.30),(22793.22),(74180.98),(66909.57),(33128.64),(22320.20),(38378.34),(43557.40),(26036.82),(42289.87),(53112.35),(52308.32),(10369.52),(38352.00),(33150.40),(5906.61),(19474.35),(66500.26),(5394.80),(14454.37),(8472.00),(20469.41),(24496.32),(64178.36),(51757.92),(21662.47),(45028.17),(58919.40),(39170.52),(7262.00),(95081.76),(91879.36),(21366.93),(33787.03),(14133.84),(49683.66),(6958.48),(85997.31),(12781.10),(8177.68),(18035.05),(60374.14),(74031.32),(20623.13),(22491.75),(42239.60),(12921.61),(3461.52),(13351.50),(44549.11),(15360.29),(60428.16),(31496.58),(41316.75),(6810.84),(15805.30),(7042.88),(89900.19),(13895.42),(61521.68),(61448.64),(32046.24),(37480.32),(2340.38),(39557.44),(18200.27),(3273.09),(9456.48),(31398.72),(43460.01),(66006.15),(44958.54),(10206.54),(1315.38),(21288.54),(42119.31),(41441.28),(80484.36),(49024.30),(48003.12),(70867.50),(15073.96),(76394.25),(53551.96),(19352.48),(9123.31),(35496.36),(94749.18),(12342.60),(30351.30),(65765.00),(15144.90),(57386.10),(34538.58),(19428.70),(70677.12),(43821.60),(63943.60),(37872.72),(36188.37),(52178.62),(37294.92),(24496.84),(33844.27),(48572.64),(25790.57),(10522.32),(2070.96),(1950.93),(29551.75),(57781.44),(8996.05),(30341.52),(60787.86),(51960.46),(64742.12),(58433.40),(73510.20),(48889.98),(4753.35),(22681.00),(23698.56),(7552.20),(10831.94),(91189.44),(56404.14),(1327.25),(96033.63),(51924.84),(20720.20),(27902.22),(27802.51),(69910.68),(45702.72),(36617.60),(67918.14),(3827.88),(15084.30),(91719.18),(81586.72),(18072.02),(30234.42),(16212.42),(59386.10),(34744.80),(22934.10),(10566.15),(42720.77),(59257.11),(38232.32),(13322.20),(60576.40),(58996.08),(65090.55),(24159.90),(7203.28),(19335.36),(7287.20),(42766.00),(29307.75),(29372.00),(72521.10),(32908.00),(34000.92),(85306.84),(11693.55),(22938.95),(27109.06),(6993.00);

# [ 3824, 78690   ]

CREATE AGGREGATE rquantile(v double, q double) RETURNS integer LANGUAGE PYTHON3YTHON3
{ 
	return numpy.percentile(v,q[0] * 100) 
};
SELECT rquantile(val,0.05) AS q5, rquantile(val,0.95) AS q95 FROM rval;

DROP AGGREGATE rquantile;
DROP TABLE rval;

ROLLBACK;
