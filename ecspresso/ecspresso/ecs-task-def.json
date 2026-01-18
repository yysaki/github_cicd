{
  "containerDefinitions": [
    {
      "cpu": 0,
      "essential": true,
      "image": "{{ tfstate `aws_ecr_repository.example.repository_url` }}:latest",
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/example",
          "awslogs-region": "ap-northeast-1",
          "awslogs-stream-prefix": "example"
        }
      },
      "name": "example-container",
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
  "executionRoleArn": "arn:aws:iam::{{ must_env `AWS_ID` }}:role/ecs-task-execution",
  "family": "example-task",
  "ipcMode": "",
  "memory": "512",
  "networkMode": "awsvpc",
  "pidMode": "",
  "requiresCompatibilities": [
    "FARGATE"
  ],
  "tags": [
    {
      "key": "Env",
      "value": "prod"
    }
  ]
}
