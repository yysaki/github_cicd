{
  "availabilityZoneRebalancing": "ENABLED",
  "deploymentConfiguration": {
    "bakeTimeInMinutes": 0,
    "deploymentCircuitBreaker": {
      "enable": false,
      "rollback": false
    },
    "maximumPercent": 200,
    "minimumHealthyPercent": 100,
    "strategy": "ROLLING"
  },
  "deploymentController": {
    "type": "ECS"
  },
  "desiredCount": 2,
  "enableECSManagedTags": false,
  "enableExecuteCommand": false,
  "healthCheckGracePeriodSeconds": 0,
  "launchType": "FARGATE",
  "loadBalancers": [
    {
      "containerName": "example-container",
      "containerPort": 80,
      "targetGroupArn": "{{ tfstate `aws_lb_target_group.example.arn` }}"
    }
  ],
  "networkConfiguration": {
    "awsvpcConfiguration": {
      "assignPublicIp": "DISABLED",
      "securityGroups": [
        "{{ tfstate `aws_security_group.nginx.id` }}"
      ],
      "subnets": [
        "{{ tfstate `aws_subnet.private['ap-northeast-1a'].id` }}",
        "{{ tfstate `aws_subnet.private['ap-northeast-1c'].id` }}"
      ]
    }
  },
  "platformFamily": "Linux",
  "platformVersion": "LATEST",
  "propagateTags": "NONE",
  "resourceManagementType": "CUSTOMER",
  "schedulingStrategy": "REPLICA",
  "tags": [
    {
      "key": "Env",
      "value": "prod"
    }
  ]
}
