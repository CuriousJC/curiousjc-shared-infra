
resource "aws_db_instance" "curiousjcdb" {
  allocated_storage      = 5     # 20 GB of storage in the Free Tier
  storage_type           = "gp2" # General Purpose SSD (SSD-backed storage)
  engine                 = "mariadb"
  instance_class         = "db.t2.micro" # Free Tier-eligible instance type
  db_name                = "curiousjcdb"
  identifier             = "curiousjcdb-instance"
  username               = "xoladmin"    #todo: var.rds_admin
  password               = "CzHq1sgh_Gx" #todo: var.rds_admin_password
  skip_final_snapshot    = true          # Prevents a final DB snapshot when the instance is deleted
  vpc_security_group_ids = [aws_security_group.curiousjcdb_access_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.curiousjcdb_subnet.name
  multi_az               = false
  publicly_accessible    = false #no need
}

resource "aws_security_group" "curiousjcdb_access_sg" {
  name_prefix = "curiousjcdb-access-sg"
  vpc_id      = aws_vpc.curiousjc_net_vpc.id

  ingress {
    from_port   = 3306 #Default MariaDB port
    to_port     = 3306 #Default MariaDB port
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
