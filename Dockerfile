FROM gvenzl/oracle-xe:latest

# On passe en root pour installer les outils
USER root

# Sur Oracle Linux, on utilise microdnf pour installer des paquets
RUN microdnf install -y iputils hostname net-tools && \
    microdnf clean all

# On repasse en utilisateur oracle
USER oracle