JQ='.taskDefinition | del (.taskDefinitionArn, .revision, .status, .requiresAttributes, .compatibilities, .registeredAt, .registeredBy)'

terraform-init:
	terraform init -backend-config="bucket=${TFSTATE_S3_BUCKET}"

ecr-login:
	aws ecr get-login-password | docker login --username AWS --password-stdin https://${AWS_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

build:
	docker build -t ${AWS_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/nginx-test:latest ../docker

push:
	docker push ${AWS_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/nginx-test:latest

deploy:
	cd ../ecspresso && ecspresso deploy
