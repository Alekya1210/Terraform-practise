provider "aws" {
    access_key = var.access_key      
    secret_key = var.secret_key
    region = var.region
}


resource "aws_vpc" "myvpc" {
    tags = {
    Name = var.vpc-name
  }
  cidr_block = var.myvpc-cidr_block

}
resource "aws_internet_gateway" "myigw" {
    vpc_id = aws_vpc.myvpc.id
    
    tags ={
    Name = var.igw-name
    }
}
resource "aws_subnet" "mysub" {
    vpc_id = aws_vpc.myvpc.id
    availability_zone = var.availability_zone
    cidr_block = var.mysub-cidr_block
    map_public_ip_on_launch = true
    tags ={
    Name = var.subnet-name
    }
}
resource "aws_route_table" "myroute_table" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = var.myroute-cidr_block
    gateway_id = aws_internet_gateway.myigw.id
  }
  tags = {
    Name = var.myroute_table-name
  }
}

resource "aws_route_table_association" "subnet_route" {
  subnet_id      = aws_subnet.mysub.id
  route_table_id = aws_route_table.myroute_table.id
}
resource "aws_security_group" "my_sga" {
  vpc_id = aws_vpc.myvpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
  ingress {
    from_port   = 0      
    to_port     = 0      
    protocol    = "-1"   
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  tags = {
    Name = var.my-sg-name 
  }
}
resource "aws_instance" "basicinsta" {
  ami          =  var.ami
  instance_type = var.instancetype 
   subnet_id     = aws_subnet.mysub.id
  vpc_security_group_ids = [ aws_security_group.my_sga.id]     

tags = {
    Name = var.instance-name
  }

user_data = <<-EOF
      #!/bin/sh
      sudo apt-get update
      sudo apt install -y apache2
      sudo systemctl status apache2
      sudo systemctl start apache2
      sudo chown -R $USER:$USER /var/www/html
      sudo echo "<html><body><h1>Hello this is from ale  </h1></body></html>" > /var/www/html/index.html
      EOF
}
