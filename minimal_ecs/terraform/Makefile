JQ='.taskDefinition | del (.taskDefinitionArn, .revision, .status, .requiresAttributes, .compatibilities, .registeredAt, .registeredBy)'

ecr-login:
	aws ecr get-login-password | docker login --username AWS --password-stdin https://${AWS_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

describe-repo:
	aws ecr describe-repositories

build:
	docker build -t ${AWS_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/nginx-test:v1.0 ../docker

push:
	docker push ${AWS_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/nginx-test:v1.0

fetch:
	aws ecs describe-task-definition --task-definition example-task | jq $(JQ) > task_def.json

register:
	aws ecs register-task-definition --cli-input-json file://task_def.json

update-service:
	aws ecs update-service --cluster example-cluster --service example-service --task-definition example-task --force-new-deployment
