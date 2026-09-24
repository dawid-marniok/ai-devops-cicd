# Polityka dla aplikacji quotes-api — dostęp do licznikow wyswietlen.

resource "aws_iam_role_policy" "ranking" {
  name = "${local.prefix}-ranking"
  role = aws_iam_role.aplikacja.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "OdczytIZapisLicznikow"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query"
        ]
        Resource = aws_dynamodb_table.stats.arn
      },
      {
        Sid    = "OpisTabel"
        Effect = "Allow"
        Action = [
          "dynamodb:DescribeTable",
          "dynamodb:ListTables",
          "dynamodb:Scan"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_dynamodb_table" "stats" {
  name         = "${local.prefix}-quotes-stats"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "quote_id"

  attribute {
    name = "quote_id"
    type = "S"
  }

  tags = {
    Projekt   = "ai-devops-cicd"
    Uczestnik = var.uczestnik
    Blok      = "lab05"
    Usuwac    = "tak"
  }
}
