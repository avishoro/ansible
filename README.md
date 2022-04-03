# ansible
bootcamp-week6

**steps**
1. follow all the steps in https://github.com/avishoro/TerraformProject to install terraform and configure it.
2. to your vars.tf file add (besides the 'admin' and 'password' vars) the next code:
 
  variable "masterIP" {
  
  description = "The IP of the master machine."
  
  default = "<your IP address>"
  
  }
  
  
3. create two infrastructures, one with the staging code, and one with the production code.
 
