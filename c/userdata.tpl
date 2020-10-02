#cloud-config
repo_update: true
repo_upgrade: all

write_files:
- path: /home/centos/testing.sh
  permissions: '0755'
  owner: centos:centos
  content: |
     #!/bin/sh
     touch /home/centos/testing.txt
- path: /home/centos/ssh_keys.sh
  permissions: '0755'
  owner: centos:centos
  content: |
     #!/bin/sh
     ssh-keygen -q -t rsa -N '' -f /home/centos/.ssh/id_rsa <<<y 2>&1 >/dev/null

     cat /home/centos/.ssh/id_rsa.pub >> /home/centos/.ssh/authorized_keys

     ssh -o StrictHostKeyChecking=no centos@localhost
- path: /home/centos/play-books.sh
  permissions: '0755'
  owner: centos:centos
  content: |
     #!/bin/sh
     git clone https://github.com/krishnamaram2/configuration-manager.git

     cd configuration-manager/src/testing

     ansible-playbook -i hosts plays/webapp.yml


runcmd:
 - [ sh, /home/centos/testing.sh ]
#- [ sh, /home/centos/ssh_keys.sh ]
 - [ sh, /home/centos/play_books.sh ]

