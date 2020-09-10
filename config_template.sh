#this declares `email` as an associative array
typeset -A email

#enter the emails of the correctors here.
#The string used as the key will also be used as a dirname, so be aware of that.
email[jon]="jon.doe@example.com"

SUBJECT="`whoami` could not be bothered to configure SUBJECT"

#Whether to check that c files compile
TRIAL_C_COMPILATION=true

#Whether to run the identify.sh script
IDENTIFY=true

#Whether to send out emails directly
DISTRIBUTE_DIRECTY=true

