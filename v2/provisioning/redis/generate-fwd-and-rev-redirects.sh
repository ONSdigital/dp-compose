#!/bin/bash
echo "Setting redirects - make sure that Redis is running on localhost port 6379"
set -x
redis-cli SET "fwd:/economy/mybulletin" "/finance/mybulletin"
redis-cli SET "fwd:/economy/furtherreading/mybulletin" "/finance/mybulletin"
redis-cli SADD set1 "/economy/mybulletin" "economy/furtherreading/mybulletin"
redis-cli SET "rev:/finance/mybulletin" set1
redis-cli SET "fwd:/economy/economicoutputandproductivity/mybulletin" "/finance/economicoutputandproductivity/mybulletin"
redis-cli SET "fwd:/economy/furtherreading/economicoutputandproductivity/mybulletin" "/finance/economicoutputandproductivity/mybulletin"
redis-cli SADD set2 "/economy/economicoutputandproductivity/mybulletin" "/economy/furtherreading/economicoutputandproductivity/mybulletin"
redis-cli SET "rev:/finance/economicoutputandproductivity/mybulletin" set2
redis-cli SET "fwd:/economy/environmentalaccounts/mybulletin" "/finance/environmentalaccounts/mybulletin"
redis-cli SET "fwd:/economy/furtherreading/environmentalaccounts/mybulletin" "/finance/environmentalaccounts/mybulletin"
redis-cli SADD set3 "/economy/environmentalaccounts/mybulletin" "/economy/furtherreading/environmentalaccounts/mybulletin"
redis-cli SET "rev:/finance/environmentalaccounts/mybulletin" set3
redis-cli SET "fwd:/economy/grossvalueaddedgva/mybulletin" "/finance/grossvalueaddedgva/mybulletin"
redis-cli SET "fwd:/economy/grossvalueaddedgva/furtherreading/mybulletin" "/finance/grossvalueaddedgva/mybulletin"
redis-cli SADD set4 "/economy/grossvalueaddedgva/mybulletin" "/economy/grossvalueaddedgva/furtherreading/mybulletin"
redis-cli SET "rev:/finance/grossvalueaddedgva/mybulletin" set4
redis-cli SET "fwd:/economy/inflationandpriceindices/mybulletin" "/finance/inflationandpriceindices/mybulletin"
redis-cli SET "fwd:/economy/furtherreading/inflationandpriceindices/mybulletin" "/finance/inflationandpriceindices/mybulletin"
redis-cli SADD set5 "/economy/inflationandpriceindices/mybulletin" "/economy/furtherreading/inflationandpriceindices/mybulletin"
redis-cli SET "rev:/finance/inflationandpriceindices/mybulletin" set5
redis-cli SET "fwd:/businessindustryandtrade/mybulletin" "/commerce/mybulletin"
redis-cli SET "fwd:/businessindustryandtrade/furtherreading/mybulletin" "/commerce/mybulletin"
redis-cli SADD set6 "/businessindustryandtrade/mybulletin" "/businessindustryandtrade/furtherreading/mybulletin"
redis-cli SET "rev:/commerce/mybulletin" set6
redis-cli SET "fwd:/businessindustryandtrade/business/mybulletin" "/commerce/trade/mybulletin"
redis-cli SET "fwd:/businessindustryandtrade/business/furtherreading/mybulletin" "/commerce/trade/mybulletin"
redis-cli SADD set7 "/businessindustryandtrade/business/mybulletin" "/businessindustryandtrade/business/furtherreading/mybulletin"
redis-cli SET "rev:/commerce/trade/mybulletin" set7
redis-cli SET "fwd:/businessindustryandtrade/constructionindustry/mybulletin" "/commerce/construction/mybulletin"
redis-cli SET "fwd:/businessindustryandtrade/constructionindustry/furtherreading/mybulletin" "/commerce/construction/mybulletin"
redis-cli SADD set8 "/businessindustryandtrade/constructionindustry/mybulletin" "/businessindustryandtrade/constructionindustry/furtherreading/mybulletin"
redis-cli SET "rev:/commerce/construction/mybulletin" set8
redis-cli SET "fwd:/businessindustryandtrade/itandinternetindustry/mybulletin" "/commerce/itandinternetindustry/mybulletin"
redis-cli SET "fwd:/businessindustryandtrade/itandinternetindustry/furtherreading/mybulletin" "/commerce/itandinternetindustry/mybulletin"
redis-cli SADD set9 "/businessindustryandtrade/itandinternetindustry/mybulletin" "/businessindustryandtrade/itandinternetindustry/furtherreading/mybulletin"
redis-cli SET "rev:/commerce/itandinternetindustry/mybulletin" set9
redis-cli SET "fwd:/businessindustryandtrade/retailindustry/mybulletin" "/commerce/retail/mybulletin"
redis-cli SET "fwd:/businessindustryandtrade/retailindustry/furtherreading/mybulletin" "/commerce/retail/mybulletin"
redis-cli SADD set10 "/businessindustryandtrade/retailindustry/mybulletin" "/businessindustryandtrade/retailindustry/furtherreading/mybulletin"
redis-cli SET "rev:/commerce/retail/mybulletin" set10
redis-cli SET "fwd:/employmentandlabourmarket/mybulletin" "/workforce/mybulletin"
redis-cli SET "fwd:/employmentandlabourmarket/furtherreading/mybulletin" "/workforce/mybulletin"
redis-cli SADD set11 "/employmentandlabourmarket/mybulletin" "/employmentandlabourmarket/furtherreading/mybulletin"
redis-cli SET "rev:/workforce/mybulletin" set11
redis-cli SET "fwd:/employmentandlabourmarket/peopleinwork/mybulletin" "/workforce/employedpeople/mybulletin"
redis-cli SET "fwd:/employmentandlabourmarket/peopleinwork/furtherreading/mybulletin" "/workforce/employedpeople/mybulletin"
redis-cli SADD set12 "/employmentandlabourmarket/peopleinwork/mybulletin" "/employmentandlabourmarket/peopleinwork/furtherreading/mybulletin"
redis-cli SET "rev:/workforce/employedpeople/mybulletin" set12
redis-cli SET "fwd:/employmentandlabourmarket/peoplenotinwork/mybulletin" "/workforce/unemployedpeople/mybulletin"
redis-cli SET "fwd:/employmentandlabourmarket/peoplenotinwork/furtherreading/mybulletin" "/workforce/unemployedpeople/mybulletin"
redis-cli SADD set13 "/employmentandlabourmarket/peoplenotinwork/mybulletin" "/employmentandlabourmarket/peoplenotinwork/furtherreading/mybulletin"
redis-cli SET "rev:/workforce/unemployedpeople/mybulletin" set13
redis-cli SET "fwd:/employmentandlabourmarket/peopleinwork/earningsandworkinghours/mybulletin" "/workforce/earnings/mybulletin"
redis-cli SET "fwd:/employmentandlabourmarket/peopleinwork/earningsandworkinghours/furtherreading/mybulletin" "/workforce/earnings/mybulletin"
redis-cli SADD set14 "/employmentandlabourmarket/peopleinwork/earningsandworkinghours/mybulletin" "/employmentandlabourmarket/peopleinwork/earningsandworkinghours/furtherreading/mybulletin"
redis-cli SET "rev:/workforce/earnings/mybulletin" set14
redis-cli SET "fwd:/employmentandlabourmarket/peoplenotinwork/outofworkbenefits/mybulletin" "/workforce/unemployedpeople/benefits/mybulletin"
redis-cli SET "fwd:/employmentandlabourmarket/peoplenotinwork/outofworkbenefits/furtherreading/mybulletin" "/workforce/unemployedpeople/benefits/mybulletin"
redis-cli SADD set15 "/employmentandlabourmarket/peoplenotinwork/outofworkbenefits/mybulletin" "/employmentandlabourmarket/peoplenotinwork/outofworkbenefits/furtherreading/mybulletin"
redis-cli SET "rev:/workforce/unemployedpeople/benefits/mybulletin" set15
redis-cli SET "fwd:/peoplepopulationandcommunity/mybulletin" "/society/mybulletin"
redis-cli SET "fwd:/peoplepopulationandcommunity/furtherreading/mybulletin" "/society/mybulletin"
redis-cli SADD set16 "/peoplepopulationandcommunity/mybulletin" "/peoplepopulationandcommunity/furtherreading/mybulletin"
redis-cli SET "rev:/society/mybulletin" set16
redis-cli SET "fwd:/peoplepopulationandcommunity/culturalidentity/mybulletin" "/society/culturalidentity/mybulletin"
redis-cli SET "fwd:/peoplepopulationandcommunity/culturalidentity/furtherreading/mybulletin" "/society/culturalidentity/mybulletin"
redis-cli SADD set17 "/peoplepopulationandcommunity/culturalidentity/mybulletin" "/peoplepopulationandcommunity/culturalidentity/furtherreading/mybulletin"
redis-cli SET "rev:/society/culturalidentity/mybulletin" set17
redis-cli SET "fwd:/peoplepopulationandcommunity/educationandchildcare/mybulletin" "/society/education/mybulletin"
redis-cli SET "fwd:/peoplepopulationandcommunity/educationandchildcare/furtherreading/mybulletin" "/society/education/mybulletin"
redis-cli SADD set18 "/peoplepopulationandcommunity/educationandchildcare/mybulletin" "/peoplepopulationandcommunity/educationandchildcare/furtherreading/mybulletin"
redis-cli SET "rev:/society/education/mybulletin" set18
redis-cli SET "fwd:/peoplepopulationandcommunity/elections/mybulletin" "/society/politics/mybulletin"
redis-cli SET "fwd:/peoplepopulationandcommunity/elections/furtherreading/mybulletin" "/society/politics/mybulletin"
redis-cli SADD set19 "/peoplepopulationandcommunity/elections/mybulletin" "/peoplepopulationandcommunity/elections/furtherreading/mybulletin"
redis-cli SET "rev:/society/politics/mybulletin" set19
redis-cli SET "fwd:/peoplepopulationandcommunity/healthandsocialcare/childhealth/mybulletin" "/society/healthandsocialcare/childhealth/mybulletin"
redis-cli SET "fwd:/peoplepopulationandcommunity/healthandsocialcare/childhealth/furtherreading/mybulletin" "/society/healthandsocialcare/childhealth/mybulletin"
redis-cli SADD set20 "/peoplepopulationandcommunity/healthandsocialcare/childhealth/mybulletin" "/peoplepopulationandcommunity/healthandsocialcare/childhealth/furtherreading/mybulletin"
redis-cli SET "rev:/society/healthandsocialcare/childhealth/mybulletin" set20
set +x
echo "20 forward and 20 reverse redirect keys and values now set in Redis"
