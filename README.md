# Continuous Delivery with Docker, Circle CI, and ECS

## Workflow

1. Push code to GitHub
1. New build is ran on Circle
  1. Docker images are build and pushed to AWS Elastic Container Registry
  1. Tasks are updated
  1. Cluster and service are updated


WIP
