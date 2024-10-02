#!/bin/bash
mkdir ds
mkdir ds/logs
mkdir config
touch config/ops.cfg
chown -R 1000:1000 ds
chown -R 1000:1000 config