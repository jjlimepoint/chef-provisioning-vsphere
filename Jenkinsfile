pipeline {
    agent {
        docker {
            args "-u root"
                reuseNode false
                image "localhost:5000/jjkeysv5"
                }
    }
    triggers {
        pollSCM('H * * * *')
    }
  stages {
    stage('Pull down ChefDK') {
      steps {
        sh '''apt-get update
apt-get install -y curl sudo git build-essential
curl -L https://chef.io/chef/install.sh | sudo bash -s -- -P chefdk -c current
if [ -d "vsphere_testing" ]; then rm -rf vsphere_testing; fi'''
      }
    }
    stage('Bundle') {
      steps {
        sh 'chef exec bundle install'
      }
    }
    stage('Checks') {
      steps {
        parallel(
          "Unit": {
            sh 'chef exec rake unit'

          },
          "Docs": {
            sh 'chef exec rake yard'

          }
        )
      }
    }
    stage('Kitchen setup') {
      steps {
        sh '''if [ -d "vsphere_testing" ]; then rm -rf vsphere_testing; fi
git clone https://github.com/jjasghar/vsphere_testing.git
cd vsphere_testing
for i in recipes/*; do sed -i 's/PASSWORD/Good4bye!/g' "$i"; done
sed -i 's/PASSWORD/Good4bye!/g' .kitchen.yml
sed -i 's/ORG/jj-model-t/g' recipes/windows_provision.rb
chef exec bundle install
chef exec gem install test-kitchen
chef exec bundle exec kitchen list'''
      }
    }
    stage('Kitchen verify') {
      steps {
        sh '''cd vsphere_testing
chef exec bundle exec kitchen test -c 2'''
      }
    }
    stage('chef-provisioning-vsphere create') {
        steps {
            parallel(
                     "Linux": {
                         sh  '''cd vsphere_testing
chef exec bundle exec chef-client -z recipes/linux_provision.rb'''
                             },
                     "Windows": {
                         sh '''cd vsphere_testing
chef exec bundle exec chef-client -z recipes/windows_provision.rb'''
                             }
                     )
                }
    }
    stage('chef-provisioning-vsphere delete') {
      steps {
        sh '''cd vsphere_testing
chef exec bundle exec chef-client -z recipes/destroy.rb
chef exec knife node delete testing-windows -y
chef exec knife client delete testing-windows -y'''
      }
    }
  }
}
