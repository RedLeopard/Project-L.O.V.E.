resource "aws_s3_bucket" "telemetry" {
  bucket = "project-love-telemetry-605383993555"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "telemetry" {
  bucket = aws_s3_bucket.telemetry.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "telemetry" {
  bucket = aws_s3_bucket.telemetry.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_role" "iot_s3" {
  name = "ProjectLOVE-IoT-S3-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "iot.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "s3_write" {
  name = "ProjectLOVE-S3-Write"
  role = aws_iam_role.iot_s3.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.telemetry.arn}/*"
      }
    ]
  })
}

resource "aws_iot_topic_rule" "store_telemetry" {
  name        = "ProjectLOVEStoreTelemetry"
  description = "Store Project LOVE telemetry in S3"
  enabled     = true

  sql         = "SELECT * FROM 'project-love/STL-001/telemetry'"
  sql_version = "2016-03-23"

  s3 {
    role_arn    = aws_iam_role.iot_s3.arn
    bucket_name = aws_s3_bucket.telemetry.bucket
    key         = "telemetry/$${topic(2)}/$${timestamp()}.json"
  }
}

resource "aws_iam_role" "iot_cloudwatch" {
  name = "ProjectLOVE-IoT-CloudWatch-Role"
  path = "/service-role/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "iot.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "iot_cloudwatch_logs" {
  name = "aws-iot-rule-project_love_cloudwatch-action-1-role-ProjectLOVE-IoT-CloudWatch-Role"
  path = "/service-role/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:us-east-1:605383993555:log-group:/project-love/telemetry:*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "iot_cloudwatch" {
  role       = aws_iam_role.iot_cloudwatch.name
  policy_arn = aws_iam_policy.iot_cloudwatch_logs.arn
}

resource "aws_cloudwatch_log_group" "telemetry" {
  name              = "/project-love/telemetry"
  retention_in_days = 7
}

resource "aws_iot_topic_rule" "cloudwatch" {
  name        = "project_love_cloudwatch"
  description = "Routes Project L.O.V.E. telemetry to CloudWatch Logs"
  enabled     = true

  sql         = "SELECT * FROM 'project-love/STL-001/telemetry'"
  sql_version = "2016-03-23"

  cloudwatch_logs {
    log_group_name = aws_cloudwatch_log_group.telemetry.name
    role_arn       = aws_iam_role.iot_cloudwatch.arn
    batch_mode     = false
  }
}

resource "aws_cloudwatch_log_metric_filter" "heartbeat" {
  name           = "ProjectLOVE-Heartbeat-Filter"
  pattern        = "{ $.device_id = \"LOVE-EDGE-01\" }"
  log_group_name = aws_cloudwatch_log_group.telemetry.name

  metric_transformation {
    name      = "TelemetryHeartbeat"
    namespace = "ProjectLOVE"
    value     = "1"
    unit      = "Count"
  }
}

resource "aws_sns_topic" "alerts" {
  name = "ProjectLOVE-Alerts"
}

resource "aws_cloudwatch_metric_alarm" "heartbeat" {
  alarm_name          = "ProjectLOVE-Heartbeat-Alarm"
  alarm_description   = "Alerts when LOVE-EDGE-01 stops sending telemetry to AWS IoT Core and CloudWatch."
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  threshold           = 1

  metric_name = "TelemetryHeartbeat"
  namespace   = "ProjectLOVE"
  period      = 60
  statistic   = "Sum"

  treat_missing_data = "breaching"
  alarm_actions      = [aws_sns_topic.alerts.arn]
  actions_enabled    = true
}
