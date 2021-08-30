terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

############################################################
# define region
############################################################
provider "aws" {
  region = "us-west-2"
}

data "aws_caller_identity" "current" { }

############################################################
# get vpc by tag name
############################################################
data "aws_vpc" "default" {
    tags = {
        Name = "vpc-0a347e4a10eb"
    }
}

############################################################
# get corresponding  subnets under vpc
############################################################
data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_iam_policy" "boundary" {
  arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/AdminPermissionsBoundary"
}

# create ecr repo
resource "aws_ecr_repository" "tess" {
	name = "tf-tess-ecr-repo"
	image_tag_mutability = "MUTABLE"
	image_scanning_configuration {
	   scan_on_push = true
	}
}
############################################################
# create the respective security group for inbound and outbound traffic
############################################################
resource "aws_security_group" "tess_ecs_vpc_sg" {
  name        = "tf-tess-ecs-vpc-sg"
  description = "Allows access from VPC"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "All inbound traffic from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    ignore_changes = [tags]
  }
}
############################################################
# create the ALB
############################################################
resource "aws_alb" "tess-alb" {
  name            = "tf-alb-tess-website"
  internal        = true
  load_balancer_type = "application"
  subnets = data.aws_subnet_ids.default.ids
  security_groups = [aws_security_group.tess_ecs_vpc_sg.id]
  enable_deletion_protection = false

}

############################################################
# create the ALB target group HTTP port 80
############################################################

resource "aws_alb_target_group" "tg-tess-website" {
  name        = "tf-tg-tess-website-alb"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.default.id
}


############################################################
# create the ALB target group HTTP port 80
############################################################
resource "aws_alb_listener" "tess-listener" {
  load_balancer_arn = "${aws_alb.tess-alb.arn}"
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.tg-tess-website.arn}"
  }
}


############################################################
# create Selenium Grid ALB
############################################################
resource "aws_alb" "tess-selenium-alb" {
  name            = "tf-selenium-grid-alb"
  internal        = true
  load_balancer_type = "application"
  subnets = data.aws_subnet_ids.default.ids
  security_groups = [aws_security_group.tess_ecs_vpc_sg.id]
  enable_deletion_protection = false

}

############################################################
# create the Selenium Grid ALB target group HTTP port 4444
############################################################

resource "aws_alb_target_group" "tg-selenium-grid-ip" {
  name        = "tf-selenium-grid-alb"
  port        = 4444
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.default.id
}


############################################################
# create the ALB target group HTTP port 4444
############################################################
resource "aws_alb_listener" "tess-selenium-listener" {
  load_balancer_arn = "${aws_alb.tess-selenium-alb.arn}"
  port              = "4444"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.tg-selenium-grid-ip.arn}"
  }
}

############################################################
# create the Route 53 association
############################################################
resource "aws_route53_record" "tess-53" {
  zone_id = "Z0627601PA9XJHTZ3VQF"
  name    = "fargate"
  type    = "CNAME"
  ttl     = "60"
  records = ["${aws_alb.tess-alb.dns_name}"]
}

############################################################
# create the Route 53 selenium gridassociation
############################################################
resource "aws_route53_record" "tess-selenium-grid-53" {
  zone_id = "Z0627601PA9XJHTZ3VQF"
  name    = "selenium-grid"
  type    = "CNAME"
  ttl     = "60"
  records = ["${aws_alb.tess-selenium-alb.dns_name}"]
}

############################################################
# create the ECS cluster
############################################################
resource "aws_ecs_cluster" "tess" {
  name                = "tf-tess-cluster"
  capacity_providers  = ["FARGATE"]
  lifecycle {
    ignore_changes = [tags]
  }
}



############################################################
# Create service role for ECS Service role to write logs to cloudwatch
############################################################

resource "aws_iam_role" "ecs_tess_service_role" {
  name                  = "TF-TessServiceRole"
  description           = "Allows ECS tasks and write CloudWatch logs"
  assume_role_policy    = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
POLICY
  permissions_boundary  = data.aws_iam_policy.boundary.arn
  lifecycle {
    ignore_changes = [ tags ]
  }
}

resource "aws_cloudwatch_log_group" "tess_log" {
  name              = "tess"
  retention_in_days = 1
  lifecycle {
    ignore_changes = [ tags ]
  }
}

############################################################
# Create respective cloudwatch policy to write logs
############################################################

resource "aws_iam_policy" "write_cloudwatch_logs_policy" {
  name        = "TF-TessWriteCloudWatchLogsPolicy"
  description = "Allows to write Cloudwatch logs"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams"
            ],
            "Resource": [
                "arn:aws:logs:*:*:*"
            ],
            "Effect": "Allow"
        }
    ]
}
	POLICY
}

############################################################
# Attach ECS Service role to cloudwatch write logs policy
############################################################

resource "aws_iam_role_policy_attachment" "tess_role_attachment_cw" {
  role       = aws_iam_role.ecs_tess_service_role.name
  policy_arn = aws_iam_policy.write_cloudwatch_logs_policy.arn
}

############################################################
# Create Task execution role so the task definition has permission 
# to access the respective services (Ex. Read access to ECR)
############################################################

resource "aws_iam_role" "ecs_task_execution_role" {
  name                  = "TF-TessEcsTaskExecutionRole"
  description           = "Role allows ECS task to have access to aws services "
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
POLICY
  permissions_boundary  = data.aws_iam_policy.boundary.arn
  lifecycle {
    ignore_changes = [ tags ]
  }
}

############################################################
# Create the ECS Task Execution role policy
############################################################

resource "aws_iam_policy" "ecs_task_execution_policy" {
  name        = "TF-TessEcsTaskExecutionPolicy"
  description = "Allows ECS services to run containers and write CloudWatch logs"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams"
            ],
            "Resource": "*"
        }
    ]
}
  POLICY
}

############################################################
# Create the Task Definition and associate the service and execution roles
############################################################

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_execution_policy.arn
}

############################################################
# Create the ECS task definition with container and port mappings
############################################################

############################################################
# Create the ECS task definition with container and port mappings
############################################################

resource "aws_ecs_task_definition" "tess" {
  family                    = "tf-tess-task-def"
  task_role_arn             = aws_iam_role.ecs_tess_service_role.arn
  execution_role_arn        = aws_iam_role.ecs_task_execution_role.arn
  network_mode              = "awsvpc"
  cpu                       = 512
  memory                    = 1024
  requires_compatibilities  = [ "FARGATE" ]
  lifecycle {
    ignore_changes = [ tags ]
  }
  container_definitions = jsonencode([
    {
      name: "tf-tess-container",
      image: "${aws_ecr_repository.tess.repository_url}:Latest",
      essential: true,
      cpu = 512
      portMappings = [
        {
          protocol      = "tcp"
          containerPort = 80
          hostPort      = 80
        }
      ],
      volumesFrom = []
      mountPoints = []
      logConfiguration: {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "tess",
          "awslogs-region": "us-west-2",
          "awslogs-stream-prefix": "ecs"
        }
      },
      environment: []
    }
  ])
}

############################################################
# Create the ECS service with spinning up maximum 1 container for the respective task
############################################################

resource "aws_ecs_service" "tess-service" {
  name                                = "tf-tess-website-service"
  cluster                             = aws_ecs_cluster.tess.id
  task_definition                     = aws_ecs_task_definition.tess.arn
  desired_count                       = 1
  deployment_minimum_healthy_percent  = 100
  deployment_maximum_percent          = 200
  depends_on                          = [ aws_iam_role.ecs_tess_service_role ]
  force_new_deployment                = true
  launch_type                         = "FARGATE"
  enable_execute_command              = true

  load_balancer {
    target_group_arn = "${aws_alb_target_group.tg-tess-website.arn}"
    container_name   = "tf-tess-container"
    container_port   = 80
  }
  network_configuration {
    subnets = data.aws_subnet_ids.default.ids
    security_groups = [ aws_security_group.tess_ecs_vpc_sg.id ]
  }

  lifecycle {
    ignore_changes = [tags, tags_all]
  }
}

############################################################
# Create Selenium Hub task definition 
############################################################


resource "aws_ecs_task_definition" "selenium-hub" {
  family                    = "tf-selenium-hub-def"
  task_role_arn             = aws_iam_role.ecs_tess_service_role.arn
  execution_role_arn        = aws_iam_role.ecs_task_execution_role.arn
  network_mode              = "awsvpc"
  cpu = 2048
  memory = 4096
  requires_compatibilities  = [ "FARGATE" ]
  lifecycle {
    ignore_changes = [ tags ]
  }
  container_definitions = jsonencode([
    {
		name: "tf-selenium-hub-container",
		image: "cgregistry.capgroup.com/selenium/hub:latest",
		essential: true,
		cpu = 512
		portMappings = [
        {
			protocol      = "tcp"
			containerPort = 4444
			hostPort      = 4444
        }
		],
		"environment": [
			{
				"name": "GRID_MAX_SESSION",
				"value": "16"
			},
            {
                 "name": "GRID_BROWSER_TIMEOUT",
                "value": "3000"
            },
            {
                "name":"GRID_TIMEOUT",
                "value":"3000"
            }

        ],
      logConfiguration: {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "tess",
          "awslogs-region": "us-west-2",
          "awslogs-stream-prefix": "ecs"
        }
      }
    },
	{
		name: "chrome-node",
		image: "cgregistry.capgroup.com/selenium/node-chrome-debug:latest",
		essential: true,
		cpu = 512
		portMappings = [
        {
			protocol      = "tcp"
			containerPort = 5555
			hostPort      = 5555
        }
		],
		"environment": [
			{
				"name": "NODE_MAX_SESSION",
				"value": "3"
			},
            {
                 "name": "NODE_MAX_INSTANCES",
                "value": "3"
            },
            {
                "name":"HUB_HOST",
                "value":"selenium-grid.tess.aws-dev.capgroup.com"
            },
			{
                "name":"HUB_PORT",
                "value":"4444"
            }
        ],
      logConfiguration: {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "tess",
          "awslogs-region": "us-west-2",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
	
  ])
}

############################################################
# Create the ECS service for spinning up Selenium Hub container 
############################################################

resource "aws_ecs_service" "selenium-hub-service" {
  name                                = "tf-selenium-hub-service"
  cluster                             = aws_ecs_cluster.tess.id
  task_definition                     = aws_ecs_task_definition.selenium-hub.arn
  desired_count                       = 1
  deployment_minimum_healthy_percent  = 100
  deployment_maximum_percent          = 200
  depends_on                          = [ aws_iam_role.ecs_tess_service_role ]
  force_new_deployment                = true
  launch_type                         = "FARGATE"
  enable_execute_command              = true

  load_balancer {
    target_group_arn = "${aws_alb_target_group.tg-selenium-grid-ip.arn}"
    container_name   = "tf-selenium-hub-container"
    container_port   = 4444
  }
  network_configuration {
    subnets = data.aws_subnet_ids.default.ids
    security_groups = [ aws_security_group.tess_ecs_vpc_sg.id ]
  }

  lifecycle {
    ignore_changes = [tags, tags_all]
  }
}
