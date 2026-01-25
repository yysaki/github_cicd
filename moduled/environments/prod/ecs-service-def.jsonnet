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
      "containerName": "prod-example-container",
      "containerPort": 80,
      "targetGroupArn": "{{ tfstate `module.workload.aws_lb_target_group.example.arn` }}"
    }
  ],
  "networkConfiguration": {
    "awsvpcConfiguration": {
      "assignPublicIp": "DISABLED",
      "securityGroups": [
        "{{ tfstate `module.workload.aws_security_group.nginx.id` }}"
      ],
      "subnets": [
        "{{ tfstate `module.workload.aws_subnet.private['ap-northeast-1a'].id` }}",
        "{{ tfstate `module.workload.aws_subnet.private['ap-northeast-1c'].id` }}",
      ]
    }
  },
  "platformFamily": "Linux",
  "platformVersion": "LATEST",
  "propagateTags": "NONE",
  "resourceManagementType": "CUSTOMER",
  "schedulingStrategy": "REPLICA"
}
