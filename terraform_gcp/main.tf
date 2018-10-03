provider "google" {
  credentials = "${file("account.json")}"
  project     = "${var.project_name}"
  region      = "us-central1"
}

resource "google_compute_instance" "tfansible" {
  name         = "terraform-ansible"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"

  tags = ["web"]

  boot_disk {
    initialize_params {
      image = "rhel-cloud/rhel-7"
    }
  }

  // Local SSD disk
  scratch_disk {}

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  metadata {
    Name     = "Terraform and Ansible Demo"
    ssh-keys = "${var.ssh_user}:${file("${var.public_key_path}")}"
  }

  metadata_startup_script = "echo hi > /test.txt"

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }

  #############################################################################
  # This is the 'local exec' method.  
  # Ansible runs from the same host you run Terraform from
  #############################################################################

  provisioner "remote-exec" {
    inline = ["echo 'Hello World'"]

    connection {
      type        = "ssh"
      user        = "${var.ssh_user}"
      private_key = "${file("${var.private_key_path}")}"
    }
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i '${google_compute_instance.tfansible.network_interface.0.access_config.0.assigned_nat_ip},' --private-key ${var.private_key_path} ../ansible/httpd.yml"
  }

  #############################################################################
  # This is the 'remote exec' method.  
  # Ansible runs on the target host.
  #############################################################################

  # provisioner "remote-exec" {
  #   inline = [
  #     "mkdir /home/${var.ssh_user}/files",
  #     "mkdir /home/${var.ssh_user}/ansible",
  #   ]

  #   connection {
  #     type        = "ssh"
  #     user        = "${var.ssh_user}"
  #     private_key = "${file("${var.private_key_path}")}"
  #   }
  # }
  # provisioner "file" {
  #   source      = "../ansible/httpd.yml"
  #   destination = "/home/${var.ssh_user}/ansible/httpd.yml"

  #   connection {
  #     type        = "ssh"
  #     user        = "${var.ssh_user}"
  #     private_key = "${file("${var.private_key_path}")}"
  #   }
  # }
  # provisioner "file" {
  #   source      = "../files/index.j2"
  #   destination = "/home/${var.ssh_user}/files/index.j2"

  #   connection {
  #     type        = "ssh"
  #     user        = "${var.ssh_user}"
  #     private_key = "${file("${var.private_key_path}")}"
  #   }
  # }
  # provisioner "remote-exec" {
  #   inline = [
  #     "sudo yum -y install ansible",
  #     "cd ansible; ansible-playbook -c local -i \"localhost,\" httpd.yml",
  #   ]

  #   connection {
  #     type        = "ssh"
  #     user        = "${var.ssh_user}"
  #     private_key = "${file("${var.private_key_path}")}"
  #   }
  # }
  # Don't comment out this next line.
}

resource "google_compute_firewall" "default" {
  name    = "web-firewall"
  network = "default"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web"]
}
