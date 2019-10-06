build:
	docker build . --tag nginx-fundamentals

run: build
	docker run --name nginx-fundamentals-background -p 80:80 --rm -d nginx-fundamentals

shell:
	docker exec -it nginx-fundamentals-background bash