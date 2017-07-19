# Continuous Delivery with Docker, Circle CI, and ECS

[![CircleCI](https://circleci.com/gh/mjhea0/docker-rails-ecs.svg?style=svg)](https://circleci.com/gh/mjhea0/docker-rails-ecs)

## Setup

1. Create new Repository on AWS ECR
1. Create new Task Definitions and a Task Family on AWS ECS
1. Create new Cluster and Service on AWS ECS

## Workflow

1. Code!
1. Push to GitHub
1. New build is ran on Circle
  1. Docker images are built and pushed to AWS ECR
  1. Tasks are updated on AWS ECS
  1. Cluster and service are updated on AWS ECS

WIP
