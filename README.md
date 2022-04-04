# ansible
bootcamp-week6

**steps**
1. follow all the steps in https://github.com/avishoro/TerraformProject to install terraform and configure it.
2. to your vars.tf file add (besides the 'admin' and 'password' vars) the next code:
 
    variable "masterIP" {
  
    description = "The IP of the master machine."
  
    default = "00.000.000.00"
  
    }
  
  
3. create two infrastructures, one with the staging code, and one with the production code.

4. follow all the steps in https://gitlab.com/ansible-workshop/labs/lab01 to install ansible and configure the nodes.
 
5. create vars.yml file with all your variables in this form:

host: <>

pghost: <>

pg_username: <>

pg_password: <>

LB_ip: <>

okta_url: https://<>.okta.com

okta_client_id: <>

okta_client_secret: <>

ansible_connection: ssh 

ansible_port: 22

ansible_user: <>

ansible_ssh_pass: <>

6. create inventory file with your VM's ip's like the inventory-example file

7. copy the playbook.yaml to your master

8. run "ansible-playbook -i inventory playbook.yaml"
