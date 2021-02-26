#!/bin/bash


TAG=r-$(date +%Y%m%d%H%M%S)
git tag $TAG
git push origin $TAG
