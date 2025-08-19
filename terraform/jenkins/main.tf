module "jenkins" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name                   = "jenkins"
  instance_type          = "t3.medium"
  vpc_security_group_ids = ["sg-0fb4314a3e3c19b76"]
  subnet_id              = "subnet-026fa8e1dc737230f"
  ami                    = data.aws_ami.ami_info.id
  user_data              = file("jenkins.sh")

  tags = {
    Name = "jenkins"
  }
}

resource "aws_key_pair" "tools" {
  key_name   = "tools"
  # you can paste the public key directly like this
  #public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL6ONJth+DzeXbU3oGATxjVmoRjPepdl7sBuPzzQT2Nc sivak@BOOK-I6CR3LQ85Q"
  public_key = file("c:/repos/key-pair.pub")
  # ~ means windows home directory
}


module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = var.zone_name

  records = [
    {
      name    = "jenkins"
      type    = "A"
      ttl     = 1
      records = [
        module.jenkins.public_ip
      ]
      allow_overwrite = true
    }
  ]
}