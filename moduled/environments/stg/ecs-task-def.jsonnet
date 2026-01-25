{
  "containerDefinitions": [
    {
      "cpu": 0,
      "essential": true,
      "image": "{{ tfstate `module.workload.aws_ecr_repository.example.repository_url` }}:latest",
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/stg-ecs/example",
          "awslogs-region": "ap-northeast-1",
          "awslogs-stream-prefix": "example"
        }
      },
      "name": "stg-example-container",
      "portMappings": [
        {
          "appProtocol": "",
          "containerPort": 80,
          "hostPort": 80,
          "protocol": "tcp"
        }
      ],
      "versionConsistency": ""
    }
  ],
  "cpu": "256",
  "executionRoleArn": "arn:aws:iam::{{ must_env `AWS_ID` }}:role/stg-ecs-task-execution",
  "family": "example-task",
  "ipcMode": "",
  "memory": "512",
  "networkMode": "awsvpc",
  "pidMode": "",
  "requiresCompatibilities": [
    "FARGATE"
  ]
}
