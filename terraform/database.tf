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
  value = aws_db_instance.curiousjcdb.address
}
