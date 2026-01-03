resource "aws_db_subnet_group" "this" {
  name       = "rds-subnet-${var.environment}"
  subnet_ids = var.subnet_ids
}

resource "aws_security_group" "this" {
  name   = "rds-sg-${var.environment}"
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.allowed_sg_ids
    content {
      from_port       = 5432
      to_port         = 5432
      protocol        = "tcp"
      security_groups = [ingress.value]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "rds-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_db_instance" "this" {
  identifier        = "infra-postgres-${var.environment}"
  engine            = "postgres"
  engine_version    = "17"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = var.db_name
  username = var.username
  password = var.password

  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.this.id]
  db_subnet_group_name   = aws_db_subnet_group.this.name

  skip_final_snapshot = true
}
