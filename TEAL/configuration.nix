{ config, pkgs, ... }:

{
  boot.initrd.availableKernelModules = [ "ahci" "ohci_pci" "ehci_pci" "nvme" "xhci_pci" "usb_storage" "usbhid" "sd_mod" "sr_mod" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "iommu=soft" ];
  boot.kernelModules = [ "kvm-amd" "v4l2loopback" ];
  powerManagement.cpuFreqGovernor = "performance";
  swapDevices = [ { device = "/swapfile"; size = 8192; } ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/Linux";
    fsType = "ext4";
  };
  
  fileSystems."/mnt/Shared" = {
    device = "/dev/disk/by-label/Shared";
    fsType = "ntfs";
  };

  #fileSystems."/mnt/Data" = {
  #  device = "/dev/disk/by-label/Data";
  #  fsType = "ext4";
  #};

  fileSystems."/mnt/Other" = {
    device = "/dev/disk/by-label/Other";
    fsType = "ntfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
  };

  fileSystems."/mnt/PI" = {
    device = "collin@172.16.0.3:/";
    options = [ "x-systemd.automount" "_netdev" "user" "idmap=user" "transform_symlinks" "identityfile=/home/collin/.ssh/id_rsa" "allow_other" "reconnect" "ServerAliveInterval=2" "ServerAliveCountMax=2" "compression=no" "cipher=chacha20-poly1305@openssh.com" "default_permissions" "uid=1000" "gid=1000" ];
    fsType = "fuse.sshfs";
  };

  fileSystems."/mnt/Seagate3TB" = {
    device = "collin@172.16.0.3:/mnt/Seagate3TB";
    options = [ "x-systemd.automount" "_netdev" "user" "idmap=user" "transform_symlinks" "identityfile=/home/collin/.ssh/id_rsa" "allow_other" "reconnect" "ServerAliveInterval=2" "ServerAliveCountMax=2" "compression=no" "cipher=chacha20-poly1305@openssh.com" "default_permissions" "uid=1000" "gid=1000" ];
    fsType = "fuse.sshfs";
  };
  
  boot.cleanTmpDir = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "TEAL";
  services.fstrim.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Set your time zone.
  time.timeZone = "America/Louisville";
  services.timesyncd.enable = true;

  networking.networkmanager.enable = true;  

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the Plasma 5 Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "collin";
  services.xserver.desktopManager.plasma5.enable = true;
  nixpkgs.config.allowUnfree = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.enable = true;

  # Configure keymap in X11
  services.xserver.layout = "us";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  users.groups.collin.gid = 1000;
  users.users.collin = {
    uid = 1000;
    group = "collin";
    isNormalUser = true;
    initialPassword = "nixos";
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDmt5hHa/KGH8HAD3fGJwKeP9z+HiObmVxz8SZ2ljhaA4b6NLnMEEda5HuV8UukacWDkRrVT8S5adHlNc2U0lLdmzmo119x5sWt+THDU8QsL2oH6IRjBJVYKBqkClk7ZBfqjzlcC5U58ibEfLIbmiZLZPjzO3ey9khpbzjHL0c882dt0CMPJHWHTtRv935GuD7yBQlRNLZ5EW/IOsw6/l5xlbGPXqCtRjOQ8sj+oivIo/TWBRFK4Qn6glupKei4WAH7ORUJxYt1rzfP0KUBfQsu8mJAIVCSETPpT3OqCtFvl9eCDuSyXRKoBANjS5E71fv3vT/hWrIrcwN+HXE01i1OlQlg7yacajliy87q99fRySfrF8FVISPsg4ft80PpLajVbhXe14IJe9P7IdTV/4rDNF+yZY/KTLRAUkiOLnKiUCgWpiDT9/gAMrFmYcQeGWb8hC7J136bD0wOYtYN6y11qJ4ytccWoNJAwfzmnQzmDceqzb5PY/hKmFN6athOoYc= collin@BURGUNDY" "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCjE3cJ6iDnaCPsNCvIWl1diZAec6RzZDX6qyaJOV+xkAlzCbeFw0gxHoPzEPkhzbCKWAA3lxTnKC+/oVmwAuLQ4SIeryYwFyq30XIb5+npsO98jZzXt5QonJoB3oPKr7uLqIa6+XDFrV/FW33l6ZcpeMBBTJvsWI8z3Mu89xgpHKOpNl+afNAgVE8QxpDYkHY91ao+3t55yC8c1CbP55FtPJ8s3UEVYw2ZnY7cDAZdm1v3QuDbAF3WJp6uZys1dVNlBquSMmchdCZAXIGiNtbukKV9bzrvXwipuG+fnU3bJjcC08eHgGz/vNKw5H6MQoFfrcA7d0l4b00ecfCfrYSDcPLStZPihHd0iAilixFmlqK6n9+15YlsKv4WtZnGOb42oHI9X+u4JlM4EjbXH0R1gdddf5owiucq3EMuwhbXwfq0YiO1stP6aeX5Yvz+ooH8YOVlK8xdGr1w7jjOxLtMEcaYuOl9YvgP85suPM++J1d97cvbhJ7Hn2OAHeI9mMcJLlYxXwNhWIalp6cTn8Wcrz5uR/d8q44OpN4kaLDG1n/51pxBS0HebRS3hXf/Pc2WAmLwyyXhnNCanDZHNVR6/+8y/SRuZHKSv+bx4RaMPalaWCZjDsX44McfCeLgiu8eXNn64uvdqwJdC+972acc4vFB1Z8d7VNzrIGxKhdbNw== collin@TEAL" ];
    extraGroups = [ "wheel" "docker" ];
  };

  services.gnome.gnome-keyring.enable = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nano
    wget
    curl
    aria
    git
    htop
    iotop
    p7zip
    docker-compose
    nettools
    neofetch
    arp-scan
    killall
    firefox
    kate
    discord
    flameshot
    filelight
    solaar
    mpv
    papirus-icon-theme
    krita
    conky
    obs-studio
    steam
    sshfs
    peek
    lxqt.pavucontrol-qt
    lutris
    unrar
    virt-manager
    gifski
    guvcview
    gwenview
    kdenlive
    krdc
    yt-dlp
    ark
    freerdp
    wireshark
    keeweb
    cpu-x
    vscode
    libsForQt5.qtstyleplugin-kvantum
    moonlight-qt
    x11vnc
    partition-manager
    gnome.simple-scan
    clementine
    audacity
    scrcpy
    ffmpeg-full
    vaapiVdpau
    libvdpau-va-gl
    vlc
    rclone
    rclone-browser
    home-manager
  ];

  services.duplicati = {
    enable = true;
    user = "collin";
  };

  services.netdata.enable = true;

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

  # Enable Docker/Virtualization
  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.docker.enableNvidia = true;
  programs.dconf.enable = true;

  # Nix Garbage Collection
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 30d";
  nix.settings.auto-optimise-store = true;

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
