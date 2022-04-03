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
 
