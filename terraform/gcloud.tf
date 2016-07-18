// Configure the Google Cloud provider
provider "google" {
  credentials = "${file("../creds/account.json")}"
  project     = "${var.project}"
  region      = "${var.region}"
}