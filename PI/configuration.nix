{ config, pkgs, ... }:

{
  # Filesystem Definitions
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
    "/mnt/Seagate3TB" = {
      device = "/dev/disk/by-uuid/172ff5cd-d4cd-48fb-ac31-3a6d0e9902e6";
      fsType = "ext4";
      options = [ "auto,nofail,noatime,errors=remount-ro,x-systemd.mount-timeout=5" ];
    };
    "/var/www" = {
      device = "overlay";
      fsType = "overlay";
      options = [ "defaults,x-systemd.requires=/mnt/Seagate3TB,lowerdir=/mnt/Seagate3TB/www,upperdir=/home/collin/Docker/php/contents,workdir=/home/collin/Docker/php/workdir" ];
    };
  };

  # Swapfile
  swapDevices = [ { device = "/swapfile"; size = 4096; } ];

  # Raspberry Pi Options
  boot.loader.raspberryPi = {
    enable = true;
    version = 4;
  };
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.kernelParams = [ "console=tty1" "panic=1" "boot.panic_on_fail" "cma=64M" "8250.nr_uarts=1" ]; #Last two needed for 8GB RPI
  boot.kernelPackages = pkgs.linuxPackages_rpi4;
  boot.initrd.availableKernelModules = [ "xhci_pci" "uas" ];
  powerManagement.cpuFreqGovernor = "performance";

  services.fstrim.enable = true;

  # Headless Config
  systemd.enableEmergencyMode = false;
  #boot.kernelParams = [ "console=tty1" "panic=1" "boot.panic_on_fail" ];

  # Set your time zone.
  time.timeZone = "America/Louisville";
  services.timesyncd.enable = true;

  # Setup LAN and VLAN
  networking = {
    hostName = "PI";
    defaultGateway = "172.16.0.1";
    nameservers = [ "208.67.222.222" "208.67.220.220" ];
    vlans = {
      iot = {
        id = 10;
        interface = "eth0";
      };
    };
    interfaces = {
      eth0 = {
        ipv4.addresses = [ {
          address = "172.16.0.3";
          prefixLength = 24;
        } ];
        useDHCP = false;
      };
      iot = {
        ipv4.addresses = [ {
          address = "172.16.1.3";
          prefixLength = 24;
        } ];
        useDHCP = false;
      };
    };
  };

  # Setup netdata
  services.netdata = {
    enable = true;
  };

  # Setup Locale, Terminal Font, and Keyboard Mapping
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Setup User
  users.groups.collin.gid = 1000;
  users.users.collin = {
    uid = 1000;
    group = "collin";
    isNormalUser = true;
    initialPassword = "nixos"; # Change this using passwd immediately
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDmt5hHa/KGH8HAD3fGJwKeP9z+HiObmVxz8SZ2ljhaA4b6NLnMEEda5HuV8UukacWDkRrVT8S5adHlNc2U0lLdmzmo119x5sWt+THDU8QsL2oH6IRjBJVYKBqkClk7ZBfqjzlcC5U58ibEfLIbmiZLZPjzO3ey9khpbzjHL0c882dt0CMPJHWHTtRv935GuD7yBQlRNLZ5EW/IOsw6/l5xlbGPXqCtRjOQ8sj+oivIo/TWBRFK4Qn6glupKei4WAH7ORUJxYt1rzfP0KUBfQsu8mJAIVCSETPpT3OqCtFvl9eCDuSyXRKoBANjS5E71fv3vT/hWrIrcwN+HXE01i1OlQlg7yacajliy87q99fRySfrF8FVISPsg4ft80PpLajVbhXe14IJe9P7IdTV/4rDNF+yZY/KTLRAUkiOLnKiUCgWpiDT9/gAMrFmYcQeGWb8hC7J136bD0wOYtYN6y11qJ4ytccWoNJAwfzmnQzmDceqzb5PY/hKmFN6athOoYc= collin@BURGUNDY" "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCjE3cJ6iDnaCPsNCvIWl1diZAec6RzZDX6qyaJOV+xkAlzCbeFw0gxHoPzEPkhzbCKWAA3lxTnKC+/oVmwAuLQ4SIeryYwFyq30XIb5+npsO98jZzXt5QonJoB3oPKr7uLqIa6+XDFrV/FW33l6ZcpeMBBTJvsWI8z3Mu89xgpHKOpNl+afNAgVE8QxpDYkHY91ao+3t55yC8c1CbP55FtPJ8s3UEVYw2ZnY7cDAZdm1v3QuDbAF3WJp6uZys1dVNlBquSMmchdCZAXIGiNtbukKV9bzrvXwipuG+fnU3bJjcC08eHgGz/vNKw5H6MQoFfrcA7d0l4b00ecfCfrYSDcPLStZPihHd0iAilixFmlqK6n9+15YlsKv4WtZnGOb42oHI9X+u4JlM4EjbXH0R1gdddf5owiucq3EMuwhbXwfq0YiO1stP6aeX5Yvz+ooH8YOVlK8xdGr1w7jjOxLtMEcaYuOl9YvgP85suPM++J1d97cvbhJ7Hn2OAHeI9mMcJLlYxXwNhWIalp6cTn8Wcrz5uR/d8q44OpN4kaLDG1n/51pxBS0HebRS3hXf/Pc2WAmLwyyXhnNCanDZHNVR6/+8y/SRuZHKSv+bx4RaMPalaWCZjDsX44McfCeLgiu8eXNn64uvdqwJdC+972acc4vFB1Z8d7VNzrIGxKhdbNw== collin@TEAL" ];
    extraGroups = [ "wheel" "docker" ];
  };

  # Install Packages
  environment.systemPackages = with pkgs; [
    nano
    wget
    curl
    git
    htop
    iotop
    p7zip
    docker-compose
    nettools
    neofetch
    arp-scan
    bpytop
    ctop
    lazydocker
    killall
    ncdu
  ];

  # Make Stuff Pretty With Oh-My-ZSH
  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestions.enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "sudo" "docker"];
      theme = "agnoster";
    };
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  #services.openssh.permitRootLogin = "yes";

  # Disable the Firewall
  networking.firewall.enable = false;

  # Enable Docker
  virtualisation.docker.enable = true;

  # Nix Garbage Collection
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 30d";
  nix.autoOptimiseStore = true;

  # Nix Auto Update
  system.autoUpgrade.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}
