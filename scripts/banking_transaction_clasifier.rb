require 'date'
require 'pp'

FIELDS 					= %w(posted_date transaction_date description debits credits balance)
SPLITTER				= /(?<account>[\w^\d]+);(?<posted_date>\d+);(?<transaction_date>\d+);(?<description>.+?);(?<debit>[\d\.]*?);(?<credit>[\d\.]*?)/
#SPLITTER				= /(?<posted_date>[\d\/]+?),(?<transaction_date>[\d\/]+?),\"(?<description>.+?)\",(?<debit>[\d\.]*?),(?<credit>[\d\.]*?),/
#CLASSIFICATIONS = [:personal, :household, :security, :water, :electricity, :rates, :petrol, :car_maintenance, :cash_withdrawl, :books]

SPAIN_HOLIDAY_DATES 				= Date.new(2011,6,9)..Date.new(2011,6,17)
KRUGER_2011_HOLIDAY_DATES		= Date.new(2011,8,4)..Date.new(2011,8,15)

NAME_MAP = {
"ACCELERATIACCELERATION" => :income,
"AFB BIRTHDAY CONTRIBUTION" => :gifts,
"AFB RUNNING RACE" => :entertainment,
"AMAZON PAYMENTS 866-749-7545 US" => :hobbies,
"AMZN PMTS 866-749-7545 US" => :hobbies,
"ANDREW NEWMAN" => :entertainment,
"ANDREW'S BIRTHDAY PRESENT" => :gifts,
"ANTONY BOTING" => :holidays,
"ANVIL ALE HOUSE AND BRE DULLSTROOM ZA" => :restuarants,
"APPLE STORE #R116 RALEIGH US" => :work,
"ARBYS #3 ATLANTA US" => :work,
"ASIAN CHAO 76 Q91 PHILADELPHIA US" => :work,
"ATLANTIC RAIL" => :kids,
"ATM CASH WITHDRAWAL" => :cash_withdrawl,
"AVIS RENT A CAR JOHANNESBURG ZA" => :work,
"AVIS RENT-A-CAR 1 RALEIGH US" => :work,
"BABY CITY GREENPOINT GREEN POINT ZA" => :kids,
"BALULE GAME" => :holidays,
"BANFF" => :entertainment,
"BEN AND JERRY'S #N RALEIGH US" => :work,
"BETTIESBAAI VULSTASIE" => :petrol,
"BIG BLUE CAPE TOWN CAPE TOWN ZA" => :work,
"BIG FIVE DUTY FREE JOHANNESBURG ZA" => :work,
"BLUE ROUTE SERV. STATION TOKAI" => :petrol,
"BON VOYAGE PHARMACY KEMPTON PARK ZA" => :medical,
"BONEFISH 9404 CARY US" => :work,
"BOOK WORLD RONDEBOSCH ZA" => :books,
"BOOKMARK CAPE TOWN ZA" => :books,
"BORTON - WITELS" => :holidays,
"BOTANICAL SOC OF SA GAR KIRSTENBOSCH ZA" => :holidays,
"BOTANICAL SOC OF SA KIR KIRSTENBOSCH ZA" => :holidays,
"BOTANICAL SOC OF SA STO KIRSTENBOSCH ZA" => :holidays,
"BOTANICAL SOCIETY OF SA CLAREMONT ZA" => :holidays,
"BOTSOC MEMBERSHIP FEES" => :hobbies,
"BREEDE R TRAFFIC FINE" => :car_maintenance_and_licenses,
"BRIANS KAYAK CENTRE CC PAARDEN EILAN ZA" => :household,
"BRIDGET & DANIELLA FLOWERS" => :gifts,
"BRITISH A 1252477834226 JOHANNESBURG ZA" => :holidays,
"BRITISH A 1252477834228 JOHANNESBURG ZA" => :holidays,
"BRITISH A 1252477834230 JOHANNESBURG ZA" => :holidays,
"BS 40TH ACCOMMODATION" => :holidays,
"BUDGET RENT-A-CAR JOHNSON CITY US" => :work,
"CA DALLAS-ORR" => :work,
"CABSTRUT CAPE TOWN MAITLAND ZA" => :entertainment,
"CALEDONIAN SERV STATION MOWBRAY ZA" => :petrol,
"CAMPGROUND MOTORS" => :petrol,
"CARYN FOR G BDAY" => :gifts,
"CAVENDISH SERVICES CLAREMONT ZA" => :petrol,
"CENTRE SHOP BETTY'S BAY BETTYSBAAI ZA" => :holidays,
"CHEMKAY PHARMACY CAPE TOWN ZA" => :medical,
"CHIPOTLE 1659 RALEIGH US" => :work,
"CINELAND FILM & VIDEO RONDEBOSCH ZA" => :entertainment,
"COLOUR & COPY SOLUTIONS RONDEBOSCH ZA" => :other,
"CORONATION RA RCW" => :financial_management,
"CORONATION RA RJW" => :financial_management,
"CRISTY SPORTS 28658 CAPE TOWN ZA" => :household,
"CYCLE TOUR ENTRIES RONDEBOSCH ZA" => :entertainment,
"D D N B RALEIGH US" => :work,
"DANDY MINI MART # 42 JOHNSON CITY US" => :work,
"DAVES SERVICE SERVICE F MOWBRAY ZA" => :petrol,
"DENNEGEUR DIENSSTASIE ALBERTINIA ZA" => :petrol,
"DHL IN-HOUSE DESK CAPE TOWN ZA" => :work,
"DIGITAL EYE CLAREMONT ZA" => :work,
"DONCASTER MOTORS KENILWORTH" => :petrol,
"DORMANT T A TOWING" => :car_maintenance_and_licenses,
"DOT*WWW.ZONEEDIT.COM 360-253-2210 US" => :hobbies,
"DRAFT RALEIGH US" => :work,
"DRAKENSIG MOTORS HOEDSPRUIT ZA" => :petrol,
"DUNCAN H PRESENT 40TH" => :gifts,
"DUNKIN #347587 Q35 BAINBRIDGE US" => :work,
"EL MADRONO MADRID ES" => :holidays,
"ENTERPRISE RENT-A-CAR RDU AIRPORT US" => :work,
"EVOLUTION GAMES BRACKENHURST ZA" => :entertainment,
"EVOLUTION POINTS HTTP://WWW.EV MU" => :entertainment,
"FABULOUS FLOWERS & FINE NUWELAND ZA" => :booze,
"FANPARK" => :entertainment,
"FISHERS HCHC" => :holidays,
"FRASER KENNEDY" => :holidays,
"FURNI CRAFT OTTERY OTTERY ZA" => :building,
"GEEK INTERNET CAFE CAPE TOWN ZA" => :restuarants,
"GODADDY.COM 480-5058855 US" => :hobbies,
"GOGOAIR.COM 877-350-0038 US" => :work,
"GREENWOODS ACCOMODAT" => :holidays,
"HARD DRIVE RECORY" => :household,
"HARRIS TEETER #0021 RALEIGH US" => :work,
"HCHC REPAYMENT" => :holidays,
"HCHC:OAKLANE" => :holidays,
"HELIOS COFFEE COMPANY RALEIGH US" => :work,
"HERMANUS SERVICE STATION HERMANUS ZA" => :petrol,
"HESSEQUA SPEED FINE" => :car_maintenance_and_licenses,
"HI-FI CORPORATION RONDEBOSCH ZA" => :household,
"HOEDSPRUIT TOPS HOEDSPRUIT ZA" => :booze,
"HUGUENOT TOLL TUNNEL" => :petrol,
"HUGUENOT TUNNEL CAPE TOWN ZA" => :petrol,
"HYPER ALUMINIUM GUTTE" => :building,
"IFIX CAPE TOWN ZA" => :household,
"INVESTEC226460" => :banking_costs,
"INVESTEC234219" => :banking_costs,
"ISTORE CANAL WALK MILNERTON ZA" => :household,
"ISTORE V&A WATERFRONT CAPE TOWN ZA" => :household,
"ITUNES-USD LUXEMBOURG LU" => :entertainment,
"JAMES" => :holidays,
"JAMES GROOTHOEKKLOOF" => :holidays,
"JAMES WYNNE" => :holidays,
"JFK PANOPOLIS B24 JAMAICA US" => :work,
"JFK PEETS B23 JAMAICA US" => :work,
"JICAMA 311 (PTY) LTD" => :income,
"JOINT A/C" => :transfer,
"K''NEX INDUSTRIES 215-9977722 US" => :work,
"KATT & IAIN WEDDING ACCOM" => :holidays,
"KEITH ANDREWS CAR PARTS RETREAT ZA" => :car_maintenance_and_licenses,
"KIM FISCHER OTTER TRAIL" => :holidays,
"KNOWLEDGETREE" => :income,
"KNOWLEDGETREE ADSL X" => :work,
"KNOWLEDGETREE- LUNCH" => :work,
"KNOWLEDGETREE- REFUN" => :work,
"KNOWLEDGETREE-ADSL M" => :work,
"KNOWLEDGETREE-SALARY" => :work,
"KNOWLEDGETREE-TRAVEL" => :work,
"KOGELBERG RENE&MART" => :holidays,
"KRUGER COSTS" => :holidays,
"KULULA COM BONAERO PARK ZA" => :holidays,
"KULULA SABR BONAERO PARK ZA" => :holidays,
"KUNISHANI MOTORS CLAREMONT ZA" => :petrol,
"KUNSHANI MOTORS CLAREMONT" => :petrol,
"KUNSHANI MOTORS CLAREMONT ZA" => :petrol,
"LABIA THEATRE CAPE TOWN ZA" => :entertainment,
"LAND ROVER GARDENS ZA" => :car_maintenance_and_licenses,
"LEARNING EXPRESS OF RALE RALEIGH US" => :work,
"LILLIPUT NOVELTIES ROSEBANK JHB ZA" => :kids,
"LINDEN APPLIANCES MILNERTON ZA" => :household,
"LOOT.CO.ZA CAPE TOWN ZA" => :books,
"MANGO AIR JOHANNESBURG ZA" => :holidays,
"MARSHALL MUSIC CONSTANTI RETREAT ZA" => :household,
"MCSA" => :holidays,
"MEADOWRIDGE SERVICE CENTRE" => :petrol,
"MEEU ST ACROSS ROAD" => :holidays,
"METRO DE MADRID MADRID ES" => :holidays,
"MICROSOFT FULFILLMENT CEN DUBLIN IE" => :household,
"MIKE & VANESSA TIX&SHEEP" => :household,
"MIKE LEVIN" => :holidays,
"MIKE S AUTO ELECTRICIAL TOKAI ZA" => :car_maintenance_and_licenses,
"MINTY'S TYRES & MAGS ROSEBANK ZA" => :car_maintenance_and_licenses,
"MONTAGU DROEVRUGTE PADS MONTAGU ZA" => :household,
"MONUMENT MOTORS FO URT PAARL ZA" => :petrol,
"MOTHER CITY MOTORS" => :petrol,
"MRS. FIELDS RELIEGH US" => :work,
"MTN" => :telephones,
"MTN - RENEN" => :telephones,
"MTN SCIENCENTRE MILNERTON ZA" => :kids,
"MUSICAL CARS CC RETREAT ZA" => :car_maintenance_and_licenses,
"NASHUA COPY SHOP RONDEBOSCH ZA" => :other,
"NATIONAL CAR RENTAL RALEIGH US" => :work,
"NATTY GREENES PUB AND BRE RALEIGH US" => :work,
"NICOLE VERHOVERT - SAIL FIX LA" => :entertainment,
"OCTOBER -FEB2013PILATES" => :entertainment,
"OCTOBER PILATES" => :entertainment,
"OPEN HOUSE RESTAURANT NAIROBI KE" => :work,
"ORANJE SERVICE CENTRE GARDENS ZA" => :petrol,
"ORMS CC CAPE TOWN ZA" => :hobbies,
"ORMS NEWLANDS ZA" => :hobbies,
"OTG JFK T5 VENTURE, LLC JAMAICA US" => :work,
"OTTER TRAIL BALANCE" => :holidays,
"OUMA SE HUIS DEPOSIT" => :holidays,
"P K HANSFORD CLAREMONT ZA" => :kids,
"PADDYS SERIVE STATION" => :petrol,
"PADDYS SERVICE STATION CAPE TOWN ZA" => :petrol,
"PANETTONE CAFE PARKW D JOHANNESBURG ZA" => :restuarants,
"PARADIES # 770 Q02 ATLANTA US" => :work,
"PC GUY" => :household,
"PC HARD DRIVE RECOVERY" => :household,
"PDM" => :schooltools,
"PENINSULA ROUNDTABLE77" => :entertainment,
"PHILLY AIR AUBONPAIN 2 PHILADELPHIA US" => :work,
"PICK N PAY CLAREMONT CLAREMONT ZA" => :household,
"PINE TIME CLAREMONT ZA" => :household,
"PITSTOP WOODSTOCK WOODSTOCK ZA" => :car_maintenance_and_licenses,
"PLASTOWS BIRTHDAY ACCOMOD" => :holidays,
"PORTERVILLE WEEKEND" => :holidays,
"POWELLS.COM 5032284651 US" => :books,
"PR BORTON" => :holidays,
"PRICLO OUTDOOR MAITLAND ZA" => :kids,
"QDOBA # 4 ATLANTA US" => :work,
"RACKSPACE CLOUD 210-312-4000 US" => :schooltools,
"RALEIGH PARKING METERS RALEIGH US" => :work,
"RAMSAY MEDIA MAGAZINE HOWARD PLACE ZA" => :gifts,
"RDU FLAVORS RALEIGH US" => :work,
"REI 97 RALEIGH RALEIGH US" => :work,
"RENEN RA ISELECT" => :financial_management,
"RENEN TRF" => :transfer,
"RGHS REUNION" => :entertainment,
"RIVERSDALE 1 STOP RIVERSDALE ZA" => :petrol,
"RNW BICYCLE PATROLLERS" => :household,
"ROBBY'S MOTOR SPARES RETREAT ZA" => :car_maintenance_and_licenses,
"ROBERTSON SHELL" => :petrol,
"ROCKFORD RALEIGH US" => :work,
"RONDEBOSCH BOYS HIGH SC RONDEBOSCH ZA" => :school,
"RONDEBOSCH BOYS' PREP" => :school,
"RONEL HIKE" => :holidays,
"RONEL STREICHER" => :holidays,
"ROS RA ISELECT" => :financial_management,
"SAFARINOW.C KOMMETJIE ZA" => :holidays,
"SAICA MEMBERSHIP SUBS" => :other,
"SANP RESERVATIONS 2 MUCKLENEUK ZA" => :holidays,
"SCHOOLTOOLS_RW_EXPEN" => :schooltools,
"SECURE CHOICE ROSEBANK SENSORS" => :building,
"SENTRAAL SUID KOOPERASIE SWELLENDAM ZA" => :household,
"SEPT PILATES AND SOFIE EXTRA L" => :entertainment,
"SHARENET CPT ZA" => :school,
"SHEETZ 00003996 MORRISVILLE US" => :work,
"SKYPE 44870835190 GB" => :household,
"SKYPE LUXEMBOURG LU" => :household,
"SOUTH AFRICAN SCOUT ASS GOODWOOD ZA" => :kids,
"SPORT UNLIM CONSTANTIA ZA" => :household,
"ST FRANCIS BAY SERVICE ST FRANCIS BA ZA" => :petrol,
"ST REFUND RENE" => :schooltools,
"STARBUCKS CORP00082180 RALEIGH US" => :work,
"STARBUCKS CORP00083733 RALEIGH US" => :work,
"STARBUCKS CORP00097899 RALEIGH US" => :work,
"STARBUCKS HOUNSLOW GB" => :work,
"STARBUCKS TERM10671535 RALEIGH US" => :work,
"STARUBUCKS ATL10201572 ATLANTA US" => :work,
"STER-KINEKOR - CAVENDIS CLAREMONT ZA" => :entertainment,
"STER-KINEKOR V & A NOUV CAPE TOWN ZA" => :entertainment,
"SUBURBAN SPARES OTTERY OTTERY ZA" => :car_maintenance_and_licenses,
"SUBWAY 00211037 JOHNSON CITY US" => :work,
"SUICIDE" => :holidays,
"SUNGLASS HUT MONTAGUE GARD ZA" => :clothes_and_shoes,
"SUNSET BEACH S/S" => :petrol,
"TABLE MOUNTAIN AERIAL CAPE TOWN ZA" => :holidays,
"TABLE MOUNTAIN CABLE Y CAPE TOWN ZA" => :holidays,
"TALISMAN LTD NAIROBI KE" => :work,
"TALJARD HOUSE 7/8/9 SEPT" => :holidays,
"TASHA'S MELROSE ARCH MELROSE ZA" => :restuarants,
"TECHNICAL FINISHES EPPING ZA" => :building,
"THE BOOK PEOPLE DIEP RIVER ZA" => :kids,
"THE FAIRY SHOP CLAREMONT ZA" => :kids,
"THE FLYING SAUCER RALEIGH US" => :work,
"THE HAPPY HOG BUTCHE ASHTON ZA" => :household,
"THE LIQUOR STORE MILNERTON ZA" => :booze,
"THE PIT RALEIGH US" => :work,
"THE POLE YARD PAARDEN E PAARDEN EILAN ZA" => :household,
"THE RACKSPACE CLOUD 210-581-0410 US" => :schooltools,
"THE TRAVELLING BOOKSHOP STRAND ZA" => :kids,
"THE WOODSTOCK TORCHBEAR WOODSTOCK ZA" => :restuarants,
"TICKETLINE SANDTON ZA" => :entertainment,
"TOKAI SERVICE STATION RETREAT ZA" => :petrol,
"TOTAL TOKAI TOKAI ZA" => :petrol,
"TOTAL WOODSTOCK" => :petrol,
"TRAC MIDDELBURG PLAZA MIDDELBURG ZA" => :petrol,
"TRANSER JEN" => :transfer,
"TRANSFER TO JOINT ACCOUNT" => :transfer,
"TRANSFORMER &GATE BATTERY" => :household,
"TRAVELOCITY.COM 800-256-9089 US" => :work,
"TRIAL RUN, 2 SEP" => :entertainment,
"TRU CANAL WALK (508) CP MONTAGUE GARD ZA" => :clothes_and_shoes,
"TRU CAVENDISH (531) CLAREMONT ZA" => :clothes_and_shoes,
"TRU CAVENDISH (531) CP CLAREMONT ZA" => :clothes_and_shoes,
"TRU GARDENS (504) GARDENS ZA" => :clothes_and_shoes,
"TSIKITSIKAMMA MAINLINE PORT ELIZABET ZA" => :petrol,
"TURNKEY LOCKSMITH" => :household,
"TURNKEY LOCKSMITHS DIEP RIVER ZA" => :household,
"TYRONE FRUITERERS JHB ZA" => :household,
"U C T STUDENT FEES CAPE TOWN ZA" => :school,
"UK VISAS ARCADIA GB" => :holidays,
"UNIFORUM SA AUCKLAND ZA" => :hobbies,
"UNITED AIR 0167076830143 SAN ANTONIO US" => :work,
"URBAN DEGREE CANAL W K CAPE TOWN ZA" => :clothes_and_shoes,
"URBAN DEGREE CAVENDI CAPE TOWN ZA" => :clothes_and_shoes,
"VANESSA F HCHC" => :holidays,
"VANESSA HCHC" => :holidays,
"VEES VIDEO RONDEBOSCH RONDEBOSCH ZA" => :entertainment,
"VINEYARD SERVICE STATION NEWLANDS ZA" => :petrol,
"VITACARE RONDEBOSCH RONDEBOSCH ZA" => :medical,
"VITECK GATE MOTOR 2ND REWIRE" => :household,
"VITECK GATE MOTOR REWIRE" => :household,
"VOB SQUASH" => :entertainment,
"VOVO TELO'S PARKHURS JOHANNESBURG ZA" => :petrol,
"WATERWORLD CAPE TOWN CAPE TOWN ZA" => :holidays,
"WEBTICKETS RONDEBOSCH ZA" => :entertainment,
"WHICH WICH #192 RALEIGH US" => :work,
"WITELS" => :holidays,
"WMMW VENTER (PTY) LTD WORCESTER ZA" => :petrol,
"WORDSWORTH BOOKS GARDEN CAPE TOWN ZA" => :books,
"WORDSWORTH BOOKS GARDENS ZA" => :books,
"ZAKY RALEIGH US" => :work,
"ZOOM FACTORY SHOP KENILWORTH ZA" => :clothes_and_shoes,

	"1890 HOUSE SUSHI CAPE TOWN ZA" => :resuarant,
	"A&A FURNISHERS CAPE TOWN ZA" => :household,
	"ABSOLUTE PETS PALMYRA CLAREMONT ZA" => :household,
	"ACROBRANCH ADVENTURE A CAPE TOWN ZA" => :kids,
	"ACROBRANCH PARK JOHANNESBURG ZA" => :kids,
	"AFRIMAT 5M2 13MM BROWN STONE" => :building,
	"AFRIMAT 5M2 6MM RAWSONVILLE ST" => :building,
	"ALBERT CARPETS CAPE TOWN ZA" => :building,
	"ALBERT HALL SUPERETT WOODSTOCK ZA" => :resuarant,
	"ALBERTS FLOORS 50% GUESTHOUSE" => :building,
	"ANAT WATERFRONT CAPE TOWN ZA" => :resuarant,
	"ANNELINE'S DECOR" => :building,
	"ATLAS SCIENTIFIC BROOKLYN US" => :hobbies,
	"AVRON CYCLES" => :bikes,
	"AXXESS" => :internet,
	"AXXESS DSL (PTY) LTD. PORT ELIZABET ZA" => :internet,
	"AXXESS DSL PTY LTD NEWTON PARK ZA" => :internet,
	"BABEL PAARL ZA" => :resuarant,
	"BABYLONS TOREN PROELOKA PAARL ZA" => :resuarant,
	"BALLET POINTE CAPE TOWN ZA" => :kids,
	"BANANA REPUBLIC #8146 RALEIGH US" => :clothes_and_shoes,
	"BARNYARD MELKBOS MELKBOSSTRAND ZA" => :resuarant,
	"BAXTER THEATRE RONDEBOSCH ZA" => :kids,
	"BEIJING KITCHEN RONDEBOSCH ZA" => :resuarant,
	"BERTHAS RESTAURANT SIMONSTOWN ZA" => :resuarant,
	"BIGGIE BEST" => :household,
	"BIGGIE BEST DEPOSIT" => :household,
	"BILLABONG CONCEPT STORE JEFFREYS BAY ZA" => :clothes_and_shoes,
	"BILLABONG FACTORY OUTLE JEFFREYSBAY ZA" => :clothes_and_shoes,
	"BILLABONG MAGNA'S SURF JEFFREYS BAY ZA" => :clothes_and_shoes,
	"BISTRO 1682 TOKAI ZA" => :resuarant,
	"BIZERCA BISTRO CAPE TOWN ZA" => :resuarant,
	"BLOCK AND CHISEL INTERI CONSTANTIA ZA" => :household,
	"BOO'S TOY EMPORIUM SWELLENDAM ZA" => :kids,
	"BORRUSO'S RONDEBOSCH RONDEBOSCH ZA" => :resuarant,
	"BREAD WOODSTOCK ZA" => :resuarant,
	"BRUCE & NOEL" => :building,
	"BUDDING BALLERINA" => :kids,
	"BUILD A BEAR WORKSHOP CAPE TOWN ZA" => :kids,
	"BUTTERFLY WORLD KLAPMUTS ZA" => :kids,
	"C D FOX (PTY) LTD CAPE TOWN ZA" => :household,
	"CA197436 CAR LICENSE" => :car_maintenance_and_licenses,
	"CA328302 CAR LICENSE" => :car_maintenance_and_licenses,
	"CAFE ROSA ROUTE 62 ROBERTSON ZA" => :resuarant,
	"CAFE ROUX NOORDHOEK ZA" => :resuarant,
	"CAFE SOFIA KLOOF ST CAPE TOWN ZA" => :resuarant,
	"CAFFE BALDUCCI CAPE TOWN ZA" => :resuarant,
	"CAFFE MILANO GARDENS ZA" => :resuarant,
	"CAFFENEO MOUILLEPOINT ZA" => :resuarant,
	"CAPE TOWN FISH MARKET GRANDWEST ZA" => :resuarant,
	"CAPE TOWN SCIENCE CE R OBSERVATORY ZA" => :kids,
	"CAPE TOWN TIMBERS GOODWOOD ZA" => :building,
	"CARAMELLO'S CAPE TOWN ZA" => :resuarant,
	"CARIBOU COFFEE #12 ATLANTA US" => :resuarant,
	"CARO SCRIPTS" => :medical,
	"CASSIS GARDENS GARDENS ZA" => :resuarant,
	"CASSIS PARIS NEWLANDS CAPE TOWN ZA" => :resuarant,
	"CHAI-YO-THAI RESTAURANT MOWBRAY ZA" => :resuarant,
	"CHARLOTTE RHYS CONSTANTIA ZA" => :gifts,
	"CHARLOTTE RHYS DIREC CONSTANTIA ZA" => :gifts,
	"CHARLY'S BAKERY CC SEA POINT ZA" => :resuarant,
	"CHARLYS BAKERY CAPE TOWN ZA" => :resuarant,
	"CHIPPIES PREGO RONDEBOSCH ZA" => :resuarant,
	"CLARE BELL PLANTING DEPOSIT" => :building,
	"CLAREMONT HOME APPLI CLAREMONT ZA" => :household,
	"CLAREMONT SENTRA CLAREMONT ZA" => :booze,
	"CLAREMONT SENTRA LIQ R CLAREMONT ZA" => :booze,
	"CLAREMONT SUPA QUICK CLAREMONT ZA" => :car_maintenance_and_licenses,
	"CLAY CAFE HOUT BAY ZA" => :kids,
	"COLF HAIR TAMBOERSKLOOF ZA" => :personal,
	"COLIN" => :building,
	"COLLINS PATENI PAINTING 19/6" => :building,
	"COLLINS PATENI PAINTING 4TH-6T" => :building,
	"COLLINSPATENI PAINTING 26/27 1" => :building,
	"COMMUNICA (PTY) LTD WOODSTOCK ZA" => :hobbies,
	"CONRAD BOTES PRINT" => :art,
	"CONSTANCIABERG PHARMACY PLUMSTEAD ZA" => :medical,
	"CONSTANTIA HARDWARE CONSTANTIA ZA" => :building,
	"CONSTANTIA MEDI CAFE CONSTANTIA ZA" => :medical,
	"CONSTANTIABERG HARDWARE DIEP RIVER ZA" => :building,
	"COPY WIZARDZ GARDENS GARDENS ZA" => :kids,
	"CREAMY BEAN SEATLE DULLSTROOM ZA" => :coffee,
	"CROCS KENILWORTH ZA" => :clothes_and_shoes,
	"CRUSH BOULEVARD WOODSTOCK ZA" => :resuarant,
	"CRUSH BRP OBSERVATORY ZA" => :resuarant,
	"CRYSTAL TOWERS HOTEL CENTURY CITY ZA" => :resuarant,
	"CT TIMBERS SKIRTING ARCHITRAVE" => :building,
	"CURRY QUEST MOWBRAY ZA" => :resuarant,
	"DANIELLA BIRTHDAY PRESENT" => :gifts,
	"DAVID BLOOM PHARMACY TOKAI ZA" => :medical,
	"DE GRENDEL RESTAURANT PANORAMA ZA" => :resuarant,
	"DE OUDE KOMBUIS ROBERTSON ZA" => :resuarant,
	"DEAR ME CAPE TOWN ZA" => :resuarant,
	"DEBONAIRS PIZZA-CAVENDI CLAREMONT ZA" => :resuarant,
	"DEM'S RONDEBOSCH ZA" => :medical,
	"DEN ANKER CAPE TOWN ZA" => :resuarant,
	"DEPOSIT ROBERTSON SKRYNWERKERS" => :building,
	"DERMATOLOGIST" => :medical,
	"DIETRICH VOIGTR MIA & P PINELANDS ZA" => :medical,
	"DION WIRED- CAVENDISH CLAREMONT ZA" => :household,
	"DIS-CHEM CAPE PHARMA CLAREMONT ZA" => :medical,
	"DOMINATOR GARAGE OPENE" => :household,
	"DR BIRKETT & DR LE GAND CLOVELLY ZA" => :medical,
	"DR BOOMSLANG RETREAT ZA" => :medical,
	"DR CR NEL INC PLUMSTEAD ZA" => :medical,
	"DR DALE C HARRISON CLAREMONT ZA" => :medical,
	"DR DOMMISSE AND ASSO ATE NEWLANDS ZA" => :medical,
	"DR GREG WEBB" => :medical,
	"DR MATLEY & PARTNERS PINELANDS ZA" => :medical,
	"DR MEH PENNY MOWBRAY ZA" => :medical,
	"DR MICHAEL MADDEN CAPE TOWN ZA" => :medical,
	"DR MILNE & PARTNERS CLAREMONT ZA" => :medical,
	"DR TUFT & PARTNERS IN CPT ZA" => :medical,
	"EAGLE LIGHTING RETREAT ZA" => :building,
	"ELECTRICAL METER" => :hobbies,
	"ELECTRO MECHANICA (CAPE MONTAGUE GARD ZA" => :hobbies,
	"ERAWAN RESTAURANT WYNBERG ZA" => :resuarant,
	"EXTERIOR LANTERNS - CANDELABRA" => :building,
	"FA WOODS PIANO LESSONS SOFIE" => :kids,
	"FAIRY DRESSES WEDDING" => :kids,
	"FALSEBAY FUMIGATION DESK" => :household,
	"FEDICS LIFE AT WEST END PINELAND ZA" => :resuarant,
	"FEDICS MAIN RESTAURANT PINELANDS ZA" => :resuarant,
	"FINN AND SOFIE STANZI HOLIDAYS" => :kids,
	"FINN INJECTIONS" => :medical,
	"FIRE & GAS STOVE" => :building,
	"FOOD LOVERS MARKET C REM CLAREMONT ZA" => :resuarant,
	"FOOD LOVERS MARKET TOKA TOKAI ZA" => :resuarant,
	"FORK CAPETOWN ZA" => :resuarant,
	"FOSCHINI 00-0155 SWELLENDAM ZA" => :clothes_and_shoes,
	"FOSSIL #655 RALEIGH US" => :clothes_and_shoes,
	"FOURNOS ROSEBANK ROSEBANK ZA" => :resuarant,
	"FRAICHE AYRES RESTAU NT ROSEBANK ZA" => :resuarant,
	"FRANK DANGEREUX LE CREUSET" => :resuarant,
	"FRANK KETTNER" => :gifts,
	"FREE RANGE FOOD SHOP KOMMETJIE ZA" => :resuarant,
	"FRUIT & VEG CITY ICON CAPE TOWN ZA" => :household,
	"FRUIT & VEG CITY KENILWORTH ZA" => :household,
	"G2 ART CAPE TOWN ZA" => :art,
	"GARDENS LOCKSMITHS GARDENS ZA" => :household,
	"GAS APPLIANCE CENTRE CLAREMONT ZA" => :household,
	"GATES/DOMINATOR/ELTON" => :household,
	"GIBSONS ALIGNMENT SE SALT RIVER ZA" => :car_maintenance_and_licenses,
	"GIOVANNI'S DELIWORLD GREENPOINT ZA" => :resuarant,
	"GLOW INNOVATIONS FIX CAR GATE" => :household,
	"GLOW INNOVATIONS GATE" => :household,
	"GODDARD'S AUTO REPAIRS OTTERY ZA" => :car_maintenance_and_licenses,
	"GRANT LEWIS TOKAI ZA" => :medical,
	"GREEK MOWBRAY ZA" => :resuarant,
	"GREENWOOD HONEY" => :household,
	"GUNNER / ALARM" => :building,
	"H B TIMM PLUMBING" => :building,
	"HAMER & TONGS CAPETOWN ZA" => :building,
	"HAMRAD ELECTRONICS CAPE TOWN ZA" => :hobbies,
	"HANDLES INC CAPE TOWN ZA" => :building,
	"HAROLD PORTER SANBI BETTY'S BAY ZA" => :resuarant,
	"HART NURSERY & LANDSCAP OTTERY ZA" => :building,
	"HAWKES & FINDLAY OBSERVATORY ZA" => :building,
	"HOBBY BOARDS 2054134052 US" => :hobbies,
	"HONEST ARTISAN CHOCOLAT CAPE TOWN ZA" => :resuarant,
	"HORIZON POOLS" => :building,
	"HOUSE AND INTERIORS CLAREMONT ZA" => :building,
	"HOUSE OF KITCHENWARE MILNERTON ZA" => :household,
	"I AXXESS DSL (PTY) LTD. MILLPARK ZA" => :internet,
	"I AXXESS DSL (PTY) LTD. PORT ELIZABET ZA" => :internet,
	"IAN LORIMER DR MATLEY" => :medical,
	"IL LEONE MASTRANTONI GREEN POINT ZA" => :resuarant,
	"INCREDIBLE CONNECTION CAVENDISH ZA" => :household,
	"INNOCULATIONS" => :medical,
	"ISUZU DOOR & IGNITION LOCK" => :car_maintenance_and_licenses,
	"ITALCOTTO CAPE TOWN ZA" => :building,
	"J DUNCAN DEPOSIT" => :rental_related,
	"JARDINE BAKERY CAPE TOWN ZA" => :resuarant,
	"JB RIVERS CLAREMONT ZA" => :resuarant,
	"JONKERSHUIS RESTAURANT CONSTANTIA ZA" => :resuarant,
	"JUICER 40TH" => :household,
	"KARATE SAMURAI" => :kids,
	"KENZAN - CAPE TOWN CAPETOWN ZA" => :building,
	"KEY BOUTIQUE CAPE TOWN ZA" => :household,
	"KIDS EMPORIUM GREENPOINT ZA" => :kids,
	"KING CAKE GARDENS GARDENS ZA" => :kids,
	"KING CAKE KC KENILWORTH ZA" => :kids,
	"KISMET SUPP WYNBERG ZA" => :household,
	"KITIMA AT THE KRONEN L CAPE TOWN ZA" => :resuarant,
	"KLOOFNEK SUPERETTE TAMBOERSKLOOF ZA" => :resuarant,
	"L T DISCOUNT PAINT WHOLE WOODSTOCK ZA" => :building,
	"LA VERNE WINE BOUTIQ CAPE TOWN ZA" => :booze,
	"LABELS JUST 4 SCHOOLS" => :kids,
	"LACOTTA TILES" => :building,
	"LADY BEE OBSERVATORY OBSERVATORY ZA" => :resuarant,
	"LARRY STOKES DEPOSIT" => :building,
	"LE CREUSET CAVENDISH SQ CLAREMONT ZA" => :household,
	"LE CREUSET CAVINDISH SQ CLAREMONT ZA" => :household,
	"LE CREUSET GARDENS CAPE TOWN ZA" => :household,
	"LEOPARDSKLOOF RESTAU N BETTY'S BAY ZA" => :resuarant,
	"LIESL LUKCY DRAW" => :gifts,
	"LIFE WEST COAST HOSP VREDENBERG ZA" => :medical,
	"LIFEHEALTH VINCENT PALLO CAPETOWN ZA" => :medical,
	"LIFESTYLE PHARMACY OBSERVATORY ZA" => :medical,
	"LIGHT WISE CLAREMONT ZA" => :building,
	"LIQUORCITY CLAREMONT CLAREMONT ZA" => :booze,
	"LIZ' BIRTHDAY PRESENT" => :gifts,
	"LIZZARD CAVENDISH. CAPE TOWN ZA" => :clothes_and_shoes,
	"LIZZARD CAVENDISH. CLAREMONT ZA" => :clothes_and_shoes,
	"LOFT LIVING CAPE TOWN ZA" => :household,
	"LOVEALL TENNIS ACADEMY" => :kids,
	"LUSH SOUTH AFRICA CLAREMONT ZA" => :gifts,
	"MAINLAND CHINA SUPERMAR CLAREMONT ZA" => :household,
	"MAIZEY PLASTICS PAARDENEILAND ZA" => :building,
	"MAKE MAGAZINE 7078277192 US" => :hobbies,
	"MANGO GINGER BAKERY & C OBSERVATORY ZA" => :resuarant,
	"MANO A MANO GARDENS ZA" => :resuarant,
	"MARCELS - CAPE TOWN CAPE TOWN ZA" => :resuarant,
	"MARCELS - RONDEBOSCH RONDEBOSCH ZA" => :resuarant,
	"MASALA DOSA AROMATIC UIS CAPE TOWN ZA" => :resuarant,
	"MASSIMO'S HOUT BAY ZA" => :resuarant,
	"MATT GORE GINJA NINJA" => :kids,
	"MAYFLY RESTAURANT DULLSTROOM ZA" => :resuarant,
	"MCCARTHY TENNIS L'BOSCH" => :kids,
	"MELISSA'S NEWLANDS ZA" => :resuarant,
	"MELISSAS THE FO 31395 NEWLANDS ZA" => :resuarant,
	"MELISSAS THE FOOD SHOP NE NEWLANDS ZA" => :resuarant,
	"MINERAL WORLD SIMONSTOWN ZA" => :kids,
	"MOOMOO KIDS BELU DAVIDSON" => :gifts,
	"MR ADAMS PIANO TUNING" => :household,
	"MR PRICE CANAL WALK- CE CAPE TOWN ZA" => :clothes_and_shoes,
	"MR PRICE KENILWORTH 2 KENILWORTH ZA" => :clothes_and_shoes,
	"MR PRICE SPORT CANAL WA CAPE TOWN ZA" => :clothes_and_shoes,
	"MR PRICE SWELLENDAM SWELLENDAM ZA" => :clothes_and_shoes,
	"MRS SIMPSONS DULLSTROOM ZA" => :resuarant,
	"MS TALIEP AND WEST" => :gifts,
	"MUGG & BEAN CAPE TOWN INT ZA" => :resuarant,
	"MUGG & BEAN CAPE TOWN ZA" => :resuarant,
	"MUTLISOURCE 1ST ORDER" => :building,
	"MYOGA RESTAURANT NEWLANDS ZA" => :resuarant,
	"NATURE NETWORK" => :kids,
	"NEWPORT EXPRESS MOUILLE POINT ZA" => :resuarant,
	"NEWPORT MARKET AND D I MOUILLE POINT ZA" => :resuarant,
	"NEWPORT MARKET AND DELI MOUILLE POINT ZA" => :resuarant,
	"NOEL FIREPLACE&UPSTAIRS DESIGN" => :building,
	"NU PHARMACY CAVENDISH CLAREMONT ZA" => :medical,
	"NU PHARMACY CLAREMONT ZA" => :medical,
	"OCEAN BASKET GARDENS ZA" => :resuarant,
	"OCEAN BASKET TYGERVA EY BELLVILLE ZA" => :resuarant,
	"OLA MILKY LANE CAPE TOWN ZA" => :resuarant,
	"OLD GAOL COFFEE SHOP SWELLENDAM ZA" => :resuarant,
	"OLE CAFE AND TAKE AWAYS OBSERVATORY ZA" => :resuarant,
	"OLIVE INTERIORS WOODSTOCK ZA" => :household,
	"OLYMPIA CAFE AND DEL FISH HOEK ZA" => :resuarant,
	"ON TAP CAPE TOWN PAARDENEILAND ZA" => :building,
	"ORIGIN COFFEE ROASTI CAPE TOWN ZA" => :resuarant,
	"ORINOCO FLAVOURS CAPE TOWN ZA" => :resuarant,
	"OSUMO CANAL WALK ZA" => :resuarant,
	"OSUMO CLAREMONT CLAREMONT ZA" => :resuarant,
	"OUTDOOR WAREHOUSE RONDE RONDEBOSCH ZA" => :household,
	"PASSAGE TO INDIA CLAREMONT ZA" => :resuarant,
	"PASTIS RESTAURANT CONSTANTIA ZA" => :resuarant,
	"PEP STORES 6438 KENILWORTH ZA" => :clothes_and_shoes,
	"PEREGRINE FARM 28408 GRABOUW ZA" => :resuarant,
	"PEREGRINE FARM STALL GRABOUW ZA" => :resuarant,
	"PHYSIO" => :medical,
	"PLANET BAR GARDEN ZA" => :resuarant,
	"PLANET RESTAURANT GARDENS ZA" => :resuarant,
	"PLASTICS FOR AFRICA RETREAT ZA" => :household,
	"PLASTOW KBOSCH BFAST" => :resuarant,
	"PLUMBLINK SA LANSDOWNE ZA" => :building,
	"PLUMSTEAD ELECTRICAL PLUMSTEAD ZA" => :building,
	"POOL NET" => :building,
	"POOL PEOPLE MOWBRAY MOWBRAY ZA" => :household,
	"POOLASCO POOL LINING" => :building,
	"POOLCITY KOI SAND" => :household,
	"PRIMI PIATTI BELLVILLE ZA" => :resuarant,
	"PRIMI PIATTI CANAL W K MILNERTON ZA" => :resuarant,
	"PRIMI PIATTI CAVANDISH JOHANNESBURG ZA" => :resuarant,
	"PRIMI PIATTI CPT AIRPOR CAPE TOWN ZA" => :resuarant,
	"RADISSON HOTEL WATERFRON CAPE TOWNT ZA" => :resuarant,
	"RAMBLING ROSE ST FRANCIS BA ZA" => :resuarant,
	"RECYCLING" => :household,
	"RECYLCING" => :household,
	"REPLACE VOLVO FUEL FILTER & RE" => :car_maintenance_and_licenses,
	"RESTAURANT JARDINE CAPE TOWN ZA" => :resuarant,
	"REYNOLDS HIRE AND EQ P PAARDEN EILAN ZA" => :building,
	"ROBERTSON ART GALLERY" => :art,
	"ROBERTSON NURSERY ROBERTSON ZA" => :household,
	"ROBERTSON SKRYNWERKERS WINDOWS" => :building,
	"ROCKSOLE BAG & SHOE REP CAPE TOWN ZA" => :clothes_and_shoes,
	"ROLANDALE RESTAURANT BUFFELJAGS RI ZA" => :resuarant,
	"ROSETTA ROASTER 36244 CAPE TOWN ZA" => :resuarant,
	"ROYO KLOOF ASIAN RESTAU GARDENS ZA" => :resuarant,
	"ROZALIA FAREWELL" => :gifts,
	"RUST EN VREDE WYNLAND STELLENBOSCH ZA" => :resuarant,
	"SAM'S AQUARIUM BERGVLIET ZA" => :household,
	"SAMS AQUARIUM BERGVLIET ZA" => :household,
	"SAN MARCO WATERFRONT CAPE TOWN ZA" => :resuarant,
	"SCAR HAIR CPT ZA" => :personal,
	"SERVICE BAKKIE EXHAUST" => :car_maintenance_and_licenses,
	"SERVICE BAKKIE, REPLACE BALL J" => :car_maintenance_and_licenses,
	"SEVEN ELEVEN MONTAGU MONTAGU ZA" => :household,
	"SHEETMETAL WORKS W CPT ZA" => :building,
	"SHERWOOD HARDWARE AND G CAPE TOWN ZA" => :building,
	"SHERWOOD HARDWARE AND GAR CAPE TOWN ZA" => :building,
	"SHOWER HAUS DOOR COTTAGE" => :building,
	"SIKA SOUTH AFRICA PTY L MONTAGUE GARD ZA" => :building,
	"SILWOOD KIDS COOKING" => :kids,
	"SIMPHIWE IRRIGATION LANSDOWNE ZA" => :household,
	"SIMPLY ASIA CAVENDISH CLAREMONT ZA" => :resuarant,
	"SIMPLY ASIA GRANDWEST GOODWOOD ZA" => :resuarant,
	"SOLARDOME DEPOSIT" => :building,
	"SOLLY KRAMERS GARDEN GARDENS ZA" => :booze,
	"SPARKFUN ELECTRONICS 3032840979 US" => :hobbies,
	"SPILHAUS STIKLAND ZA" => :gifts,
	"STARLINGS CAPE TOWN ZA" => :resuarant,
	"STARLINGS CLAREMONT ZA" => :resuarant,
	"STRICTLY COFFEE ROBERTSON ZA" => :resuarant,
	"STRIPPERS CAPE TOWN ZA" => :building,
	"SUPERETTE WOODSTOCK ZA" => :resuarant,
	"SUPERMEAT MARKET KENILWORTH ZA" => :household,
	"SWARTLAND FINE 19/2/2011 12.40" => :building,
	"SWEDESPEED AUTO MONTAGUE GARD ZA" => :car_maintenance_and_licenses,
	"SWEDO CARS CAPE TOWN ZA" => :car_maintenance_and_licenses,
	"TAG RUGBY" => :kids,
	"TELKOM CAPE TOWN CSB CAPE TOWN ZA" => :internet,
	"TELKOM KENNILWORTH TDS KENILWORTH CL ZA" => :internet,
	"THAI CAFE CLAREMONT ZA" => :resuarant,
	"THE ALPHEN LA BELLE CONSTANTIA ZA" => :resuarant,
	"THE BARNYARD FISH HOEK ZA" => :resuarant,
	"THE CELLARS HOHENHORT 1 CONSTANTIA ZA" => :resuarant,
	"THE DELI EXPRESS CO WOODSTOCK ZA" => :resuarant,
	"THE FOOD LOVERS MARK CLAREMONT ZA" => :resuarant,
	"THE GARDENER'S COTTAGE NEWLANDS ZA" => :resuarant,
	"THE KIRSTENBOSCH TEA ROO NEWLANDS ZA" => :resuarant,
	"THE LOOK OUT PLETTENBERG B ZA" => :resuarant,
	"THE MILKWOOD RESTAURANT HERMANUS ZA" => :resuarant,
	"THE OLIVE BRANCH COFFEE DIEP RIVER ZA" => :resuarant,
	"THE OLIVE STATION MUIZENBERG ZA" => :resuarant,
	"THE POT LUCK CLUB WOODSTOCK ZA" => :resuarant,
	"THE POTLUCK CLUB WOODSTOCK ZA" => :resuarant,
	"THE ROUNDHOUSE RESTAURAN CAMPSBAY ZA" => :resuarant,
	"THE WILD FIG MOWBRAY ZA" => :resuarant,
	"TIMBERLAND CANALWALK CAPE TOWN ZA" => :clothes_and_shoes,
	"TIMBERLAND CAVENDISH CAPE TOWN ZA" => :clothes_and_shoes,
	"TOKARA STELENBOSCH ZA" => :resuarant,
	"TOPS DRANKWINKEL BREDASD BREDASDORP ZA" => :booze,
	"TRIBAKERY BERGVLEIT BERGVLEIT ZA" => :resuarant,
	"TRINITY GREEN POINT ZA" => :resuarant,
	"ULTRA LIQUORS PARKVIEW PARKVIEW ZA" => :booze,
	"UNCLE WILLY'S" => :kids,
	"UNCLE WILLY'S XMAS PARTY" => :kids,
	"VICTORIA BATHROOMS WETTON ZA" => :building,
	"VICTORIAN BATHROOMS GREEN POINT ZA" => :building,
	"VOLTEX CAPE TOWN NDABENI ZA" => :building,
	"VOLTEX CAPE TOWN ZA" => :building,
	"VOLVO REGISTRATION RENEWAL" => :car_maintenance_and_licenses,
	"WAFU MOUILLE POINT ZA" => :resuarant,
	"WALTONS BTS CAPE TOWN ZA" => :kids,
	"WALTONS CLAREMONT CLAREMONT ZA" => :kids,
	"WARWICK FARM STELLENBOSCH ZA" => :resuarant,
	"WELLHOUSE WAREHOUSE CAPE TOWN ZA" => :household,
	"WELLNESS WAREHOUSE CAPE TOWN ZA" => :household,
	"WELTEVREDE WYNLANDGOED BONNIEVALE ZA" => :resuarant,
	"WESTCOAST HOSPITAL" => :medical,
	"WETHERLYS 503 TOKAI ZA" => :household,
	"WEYLANDTS GREEN POINT ZA" => :household,
	"WIESENHOF COFFEE SHOP PINELANDS ZA" => :resuarant,
	"WILD ORGANICS" => :household,
	"WILLOUGHBY AND CO V & A WATERFR ZA" => :resuarant,
	"WILLY DE KLERK 2ND PMT" => :building,
	"WILLY REFUND A15128" => :building,
	"WOODSTOCK GAS WOODSTOCK ZA" => :household,
	"WYNBERG PHARMACY WYNBERG ZA" => :medical,
	"YOUNGBLOOD AFRICAN CULT CAPE TOWN ZA" => :resuarant,
	"ZIP ZAP CIRCUS SCHOOL" => :kids,
	"ZIPZAP" => :kids,
}

def parse(line)
	r = SPLITTER.match(line)
	if r
		transaction = Hash[ r.names.zip( r.captures ) ]
		#d = transaction['transaction_date'].split("/")
		#transaction['transaction_date'] = Date.new(d[0].to_i,d[1].to_i,d[2].to_i)
		transaction['transaction_date'] = DateTime.new(1899,12,30) + transaction['transaction_date'].to_i
	end
	transaction
end

#def cash_withdrawl?

#end

def method_missing(meth, *args, &block)
	r = if meth.to_s =~ /\w{2,}\?/
					target = meth.to_s.gsub('_', ' ').gsub('?', '')
					@transaction['description'] =~ /#{target}/i
			  else
			    super
			  end
  !r.nil?
end

def atm?
	( (@transaction['description'] =~ /\d{5,}\/[\w\s]{3,}/) || (@transaction['description'] =~ /[\w\s]{3,}\/[\*\w\s]{3,}/) )
end

def spain?
	(@transaction['description'] =~ /\sES$/ && SPAIN_HOLIDAY_DATES === @transaction['transaction_date'])
end

def kruger_2011?
	r = (KRUGER_2011_HOLIDAY_DATES === @transaction['transaction_date'])
	if r
		case @transaction['description']
			when "AMAZON WEB SERVICES AWS.AMAZON.CO US", "ST ANNE'S", "FINN SWIM LESSONS", "SOFIE SWIM LESSONS", "ANNIE", \
				"MONTHLY SERVICE CHARGE", "PNP CLAREMONT CLAREMONT ZA", "EASYPAY E-COMMERCE RONDEBOSCH ZA", \
				"00000000000002/PNP CLAREM CLAREMONT ZA"
					r = false
		end
	end
	r
end

def description_matches(description)
	(@transaction['description'] == description)
end

def at_home?
	(@transaction['description'] =~ /@HOMe/i) 
end


def classify
	if NAME_MAP[@transaction['description']]
		NAME_MAP[@transaction['description']]
	else
		case
		# the holiday entry must come first
		when spain?, turf_madrid_es?, wagamama?, kruger_park_za?, ingwe_supermarket?, kruger_2011?, when_sparks_fly_ltd_internet_gb?,
						luggage_warehouse?, riveredge_accom?
			:holidays
		when atm?
			:cash_withdrawl
		when description_matches('2ND HAND GT')
			:bikes
		when annie?, scar_hair_gardens_za?, clicks?, coif_hair?, body_shop?
			:personal
		when green_cross?, stuttafords?, footgear_kenilworth?, new_balance_kenilworth?, truworths?, accessorize?, ackermans?, naartjie?,
						sportsmans_warehouse?, cape_union_mart?, capestorm?
			:clothes_and_shoes
		when easypay?
			:rates
		when amazon_web_services?, rs_components_sa_midrand_za?, computer_mania?, photographic_repairs?, sa_institute_of_char?, virgin_active?, communica?
			:hobbies
		when woolworth?, pnp_?, checkers_?, kwikspar?, shoprite?, at_home?, atlas_trading?, spar_?, banks_dealers?, kwiksp?, mr_price_home?,
						raith?, pillow_factory?, description_matches('711 CALEDON CALEDON ZA'), description_matches('711 KENILWORTH ATHLONE ZA'), description_matches('A&A FURNISHERS CAPE TOWN ZA')
			:household
		when cottage_mtrs_rondebosch?, campground_motors_rondebosch?, engen?, paddys_serce_cape_town?, cottage_motors?, daves_service_station?, 
						caledonian_motors?, total_la_boutique_caledon?, community_motors_salt_river?, kleinplasie_service_station?, meadowridge_serv_centre?,
						oranje_service_station?, ultra_city?, premier_motors_rondebosch?, total_melkbos?
			:petrol
		when b_m_c_woodstock?, city_cycles?, olympic_cycle?
			:bikes
		when fir_r_mowbray_za?, donca_kenilworth_za?, fnb_bob_atm?, absa_cavendish?, nedbank_atm?, shell_cam_cape_town_za?
			:cash_withdrawl
		when caxton_books?, exclusive_books?
			:books
		when vida?, seattle_coffee?
			:coffee
		when knead?, kirstenbosch_tea_room?, crave_cape_town_za?, bruegels_restaurant_mowbray_za?, chef_pons_asian_kitchen?, aquarium_restaurant?,
						kauai_?, manna_epicure?, millstone_farmstall?, cacchio?, deer_park?, the_foodbarn_noordhoek?, colombe?, wakame?, bukhara?,
						house_sushi_observatory?, jewel_of_east_lansdowne?, jordan_restaurant?, spur_?, park_cafe_observatory?, steers_?,
						southern_cross_seafo?, roseberry_asian_cuisine?, the_test_kitchen?, description_matches('1890 HOUSE SUSHI CAPE TOWN ZA'),
						borruso?
			:restuarants
		when kirstenbosch_garden_cntr?, ferndale_nuseries?, starke_ayres?
			:garden
		when obs_printing_observatory_za?, cna_?
			:other
		when deposit_josephine?, margaret_wages?, josephine_capitec?, derek_pension?, josephine?
			:wages_and_staff
		when kiddiwinks_claremont_za?, lindsay_young_photos_lea?, sarah_daniell_ballet?, toys_r_us?, two_oceans?, kindermusik?,
						reggies?, nucleus_toys?, kidz_disco?, toy_kingdom?, finn_photos?, peggity?, hi_ho_cherry?, tinka_tonka_toys?, noddy?, tennis_coach?
			:kids
		when montessori_school?, lea_pre?, swim_lessons?, oakhurst?, playball?, swim_lessons?, curious_cubs?, kids_clay?, brawns_gymnastics?
			:school
		when ryder_plans_council?, glassmen_?, budget_locks?, hammer_and_tongs_capetown?, eagle_electric?, noel_pool_layout?,
						reuben?, yasmeen_adams?, noel_architects?, paul_borton_pool_design?, colin_weekly_wages?, pennypinchers?, sales_hire?,
						bricks_?, lt_discount_paint?, builders_warehouse?, old_world_cappings?, game_?, afrisam?, siyazama?, multisource_technologies?,
						pool_city?, nicolas_lehmann?, master_organics?, paul_borton_pool?, peninsular_brick?, pavatile?, woodlands_hardware?,
						italtile?, jotun_paints?, pool_aggregate?, timbercity?, baltic_timber?, pavers_and_cobbles?, pudlo?, revelstone?,
						gasant?, waterfront_pool_renovation?, fowkes_bros?, allied_fibreglass?, r_james_hardware?
			:building
		when j_duncan_rent?
			:rental_related
		when chamberlain?
			:rental_expense
		when from_renen?
			:transfer
		when santam?, adt_cpt_?, altrisk_?, pps_?, disc?
			:insurance
		when dr_c_r_nel_constantia_za?, dr_g_l_wainer?, savoy_pharmacy?, van_der_meer?, hofmeyr_street_surgery?, dr_coburn?, dr_laurence_oliver?,
						barry_baumgart?
			:medical
		when st_anne?
			:charity
		when langebaan_cleaning?, langebaan?
			:langebaan
		when gregg_sneddon?, allan_gray?, debit_interest?, credit_interest?, monthly_service_charge?
			:financial_management
		when sanbi_kirstenbosch?, acrobranch?
			:weekends_and_weekends_away
		when oxford_stationery?
			:stationary
		when wine_concepts?
			:wine
		when wembley_square_market_observatory?, interpark?
			:parking
		when bakkie_valet?, isuzu_registration_renewal?, city_of_cape_town_volv?, service_volvo?, steenberg?
			:car_maintenance_and_licenses
		when banff_film?, computicket?, cityrock?
			:entertainment
		when drop_inn?
			:booze
		when taxi?
			:transport_other
		when axxess?
			:internet
		when bp_?
			:petrol
		when investecpb?
			:banking_costs
		when mtn_sp?
			:telephones
		when vitaretail?
			:medical
		end
	end
end


def load_transactions
	transactions = []
	File.open("merged_20140303.csv", "r").each_line(separator = "\r") do |line|
		t = parse(line)
		transactions << t if t
	end
	transactions
end



start_time = Time.now.to_i
p 'starting...'

transactions = load_transactions

p "transactions loaded in #{Time.now.to_i - start_time} ms."

p 'classifying...'

classifications = {}
classified 		= 0
classifiable 	= 0
failed				= 0
total 				= 0

transactions.each do |t|

	total += 1

	classification = nil
	@transaction = t
	#p "[#{@transaction['description']}]" if total<10
  if @transaction # && @transaction['description']=='VITARETAIL5002781725-57226867'
  	classification = classify
  	classifications[classification] ||= 0
  	classifications[classification] += 1
  	#p "#{total} #{@transaction['description']} #{classification}"
  	p classification
  end

	classified 		+= 1 if classification
	classifiable 	+= 1 if @transaction

	#p @transaction if @transaction && classification.nil? && failed > 120 && failed < 180
	failed += 1    if @transaction.nil? || classification.nil?

end

#pp classifications

p "Classified #{classified} of #{total} (#{((classified/transactions.length.to_f*10000).round/100.0)}%) in #{Time.now.to_i - start_time} ms."








