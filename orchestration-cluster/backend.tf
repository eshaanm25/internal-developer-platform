terraform {
  cloud {
    organization = "eshaanm"

    workspaces {
      name = "internal-developer-platform"
    }
  }
}