## Overview
Dockerfile for KyotoTycoon

## Usage
docker build -t kyototycoon ./ <br />
docker run -v /var/ktserver:/var/ktserver -p 1978:1978 --name kt -d -t kyototycoon


