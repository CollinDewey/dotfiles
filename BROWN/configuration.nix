{ modulesPath, pkgs, ... }: {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  boot.initrd.kernelModules = [ "nvme" ];
  systemd.enableEmergencyMode = false;
  boot.kernelParams = [ "panic=1" "boot.panic_on_fail" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.cleanTmpDir = true;
  powerManagement.cpuFreqGovernor = "performance";
  swapDevices = [ { device = "/swapfile"; size = 16384; } ];

  fileSystems."/" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };

  fileSystems."/mnt/Block" = {
    device = "/dev/disk/by-label/Block";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/UEFI";
    fsType = "vfat";
  };

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };

  users.groups.collin.gid = 1000;
  users.users.collin = {
    uid = 1000;
    group = "collin";
    isNormalUser = true;
    initialPassword = "nixos";
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDmt5hHa/KGH8HAD3fGJwKeP9z+HiObmVxz8SZ2ljhaA4b6NLnMEEda5HuV8UukacWDkRrVT8S5adHlNc2U0lLdmzmo119x5sWt+THDU8QsL2oH6IRjBJVYKBqkClk7ZBfqjzlcC5U58ibEfLIbmiZLZPjzO3ey9khpbzjHL0c882dt0CMPJHWHTtRv935GuD7yBQlRNLZ5EW/IOsw6/l5xlbGPXqCtRjOQ8sj+oivIo/TWBRFK4Qn6glupKei4WAH7ORUJxYt1rzfP0KUBfQsu8mJAIVCSETPpT3OqCtFvl9eCDuSyXRKoBANjS5E71fv3vT/hWrIrcwN+HXE01i1OlQlg7yacajliy87q99fRySfrF8FVISPsg4ft80PpLajVbhXe14IJe9P7IdTV/4rDNF+yZY/KTLRAUkiOLnKiUCgWpiDT9/gAMrFmYcQeGWb8hC7J136bD0wOYtYN6y11qJ4ytccWoNJAwfzmnQzmDceqzb5PY/hKmFN6athOoYc= collin@BURGUNDY" "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCjE3cJ6iDnaCPsNCvIWl1diZAec6RzZDX6qyaJOV+xkAlzCbeFw0gxHoPzEPkhzbCKWAA3lxTnKC+/oVmwAuLQ4SIeryYwFyq30XIb5+npsO98jZzXt5QonJoB3oPKr7uLqIa6+XDFrV/FW33l6ZcpeMBBTJvsWI8z3Mu89xgpHKOpNl+afNAgVE8QxpDYkHY91ao+3t55yC8c1CbP55FtPJ8s3UEVYw2ZnY7cDAZdm1v3QuDbAF3WJp6uZys1dVNlBquSMmchdCZAXIGiNtbukKV9bzrvXwipuG+fnU3bJjcC08eHgGz/vNKw5H6MQoFfrcA7d0l4b00ecfCfrYSDcPLStZPihHd0iAilixFmlqK6n9+15YlsKv4WtZnGOb42oHI9X+u4JlM4EjbXH0R1gdddf5owiucq3EMuwhbXwfq0YiO1stP6aeX5Yvz+ooH8YOVlK8xdGr1w7jjOxLtMEcaYuOl9YvgP85suPM++J1d97cvbhJ7Hn2OAHeI9mMcJLlYxXwNhWIalp6cTn8Wcrz5uR/d8q44OpN4kaLDG1n/51pxBS0HebRS3hXf/Pc2WAmLwyyXhnNCanDZHNVR6/+8y/SRuZHKSv+bx4RaMPalaWCZjDsX44McfCeLgiu8eXNn64uvdqwJdC+972acc4vFB1Z8d7VNzrIGxKhdbNw== collin@TEAL" ];
    extraGroups = [ "wheel" "docker" ];
  };

  environment.systemPackages = with pkgs; [
    nano
    wget
    curl
    git
    htop
    iotop
    ctop
    lazydocker
    nettools
    neofetch
    killall
    ncdu
  ];

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

  networking = {
    hostName = "BROWN";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    interfaces.enp0s3.useDHCP = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 25565 ];
      allowedUDPPorts = [ 51820 ];
    };
  };
  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;

  # Set your time zone.
  time.timeZone = "America/Louisville";
  services.timesyncd.enable = true;

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
  system.stateVersion = "21.11"; # Did you read the comment?
}
