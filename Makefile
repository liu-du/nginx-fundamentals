build:
	docker build . --tag nginx-fundamentals

run: build
	docker run --rm -d -p 80:80 --name nginx-fundamentals-background \
	-v $(shell pwd)/conf/nginx.conf:/etc/nginx/nginx.conf:consistent \
	-v $(shell pwd)/src:/app:consistent \
	nginx-fundamentals

restart:
	docker exec nginx-fundamentals-background supervisorctl restart nginx

shell:
	docker exec -it nginx-fundamentals-background bash

kill:
	docker kill nginx-fundamentals-background

logs:
	docker logs nginx-fundamentals-background