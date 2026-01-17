# vim: set ft=make :

regenerate-grub:
    #!/usr/bin/bash
    source /usr/libexec/bazzite-boot-remount
    remount_boot_rw
    if [ -d /sys/firmware/efi ]; then
      sudo grub2-mkconfig -o /etc/grub2-efi.cfg
    else
      sudo grub2-mkconfig -o /etc/grub2.cfg
    fi
    remount_boot_ro

enable-tailscale:
    systemctl enable --now tailscaled.service

my-cli:
    #!/usr/bin/bash
    #shellcheck disable=SC2154
    set -eou pipefail
    # Source libujust for colors/ugum
    source /usr/lib/ujust/ujust.sh
    # Exit Handling
    function Exiting(){
        printf "%s%sExiting...%s\n" "${red}" "${bold}" "${normal}"
        printf "Rerun script with %s%sujust bazzite-cli%s\n" "${blue}" "${bold}" "${normal}"
        exit 0
    }
    # Trap function
    function ctrl_c(){
        printf "\nSignal SIGINT caught\n"
        Exiting
    }
    # Brew Bundle Install
    function brew-bundle(){
    echo 'Installing bling from Homebrew 🍻🍻🍻'
    brew bundle --file /usr/share/mine/my-cli.Brewfile
    }
    # Check if bling is already sourced
    function check-bling() {
    shell="$1"
    if [[ "${shell}" == "fish" ]]; then
        line=$(grep -n "source /usr/share/mine/bling.fish" \
            "${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish" \
            | grep -Eo '^[^:]+')
        if [[ -n "${line}" ]]; then
            return 1;
        fi
        return 0;
    elif [[ "${shell}" == "zsh" ]]; then
        line=$(grep -n "source /usr/share/mine/bling.sh" \
            "${ZDOTDIR:-$HOME}/.zshrc" \
            | grep -Eo '^[^:]+')
        if [[ -n "${line}" ]]; then
            return 1;
        fi
        return 0;
    elif [[ "${shell}" == "bash" ]]; then
        line=$(grep -n "source /usr/share/mine/bling.sh" \
            "${HOME}/.bashrc" \
            | grep -Eo '^[^:]+')
        if [[ -n "${line}" ]]; then
            return 1;
        fi
        return 0;
    else
        echo 'Unknown Shell ... You are on your own'
        exit 1;
    fi
    }
    # Add Bling
    function add-bling(){
    shell="$1"
    if ! brew-bundle; then
        Exiting
    fi
    echo 'Setting up your Shell 🐚🐚🐚'
    if [[ "${shell}" == "fish" ]]; then
        echo 'Adding bling to your config.fish 🐟🐟🐟'
        cat<<-EOF >> "${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish"
    ### bling.fish source start
    test -f /usr/share/mine/bling.fish && source /usr/share/mine/bling.fish
    ### bling.fish source end
    EOF
    elif [[ "${shell}" == "zsh" ]]; then
        echo 'Adding bling to your .zshrc 💤💤💤'
        cat<<-EOF >> "${ZDOTDIR:-$HOME}/.zshrc"
    ### bling.sh source start
    test -f /usr/share/mine/bling.sh && source /usr/share/mine/bling.sh
    ### bling.sh source end
    EOF
    elif [[ "${shell}" == "bash" ]]; then
        echo 'Adding bling to your .bashrc 💥💥💥'
        cat<<-EOF >> "${HOME}/.bashrc"
    ### bling.sh source start
    test -f /usr/share/mine/bling.sh && source /usr/share/mine/bling.sh
    ### bling.sh source end
    EOF
    else
        echo 'Unknown Shell ... You are on your own'
    fi
    }
    # Remove bling, handle if old method
    function remove-bling(){
    shell="$1"
    if [[ "${shell}" == "fish" ]]; then
        sed -i '/### bling.fish source start/,/### bling.fish source end/d' \
            "${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish" \
            || \
            line=$(grep -n "source /usr/share/ublue-os/bluefin-cli/bling.fish" \
            "${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish" \
            | grep -Eo '^[^:]+') && sed -i "${line}"d \
            "${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish"
    elif [[ "${shell}" == "zsh" ]]; then
        sed -i '/### bling.sh source start/,/### bling.sh source end/d' \
            "${ZDOTDIR:-$HOME}/.zshrc" \
            || \
            line=$(grep -n "source /usr/share/ublue-os/bluefin-cli/bling.sh" \
            "${ZDOTDIR:-$HOME}/.zshrc" \
            | grep -Eo '^[^:]+') && sed -i "${line}"d \
            "${ZDOTDIR:-$HOME}/.zshrc"
    elif [[ "${shell}" == "bash" ]]; then
        sed -i '/### bling.sh source start/,/### bling.sh source end/d' \
            "${HOME}/.bashrc" \
            || \
            line=$(grep -n "source /usr/share/ublue-os/bluefin-cli/bling.sh" \
            "${HOME}/.bashrc" \
            | grep -Eo '^[^:]+') && sed -i "${line}"d \
            "${HOME}/.bashrc"
    fi
    }

    # Main function.
    function main(){

    # Get Shell
    shell=$(basename "$SHELL")
    reentry="$1"
    clear
    if [[ -n "${reentry:-}" ]]; then
        printf "%s%s%s\n\n" "${bold}" "$reentry" "$normal"
    fi

    # Check if bling is enabled and display
    printf "Shell:\t%s%s%s%s\n" "${green}" "${bold}" "${shell}" "${normal}"
    if ! check-bling "${shell}"; then
        printf "Bling:\t%s%sEnabled%s\n" "${green}" "${bold}" "${normal}"
    else
        printf "Bling:\t%s%sDisabled%s\n" "${red}" "${bold}" "${normal}"
    fi

    # ugum enable/disable
    CHOICE=$(Choose enable disable cancel)

    # Enable/Disable. Recurse if bad option.
    if [[ "${CHOICE}" == "enable" ]]; then
        if check-bling "${shell}"; then
            trap ctrl_c SIGINT
            add-bling "${shell}"
            printf "%s%sInstallation Complete%s ... please close and reopen your terminal!" "${green}" "${bold}" "${normal}"
        else
            main "Bling is already configured ..."
        fi
    elif [[ "${CHOICE}" == "disable" ]]; then
        if check-bling "${shell}"; then
            main "Bling is not yet configured ..."
        else
            remove-bling "${shell}"
            trap ctrl_c SIGINT
            printf "%s%sBling Removed%s ... please close and reopen your terminal\n" "${red}" "${bold}" "${normal}"
        fi
    else
        Exiting
    fi
    }

    # Entrypoint
    main ""

distrobox-assemble CONTAINER="prompt" ACTION="create" FILE="/etc/distrobox/distrobox.ini":
    #!/usr/bin/bash
    # Distroboxes are gathered from /etc/distrobox/distrobox.ini, add them there
    source /usr/lib/ujust/ujust.sh
    AssembleList {{ FILE }} {{ ACTION }} {{ CONTAINER }}

spicetify:
    #!/usr/bin/bash
    cd /var/tmp
    git clone https://github.com/boudywho/easy-spicetify-arch.git
    cd easy-spicetify-arch
    chmod +x spicetify.sh
    ./spicetify.sh

toggle-iwd:
    #!/usr/bin/bash
    echo -e "This script manages enabling or disabling iwd as a replacement for wpa_supplicant for Wi-Fi networking."
    echo -e "Enabling this can improve throughput, mesh networking, and reduce latency increases when scanning for networks"
    echo -e "Disabling this can improve corporate or eduroam network compatibility"
    echo -e ""
    echo -e "WARNING: Changing this will remove all saved wifi networks"
    get_current_status() {
      if [[ -f "/etc/NetworkManager/conf.d/iwd.conf" ]]; then
        echo "Enabled"
      else
        echo "Disabled"
      fi
    }
    remove_saved_networks() {
      nmcli -t -f NAME connection show | while read -r line; do sudo nmcli connection delete "$line"; done
    }
    enable_iwd() {
      sudo mkdir -p "/etc/NetworkManager/conf.d/"
      sudo rm -f "/etc/NetworkManager/conf.d/iwd.conf"
      printf "[device]\nwifi.backend=iwd" | sudo tee /etc/NetworkManager/conf.d/iwd.conf > /dev/null
      remove_saved_networks
      echo -e "iwd enabled. Reboot required to apply changes."
    }
    disable_iwd() {
      sudo rm -f "/etc/NetworkManager/conf.d/iwd.conf"
      remove_saved_networks
      echo -e "iwd disabled. Reboot required to apply changes."
    }
    # Display current status
    current_status=$(get_current_status)
    echo -e "\nCurrent iwd status: $current_status\n"
    # Prompt user for action
    CHOICE=$(gum choose "Enable iwd" "Disable iwd" "Exit without changes")
    case "$CHOICE" in
      "Enable iwd")
        enable_iwd
        ;;
      "Disable iwd")
        disable_iwd
        ;;
      "Exit without changes")
        echo "No changes made."
        ;;
      *)
        echo "Invalid choice. Exiting without changes."
        ;;
    esac
setup-virtualization ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    if [[ $(id -u) -eq 0 ]]; then
      echo "Please do not run this command as root"
      exit 1
    fi
    # Check if we are running on a Steam Deck
    if /usr/libexec/hwsupport/valve-hardware; then
      echo "${red}${b}WARNING${n}: Virtualization is not properly supported on Steam Deck by Valve"
      echo "Use at your own risk and performance may not be ideal."
    fi
    if [ "$(systemctl is-enabled libvirtd.service)" == "disabled" ]; then
      echo "${b}libvirtd${n} service is ${red}disabled${n}!"
      echo "${green}enabling${n} and starting libvirtd"
      echo "If virt-manager says libvirtd.sock is not available after a big update, re-run this command."
      sudo systemctl enable --now libvirtd 2> /dev/null
      echo "Press ESC if you want to exit and do not need to do anything"
    fi
    OPTION={{ ACTION }}
    if [ "$OPTION" == "help" ]; then
      echo "Usage: ujust setup-virtualization <option>"
      echo "  <option>: Specify the quick option to skip the prompt"
      echo "  Use 'virt-on' to select Enable Virtualization"
      echo "  Use 'virt-off' to select Disable Virtualization"
      echo "  Use 'group' to select Add $USER to libvirt group"
      echo "  Use 'vfio-on' to select Enable VFIO drivers"
      echo "  Use 'vfio-off' to select Disable VFIO drivers"
      echo "  Use 'kvmfr' to select Autocreate Looking-Glass shm"
      echo "  Use 'usbhp-on' to select Enable SPICE USB hot plugging"
      echo "  Use 'usbhp-off' to select Disable SPICE USB hot plugging"
      exit 0
    elif [ "$OPTION" == "" ]; then
      echo "${bold}Virtualization Setup${normal}"
      echo "NOTE: Enabling Virtualization will install the virt-manager flatpak and set kernel args"
      OPTION=$(Choose \
        "Enable Virtualization" \
        "Disable Virtualization" \
        "Add $USER to libvirt group" \
        "Enable VFIO drivers" \
        "Disable VFIO drivers" \
        "Enable kvmfr module" \
        "Enable USB hot plugging" \
        "Disable USB hot plugging" \
      )
    fi
    if [[ "${OPTION,,}" =~ (^enable[[:space:]]virtualization|virt-on) ]]; then
        if ! rpm -q virt-manager | grep -P "^virt-manager-" 1>/dev/null; then
          echo "Installing virt-manager..."
          flatpak install flathub org.virt_manager.virt-manager
          rpm-ostree kargs \
          --append-if-missing="kvm.ignore_msrs=1" \
          --append-if-missing="kvm.report_ignored_msrs=0"
          echo "Making sure swtpm will work"
          if [ ! -d "/var/lib/swtpm-localca" ]; then
            sudo mkdir /var/lib/swtpm-localca
          fi
          sudo chown tss /var/lib/swtpm-localca
          sudo restorecon -rv /var/lib/libvirt
          sudo restorecon -rv /var/log/libvirt
          echo "Giving qemu access to read ISO files from $HOME"
          sudo setfacl -m u:qemu:rx $HOME
          if sudo test ! -f "/etc/libvirt/hooks/qemu"; then
            echo "Adding libvirt qemu hooks"
            sudo wget 'https://raw.githubusercontent.com/PassthroughPOST/VFIO-Tools/master/libvirt_hooks/qemu' -O /etc/libvirt/hooks/qemu
            sudo chmod +x /etc/libvirt/hooks/qemu
            sudo grep -A1 -B1 "# Add" /etc/libvirt/hooks/qemu | sed 's/^# //g'
            if sudo test ! -d "/etc/libvirt/hooks/qemu.d"; then
              sudo mkdir /etc/libvirt/hooks/qemu.d
            fi
          fi
          sudo systemctl enable bazzite-libvirtd-setup.service \
            && echo "libvirtd will be enabled at next reboot"
          echo 'Please reboot to apply changes'
        fi
    elif [[ "${OPTION,,}" =~ (^disable[[:space:]]virtualization|virt-off) ]]; then
      if [ "$(systemctl is-enabled libvirtd.service)" == "enabled" ]; then
        echo "${red}Disabling${n} libvirtd before removal"
        sudo systemctl disable --now libvirtd 2> /dev/null
      fi
      if [ "$(systemctl is-enabled bazzite-libvirtd-setup.service)" == "enabled" ]; then
        echo "${red}Disabling${n} bazzite-libvirtd-setup"
        sudo systemctl disable --now bazzite-libvirtd-setup.service 2> /dev/null
      fi
      echo "Removing virt-manager..."
      flatpak uninstall org.virt_manager.virt-manager
      rpm-ostree kargs \
      --delete-if-present="kvm.ignore_msrs=1" \
      --delete-if-present="kvm.report_ignored_msrs=0"
      echo 'Please reboot to apply changes'
    elif [[ "${OPTION,,}" =~ (^enable[[:space:]]vfio|vfio-on) ]]; then
      # Check if we are running on a Steam Deck
      if /usr/libexec/hwsupport/valve-hardware; then
        echo "IOMMU is not supported on Steam Deck"
        exit 0
      fi
      echo "Enabling VFIO..."
      VIRT_TEST=$(rpm-ostree kargs)
      CPU_VENDOR=$(grep "vendor_id" "/proc/cpuinfo" | uniq | awk -F": " '{ print $2 }')
      VENDOR_KARG="unset"
      if [[ ${VIRT_TEST} == *kvm.report_ignored_msrs* ]]; then
        rpm-ostree initramfs --enable
        if [[ ${CPU_VENDOR} == "AuthenticAMD" ]]; then
          VENDOR_KARG="amd_iommu=on"
        elif [[ ${CPU_VENDOR} == "GenuineIntel" ]]; then
          VENDOR_KARG="intel_iommu=on"  
        fi
        if [[ ${VENDOR_KARG} == "unset" ]]; then
          echo "Failed to get CPU vendor, exiting..."
          exit 1
        else
          rpm-ostree kargs \
            --append-if-missing="${VENDOR_KARG}" \
            --append-if-missing="iommu=pt" \
            --append-if-missing="rd.driver.pre=vfio-pci" \
            --append-if-missing="vfio_pci.disable_vga=1"
          echo "VFIO will be enabled on next boot, make sure you enable IOMMU, VT-d or AMD-v in your BIOS!"
          echo "Please understand that since this is such a niche use case, support will be very limited!"
          echo 'Use the command "ls-iommu -grk" to get iommu information about your GPUs, use the "--help" flag for more options'
          echo ""
          echo "${b}Systems with multiple GPUs${n}"
          echo "Bind your unused/second GPU device ids to the vfio driver by running"
          echo 'rpm-ostree kargs --append-if-missing="vfio_pci.ids=xxxx:yyyy,xxxx:yyzz"'
          echo "You will require a $(Urllink "https://www.amazon.com/s?k=hdmi+displayport+dummy+plug" "Dummy HDMI/DisplayPort plug (Ghost Adapter)") or hook the GPU"
          echo "to a separate monitor input in order to turn the GPU on when starting the VM."
          echo "NOTE: Your second GPU should be as different as possible from your main GPU and will not be usable by the host after you bind it to the vfio driver!"
          echo ""
          echo "${b}Systems with 1 GPU${n}"
          echo "Once rebooted you can continue setting up whatever scripts and hooks you need"
          echo "to get Single GPU passthrough working, however ${u}you will be on your own${n}."
          echo "${b}Do not ask for support for setting up Single GPU Passthrough, we can not help you!${n}"
        fi
      fi
    elif [[ "${OPTION,,}" =~ (^disable[[:space:]]vfio|vfio-off) ]]; then
      # Check if we are running on a Steam Deck
      if /usr/libexec/hwsupport/valve-hardware; then
        echo "IOMMU is not supported on Steam Deck"
        exit 0
      fi
      echo ""
      echo "Make sure you have ${b}disabled autostart of all VMs using VFIO${n} before continuing!"
      CONFIRM=$(Choose Cancel Continue)
      if [ "$CONFIRM" == "Continue" ]; then
        echo "Disabling VFIO..."
        VFIO_IDS="$(rpm-ostree kargs | sed -E 's/.+(vfio_pci.ids=.+\s)/\1/' | awk '{ print $1 }' | grep vfio_pci.ids)"
        VFIO_IDS_KARG=""
        if [ -n "$VFIO_IDS" ]; then
          echo "Found VFIO ids in kargs, adding the below line to removal list"
          echo "$VFIO_IDS"
          VFIO_IDS_KARG="--delete-if-present=\"$VFIO_IDS\""
        fi
        KVMFR_VAL="$(rpm-ostree kargs | sed -E 's/.+(kvmfr.static_size_mb=.+\s)/\1/' | awk '{ print $1 }' | grep kvmfr.static_size_mb)"
        KVMFR_KARG=""
        if [ -n "$KVMFR_VAL" ]; then
          echo "Found KVMFR static_size_mb in kargs, adding the below line to removal list"
          echo "$KVMFR_VAL"
          KVMFR_KARG="--delete-if-present=\"$KVMFR_VAL\""
        fi
        echo "Removing deprecated dracut modules"
        sudo rm /etc/dracut.conf.d/vfio.conf
        sudo rm /etc/modprobe.d/kvmfr.conf
        rpm-ostree kargs \
        --delete-if-present="iommu=pt" \
        --delete-if-present="iommu=on" \
        --delete-if-present="amd_iommu=on" \
        --delete-if-present="intel_iommu=on" \
        --delete-if-present="rd.driver.pre=vfio-pci" \
        --delete-if-present="vfio_pci.disable_vga=1" \
        --delete-if-present="vfio_pci.disable_vga=0" \
        $VFIO_IDS_KARG \
        $KVMFR_KARG
      fi
    elif [[ "${OPTION,,}" =~ kvmfr ]]; then
      # Check if we are running on a Steam Deck
      if /usr/libexec/hwsupport/valve-hardware; then
        echo "IOMMU is not supported on Steam Deck"
        exit 0
      fi
      echo "$(Urllink "https://looking-glass.io/docs/rc/ivshmem_kvmfr/#libvirt" "This module") along with $(Urllink "https://looking-glass.io" "Looking Glass") is very experimental and not recommended for production use!"
      echo "The ublue team packages the kvmfr module only because it has to be supplied with the system image while using an atomic desktop."
      echo "If you do plan to use Looking Glass, please $(Urllink "https://docs.bazzite.gg/Advanced/looking-glass/" "follow the guide here") on how to compile it for your system."
      echo "To use the kvmfr module after enabling it, just add and edit the xml for libvirt from the documentation in the first link."
      echo "Since we package the kvmfr module please open kvmfr related issues you have on Bazzite"
      echo "in the $(Urllink "https://discord.bazzite.gg/" "Bazzite Discord") or the $(Urllink "https://github.com/ublue-os/bazzite/issues" "Bazzite Github issue tracker")."
      echo "~ @HikariKnight"
      CONFIRM=$(Choose Ok Cancel)
      if [ "$CONFIRM" == "Cancel" ]; then
        exit 0
      fi
      echo ""
      echo "Setting up kvmfr module so it loads next boot"
      if [ -f "/etc/modprobe.d/kvmfr.conf" ]; then
        echo "Re-creating dummy kvmfr modprobe file"
        sudo rm /etc/modprobe.d/kvmfr.conf
      fi
      sudo bash -c 'cat << KVMFR_MODPROBE > /etc/modprobe.d/kvmfr.conf
    # This is a dummy file and changing it does nothing
    # If you want to change the kvmfr static_size_mb
    # Run "rpm-ostree kargs --replace=kvmfr.static_size_mb=oldvalue=newvalue"
    # Default value set by us is 128 which is enough for 4k SDR
    # Find the current value by running "rpm-ostree kargs"
    KVMFR_MODPROBE'
      rpm-ostree kargs --append-if-missing="kvmfr.static_size_mb=128" --append-if-missing="split_lock_detect=off"
      if [ -f "/etc/udev/rules.d/70-kvmfr.rules" ]; then
        echo "Re-creating kvmfr udev rules"
        sudo rm /etc/udev/rules.d/70-kvmfr.rules
      fi
      echo "Adding udev rule for /dev/kvmfr0"
      sudo bash -c 'cat << KVMFR_UDEV > /etc/udev/rules.d/70-kvmfr.rules
    SUBSYSTEM=="kvmfr", TAG+="uaccess", GROUP="qemu", MODE="0660"
    KVMFR_UDEV'
      echo "Adding /dev/kvmfr0 to qemu cgroup_device_acl"
      sudo perl -0777 -pi -e 's/
    #cgroup_device_acl = \[
    #    "\/dev\/null", "\/dev\/full", "\/dev\/zero",
    #    "\/dev\/random", "\/dev\/urandom",
    #    "\/dev\/ptmx", "\/dev\/kvm",
    #    "\/dev\/userfaultfd"
    #\]
    /
    cgroup_device_acl = \[
        "\/dev\/null", "\/dev\/full", "\/dev\/zero",
        "\/dev\/random", "\/dev\/urandom",
        "\/dev\/ptmx", "\/dev\/kvm",
        "\/dev\/userfaultfd", "\/dev\/kvmfr0"
    \]
    /' /etc/libvirt/qemu.conf
      echo "Adding SELinux context record for /dev/kvmfr0"
      sudo semanage fcontext -a -t svirt_tmpfs_t /dev/kvmfr0
      echo "Adding SELinux access rules for /dev/kvmfr0"
      if [ ! -d "$HOME/.config/selinux_te/mod" ]; then
        mkdir -p "$HOME/.config/selinux_te/mod"
      fi
      if [ ! -d "$HOME/.config/selinux_te/pp" ]; then
        mkdir -p "$HOME/.config/selinux_te/pp"
      fi
      if [ -f "$HOME/.config/selinux_te/kvmfr.te" ]; then
        echo "Re-creating kvmfr selinux type enforcement rules"
        rm $HOME/.config/selinux_te/kvmfr.te
      fi
      bash -c "cat << KVMFR_SELINUX > $HOME/.config/selinux_te/kvmfr.te
    module kvmfr 1.0;

    require {
        type device_t;
        type svirt_t;
        class chr_file { open read write map };
    }

    #============= svirt_t ==============
    allow svirt_t device_t:chr_file { open read write map };
    KVMFR_SELINUX"
      echo "This is the type enforcement we wrote for SELinux and you can find it in $HOME/.config/selinux_te/kvmfr.te"
      echo "#======= start of kvmfr.te ======="
      cat "$HOME/.config/selinux_te/kvmfr.te"
      echo "#======== end of kvmfr.te ========"
      checkmodule -M -m -o "$HOME/.config/selinux_te/mod/kvmfr.mod" "$HOME/.config/selinux_te/kvmfr.te"
      semodule_package -o "$HOME/.config/selinux_te/pp/kvmfr.pp" -m "$HOME/.config/selinux_te/mod/kvmfr.mod"
      sudo semodule -i "$HOME/.config/selinux_te/pp/kvmfr.pp"
      echo "Loading kvmfr module so you do not have to reboot to use it the first time"
      sudo modprobe kvmfr static_size_mb=128
      sudo chown $USER:qemu /dev/kvmfr0
      echo ""
      echo "Kvmfr0 $(Urllink "https://looking-glass.io/docs/B7-rc1/install_libvirt/#determining-memory" "static size is set to 128mb by default")"
      echo "this will work with up to 4K SDR resolutiion, as most dummy plugs go up to 4K"
      echo "some games will try use the adapters max resolution on first boot and cause issues if the value is too low."
      echo "Most ghost display adapters max out at 4k, hence the default value of 128mb."
      echo ""
      echo "If you need to change it to a different value"
      echo "you can do that by running \"rpm-ostree kargs --replace=kvmfr.static_size_mb=128=newvalue\""
      echo "You can check the current kernel arguments with \"rpm-ostree kargs\""
      echo "$(Urllink "https://looking-glass.io/docs/rc/ivshmem_kvmfr/#libvirt" "Please read official documentation for kvmfr for how to use it")"
      echo "${b}NOTE: You can start using kvmfr right now without rebooting if you already rebooted after enabling VFIO.${n}"
      CONFIRM=$(Choose OK)
    elif [[ "${OPTION,,}" =~ (^enable[[:space:]]usb|usbhp-on) ]]; then
      echo "Adding udev rule for USB devices"
      sudo bash -c 'cat << USBHP_UDEV > /etc/udev/rules.d/72-usbhp.rules
    ACTION=="add" SUBSYSTEM=="usb", TAG+="uaccess"
    USBHP_UDEV'
    elif [[ "${OPTION,,}" =~ (^disable[[:space:]]usb|usbhp-off) ]]; then
      sudo bash -c 'rm /etc/udev/rules.d/72-usbhp.rules'
    elif [[ "${OPTION,,}" =~ group ]]; then
      if ! grep -q "^libvirt" /etc/group; then
        grep '^libvirt' /usr/lib/group | sudo tee -a /etc/group > /dev/null
      fi
      sudo usermod -aG libvirt $USER
    fi
