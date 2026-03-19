variable "web_provision" {
  type    = bool
  default = true
}

locals {
  webservers = [
    for i in range(length(yandex_compute_instance.web)) : {
      name          = yandex_compute_instance.web[i].name
      ansible_host  = yandex_compute_instance.web[i].network_interface[0].nat_ip_address
      fqdn          = yandex_compute_instance.web[i].fqdn
    }
  ]

  databases = [
    for key, vm in yandex_compute_instance.db : {
      name          = vm.name
      ansible_host  = vm.network_interface[0].nat_ip_address
      fqdn          = vm.fqdn
    }
  ]

  storage = [
    {
      name          = yandex_compute_instance.storage.name
      ansible_host  = yandex_compute_instance.storage.network_interface[0].nat_ip_address
      fqdn          = yandex_compute_instance.storage.fqdn
    }
  ]
}

resource "local_file" "ansible_inventory" {
  count    = var.web_provision ? 1 : 0
  filename = "${path.module}/inventory.ini"

  content = templatefile("${path.module}/hosts.tftpl", {
    webservers = local.webservers
    databases  = local.databases
    storage    = local.storage
  })
}
