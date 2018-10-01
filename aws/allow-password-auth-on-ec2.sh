echo "Update cloud-init configuration file"
echo "vim /etc/cloud/cloud.cfg"
echo "disable_root: false"
echo "ssh_pwauth: true"

echo ""
echo "Update the authorized_keys file"
echo "vim ~/.ssh/authorized_keys"
echo "Delete everything up to \`ssh-rsa <content of sshkey>\` leaving only: "
echo "ssh-rsa <content of sshkey>"

echo ""

