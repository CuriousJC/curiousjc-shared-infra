resource "aws_vpc" "curiousjc_net_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "curiousjc_net_vpc"
  }
}

resource "aws_internet_gateway" "curiousjc_net_igw" {
  vpc_id = aws_vpc.curiousjc_net_vpc.id
  tags = {
    Name = "curiousjc_net_igw"
  }
}

resource "aws_route_table" "curiousjc_net_route_table" {
  vpc_id = aws_vpc.curiousjc_net_vpc.id

  route { #so traffic can escape the VPC for public connections
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.curiousjc_net_igw.id
  }
  tags = {
    Name = "curiousjc_net_route_table"
  }
}

resource "aws_subnet" "curiousjc_net_subnet_a" {
  vpc_id            = aws_vpc.curiousjc_net_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "curiousjc_net_subnet_a"
  }
}

resource "aws_route_table_association" "subnet_a_route" {
  subnet_id      = aws_subnet.curiousjc_net_subnet_a.id
  route_table_id = aws_route_table.curiousjc_net_route_table.id
}

resource "aws_subnet" "curiousjc_net_subnet_b" {
  vpc_id            = aws_vpc.curiousjc_net_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "curiousjc_net_subnet_b"
  }
}

resource "aws_route_table_association" "subnet_b_route" {
  subnet_id      = aws_subnet.curiousjc_net_subnet_b.id
  route_table_id = aws_route_table.curiousjc_net_route_table.id
}

resource "aws_db_subnet_group" "curiousjcdb_subnet" {
  name        = "curiousjcdb-subnet-sg"
  description = "subnet group for our database"

  subnet_ids = [
    aws_subnet.curiousjc_net_subnet_a.id,
    aws_subnet.curiousjc_net_subnet_b.id,
  ]
}

resource "aws_security_group" "curiousjcdb_access_sg" {
  name_prefix = "curiousjcdb-access-sg"
  vpc_id      = aws_vpc.curiousjc_net_vpc.id

  ingress {
    from_port = 3306 #Default MariaDB port
    to_port   = 3306 #Default MariaDB port
    protocol  = "tcp"
    #cidr_blocks = ["0.0.0.0/0"] #accepting all traffic from everywhere.  scary.
    cidr_blocks = ["96.33.90.111/32"]
  }

  tags = {
    Name = "curiousjcdb_access_sg"
  }
}


resource "aws_db_instance" "curiousjcdb" {
  allocated_storage      = 5     # 20 GB of storage in the Free Tier
  storage_type           = "gp2" # General Purpose SSD (SSD-backed storage)
  engine                 = "mariadb"
  instance_class         = "db.t2.micro" # Free Tier-eligible instance type
  db_name                = "curiousjcdb"
  identifier             = "curiousjcdb-instance"
  username               = var.rds_admin
  password               = var.rds_admin_password
  skip_final_snapshot    = true # Prevents a final DB snapshot when the instance is deleted
  vpc_security_group_ids = [aws_security_group.curiousjcdb_access_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.curiousjcdb_subnet.name
  multi_az               = false
  publicly_accessible    = true
}

output "curiousjcdb_endpoint" {
  value = aws_db_instance.curiousjcdb.endpoint
}

output "rds_admin" {
  value = var.rds_admin
}

output "rds_admin_password" {
  value     = var.rds_admin_password
  sensitive = true
}










