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

############################################################
# get corresponding  Security Group Info
############################################################

data "aws_security_group" "tess_ecs_vpc_sg"  {
	name = "tf-tess-ecs-vpc-sg"
}

/*
output "myvar"  {
	
	value = data.aws_security_group.tess_ecs_vpc_sg.id
}*/



############################################################
# get corresponding ecs Service role Info
############################################################

data "aws_iam_role" "ecs_tess_service_role" {
	name = "TF-TessServiceRole"
}

############################################################
# get corresponding ecs Task Execution role Info
############################################################

data "aws_iam_role" "ecs_task_execution_role" {
	name = "TF-TessEcsTaskExecutionRole"
}

############################################################
# get corresponding ecr Info
############################################################
data "aws_ecr_repository" "tess" {
	name = "tf-tess-ecr-repo"
}


############################################################
# create the ALB
############################################################
resource "aws_alb" "tess-alb" {
  name            = "tf-alb-tess-website"
  internal        = true
  load_balancer_type = "application"
  subnets = data.aws_subnet_ids.default.ids
  security_groups = [data.aws_security_group.tess_ecs_vpc_sg.id]
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
  security_groups = [data.aws_security_group.tess_ecs_vpc_sg.id]
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
# create the Route 53 selenium grid association
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
# Create the ECS task definition with container and port mappings
############################################################

resource "aws_ecs_task_definition" "tess" {
  family                    = "tf-tess-task-def"
  task_role_arn             = data.aws_iam_role.ecs_tess_service_role.arn
  execution_role_arn        = data.aws_iam_role.ecs_task_execution_role.arn
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
      image: "${data.aws_ecr_repository.tess.repository_url}:tess-website-latest",
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
  depends_on                          = [ data.aws_iam_role.ecs_tess_service_role ]
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
    security_groups = [ data.aws_security_group.tess_ecs_vpc_sg.id ]
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
  task_role_arn             = data.aws_iam_role.ecs_tess_service_role.arn
  execution_role_arn        = data.aws_iam_role.ecs_task_execution_role.arn
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
  depends_on                          = [ data.aws_iam_role.ecs_tess_service_role ]
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
    security_groups = [ data.aws_security_group.tess_ecs_vpc_sg.id ]
  }

  lifecycle {
    ignore_changes = [tags, tags_all]
  }
  
}
