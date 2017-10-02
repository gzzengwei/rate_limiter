# README

Rate Limit Example

### Summary

limit the number of requests to specific controller per IP in given time period. 

### Assumptions
* use `Rails.cache` for caching
* throttling by request ip
* rate limit and period variables can be read from `.env` file
* controller(s) needs throttling config in `config/initializer/middlewares.rb`

### Setup

##### setup .env

```bash
cp .env.example .env
```

and edit the required variables  

```
RATE_LIMIT_COUNT = 100
RATE_LIMIT_PERIOD = 3600
```
or skip this and use default values in `rate_limit.rb`  
(for local testing you might want to set these with smaller values)

##### install dependency
```
bundle install
```  
	
### check on web

```
bundle exec rails s
```

and visit in browser `http://localhost:3000/`

### testing

```
bundle exec rspec
```
