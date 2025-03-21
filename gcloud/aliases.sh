# ------------------------------------------------------------------------------
# ☁️ Google Cloud SDK Essentials
# ------------------------------------------------------------------------------

alias gcloud-init='gcloud init'
alias gcloud-login-cli='gcloud auth login'                     # CLI: User account login
alias gcloud-login-adc='gcloud auth application-default login' # ADC: Used by services and libraries
alias gcloud-logout='gcloud auth revoke'
alias gcloud-info='gcloud info'
alias gcloud-update='gcloud components update'

# ------------------------------------------------------------------------------
# 🔐 GCP Account Management
# ------------------------------------------------------------------------------

alias gcloud-account-list='gcloud auth list'

# Use function for dynamic input
function gcloud-account-set() {
    gcloud config set account "$1"
}

# ------------------------------------------------------------------------------
# 🏗️ GCP Project Management
# ------------------------------------------------------------------------------

alias gcloud-projects-list='gcloud projects list'

function gcloud-project-describe() {
    gcloud projects describe "$1"
}

function gcloud-project-set() {
    gcloud config set project "$1"
}
