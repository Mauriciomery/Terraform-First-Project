provider "aws" {
    region ="us-east-1"
}
resource "aws_instance" "MM-Terraform-FI" {
  ami           = "ami-005f9685cb30f234b"
  instance_type = "t2.micro"

  tags = {
    Name= "MM-Terraform-FI",
    responsible = "mauricio.merya", 
    project = "ramp-up-devops", 
  }
  volume_tags = {
    Name = "MM-Terraform-FI", 
    responsible = "mauricio.merya",  
    project = "ramp-up-devops",
  }
}
#Creating the main VPC for the terraform project
resource "aws_vpc" "MM-VPC" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "MM-VPC"
    responsible= "mauricio.merya"
    project = "ramp-up-devops"
  }
}

# Create the public subnets in each availability zone
resource "aws_subnet" "public-subnet-1a" {

  cidr_block = "10.0.101.0/24"
  vpc_id     = aws_vpc.MM-VPC.id
  availability_zone = "us-east-1a"

  tags = {
    Name = "public-subnet-1a"
    responsible = "mauricio.merya"
    project = "ramp-up-devops"
  }
}
resource "aws_subnet" "public-subnet-1b" {

  cidr_block = "10.0.102.0/24"
  vpc_id     = aws_vpc.MM-VPC.id
  availability_zone = "us-east-1b"

  tags = {
    Name = "public-subnet-1b"
    responsible = "mauricio.merya"
    project = "ramp-up-devops"
  }
}

# Create the private subnets in each availability zone
resource "aws_subnet" "private-subnet-1a" {

  cidr_block = "10.0.1.0/24"
  vpc_id     = aws_vpc.MM-VPC.id
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-subnet-1a"
    responsible = "mauricio.merya"
    project = "ramp-up-devops"
  }
}
resource "aws_subnet" "private-subnet-1b" {

  cidr_block = "10.0.2.0/24"
  vpc_id     = aws_vpc.MM-VPC.id
  availability_zone = "us-east-1b"

  tags = {
    Name = "private-subnet-1b"
    responsible = "mauricio.merya"
    project = "ramp-up-devops"
  }
}

# Create the Internet Gateway
resource "aws_internet_gateway" "MM-igw" {
  vpc_id = aws_vpc.MM-VPC.id

  tags = {
    Name = "MM-igw"
    responsible = "mauricio.merya"
    project = "ramp-up-devops"
  }
}

# Create the NAT Gateway in the first public subnet
resource "aws_nat_gateway" "MM-nat-gateway" {
  allocation_id = aws_eip.MM-eip.id
  subnet_id     = aws_subnet.public-subnet-1a.id

  tags = {
    Name = "MM-nat-gateway"
    responsible = "mauricio.merya"
    project = "ramp-up-devops"
  }
}

# Allocate an Elastic IP address for the NAT Gateway
resource "aws_eip" "MM-eip" {
  vpc = true

  tags = {
    Name = "MM-eip"
    responsible = "mauricio.merya"
    project = "ramp-up-devops"
  }
}

# Create a route table for the public subnets
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.MM-VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.MM-igw.id
  }

  tags = {
    Name = "public-rt"
    responsible = "mauricio.merya"
    project = "ramp-up-devops"
  }
}

# Associate the public route table with the public subnets
resource "aws_route_table_association" "public-1a" {

  subnet_id      = aws_subnet.public-subnet-1a.id
  route_table_id = aws_route_table.public-rt.id
}
resource "aws_route_table_association" "public-1b" {

  subnet_id      = aws_subnet.public-subnet-1b.id
  route_table_id = aws_route_table.public-rt.id
}

# Create a route table for the private subnets
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.MM-VPC.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.MM-nat-gateway.id
  }

  tags = {
    Name = "private-rt"
    responsible = "mauricio.merya"
    project = "ramp-up-devops"
  }
}

# Associate the private route table with the private subnets
resource "aws_route_table_association" "private-1a" {

  subnet_id      = aws_subnet.private-subnet-1a.id
  route_table_id = aws_route_table.private-rt.id
}
resource "aws_route_table_association" "private-1b" {

  subnet_id      = aws_subnet.private-subnet-1b.id
  route_table_id = aws_route_table.private-rt.id
}
# Se termina la creacion de la VPC

# Se comienza a crear los Launch Template
# Launch Template for frontend instances
data "template_file" "front_data" {
  template = "${file("/front.sh")}"
}

resource "aws_launch_template" "MM-Front-LT" {
  name             = "MM-Front-LT"
  image_id         = "ami-005f9685cb30f234b"
  instance_type    = "t2.micro"
  key_name = "rampup-mery2"
  user_data        = "${base64encode(data.template_file.front_data.rendered)}"
  //vpc_security_group_ids = ["${aws_security_group.MM-Front-SG.id}"]

   network_interfaces {
    associate_public_ip_address = true
    device_index = 0
    security_groups = ["${aws_security_group.MM-Front-SG.id}"]
    //subnet_id = aws_subnet.public-subnet-1a.id
  }
  /* network_interfaces {
    associate_public_ip_address = true
    device_index = 1
    security_groups = ["${aws_security_group.MM-Front-SG.id}"]
    subnet_id = aws_subnet.public-subnet-1b.id
  }*/


  tag_specifications {
    resource_type = "instance"
    tags = {
    Name= "MM-Front-LT",
    responsible = "mauricio.merya", 
    project = "ramp-up-devops", 
  }
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
    Name= "MM-Front-LT",
    responsible = "mauricio.merya", 
    project = "ramp-up-devops", 
    }
  }
}

# Creating a SG for the Front LT

resource "aws_security_group" "MM-Front-SG" {
  name= "MM-Front-SG"
  vpc_id = aws_vpc.MM-VPC.id
  description = "Security group for Front LT"
  ingress {
    from_port   = 9050
    to_port     = 9050
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["190.158.28.26/32", "190.158.28.63/32"]
  }
  
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    name = "MM-Front-SG"
    responsible = "mauricio.merya"
    project = "ramp-up-devops"
  }
}


#Creating the first ASG with front LT
resource "aws_autoscaling_group" "MM-Front-ASG" {
  name                 = "MM-Front-ASG"
  vpc_zone_identifier = [aws_subnet.public-subnet-1a.id, aws_subnet.public-subnet-1b.id]
  launch_template {
    id      = "${aws_launch_template.MM-Front-LT.id}"
    version = "${aws_launch_template.MM-Front-LT.latest_version}"
  }

  target_group_arns = ["${aws_lb_target_group.MM-External-LB-TG.arn}"]

  min_size = 2
  max_size = 3
  
}


#Create the first ALB
#The external load balancer
resource "aws_lb" "MM-External-LB" {
  name               = "MM-External-LB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.MM-External-LB-SG.id}"]

  subnets            = [aws_subnet.public-subnet-1a.id, aws_subnet.public-subnet-1b.id]

  tags = {
    Name = "MM-External-LB"
    responsible = "mauricio.merya"
    project = "ramp-up-devops"
  }
}

# Definig the listener for the External Load Balancer
resource "aws_lb_listener" "MM-External-LB-Listener" {
  load_balancer_arn = "${aws_lb.MM-External-LB.arn}"
  port              = 9050
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.MM-External-LB-TG.arn}"
    type             = "forward"
  }
}
#Definig the target group for the external load balancer
resource "aws_lb_target_group" "MM-External-LB-TG" {
  name               = "MM-External-LB-TG"
  port               = 9050
  protocol           = "HTTP"
  vpc_id             = aws_vpc.MM-VPC.id

  health_check {
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
}
#Defining the TG attachment to a ASG
resource "aws_autoscaling_attachment" "MM-External-LB-TGA" {
  autoscaling_group_name = aws_autoscaling_group.MM-Front-ASG.name
  lb_target_group_arn   = aws_lb_target_group.MM-External-LB-TG.arn
}


#Creating the ALB security group
resource "aws_security_group" "MM-External-LB-SG" {
  name = "MM-External-LB-SG"
  description = "Security group for the external Application Load Balancer"
  vpc_id = aws_vpc.MM-VPC.id

  ingress {
    from_port = 9050
    to_port   = 9050
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MM-External-LB-SG"
    responsible = "mauricio.merya"
    project = "ramp-up-devops"
  }
}
#-------------------
#Creating Launch Templates for the Back Instances
#Starting for Users Api'

# Launch Template for Users instances
data "template_file" "users_data" {
  template = "${file("/users.sh")}"
}

resource "aws_launch_template" "MM-Users-api-LT" {
  name             = "MM-Users-api-LT"
  image_id         = "ami-005f9685cb30f234b"
  instance_type    = "t2.micro"
  key_name = "rampup-mery2"
  user_data        = "${base64encode(data.template_file.users_data.rendered)}"
  vpc_security_group_ids = ["${aws_security_group.MM-Users-api-SG.id}"]

  tag_specifications {
    resource_type = "instance"
    tags = {
    Name= "MM-Users-api-LT",
    responsible = "mauricio.merya", 
    project = "ramp-up-devops", 
  }
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
    Name= "MM-Users-api-LT",
    responsible = "mauricio.merya", 
    project = "ramp-up-devops", 
    }
  }
  
}

# Creating a SG for the Users LT

resource "aws_security_group" "MM-Users-api-SG" {
  name = "MM-Users-api-SG"
  vpc_id = aws_vpc.MM-VPC.id
  description = "Security group for Front LT"
  ingress {
    from_port   = 8083
    to_port     = 8083
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = aws_lb.MM-Internal-LB.security_groups
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["190.158.28.26/32", "190.158.28.63/32"]
  }
  
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    name = "MM-Users-api-SG"
    responsible = "mauricio.merya"
    project = "ramp-up-devops"
  }
}


#Creating the first ASG with Users LT
resource "aws_autoscaling_group" "MM-Users-api-ASG" {
  name                 = "MM-Users-api-ASG"
  vpc_zone_identifier = [aws_subnet.public-subnet-1a.id, aws_subnet.public-subnet-1b.id]
  launch_template {
    id      = "${aws_launch_template.MM-Users-api-LT.id}"
    version = "${aws_launch_template.MM-Users-api-LT.latest_version}"
  }

  target_group_arns = ["${aws_lb_target_group.MM-Internal-LB-TG1.arn}"]

  min_size = 2
  max_size = 3

}
#Finshing launch template and ASG Associated

#Starting for Auth Api'

# Launch Template for Auth instances
data "template_file" "auth_data" {
  template = "${file("/auth.sh")}"
}

resource "aws_launch_template" "MM-Auth-api-LT" {
  name             = "MM-Auth-api-LT"
  image_id         = "ami-005f9685cb30f234b"
  instance_type    = "t2.micro"
  key_name = "rampup-mery2"
  user_data        = "${base64encode(data.template_file.auth_data.rendered)}"
  vpc_security_group_ids = ["${aws_security_group.MM-Auth-api-SG.id}"]

  tag_specifications {
    resource_type = "instance"
    tags = {
    Name= "MM-Auth-api-LT",
    responsible = "mauricio.merya", 
    project = "ramp-up-devops", 
  }
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
    Name= "MM-Auth-api-LT",
    responsible = "mauricio.merya", 
    project = "ramp-up-devops", 
    }
  }
  
}

# Creating a SG for the Auth LT

resource "aws_security_group" "MM-Auth-api-SG" {
  name_prefix = "MM-Auth-api-SG"
  vpc_id = aws_vpc.MM-VPC.id
  description = "Security group for Auth LT"
  ingress {
    from_port   = 8020
    to_port     = 8020
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = aws_lb.MM-Internal-LB.security_groups
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["190.158.28.26/32", "190.158.28.63/32"]
  }
  
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    name = "MM-Auth-api-SG"
    responsible = "mauricio.merya"
    project = "ramp-up-devops"
  }
}


#Creating the first ASG with Auth LT
resource "aws_autoscaling_group" "MM-Auth-api-ASG" {
  name                 = "MM-Auth-api-ASG"
  vpc_zone_identifier = [aws_subnet.public-subnet-1a.id, aws_subnet.public-subnet-1b.id]
  launch_template {
    id      = "${aws_launch_template.MM-Auth-api-LT.id}"
    version = "${aws_launch_template.MM-Auth-api-LT.latest_version}"
  }

  target_group_arns = ["${aws_lb_target_group.MM-Internal-LB-TG2.arn}"]

  min_size = 2
  max_size = 3

}

#Starting for TODOs Api'

# Launch Template for TODOs instances
data "template_file" "todos_data" {
  template = "${file("/todos.sh")}"
}

resource "aws_launch_template" "MM-TODOs-api-LT" {
  name             = "MM-TODOs-api-LT"
  image_id         = "ami-005f9685cb30f234b"
  instance_type    = "t2.micro"
  key_name = "rampup-mery2"
  user_data        = "${base64encode(data.template_file.todos_data.rendered)}"
  vpc_security_group_ids = ["${aws_security_group.MM-TODOs-api-SG.id}"]

  tag_specifications {
    resource_type = "instance"
    tags = {
    Name= "MM-TODOs-api-LT",
    responsible = "mauricio.merya", 
    project = "ramp-up-devops", 
  }
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
    Name= "MM-TODOs-api-LT",
    responsible = "mauricio.merya", 
    project = "ramp-up-devops", 
    }
  }
  
}

# Creating a SG for the TODOs LT

resource "aws_security_group" "MM-TODOs-api-SG" {
  name_prefix = "MM-TODOs-api-SG"
  vpc_id = aws_vpc.MM-VPC.id
  description = "Security group for TODOs LT"
  ingress {
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = aws_lb.MM-Internal-LB.security_groups
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["190.158.28.26/32", "190.158.28.63/32"]
  }
  
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    name = "MM-TODOs-api-SG"
    responsible = "mauricio.merya"
    project = "ramp-up-devops"
  }
}


#Creating the first ASG with TODOs LT
resource "aws_autoscaling_group" "MM-TODOs-api-ASG" {
  name                 = "MM-TODOs-api-ASG"
  vpc_zone_identifier = [aws_subnet.public-subnet-1a.id, aws_subnet.public-subnet-1b.id]
  launch_template {
    id      = "${aws_launch_template.MM-TODOs-api-LT.id}"
    version = "${aws_launch_template.MM-TODOs-api-LT.latest_version}"
  }

  target_group_arns = ["${aws_lb_target_group.MM-Internal-LB-TG3.arn}"]

  min_size = 1
  max_size = 2

}

#Starting for LogMP'

# Launch Template for LOGMP instances
data "template_file" "logmp_data" {
  template = "${file("/logmp.sh")}"
}

resource "aws_launch_template" "MM-LogMP-LT" {
  name             = "MM-LogMP-LT"
  image_id         = "ami-005f9685cb30f234b"
  instance_type    = "t2.micro"
  key_name = "rampup-mery2"
  user_data        = "${base64encode(data.template_file.logmp_data.rendered)}"
  vpc_security_group_ids = ["${aws_security_group.MM-LogMP-SG.id}"]

  tag_specifications {
    resource_type = "instance"
    tags = {
    Name= "MM-LogMP-LT",
    responsible = "mauricio.merya", 
    project = "ramp-up-devops", 
  }
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
    Name= "MM-LogMP-LT",
    responsible = "mauricio.merya", 
    project = "ramp-up-devops", 
    }
  }
  
}

# Creating a SG for the LogMP LT

resource "aws_security_group" "MM-LogMP-SG" {
  name = "MM-LogMP-SG"
  vpc_id = aws_vpc.MM-VPC.id
  description = "Security group for LogMP LT"
  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["190.158.28.26/32", "190.158.28.63/32"]
  }
  
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    name = "MM-LogMP-SG"
    responsible = "mauricio.merya"
    project = "ramp-up-devops"
  }
}


#Creating the first ASG with LogMP LT
resource "aws_autoscaling_group" "MM-LogMP-ASG" {
  name                 = "MM-LogMP-ASG"
  vpc_zone_identifier = [aws_subnet.public-subnet-1a.id, aws_subnet.public-subnet-1b.id]
  launch_template {
    id      = "${aws_launch_template.MM-LogMP-LT.id}"
    version = "${aws_launch_template.MM-LogMP-LT.latest_version}"
  }

  target_group_arns = ["${aws_lb_target_group.MM-Internal-LB-TG4.arn}"]

  min_size = 2
  max_size = 3
  
}



#-------------------------
#-------- Internal LB-------------


#Security group for the internal LB
resource "aws_security_group" "MM-Internal-LB-SG" {
  name = "MM-Internal-LB-SG"
  vpc_id = aws_vpc.MM-VPC.id

  ingress {
    from_port = 8019
    to_port = 8090
    protocol = "tcp"
    cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24", "10.0.101.0/24", "10.0.101.0/24"]
  }

  tags = {
    Name = "MM-Internal-LB-SG"
    responsible = "mauricio.merya"
    project = "ramp-up-devops"
  }
}
# Creamos el LB interno

resource "aws_lb" "MM-Internal-LB" {
  name = "MM-Internal-LB"
  internal = true
  load_balancer_type = "application"
  subnets = [aws_subnet.public-subnet-1a.id, aws_subnet.public-subnet-1b.id]
  security_groups = [aws_security_group.MM-Internal-LB-SG.id]

  tags = {
    Name = "MM-Internal-LB"
  }
}

#----------------------------------------

#creamos el TG del LB interno para Users Api

resource "aws_lb_target_group" "MM-Internal-LB-TG1" {
  name = "MM-Internal-LB-TG1"
  port = 8083
  protocol = "HTTP"
  vpc_id = aws_vpc.MM-VPC.id
  target_type = "instance"

  health_check {
    path = "/"
    port = "traffic-port"
    protocol = "HTTP"
  }

  tags = {
    Name = "MM-Internal-LB-TG1"
    responsible = "mauricio.merya"
    project = "ramp-up-devops"
  }
}

#Creamos el listener del  LB interno para Users Api
resource "aws_lb_listener" "MM-Internal-LB-Listener-Users" {
  load_balancer_arn = aws_lb.MM-Internal-LB.arn
  port = 8083
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.MM-Internal-LB-TG1.arn
  }
}
#Defining the TG attachment to a ASG USERS api
resource "aws_autoscaling_attachment" "MM-Internal-LB-TGA1" {
  autoscaling_group_name = aws_autoscaling_group.MM-Users-api-ASG.name
  lb_target_group_arn   = aws_lb_target_group.MM-Internal-LB-TG1.arn
}


#Create TG2 for Auth Api
#creamos el TG del LB interno para Users Api

resource "aws_lb_target_group" "MM-Internal-LB-TG2" {
  name = "MM-Internal-LB-TG2"
  port = 8020
  protocol = "HTTP"
  vpc_id = aws_vpc.MM-VPC.id
  target_type = "instance"

  health_check {
    path = "/"
    port = "traffic-port"
    protocol = "HTTP"
  }

  tags = {
    Name = "MM-Internal-LB-TG2"
    responsible = "mauricio.merya"
    project = "ramp-up-devops"
  }
}

#Creamos el listener del  LB interno para Users Api
resource "aws_lb_listener" "MM-Internal-LB-Listener-Auth" {
  load_balancer_arn = aws_lb.MM-Internal-LB.arn
  port = 8020
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.MM-Internal-LB-TG2.arn
  }
}

#Defining the TG attachment to a ASG AUTH API
resource "aws_autoscaling_attachment" "MM-Internal-LB-TGA2" {
  autoscaling_group_name = aws_autoscaling_group.MM-Auth-api-ASG.name
  lb_target_group_arn   = aws_lb_target_group.MM-Internal-LB-TG2.arn
}

#Create TG3 for TODOs Api
resource "aws_lb_target_group" "MM-Internal-LB-TG3" {
  name = "MM-Internal-LB-TG3"
  port = 8082
  protocol = "HTTP"
  vpc_id = aws_vpc.MM-VPC.id
  target_type = "instance"

  health_check {
    path = "/"
    port = "traffic-port"
    protocol = "HTTP"
  }

  tags = {
    Name = "MM-Internal-LB-TG3"
    responsible = "mauricio.merya"
    project = "ramp-up-devops"
  }
}

#Creamos el listener del  LB interno para TODOs Api
resource "aws_lb_listener" "MM-Internal-LB-Listener-TODOs" {
  load_balancer_arn = aws_lb.MM-Internal-LB.arn
  port = 8082
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.MM-Internal-LB-TG3.arn
  }
}

#Defining the TG attachment to a ASG  TODOs API
resource "aws_autoscaling_attachment" "MM-Internal-LB-TGA3" {
  autoscaling_group_name = aws_autoscaling_group.MM-TODOs-api-ASG.name
  lb_target_group_arn   = aws_lb_target_group.MM-Internal-LB-TG3.arn
}

#Create TG4 for LogMP Api
resource "aws_lb_target_group" "MM-Internal-LB-TG4" {
  name = "MM-Internal-LB-TG4"
  port = 6379
  protocol = "HTTP"
  vpc_id = aws_vpc.MM-VPC.id
  target_type = "instance"

  health_check {
    path = "/"
    port = "traffic-port"
    protocol = "HTTP"
  }

  tags = {
    Name = "MM-Internal-LB-TG4"
    responsible = "mauricio.merya"
    project = "ramp-up-devops"
  }
}

#Creamos el listener del  LB interno para Users Api
resource "aws_lb_listener" "MM-Internal-LB-Listener-LogMP" {
  load_balancer_arn = aws_lb.MM-Internal-LB.arn
  port = 8070
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.MM-Internal-LB-TG4.arn
  }
}



#Defining the TG attachment to a ASG LogMP
resource "aws_autoscaling_attachment" "MM-Internal-LB-TGA4" {
  autoscaling_group_name = aws_autoscaling_group.MM-LogMP-ASG.name
  lb_target_group_arn   = aws_lb_target_group.MM-Internal-LB-TG4.arn
}


