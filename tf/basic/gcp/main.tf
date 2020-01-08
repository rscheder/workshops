provider "google" {
  credentials = "${file("account.json")}"
  project     = "alpine-tracker-251408"
  region      = "us-central1"
  zone        = "us-central1-c"
}
