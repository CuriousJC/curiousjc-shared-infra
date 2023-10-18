
resource "aws_db_instance" "curiousjcdb" {
  allocated_storage    = 5     # 20 GB of storage in the Free Tier
  storage_type         = "gp2" # General Purpose SSD (SSD-backed storage)
  engine               = "postgres"
  engine_version       = "15.4"
  instance_class       = "db.t2.micro" # Free Tier-eligible instance type
  db_name              = "curiousjcdb"
  username             = "xoladmin"    #var.rds_admin
  password             = "CzHq1sgh_Gx" #var.rds_admin_password
  parameter_group_name = "default.postgres12"

  skip_final_snapshot = true # Prevents a final DB snapshot when the instance is deleted

  # Security Group Settings
  vpc_security_group_ids = [aws_security_group.curiousjcdb_access_sg.id]

  # Subnet Group Settings
  db_subnet_group_name = aws_db_subnet_group.curiousjcdb_subnet.id

  # Multi-AZ Deployment
  multi_az = false

  # Publicly Accessible (for demo purposes, you can set this to false for production)
  publicly_accessible = false
}

resource "aws_security_group" "curiousjcdb_access_sg" {
  name_prefix = "curiousjcdb-access-sg"

  ingress {
    from_port   = 5432 # PostgreSQL default port
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_service_linked_role" "rds" {
  aws_service_name = "rds.amazonaws.com"
}

resource "time_sleep" "wait_10_seconds" {
  depends_on      = [aws_iam_service_linked_role.rds]
  create_duration = "10s"
}

resource "aws_db_subnet_group" "curiousjcdb_subnet" {
  name        = "curiousjcdb-subnet-sg"
  description = "subnet group for our database"

  subnet_ids = [
    aws_subnet.curiousjc_net_subnet_a.id,
    aws_subnet.curiousjc_net_subnet_b.id,
  ]

  depends_on = [
    aws_iam_service_linked_role.rds,
    time_sleep.wait_10_seconds
  ]
}

resource "aws_subnet" "curiousjc_net_subnet_a" {
  vpc_id            = aws_vpc.curiousjc_net_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a" # Replace with the desired AZs
}

resource "aws_subnet" "curiousjc_net_subnet_b" {
  vpc_id            = aws_vpc.curiousjc_net_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1b" # Replace with the desired AZs
}

resource "aws_vpc" "curiousjc_net_vpc" {
  cidr_block = "10.0.0.0/16" # Replace with your desired VPC CIDR block
}
