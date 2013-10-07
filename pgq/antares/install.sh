#!/bin/bash

cp pgq /lib/svc/method/
cp pgq.xml /var/svc/manifest/application/database
svccfg import /var/svc/manifest/application/database/pgq.xml