resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = "jenkins"
  }
}

resource "kubernetes_namespace" "nginx" {
  metadata {
    name = "nginx"
  }
}

resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"  
  namespace =   "nginx"
  set {
    name  = "controller.service.loadBalancerIP"
    value = var.ingress_ip_address
  }
}

resource "helm_release" "cert_manager" {
  depends_on = [helm_release.nginx]
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.6.0"
  namespace  = "cert-manager"
  set {
    name  = "installCRDs"
    value = "true"
  }
}

# resource "time_sleep" "wait_180_seconds_cert_manager" {
#   depends_on                     = [helm_release.cert_manager]
#   create_duration                = "180s"
# }

resource "kubernetes_manifest" "letsencrypt_clusterissuer" {
  manifest = yamldecode(file("${path.module}/cluster-issuer.yaml"))
  #depends_on = [time_sleep.wait_180_seconds_cert_manager]
}


resource "helm_release" "jenkins" {
  name       = "jenkins"
  chart      = "https://charts.jenkins.io"
  namespace  = "jenkins"
  set {
    name  = "controller.adminPassword"
    value = var.jenkins_admin_password
  }
}