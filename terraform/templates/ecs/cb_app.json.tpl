[
  {
    "name": "${name}",
    "image": "${app_image}",
    "cpu": ${fargate_cpu},
    "memory": ${fargate_memory},
    "networkMode": "awsvpc",
    "essential": true,
    "mountPoints": [],
    "volumesFrom": [],    
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/${name}",
          "awslogs-region": "${aws_region}",
          "awslogs-stream-prefix": "ecs"
        }
    },
    "healthCheck":{
          "command": [ "CMD-SHELL","curl -f http://localhost:${app_port}${health_check_path} || exit 1" ],
          "interval": 30,
          "retries": 3,
          "timeout": 5          
    },
    "Environment" : [
      { "name" : "NODE_ENV", "value" : "${environment}" },
      { "name" : "BASE_URL", "value" : "https://devops.evacenter.com/" }
    ],
    "portMappings": [
      {
        "containerPort": ${app_port},
        "hostPort": ${app_port},
        "protocol": "tcp"
      }
    ]
  }
]
