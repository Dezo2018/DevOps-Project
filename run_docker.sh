#!/usr/bin/env bash

## run Docker locally

# Step 1:
# Build image and add a descriptive tag

# Step 2: 
# List docker images

# Step 3: 
# Run flask app

docker build --tag=capstone .

docker image ls

docker run -p 8081:8081 capstone
