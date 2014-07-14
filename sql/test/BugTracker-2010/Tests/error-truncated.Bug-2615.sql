START TRANSACTION;

CREATE TABLE "sys"."uitspraken" (
        "id"             int           NOT NULL,
        "ljn"            char(6)       NOT NULL,
        "gepubliceerd"   boolean       NOT NULL,
        "instantie"      varchar(63)   NOT NULL,
        "datum"          date          NOT NULL,
        "publicatie"     date,
        "zaaknummers"    varchar(100)  NOT NULL,
        "uitspraak"      CHARACTER LARGE OBJECT,
        "conclusie"      CHARACTER LARGE OBJECT,
        "zittingsplaats" varchar(16),
        "rechtsgebied"   varchar(24),
        "sector"         varchar(20),
        "soort"          varchar(32),
        "indicatie"      CHARACTER LARGE OBJECT,
        "kop"            CHARACTER LARGE OBJECT,
        CONSTRAINT "uitspraken_id_pkey" PRIMARY KEY ("id"),
        CONSTRAINT "uitspraken_ljn_unique" UNIQUE ("ljn")
);
COPY 2 RECORDS INTO uitspraken FROM STDIN DELIMITERS '\t', '\n' NULL as '';
277351	AA7351	1	Rechtbank 's-Gravenhage	2000-08-04		AWB 00/6928, 00/6929, 00/6930	Arrondissementsrechtbank te 's-Gravenhage\nzittinghoudende te Haarlem\nfungerend president\nenkelvoudige kamer voor Vreemdelingenzaken\n\nU I T S P R A A K\n\nartikel 8:81 en 8:86 Algemene Wet Bestuursrecht (Awb)\nartikel 33a, 34a en 34j Vreemdelingenwet (Vw)\n\nreg.nr: AWB 00/6928 VRWET H (voorlopige voorziening)\nAWB 00/6929 VRWET H (beroepszaak)\nAWB 00/6930 VRWET H (vrijheidsontneming)\n\ninzake: A, geboren op [...] 1964, van Iraakse\nnationaliteit, verblijvende in het Grenshospitium te\nAmsterdam, verzoeker,\ngemachtigde: mr. M.R. van der Linde, advocaat te Utrecht,\n\ntegen: de Staatssecretaris van Justitie, verweerder,\ngemachtigden: mr. M. Ramsaroep en mr. T.H.T.W. Zee, werkzaam bij de onder verweerder ressorterende Immigratie- en Naturalisatiedienst te 's-Gravenhage.\n\n1.  GEGEVENS INZAKE HET GEDING\n\n1.1. Aan de orde is het verzoek om voorlopige voorziening hangende het beroep van verzoeker tegen de beschikking van verweerder van 21 juli 2000. Deze beschikking is genomen in het kader van de zogenoemde AC-procedure en behelst de  \nniet-inwilliging van de aanvraag om toelating als vluchteling en strekt tevens tot het niet verlenen van een vergunning tot verblijf wegens klemmende redenen van humanitaire aard. Verzocht wordt om schorsing van de beslissing van  \nverweerder om uitzetting niet achterwege te laten totdat op het beroep tegen voormelde beschikking is beslist.\n\n1.2 Voorts is aan de orde het beroep gericht tegen de vrijheidsontnemende maatregel van artikel 7a Vw die verweerder verzoeker met ingang van 18 juli 2000 heeft opgelegd. Dit beroep strekt tevens tot toekenning van schadevergoeding.  \n\n1.3 De openbare behandeling van de geschillen heeft plaatsgevonden op 2 augustus 2000. Daarbij hebben verzoeker en verweerder bij monde van hun gemachtigden hun standpunten nader uiteengezet. Voorts is verzoeker ter zitting gehoord.  \n\n2. OVERWEGINGEN\n\n2.1 Ingevolge artikel 8:81 van de Awb kan, indien tegen een besluit bij de rechtbank beroep is ingesteld, de president van de rechtbank die bevoegd is in de hoofdzaak op verzoek een voorlopige voorziening treffen indien onverwijlde  \nspoed, gelet op de betrokken belangen, zulks vereist.\n\n2.2 Op grond van artikel 8:86 van de Awb heeft de president na behandeling ter zitting van het verzoek om een voorlopige voorziening de bevoegdheid om, indien hij van oordeel is dat nader onderzoek redelijkerwijs niet kan bijdragen  \naan de beoordeling van de zaak, onmiddellijk uitspraak te doen in de hoofdzaak. Er bestaat in dit geval aanleiding om van deze bevoegdheid gebruik te maken.\n\n2.3 De AC-procedure voorziet in een afdoening van asielaanvragen binnen 48 uur. Deze procedure leent zich slechts voor die asielaanvragen waaromtrent binnen deze korte termijn procedureel en inhoudelijk naar behoren kan worden  \nbeslist.\n\n2.4 Bij de beoordeling of in het onderhavige geval van een zodanige aanvraag sprake is, is het volgende van belang.\n\n2.5 Ingevolge het door verweerder gevoerde beleid, neergelegd in hoofdstuk B7/3 Vc 1994, bestaat de AC-procedure uit twee fasen. Het eerste deel betreft in ieder geval de formele indiening van de asielaanvraag en het onderzoek naar  \nidentiteit, nationaliteit en reisroute. Het tweede deel betreft de beoordeling van de asielaanvraag. Voor het tweede deel zijn maximaal 24 procesuren beschikbaar. Indien de eerste fase langer dan 24 uur duurt, gaat dit ten koste van  \nde tijd die beschikbaar is voor de tweede fase.\nIn principe vindt doorverwijzing naar een OC plaats indien de AC-procedure langer duurt dan 48 procesuren.\n\n2.6 Ter beoordeling ligt allereerst voor de vraag of het tweede deel van de AC-procedure is afgerond binnen de voor dat deel maximaal beschikbare termijn van 24 procesuren. Hierover overweegt de president als volgt.\n\n2.7 Tussen partijen is niet in geschil dat (een afschrift van) de beslissing op de asielaanvraag van verzoeker aan verzoeker is uitgereikt op een moment dat reeds 23 uur en 54 minuten waren verstreken van de beschikbare tijd van 24  \nprocesuren.\n\n2.8 In hoofdstuk B7/3.1 Vc 1994 is bepaald dat een beschikking voor het einde van de AC-termijn wordt uitgereikt en de rechtsbijstandverlener een uur de tijd heeft om aan te geven of een rechtsmiddel wordt aangewend. Hieruit kan  \nworden afgeleid dat het laatste uur van eerdergenoemde termijn van 24 procesuren exclusief gereserveerd is voor de rechtsbijstandverlener en dat verweerder van dit uur geen gebruik mag maken. Nu verweerder, zoals blijkt uit het  \nvoorgaande, van bedoeld uur wel gebruik heeft gemaakt, heeft verweerder in strijd gehandeld met zijn eigen beleid aangaande de AC-procedure.\n\n2.9 De gemachtigde van verweerder heeft ter zitting betoogd dat verzoeker door het vorenstaande niet is benadeeld omdat het rechtsmiddel niet is aangewend binnen het uur dat de rechtshulpverlening alsnog heeft kunnen gebruiken, maar  \npas enkele uren daarna. Dit betoog faalt naar het oordeel van de president.\nDaartoe is het navolgende redengevend.\n\n2.10 Verweerder heeft zich blijkens zijn eigen beleid ten doel gesteld om de AC-procedure, met inachtneming van de eisen van zorgvuldigheid, binnen 48 uren af te ronden. Dit impliceert dat de tijd die de rechtsbijstandverlening  \ntoekomt in ieder geval in acht moet worden genomen en dat, zoals hiervoor al is opgemerkt, doorverwijzing naar een OC behoort plaats te vinden indien de procedure langer duurt dan 48 uren, tenzij duidelijk is dat beide partijen met  \neen overschrijding instemmen.\nIndien, zoals in casu, de 48-uursprocedure alleen kan worden gehaald ten detrimente van het laatste uur dat aan de rechtsbijstandsverlening toekomt en de procedure desondanks wordt voortgezet, moet daarom in beginsel worden  \naangenomen dat verzoeker hierdoor in zijn belangen is geschaad. Dat het rechtsmiddel pas na enige tijd is ingesteld is hierbij\nirrelevant, reeds omdat uit het beleid niet kan worden afgeleid dat het rechtsmiddel binnen de beschikbare termijn van 48 procesuren daadwerkelijk moet worden aangewend.\n\n2.11 Verweerder heeft ter zitting voorts aangevoerd dat, wat er ook zij van het vorenstaande, de termijnoverschrijding desondanks voor rekening van verzoeker moet komen. Verweerder heeft daartoe, onder verwijzing naar hoofdstuk  \nB7/3.2 en B7/5.2 Vc 1994, betoogd dat de rechtsbijstandverlener de voor de voor- en nabespreking van het nader gehoor beschikbare tijd ruimschoots heeft overschreden. Dienaangaande overweegt de president als volgt.\n\n2.12 Er is, aldus hoofdstuk B7/3.2 Vc 1994, geen sprake van termijnoverschrijding (onder meer) indien de asielzoeker binnen de 48 procesuren meer tijd benut met rechtsbijstand dan de termijnen die daarvoor formeel beschikbaar zijn  \n(de extra tijd geldt niet als proceduretijd en is in het belang van de asielzoeker).\nIngevolge hoofdstuk B7/5.2 Vc 1994 heeft de asielzoeker voor aanvang van het nader gehoor gedurende maximaal twee uur de gelegenheid om met behulp van een rechtsbijstandverlener het verslag van het eerste gehoor en overige  \nonderzoeksresultaten uit de eerste fase na te bespreken en zich voor te bereiden op het nader gehoor.\nNa afronding van het nader gehoor krijgt de asielzoeker ingevolge hoofdstuk B7/5.3 Vc 1994 maximaal drie uur de gelegenheid te reageren op het voornemen van verweerder de asielaanvraag niet in te willigen en het rapport van het  \nnader gehoor na te bespreken. De rechtsbijstandverlener kan binnen die termijn (schriftelijk) reageren op het voornemen van de IND.\n\n2.13 In een tweetal uitspraken van de president van deze rechtbank en nevenzittingsplaats van 14 juli 2000 (onder meer geregistreerd onder de nummers AWB 00\\6203 VRWET H t/m AWB 00/6205 VRWET H) is overwogen dat verweerder reeds nu  \ngehouden kan worden aan zijn primaire verantwoordelijkheid voor bewaking van de 48-uurstermijn. Voorts is overwogen dat dit betekent dat verweerder de rechtsbijstandverlener er in een voorkomend geval op moet wijzen dat de voor  \nrechtsbijstand beschikbare tijd is overschreden. Een en ander brengt met zich mee dat indien in het dossier een deugdelijke verslaglegging van vertragende gebeurtenissen of omstandigheden ontbreekt, aangenomen zal moeten worden dat  \nverweerder de\nrechtsbijstandverlener niet aan de hem toekomende tijd heeft gehouden en de termijnoverschrijding aan verweerder, als bewaker van de door hem zelf ingevoerde 48-uurstermijn, zal worden toegerekend.\n\n2.14 Uit de beschikbare stukken kan niet worden afgeleid dat verweerder de rechtsbijstandverlener op het moment van overschrijding van de voor de voor- en nabespreking van het nader gehoor beschikbare termijnen op die overschrijding  \nheeft gewezen. Ter zitting heeft de gemachtigde van verweerder hieromtrent niet meer duidelijkheid kunnen verschaffen. Deze omstandigheid brengt de president, gelet op hetgeen in 2.13 is overwogen, tot het oordeel dat verweerder te  \nkort is geschoten in zijn primaire verantwoordelijkheid voor de bewaking van de 48-uurstermijn. De gemachtigde van verweerder heeft ter zitting weliswaar aangegeven dat de Afdeling Planning van het Aanmeldcentrum Schiphol inmiddels  \nis verzocht de processtappen duidelijker op te nemen in het dossier, doch deze omstandigheid doet niets af aan het vorenstaande, nu van uitvoering van dit verzoek in de onderhavige zaak niet is gebleken.\n\n2.15 Het beroep tegen de afwijzende beschikking op de asielaanvraag van verzoeker zal dan ook gegrond worden verklaard. Gegeven deze beslissing bestaat geen aanleiding meer voor toewijzing van het verzoek om voorlopige voorziening.\n\n2.16 Ten aanzien van de op 18 juli 2000 aan verzoeker opgelegde vrijheidsbenemende maatregel overweegt de rechtbank als volgt.\n\n2.17 Gelet op voormelde gegrondverklaring van het beroep is de grond voor de voortgezette toepassing van de vrijheidsbenemende maatregel komen te ontbreken. Het beroep tegen de voortduring van de maatregel na de beslissing op de  \naanvraag is derhalve gegrond.\n\n2.18 Het betoog van de gemachtigde van verzoeker dat oplegging van de vrijheidsbenemende maatregel van meet af aan onrechtmatig is, nu verwijderingen naar (Noord-)Irak de facto niet\nplaatsvinden, faalt naar het oordeel van de rechtbank. Hierbij is in aanmerking genomen de mededeling van de gemachtigde van verweerder ter zitting dat (vrijwillige) terugkeer naar\n(Noord-)Irak mogelijk is door tussenkomst van de Internationale Organisatie voor Migratie (IOM). De rechtbank ziet geen aanleiding om aan de inhoud van deze mededeling te twijfelen en verwijst in dit verband voorts naar de uitspraak  \nvan deze rechtbank en nevenzittingsplaats van 11 juli 2000 (geregistreerd onder de nummers AWB 00/5810 VRWET H t/m AWB 00/5812 VRWET H). Bovendien is in dit verband nog van belang dat verzoeker door verweerder is geclaimd bij de  \nGeorgische luchtvaartmaatschappij waarmee hij naar Nederland is gekomen en verweerder derhalve in eerste instantie, indien verzoeker Nederland zal dienen te verlaten, zal pogen verzoeker naar Georgië te verwijderen.\n\n2.19 Nu de toepassing van de maatregel, gelet op het vorenstaande, vanaf 21 juli 2000 onrechtmatig is geweest, wordt, gelet op het in het Aanmeldcentrum Schiphol en het Grenshospitium te Amsterdam geldende regime, een  \nschadevergoeding toegekend van totaal f 1.450,--, zijnde een vergoeding van f 150,-- voor een dag in het Aanmeldcentrum en een vergoeding van f 100,- per dag voor 13 dagen in het Grenshospitium.\n\n2.20 In dit geval ziet de president aanleiding verweerder met toepassing van artikel 8:75, eerste lid, Awb te veroordelen in de door verzoeker gemaakte proceskosten, zulks met\ninachtneming van het Besluit proceskosten bestuursrecht. De kosten zijn op voet van het bepaalde in het bovengenoemde Besluit vastgesteld op f 1.420,-- (1 punt voor het\nverzoekschrift en 1 punt voor het verschijnen ter zitting, wegingsfactor 1). Aangezien ten behoeve van verzoeker een toevoeging is verleend krachtens de Wet op de rechtsbijstand, dient ingevolge het tweede lid van artikel 8:75 Awb  \nde betaling van dit bedrag te geschieden aan de griffier.\n\n2.21 De president ziet tevens aanleiding om met toepassing van artikel 8:82, vierde lid, Awb, te bepalen dat verweerder aan verzoeker het zowel voor de hoofdzaak als voor het verzoek om voorlopige voorziening betaalde griffierecht  \nad telkens f 50,-- zal vergoeden.\n\n3. BESLISSING\n\nDe fungerend president:\n\n3.1 verklaart het beroep gegrond en vernietigt de bestreden beschikking van 21 juli 2000;\n\n3.2 draagt verweerder op een nieuwe beschikking te nemen op de aanvraag van 19 juli 2000;\n\n3.3 wijst het verzoek om een voorlopige voorziening af;\n\n3.4 veroordeelt verweerder in de proceskosten ad f 1.420,-- onder aanwijzing van de Staat der Nederlanden als rechtspersoon die deze kosten aan de griffier van deze rechtbank, nevenzittingsplaats Haarlem, moet voldoen;\n\n3.5 wijst de Staat der Nederlanden aan als rechtspersoon ter vergoeding van het door verzoeker betaalde griffierecht ad tweemaal f 50,--.\n\nDe rechtbank:\n\n3.6 verklaart het beroep tegen de vrijheidsontnemende maatregel ex artikel 7a, tweede en derde lid, Vw gegrond en beveelt de opheffing van de maatregel van de vreemdeling met ingang van\n4 augustus 2000;\n\n3.7 wijst het verzoek om toekenning van schadevergoeding toe;\n\n3.8 kent aan de vreemdeling ten laste van de Staat (Ministerie van Justitie) een vergoeding toe van f 1.450,-- (zegge: veertienhonderdenvijftig), uit te betalen door de griffier van deze rechtbank, nevenzittingsplaats Haarlem;\n\n3.9 veroordeelt verweerder in de proceskosten ad f 710,--, onder aanwijzing van de Staat der Nederlanden als rechtspersoon, die deze kosten aan de griffier van deze rechtbank, nevenzittingsplaats Haarlem, moet voldoen.\n\nDeze uitspraak is gedaan door mr. G.F.H. Lycklama à Nijeholt, fungerend president, tevens lid van de enkelvoudige kamer voor vreemdelingenzaken, en uitgesproken in het openbaar op 4 augustus 2000, in tegenwoordigheid van mr. J.E.  \nBierling als griffier.\n\nVoornoemd lid van de enkelvoudige kamer voor vreemdelingenzaken beveelt de tenuitvoerlegging van de in deze uitspraak toegekende schadevergoeding ten bedrage van f 1.450,-- (zegge: veertienhonderdenvijftig).\n\nAldus gedaan op 4 augustus 2000, door mr. G.F.H. Lycklama à Nijeholt, lid van de enkelvoudige kamer voor vreemdelingenzaken.\n\nafschrift verzonden op: 4 augustus 2000\nRECHTSMIDDEL\n\nTegen deze uitspraak staat hoger beroep open bij het Gerechtshof te 's-Gravenhage, voor zover het betreft de beslissing inzake schadevergoeding. De Officier van Justitie kan binnen veertien dagen na de uitspraak en de vreemdeling  \nbinnen een maand na de betekening van de uitspraak hoger beroep instellen door het indienen van een verklaring als bedoeld in de artikelen 449 en 451a van het Wetboek van Strafvordering bij de Arrondissementsrechtbank te  \n's-Gravenhage, zittingsplaats Haarlem.\n\nVoor het overige staat geen gewoon rechtsmiddel open.\n		Haarlem	Vreemdelingen		Voorlopige voorziening+bodemzaak		
277351	AA7351	1	Rechtbank 's-Gravenhage	2000-08-04		AWB 00/6928, 00/6929, 00/6930	Arrondissementsrechtbank te 's-Gravenhage\nzittinghoudende te Haarlem\nfungerend president\nenkelvoudige kamer voor Vreemdelingenzaken\n\nU I T S P R A A K\n\nartikel 8:81 en 8:86 Algemene Wet Bestuursrecht (Awb)\nartikel 33a, 34a en 34j Vreemdelingenwet (Vw)\n\nreg.nr: AWB 00/6928 VRWET H (voorlopige voorziening)\nAWB 00/6929 VRWET H (beroepszaak)\nAWB 00/6930 VRWET H (vrijheidsontneming)\n\ninzake: A, geboren op [...] 1964, van Iraakse\nnationaliteit, verblijvende in het Grenshospitium te\nAmsterdam, verzoeker,\ngemachtigde: mr. M.R. van der Linde, advocaat te Utrecht,\n\ntegen: de Staatssecretaris van Justitie, verweerder,\ngemachtigden: mr. M. Ramsaroep en mr. T.H.T.W. Zee, werkzaam bij de onder verweerder ressorterende Immigratie- en Naturalisatiedienst te 's-Gravenhage.\n\n1.  GEGEVENS INZAKE HET GEDING\n\n1.1. Aan de orde is het verzoek om voorlopige voorziening hangende het beroep van verzoeker tegen de beschikking van verweerder van 21 juli 2000. Deze beschikking is genomen in het kader van de zogenoemde AC-procedure en behelst de  \nniet-inwilliging van de aanvraag om toelating als vluchteling en strekt tevens tot het niet verlenen van een vergunning tot verblijf wegens klemmende redenen van humanitaire aard. Verzocht wordt om schorsing van de beslissing van  \nverweerder om uitzetting niet achterwege te laten totdat op het beroep tegen voormelde beschikking is beslist.\n\n1.2 Voorts is aan de orde het beroep gericht tegen de vrijheidsontnemende maatregel van artikel 7a Vw die verweerder verzoeker met ingang van 18 juli 2000 heeft opgelegd. Dit beroep strekt tevens tot toekenning van schadevergoeding.  \n\n1.3 De openbare behandeling van de geschillen heeft plaatsgevonden op 2 augustus 2000. Daarbij hebben verzoeker en verweerder bij monde van hun gemachtigden hun standpunten nader uiteengezet. Voorts is verzoeker ter zitting gehoord.  \n\n2. OVERWEGINGEN\n\n2.1 Ingevolge artikel 8:81 van de Awb kan, indien tegen een besluit bij de rechtbank beroep is ingesteld, de president van de rechtbank die bevoegd is in de hoofdzaak op verzoek een voorlopige voorziening treffen indien onverwijlde  \nspoed, gelet op de betrokken belangen, zulks vereist.\n\n2.2 Op grond van artikel 8:86 van de Awb heeft de president na behandeling ter zitting van het verzoek om een voorlopige voorziening de bevoegdheid om, indien hij van oordeel is dat nader onderzoek redelijkerwijs niet kan bijdragen  \naan de beoordeling van de zaak, onmiddellijk uitspraak te doen in de hoofdzaak. Er bestaat in dit geval aanleiding om van deze bevoegdheid gebruik te maken.\n\n2.3 De AC-procedure voorziet in een afdoening van asielaanvragen binnen 48 uur. Deze procedure leent zich slechts voor die asielaanvragen waaromtrent binnen deze korte termijn procedureel en inhoudelijk naar behoren kan worden  \nbeslist.\n\n2.4 Bij de beoordeling of in het onderhavige geval van een zodanige aanvraag sprake is, is het volgende van belang.\n\n2.5 Ingevolge het door verweerder gevoerde beleid, neergelegd in hoofdstuk B7/3 Vc 1994, bestaat de AC-procedure uit twee fasen. Het eerste deel betreft in ieder geval de formele indiening van de asielaanvraag en het onderzoek naar  \nidentiteit, nationaliteit en reisroute. Het tweede deel betreft de beoordeling van de asielaanvraag. Voor het tweede deel zijn maximaal 24 procesuren beschikbaar. Indien de eerste fase langer dan 24 uur duurt, gaat dit ten koste van  \nde tijd die beschikbaar is voor de tweede fase.\nIn principe vindt doorverwijzing naar een OC plaats indien de AC-procedure langer duurt dan 48 procesuren.\n\n2.6 Ter beoordeling ligt allereerst voor de vraag of het tweede deel van de AC-procedure is afgerond binnen de voor dat deel maximaal beschikbare termijn van 24 procesuren. Hierover overweegt de president als volgt.\n\n2.7 Tussen partijen is niet in geschil dat (een afschrift van) de beslissing op de asielaanvraag van verzoeker aan verzoeker is uitgereikt op een moment dat reeds 23 uur en 54 minuten waren verstreken van de beschikbare tijd van 24  \nprocesuren.\n\n2.8 In hoofdstuk B7/3.1 Vc 1994 is bepaald dat een beschikking voor het einde van de AC-termijn wordt uitgereikt en de rechtsbijstandverlener een uur de tijd heeft om aan te geven of een rechtsmiddel wordt aangewend. Hieruit kan  \nworden afgeleid dat het laatste uur van eerdergenoemde termijn van 24 procesuren exclusief gereserveerd is voor de rechtsbijstandverlener en dat verweerder van dit uur geen gebruik mag maken. Nu verweerder, zoals blijkt uit het  \nvoorgaande, van bedoeld uur wel gebruik heeft gemaakt, heeft verweerder in strijd gehandeld met zijn eigen beleid aangaande de AC-procedure.\n\n2.9 De gemachtigde van verweerder heeft ter zitting betoogd dat verzoeker door het vorenstaande niet is benadeeld omdat het rechtsmiddel niet is aangewend binnen het uur dat de rechtshulpverlening alsnog heeft kunnen gebruiken, maar  \npas enkele uren daarna. Dit betoog faalt naar het oordeel van de president.\nDaartoe is het navolgende redengevend.\n\n2.10 Verweerder heeft zich blijkens zijn eigen beleid ten doel gesteld om de AC-procedure, met inachtneming van de eisen van zorgvuldigheid, binnen 48 uren af te ronden. Dit impliceert dat de tijd die de rechtsbijstandverlening  \ntoekomt in ieder geval in acht moet worden genomen en dat, zoals hiervoor al is opgemerkt, doorverwijzing naar een OC behoort plaats te vinden indien de procedure langer duurt dan 48 uren, tenzij duidelijk is dat beide partijen met  \neen overschrijding instemmen.\nIndien, zoals in casu, de 48-uursprocedure alleen kan worden gehaald ten detrimente van het laatste uur dat aan de rechtsbijstandsverlening toekomt en de procedure desondanks wordt voortgezet, moet daarom in beginsel worden  \naangenomen dat verzoeker hierdoor in zijn belangen is geschaad. Dat het rechtsmiddel pas na enige tijd is ingesteld is hierbij\nirrelevant, reeds omdat uit het beleid niet kan worden afgeleid dat het rechtsmiddel binnen de beschikbare termijn van 48 procesuren daadwerkelijk moet worden aangewend.\n\n2.11 Verweerder heeft ter zitting voorts aangevoerd dat, wat er ook zij van het vorenstaande, de termijnoverschrijding desondanks voor rekening van verzoeker moet komen. Verweerder heeft daartoe, onder verwijzing naar hoofdstuk  \nB7/3.2 en B7/5.2 Vc 1994, betoogd dat de rechtsbijstandverlener de voor de voor- en nabespreking van het nader gehoor beschikbare tijd ruimschoots heeft overschreden. Dienaangaande overweegt de president als volgt.\n\n2.12 Er is, aldus hoofdstuk B7/3.2 Vc 1994, geen sprake van termijnoverschrijding (onder meer) indien de asielzoeker binnen de 48 procesuren meer tijd benut met rechtsbijstand dan de termijnen die daarvoor formeel beschikbaar zijn  \n(de extra tijd geldt niet als proceduretijd en is in het belang van de asielzoeker).\nIngevolge hoofdstuk B7/5.2 Vc 1994 heeft de asielzoeker voor aanvang van het nader gehoor gedurende maximaal twee uur de gelegenheid om met behulp van een rechtsbijstandverlener het verslag van het eerste gehoor en overige  \nonderzoeksresultaten uit de eerste fase na te bespreken en zich voor te bereiden op het nader gehoor.\nNa afronding van het nader gehoor krijgt de asielzoeker ingevolge hoofdstuk B7/5.3 Vc 1994 maximaal drie uur de gelegenheid te reageren op het voornemen van verweerder de asielaanvraag niet in te willigen en het rapport van het  \nnader gehoor na te bespreken. De rechtsbijstandverlener kan binnen die termijn (schriftelijk) reageren op het voornemen van de IND.\n\n2.13 In een tweetal uitspraken van de president van deze rechtbank en nevenzittingsplaats van 14 juli 2000 (onder meer geregistreerd onder de nummers AWB 00\6203 VRWET H t/m AWB 00/6205 VRWET H) is overwogen dat verweerder reeds nu  \ngehouden kan worden aan zijn primaire verantwoordelijkheid voor bewaking van de 48-uurstermijn. Voorts is overwogen dat dit betekent dat verweerder de rechtsbijstandverlener er in een voorkomend geval op moet wijzen dat de voor  \nrechtsbijstand beschikbare tijd is overschreden. Een en ander brengt met zich mee dat indien in het dossier een deugdelijke verslaglegging van vertragende gebeurtenissen of omstandigheden ontbreekt, aangenomen zal moeten worden dat  \nverweerder de\nrechtsbijstandverlener niet aan de hem toekomende tijd heeft gehouden en de termijnoverschrijding aan verweerder, als bewaker van de door hem zelf ingevoerde 48-uurstermijn, zal worden toegerekend.\n\n2.14 Uit de beschikbare stukken kan niet worden afgeleid dat verweerder de rechtsbijstandverlener op het moment van overschrijding van de voor de voor- en nabespreking van het nader gehoor beschikbare termijnen op die overschrijding  \nheeft gewezen. Ter zitting heeft de gemachtigde van verweerder hieromtrent niet meer duidelijkheid kunnen verschaffen. Deze omstandigheid brengt de president, gelet op hetgeen in 2.13 is overwogen, tot het oordeel dat verweerder te  \nkort is geschoten in zijn primaire verantwoordelijkheid voor de bewaking van de 48-uurstermijn. De gemachtigde van verweerder heeft ter zitting weliswaar aangegeven dat de Afdeling Planning van het Aanmeldcentrum Schiphol inmiddels  \nis verzocht de processtappen duidelijker op te nemen in het dossier, doch deze omstandigheid doet niets af aan het vorenstaande, nu van uitvoering van dit verzoek in de onderhavige zaak niet is gebleken.\n\n2.15 Het beroep tegen de afwijzende beschikking op de asielaanvraag van verzoeker zal dan ook gegrond worden verklaard. Gegeven deze beslissing bestaat geen aanleiding meer voor toewijzing van het verzoek om voorlopige voorziening.\n\n2.16 Ten aanzien van de op 18 juli 2000 aan verzoeker opgelegde vrijheidsbenemende maatregel overweegt de rechtbank als volgt.\n\n2.17 Gelet op voormelde gegrondverklaring van het beroep is de grond voor de voortgezette toepassing van de vrijheidsbenemende maatregel komen te ontbreken. Het beroep tegen de voortduring van de maatregel na de beslissing op de  \naanvraag is derhalve gegrond.\n\n2.18 Het betoog van de gemachtigde van verzoeker dat oplegging van de vrijheidsbenemende maatregel van meet af aan onrechtmatig is, nu verwijderingen naar (Noord-)Irak de facto niet\nplaatsvinden, faalt naar het oordeel van de rechtbank. Hierbij is in aanmerking genomen de mededeling van de gemachtigde van verweerder ter zitting dat (vrijwillige) terugkeer naar\n(Noord-)Irak mogelijk is door tussenkomst van de Internationale Organisatie voor Migratie (IOM). De rechtbank ziet geen aanleiding om aan de inhoud van deze mededeling te twijfelen en verwijst in dit verband voorts naar de uitspraak  \nvan deze rechtbank en nevenzittingsplaats van 11 juli 2000 (geregistreerd onder de nummers AWB 00/5810 VRWET H t/m AWB 00/5812 VRWET H). Bovendien is in dit verband nog van belang dat verzoeker door verweerder is geclaimd bij de  \nGeorgische luchtvaartmaatschappij waarmee hij naar Nederland is gekomen en verweerder derhalve in eerste instantie, indien verzoeker Nederland zal dienen te verlaten, zal pogen verzoeker naar Georgië te verwijderen.\n\n2.19 Nu de toepassing van de maatregel, gelet op het vorenstaande, vanaf 21 juli 2000 onrechtmatig is geweest, wordt, gelet op het in het Aanmeldcentrum Schiphol en het Grenshospitium te Amsterdam geldende regime, een  \nschadevergoeding toegekend van totaal f 1.450,--, zijnde een vergoeding van f 150,-- voor een dag in het Aanmeldcentrum en een vergoeding van f 100,- per dag voor 13 dagen in het Grenshospitium.\n\n2.20 In dit geval ziet de president aanleiding verweerder met toepassing van artikel 8:75, eerste lid, Awb te veroordelen in de door verzoeker gemaakte proceskosten, zulks met\ninachtneming van het Besluit proceskosten bestuursrecht. De kosten zijn op voet van het bepaalde in het bovengenoemde Besluit vastgesteld op f 1.420,-- (1 punt voor het\nverzoekschrift en 1 punt voor het verschijnen ter zitting, wegingsfactor 1). Aangezien ten behoeve van verzoeker een toevoeging is verleend krachtens de Wet op de rechtsbijstand, dient ingevolge het tweede lid van artikel 8:75 Awb  \nde betaling van dit bedrag te geschieden aan de griffier.\n\n2.21 De president ziet tevens aanleiding om met toepassing van artikel 8:82, vierde lid, Awb, te bepalen dat verweerder aan verzoeker het zowel voor de hoofdzaak als voor het verzoek om voorlopige voorziening betaalde griffierecht  \nad telkens f 50,-- zal vergoeden.\n\n3. BESLISSING\n\nDe fungerend president:\n\n3.1 verklaart het beroep gegrond en vernietigt de bestreden beschikking van 21 juli 2000;\n\n3.2 draagt verweerder op een nieuwe beschikking te nemen op de aanvraag van 19 juli 2000;\n\n3.3 wijst het verzoek om een voorlopige voorziening af;\n\n3.4 veroordeelt verweerder in de proceskosten ad f 1.420,-- onder aanwijzing van de Staat der Nederlanden als rechtspersoon die deze kosten aan de griffier van deze rechtbank, nevenzittingsplaats Haarlem, moet voldoen;\n\n3.5 wijst de Staat der Nederlanden aan als rechtspersoon ter vergoeding van het door verzoeker betaalde griffierecht ad tweemaal f 50,--.\n\nDe rechtbank:\n\n3.6 verklaart het beroep tegen de vrijheidsontnemende maatregel ex artikel 7a, tweede en derde lid, Vw gegrond en beveelt de opheffing van de maatregel van de vreemdeling met ingang van\n4 augustus 2000;\n\n3.7 wijst het verzoek om toekenning van schadevergoeding toe;\n\n3.8 kent aan de vreemdeling ten laste van de Staat (Ministerie van Justitie) een vergoeding toe van f 1.450,-- (zegge: veertienhonderdenvijftig), uit te betalen door de griffier van deze rechtbank, nevenzittingsplaats Haarlem;\n\n3.9 veroordeelt verweerder in de proceskosten ad f 710,--, onder aanwijzing van de Staat der Nederlanden als rechtspersoon, die deze kosten aan de griffier van deze rechtbank, nevenzittingsplaats Haarlem, moet voldoen.\n\nDeze uitspraak is gedaan door mr. G.F.H. Lycklama à Nijeholt, fungerend president, tevens lid van de enkelvoudige kamer voor vreemdelingenzaken, en uitgesproken in het openbaar op 4 augustus 2000, in tegenwoordigheid van mr. J.E.  \nBierling als griffier.\n\nVoornoemd lid van de enkelvoudige kamer voor vreemdelingenzaken beveelt de tenuitvoerlegging van de in deze uitspraak toegekende schadevergoeding ten bedrage van f 1.450,-- (zegge: veertienhonderdenvijftig).\n\nAldus gedaan op 4 augustus 2000, door mr. G.F.H. Lycklama à Nijeholt, lid van de enkelvoudige kamer voor vreemdelingenzaken.\n\nafschrift verzonden op: 4 augustus 2000\nRECHTSMIDDEL\n\nTegen deze uitspraak staat hoger beroep open bij het Gerechtshof te 's-Gravenhage, voor zover het betreft de beslissing inzake schadevergoeding. De Officier van Justitie kan binnen veertien dagen na de uitspraak en de vreemdeling  \nbinnen een maand na de betekening van de uitspraak hoger beroep instellen door het indienen van een verklaring als bedoeld in de artikelen 449 en 451a van het Wetboek van Strafvordering bij de Arrondissementsrechtbank te  \n's-Gravenhage, zittingsplaats Haarlem.\n\nVoor het overige staat geen gewoon rechtsmiddel open.\n		Haarlem	Vreemdelingen		Voorlopige voorziening+bodemzaak		


ROLLBACK;
