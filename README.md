# Blue/Green deployment wih Docker compose, Nginx, Consul and Registrator

* Run `docker network create consul` to create a new network;
* Run `docker-compose -f docker-compose-consul.yml up -d` to start Consul and Registrator;
* Open in browser `http://localhost:8500/` to check;
* Run `./deploy.sh` to first run;
* Open in browser `http://localhost/` to check;
* Run `./deploy.sh` to imitate deploying of a new app;
* Open in browser `http://localhost/` to check a new version;
* Run `./rollback.sh` to imitate a rollback;
* Open in browser `http://localhost/` to check an old version;
* Use `python2.7 test.py` in a new terminal to be sure that an app is always online during a deploy/rollback.
