resource "yandex_compute_disk" "extra" {
  count    = 3
  name     = "extra-disk-${count.index + 1}"
  type     = "network-hdd"
  size     = 1             
  zone     = var.default_zone 
  folder_id = var.folder_id
}

resource "yandex_compute_instance" "storage" {
  name        = "storage"
  platform_id = "standard-v3"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id 
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.develop.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.example.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${local.ssh_public_key}"
  }

  scheduling_policy {
    preemptible = true
  }

  dynamic "secondary_disk" {
    for_each = yandex_compute_disk.extra[*].id

    content {
      disk_id     = secondary_disk.value
      auto_delete = true 
    }
  }
}
