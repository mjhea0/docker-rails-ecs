#!/usr/bin/env bash

# bash-friendly output for jq
JQ="jq --raw-output --exit-status"

configure_aws_cli() {
	aws --version
	aws configure set default.region us-west-2
	aws configure set default.output json
	echo "Configured!"
}

push_images() {
	eval $(aws ecr get-login)
  # docker tag -f web $AWS_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/web:$CIRCLE_SHA1
	# docker push $AWS_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/web:$CIRCLE_SHA1
  docker tag -f web $AWS_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/web:latest
	docker push $AWS_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/web:latest
	# docker tag -f web-database $AWS_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/web-database:$CIRCLE_SHA1
	# docker push $AWS_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/web:$CIRCLE_SHA1
  docker tag -f web-database $AWS_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/web-database:latest
	docker push $AWS_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/web-database:latest
	echo "Image(s) pushed!"
}

make_task_def() {
    task_template=$(cat ecs_taskdefinition.json)
    task_def=$(printf "$task_template" $AWS_ACCOUNT_ID $AWS_ACCOUNT_ID)
    echo "$task_def"
}

register_definition() {

    if revision=$(aws ecs register-task-definition --cli-input-json "$task_def" --family $family | $JQ '.taskDefinition.taskDefinitionArn'); then
        echo "Revision: $revision"
    else
        echo "Failed to register task definition"
        return 1
    fi

}

deploy_cluster() {

    family="sample-rails-task-family"

    make_task_def
    register_definition

    if [[ $(aws ecs update-service --cluster sample-rails-cluster --service sample-rails-service --task-definition $revision | \
                   $JQ '.service.taskDefinition') != $revision ]]; then
        echo "Error updating service."
        return 1
    fi

    # wait for older revisions to disappear
    for attempt in {1..30}; do
        if stale=$(aws ecs describe-services --cluster sample-rails-cluster --services sample-rails-service | \
                       $JQ ".services[0].deployments | .[] | select(.taskDefinition != \"$revision\") | .taskDefinition"); then
            echo "Waiting for stale deployments:"
            echo "$stale"
            sleep 5
        else
            echo "Deployed!"
            return 0
        fi
    done
    echo "Service update took too long."
    return 1
}

configure_aws_cli
push_images
deploy_cluster
