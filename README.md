# ansible
bootcamp-week6

**steps**
1. follow all the steps in https://github.com/avishoro/TerraformProject to install terraform and configure it.
2. to your vars.tf file add (besides the 'admin' and 'password' vars) the next code:
 
    variable "masterIP" {
  
    description = "The IP of the master machine."
  
    default = "00.000.000.00"
  
    }
  
  
3. create two infrastructures, one with the staging code, and one with the production code, in the production enviorment, use the production-variables file in https://github.com/avishoro/ansible/tree/main/terraform-code/modules/vm, for the staging enviorment, use the staging-variables file there.

4. follow all the steps in https://gitlab.com/ansible-workshop/labs/lab01 to install ansible and configure the nodes.
 
5. create vars.yml file with all your variables in this form:

host: {your host address}
 
pghost: {your db name}.postgres.database.azure.com

pg_username:  postgres

pg_password: {Your password}

LB_ip: {Your public IP}

okta_url: {Your OKTA url like dev-*******.okta.com}

okta_client_id:  {Your client ID}

okta_client_secret: {Your client secret}

ansible_connection: ssh 

ansible_port: 22

ansible_user: {your username}

ansible_ssh_pass: {your password}

6. create inventory file with your VM's ip's like the inventory-example file

7. copy the playbook.yaml to your master

8. run "ansible-playbook -i inventory playbook.yaml"
