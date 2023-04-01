source "virtualbox-iso" "centos-7-vagrant-box" {
  guest_os_type = "RedHat_64"
  iso_url       = "isos/CentOS-7-x86_64-Minimal-2207-02.iso"
  iso_checksum  = "md5:3e39d08511a014c16730650051a0dcca"
  boot_command = [
    "<up><wait><tab> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter><wait>"
  ]
  disk_size        = 10240
  headless         = false
  ssh_username     = "vagrant"
  ssh_password     = "vagrant"
  ssh_port         = 22
  ssh_wait_timeout = "30m"
  shutdown_command = "echo 'packer'|sudo -S /sbin/halt -h -p"
  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--memory", "1024"],
    ["modifyvm", "{{.Name}}", "--cpus", "4"],
  ]
  http_directory   = "http"
  output_directory = "builds/${source.name}"
  format           = "ova"
}

variable "foo" {
  type        = string
  default     = "the default value of the `foo` variable"
  description = "description of the `foo` variable"
  sensitive   = false
  # When a variable is sensitive all string-values from that variable will be
  # obfuscated from Packer's output.
}

build {
  sources = ["sources.virtualbox-iso.centos-7-vagrant-box"]
  provisioner "shell" {
    inline = [
      "echo provisioning all the things",
      "echo the value of 'foo' is '${var.foo}'",
    ]
  }
  provisioner "shell" {
    scripts = ["scripts/setup.sh"]
  }
  post-processors {
    post-processor "vagrant" {
      keep_input_artifact = true
      provider_override   = "virtualbox"
      output              = "builds_box/packer_${source.name}_virtualbox.box"
    }
  }
}
