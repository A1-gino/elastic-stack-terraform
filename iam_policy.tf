resource "aws_iam_role" "elasticsearch_iam_role" {
  name = "elasticsearch_iam_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "elasticsearch_iam_policy_document" {
  statement {
    sid = "1"

    actions = [
      "ec2:*"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "elasticsearch_iam_policy" {
  name   = "elasticsearch_iam_policy"
  policy = "${data.aws_iam_policy_document.elasticsearch_iam_policy_document.json}"
}

resource "aws_iam_role_policy_attachment" "elasticsearch_iam_role_policy" {
  role       = "${aws_iam_role.elasticsearch_iam_role.name}"
  policy_arn = "${aws_iam_policy.elasticsearch_iam_policy.arn}"
}

resource "aws_iam_instance_profile" "elastic_ec2_instance_profile" {
  name  = "elastic_ec2_instance_profile"
  role = "${aws_iam_role.elasticsearch_iam_role.name}"
}
