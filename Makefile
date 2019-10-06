help:
	@grep -E '^(\w|-)+:.*##.*$$' $(MAKEFILE_LIST) | awk -F ':.*##' '{printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Build nginx image
	docker build . --tag nginx-fundamentals


run: ## Run nginx image
	docker run --rm -d \
	-p 80:80 \
	--name nginx-fundamentals-background \
	-v $(shell pwd)/conf/nginx.conf:/etc/nginx/nginx.conf:consistent \
	-v $(shell pwd)/src:/app:consistent \
	nginx-fundamentals
	docker logs -f nginx-fundamentals-background

shell: ## Get a bash shell into running container
	docker exec -it nginx-fundamentals-background bash

kill: ## Kill running container
	docker kill nginx-fundamentals-background

logs: ## Print running container logs 
	docker logs nginx-fundamentals-background

start: ## Start nginx in running contianer
	docker exec nginx-fundamentals-background supervisorctl start nginx

restart: ## Restart nginx in running contianer
	docker exec nginx-fundamentals-background supervisorctl restart nginx

stop: ## Stop nginx in running contianer
	docker exec nginx-fundamentals-background supervisorctl stop nginx