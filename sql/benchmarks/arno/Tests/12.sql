SELECT MODEL110.is_mutagen, count(distinct MODEL110.model_id ) FROM MODEL MODEL110, BOND BOND111, BOND T1008290387970  WHERE MODEL110.model_id=BOND111.model_id AND MODEL110.model_id=T1008290387970.model_id group by MODEL110.is_mutagen;
