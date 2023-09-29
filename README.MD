# Introduction 
This reposistory houses puppet modules used to build and configure 
Learning and Teaching Systems Linux Servers.

# Branches
* master :
  * Puppet3 modules published to Production Satellite 6.3
* puppet5:
  * Puppet5 modules published to Test & Production Satellite 6.7
  * Branches from puppet5 will trigger a CI pipeline job to run puppet-lint. Check for a success full linting run before submitting a merge request in to puppet5. **We are treating warnings a failures.**