# nginx-docker-swarm
A Nginx wich can see changes in Upstream via DNS

Here ist a docker-stack.yml docker-compose.yml File which reloads nginx if the upstream collabora are restarting:

```
version: "3.5"

networks:
  traefik_public:
    external: true

 web:
    image: styliteag/nginx-docker-swarm:latest
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    environment:
      - UPSTREAM=tasks.collabora
    networks:
      - traefik_public
      - default
    depends_on:
      - collabora
    # This ist for docker-compose
    labels:
      - traefik.enable=true
      - traefik.port=80
      - traefik.frontend.rule=Host:collabora.your.domain
      - traefik.protocol=http
    deploy:
      replicas: 1
      # This is for docker stack
      labels:
        - traefik.enable=true
        - traefik.port=80
        - traefik.frontend.rule=Host:collabora.your.domain
        - traefik.protocol=http
        - traefik.frontend.passHostHeader=true
        - traefik.backend.loadbalancer.stickiness=true
        
  collabora:
    #image: styliteag/collabora-code:latest
    image: collabora/code
    env_file: ./collabora.env
    cap_add:
      - MKNOD
    deploy:
      replicas: 2
 ```
 
 
