#!/bin/bash
ls -la
pwd
id
./aniv-ds.sh validate anonymous
cd aniv-ds
./aniv_server.x86_64 -map nightmare -timestamps
# ./aniv_server.x86_64 -map nightmare -timestamps