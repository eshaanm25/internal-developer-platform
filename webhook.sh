gh api /repos/eshaanm25/internal-developer-platform/hooks --input - <<< '{

  "name": "web",
  "active": true,
  "events": [
    "push"
  ],
  "config": {
    "url": "https://k8s-argocd-argocdnl-fb7d1cecc9-9be4a7533103327e.elb.us-east-1.amazonaws.com/api/webhook",
    "content_type": "json",
    "insecure_ssl": "1"
  }
}'