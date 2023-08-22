resource "port_blueprint" "environment" {
  provider = port-labs
  title      = "test-environment"
  icon       = "Environment"
  identifier = "eshaan-env-one-test"
  properties = {
    string_props = {
      "name" = {
        type  = "string"
        title = "name"
      }
    }
  }
}


resource "port_action" "application_onboarding" {
  provider = port-labs
  blueprint = port_blueprint.environment.identifier
  identifier = "application_onboarding"
  title = "Application Onboarding"
  description = "Onboard an application to the orchestration cluster"
  trigger = "CREATE"
  icon = "Argo"

  github_method = {
    org = "eshaanm25"
    repo = "internal-developer-platform"
    workflow = "onboard-application.yaml"
    report_workflow_status = true
  }
  user_properties = {
    string_props = {
      "application_name" = {
        title       = "Application Name"
        description = "The name of your application"
        pattern     = "[a-z0-9]([-a-z0-9]*[a-z0-9])?"
        icon = "BlankPage"
        required = true
      }
      "image" = {
        title       = "Image"
        description = "Image for Application (can be changed after Deployment)"
        default = "gcr.io/heptio-images/ks-guestbook-demo:0.2"
        icon = "Package"
        required = true
      }
      "port" = {
        title       = "Port"
        description = "The Port where the Application is Serving Content (can be changed after Deployment)"
        default = 80
        icon = "Day2Operation"
        required = true
        pattern = "[0-9]*"
      }
    }
  }

}