# Topología de red

```text
                         Internet
                            |
                           NAT
                            |
               +--------------------------+
               | pg-primary               |
               | NAT: DHCP                |
               | Host-only: 192.168.56.20 |
               +--------------------------+
                            |
                  Host-only 192.168.56.0/24
                            |
               +------------+-------------+
               |                          |
            Anfitrión                VMs futuras
           192.168.56.1              ansible-control .10
                                     pg-standby .21
                                     mariadb-lab .30
```

La red Host-only se utiliza para administración y tráfico privado del laboratorio. La salida por defecto a Internet permanece en NAT.
