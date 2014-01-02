require 'date'
require 'pp'

FIELDS 					= %w(posted_date transaction_date description debits credits balance)
SPLITTER				= /(?<posted_date>[\d\/]+?),(?<transaction_date>[\d\/]+?),\"(?<description>.+?)\",(?<debit>[\d\.]*?),(?<credit>[\d\.]*?),/
#CLASSIFICATIONS = [:personal, :household, :security, :water, :electricity, :rates, :petrol, :car_maintenance, :cash_withdrawl, :books]

SPAIN_HOLIDAY_DATES 				= Date.new(2011,6,9)..Date.new(2011,6,17)
KRUGER_2011_HOLIDAY_DATES		= Date.new(2011,8,4)..Date.new(2011,8,15)


def parse(line)
	r = SPLITTER.match(line)
	if r
		transaction = Hash[ r.names.zip( r.captures ) ]
		d = transaction['transaction_date'].split("/")
		transaction['transaction_date'] = Date.new(d[0].to_i,d[1].to_i,d[2].to_i)
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

def at_home?
	(@transaction['description'] =~ /@HOMe/i)
end


def classify
	case
	# the holiday entry must come first
	when spain?, turf_madrid_es?, wagamama?, kruger_park_za?, ingwe_supermarket?, kruger_2011?, when_sparks_fly_ltd_internet_gb?,
					luggage_warehouse?, riveredge_accom?
		:holidays
	when annie?, scar_hair_gardens_za?, clicks?, coif_hair?, body_shop?
		:personal
	when green_cross?, stuttafords?, footgear_kenilworth?, new_balance_kenilworth?, truworths?, accessorize?, ackermans?, naartjie?,
					sportsmans_warehouse?, cape_union_mart?, capestorm?
		:clothes_and_shoes
	when easypay?
		:rates
	when amazon_web_services?, rs_components_sa_midrand_za?, computer_mania?, photographic_repairs?, sa_institute_of_char?, virgin_active?
		:hobbies
	when woolworth?, pnp_?, checkers_?, kwikspar?, shoprite?, at_home?, atlas_trading?, spar_?, banks_dealers?, kwiksp?, mr_price_home?,
					raith?, pillow_factory?
		:household
	when cottage_mtrs_rondebosch?, campground_motors_rondebosch?, engen?, paddys_serce_cape_town?, cottage_motors?, daves_service_station?, 
					caledonian_motors?, total_la_boutique_caledon?, community_motors_salt_river?, kleinplasie_service_station?, meadowridge_serv_centre?,
					oranje_service_station?, ultra_city?, premier_motors_rondebosch?, total_melkbos?
		:petrol
	when b_m_c_woodstock?, city_cycles?, olympic_cycle?
		:bikes
	when fir_r_mowbray_za?, donca_kenilworth_za?
		:cash_withdrawl
	when caxton_books?, exclusive_books?
		:books
	when vida?, seattle_coffee?
		:coffee
	when knead?, kirstenbosch_tea_room?, crave_cape_town_za?, bruegels_restaurant_mowbray_za?, chef_pons_asian_kitchen?, aquarium_restaurant?,
					kauai_?, manna_epicure?, millstone_farmstall?, cacchio?, deer_park?, the_foodbarn_noordhoek?, colombe?, wakame?, bukhara?,
					house_sushi_observatory?, jewel_of_east_lansdowne?, jordan_restaurant?, spur_?, park_cafe_observatory?, steers_?,
					southern_cross_seafo?, roseberry_asian_cuisine?, the_test_kitchen?
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
	when santam?, adt_cpt_?, altrisk_?, pps_?
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
	when sanbi_kirstenbosch?
		:weekends_and_weekends_away
	when fnb_bob_atm?, absa_cavendish?, nedbank_atm?, shell_cam_cape_town_za?
		:cash
	when oxford_stationery?
		:stationary
	when wine_concepts?
		:wine
	when wembley_square_market_observatory?, interpark?
		:parking
	when bakkie_valet?, isuzu_registration_renewal?, city_of_cape_town_volv?, service_volvo?, steenberg?
		:car_maintenance_and_licenses
	when banff_film?, computicket?
		:entertainment
	when drop_inn?
		:booze
	end
end


def load_transactions
	transactions = []
	File.open("banking_transactions/201305302107", "r").each_line do |line|
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
  if @transaction
  	classification = classify
  	classifications[classification] ||= 0
  	classifications[classification] += 1
  end

	classified 		+= 1 if classification
	classifiable 	+= 1 if @transaction

	p line 				 unless @transaction
	p @transaction if @transaction && classification.nil? && failed > 120 && failed < 180
	failed += 1    if @transaction.nil? || classification.nil?

end

#pp classifications

p "Classified #{classified} of #{total} (#{((classified/transactions.length.to_f*10000).round/100.0)}%) in #{Time.now.to_i - start_time} ms."

