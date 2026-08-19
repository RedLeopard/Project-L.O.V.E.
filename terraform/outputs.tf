output "telemetry_bucket_name" {
  description = "S3 bucket storing Project L.O.V.E. telemetry"
  value       = aws_s3_bucket.telemetry.bucket
}

output "cloudwatch_log_group" {
  description = "CloudWatch log group receiving edge telemetry"
  value       = aws_cloudwatch_log_group.telemetry.name
}

output "heartbeat_alarm_name" {
  description = "CloudWatch heartbeat alarm"
  value       = aws_cloudwatch_metric_alarm.heartbeat.alarm_name
}

output "sns_alert_topic_arn" {
  description = "SNS topic used for Project L.O.V.E. alerts"
  value       = aws_sns_topic.alerts.arn
}

output "s3_iot_rule_name" {
  description = "IoT rule routing telemetry to S3"
  value       = aws_iot_topic_rule.store_telemetry.name
}

output "cloudwatch_iot_rule_name" {
  description = "IoT rule routing telemetry to CloudWatch Logs"
  value       = aws_iot_topic_rule.cloudwatch.name
}
