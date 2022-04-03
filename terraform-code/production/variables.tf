variable "projectPrefix" {
  description = "The prefix which should be used for all resources connected to the web app."
  default = "weight-tracker-app"
}

variable "location" {
  description = "The supported Azure location where the resource exists."
  default = "Switzerland North"
}


variable "num" {
  description = "The number of  resources to create."
  default = "3"
}

variable "subnets" {
  type = map(string)
  description = "The names of the subnets."
  default = {
    public = "publicApp"
    private = "privateDB"
  }
}