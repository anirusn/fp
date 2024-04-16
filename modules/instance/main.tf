# resource "aws_iam_role" "web_iam_role" {
#     name = "web_iam_role"
#     assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": "ec2.amazonaws.com"
#       },
#       "Effect": "Allow",
#       "Sid": ""
#     }
#   ]
# }
# EOF
# }

# resource "aws_iam_instance_profile" "web_instance_profile" {
#     name = "web_instance_profile"
#     role = "web_iam_role"
# }

# resource "aws_iam_role_policy" "web_iam_role_policy" {
#   name = "web_iam_role_policy"
#   role = "${aws_iam_role.web_iam_role.id}"
#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": ["s3:ListBucket"],
#       "Resource": ["arn:aws:s3:::fpbucket730"]
#     },
#     {
#       "Effect": "Allow",
#       "Action": [
#         "s3:PutObject",
#         "s3:GetObject",
#         "s3:DeleteObject"
#       ],
#       "Resource": ["arn:aws:s3:::fpbucket730/*"]
#     }
#   ]
# }
# EOF
# }
resource "aws_instance" "instances" {
  count = length(var.instances)

  ami           = var.instances[count.index].ami_id
  instance_type = var.instances[count.index].instance_type
  subnet_id     = var.instances[count.index].subnet_id
  user_data     = var.instances[count.index].user_data
  security_groups = [var.instances[count.index].security_group_id]
  associate_public_ip_address = var.instances[count.index].assign_public_ip != false  
  key_name = var.instances[count.index].key_name
  # iam_instance_profile = "${aws_iam_instance_profile.web_instance_profile.id}"

  tags = {
    Name = var.instances[count.index].name
  }
  
}