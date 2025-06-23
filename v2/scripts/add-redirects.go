package main

import (
	"context"
	"fmt"

	disRedis "github.com/ONSdigital/dis-redis"
	"github.com/ONSdigital/log.go/v2/log"
)

func main() {
	fmt.Println("Setting redirects - make sure that Redis is running on localhost port 6379")

	ctx := context.Background()
	redisCli, redisErr := GetRedisClient(ctx)

	if redisErr != nil {
		log.Fatal(ctx, "failed to create redis client", redisErr)
	}

	// Add 20 redirects
	redisErr = redisCli.SetValue(ctx, "/economy/mybulletin", "/finance/mybulletin", 0)
	redisErr = redisCli.SetValue(ctx, "/economy/economicoutputandproductivity/mybulletin", "/finance/economicoutputandproductivity/mybulletin", 0)
	redisErr = redisCli.SetValue(ctx, "/economy/environmentalaccounts/mybulletin", "/finance/environmentalaccounts/mybulletin", 0)
	redisErr = redisCli.SetValue(ctx, "/economy/grossvalueaddedgva/mybulletin", "/finance/grossvalueaddedgva/mybulletin", 0)
	redisErr = redisCli.SetValue(ctx, "/economy/inflationandpriceindices/mybulletin", "/finance/inflationandpriceindices/mybulletin", 0)
	redisErr = redisCli.SetValue(ctx, "/businessindustryandtrade/mybulletin", "/commerce/mybulletin", 0)
	redisErr = redisCli.SetValue(ctx, "/businessindustryandtrade/business/mybulletin", "/commerce/trade/mybulletin", 0)
	redisErr = redisCli.SetValue(ctx, "/businessindustryandtrade/constructionindustry/mybulletin", "/commerce/construction/mybulletin", 0)
	redisErr = redisCli.SetValue(ctx, "/businessindustryandtrade/itandinternetindustry/mybulletin", "/commerce/itandinternetindustry/mybulletin", 0)
	redisErr = redisCli.SetValue(ctx, "/businessindustryandtrade/retailindustry/mybulletin", "/commerce/retail/mybulletin", 0)
	redisErr = redisCli.SetValue(ctx, "/employmentandlabourmarket/mybulletin", "/workforce/mybulletin", 0)
	redisErr = redisCli.SetValue(ctx, "/employmentandlabourmarket/peopleinwork/mybulletin", "/workforce/employedpeople/mybulletin", 0)
	redisErr = redisCli.SetValue(ctx, "/employmentandlabourmarket/peoplenotinwork/mybulletin", "/workforce/unemployedpeople/mybulletin", 0)
	redisErr = redisCli.SetValue(ctx, "/employmentandlabourmarket/peopleinwork/earningsandworkinghours/mybulletin", "/workforce/earnings/mybulletin", 0)
	redisErr = redisCli.SetValue(ctx, "/employmentandlabourmarket/peoplenotinwork/outofworkbenefits/mybulletin", "/workforce/unemployedpeople/benefits/mybulletin", 0)
	redisErr = redisCli.SetValue(ctx, "/peoplepopulationandcommunity/mybulletin", "/society/mybulletin", 0)
	redisErr = redisCli.SetValue(ctx, "/peoplepopulationandcommunity/culturalidentity/mybulletin", "/society/culturalidentity/mybulletin", 0)
	redisErr = redisCli.SetValue(ctx, "/peoplepopulationandcommunity/educationandchildcare/mybulletin", "/society/education/mybulletin", 0)
	redisErr = redisCli.SetValue(ctx, "/peoplepopulationandcommunity/elections/mybulletin", "/society/politics/mybulletin", 0)
	redisErr = redisCli.SetValue(ctx, "/peoplepopulationandcommunity/healthandsocialcare/childhealth/mybulletin", "/society/healthandsocialcare/childhealth/mybulletin", 0)

	if redisErr != nil {
		log.Fatal(ctx, "failed to set redirect values", redisErr)
	}

	fmt.Println("20 redirect keys and values now set in Redis")
}

var GetRedisClient = func(ctx context.Context) (*disRedis.Client, error) {
	clientConfig := &disRedis.ClientConfig{
		Address: "localhost:6379",
	}
	redisClient, err := disRedis.NewClient(ctx, clientConfig)

	if err != nil {
		log.Error(ctx, "Failed to create dis-redis client", err)
		return nil, err
	}

	return redisClient, nil
}
