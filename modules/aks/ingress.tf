resource "kubernetes_ingress_v1" "app_ingress" {
  metadata {
    name      = "app-ingress"
    namespace = "default"
    annotations = {
      "kubernetes.io/ingress.class"      = "azure/application-gateway"
      "appgw.ingress.kubernetes.io/backend-path-prefix" = "/"
    }
  }

  spec {
    rule {
      host = "myapp.example.com"
      http {
        path {
          backend {
            service {
              name = "myapp-service"
              port {
                number = 80
              }
            }
          }
          path = "/"
        }
      }
    }
  }
}
