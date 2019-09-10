up: kill
	docker-compose up -d
	docker exec crpd1 ifconfig eth0 192.168.168.1/24
	docker exec crpd2 ifconfig eth0 192.168.168.2/24

down:
	docker-compose down
	sudo rm -rf /var/run/snabb
	sudo chown -R mwiget snabb1 snabb2 crpd1 crpd2
	sudo chgrp -R mwiget snabb1 snabb2 crpd1 crpd2
kill:
	docker-compose kill
	sudo rm -rf /var/run/snabb

