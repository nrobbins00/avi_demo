provider "azurerm" {
    version = "~> 1.20.0"
    #using az cli auth
    subscription_id = "${var.sub_id}"
}

provider "random" {
    version = "~> 2.0"
}

provider "template" {
    version = "~> 1.0"
}
