# Agente aislado: Java, Git, Bash, SSH y cliente PostgreSQL.

FROM jenkins/ssh-agent:jdk21

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends postgresql-client \
    && rm -rf /var/lib/apt/lists/*