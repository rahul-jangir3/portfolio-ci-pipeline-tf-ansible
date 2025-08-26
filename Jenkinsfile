pipeline {
  agent any
  environment {
    TF_DIR = 'terraform'
    ANSIBLE_DIR = 'ansible'
  }
  stages {
    stage('Checkout pipeline repo') {
      steps {
        checkout scm
      }
    }

    stage('Terraform Init & Apply') {
      steps {
        withCredentials([
          usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')
        ]) {
          sh '''
            export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
            export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
            cd ${TF_DIR}
            terraform init -input=false
            terraform apply -auto-approve -input=false
          '''
        }
      }
    }

    stage('Prepare Ansible Inventory') {
      steps {
        // Read terraform outputs and write inventory.ini in workspace root (group: ec2)
        script {
          def public_ip = sh(script: "terraform -chdir=terraform output -raw public_ip", returnStdout: true).trim()
          def public_dns = sh(script: "terraform -chdir=terraform output -raw public_dns", returnStdout: true).trim()
          if (!public_ip) {
            error "Failed to get public_ip from terraform outputs"
          }
          echo "Terraform instance IP: ${public_ip}"
          // write inventory.ini (overwrites existing); keep it minimal to avoid parsing errors
          sh """
            cat > inventory.ini <<EOF
[ec2]
${public_ip} ansible_user=ubuntu
EOF
            ls -la inventory.ini
            cat inventory.ini
          """
          // expose values for next stage
          env.INSTANCE_IP = public_ip
          env.INSTANCE_DNS = public_dns
        }
      }
    }

    stage('Run Ansible Playbook') {
      steps {
        // Bind SSH private key credential and run ansible against inventory.ini group ec2
        withCredentials([sshUserPrivateKey(credentialsId: 'abc-ssh', keyFileVariable: 'SSH_KEY', usernameVariable: 'SSH_USER')]) {
          sh '''
            # make key only readable
            chmod 600 ${SSH_KEY} || true
            echo "Using SSH key: ${SSH_KEY}, user: ${SSH_USER}"
            # Run ansible (main.yml at repo root). Limit to group ec2.
            ansible-playbook -i inventory.ini -l ec2 main.yml --private-key ${SSH_KEY} -e ansible_python_interpreter=/usr/bin/python3 -v
          '''
        }
      }
    }

    stage('Show site URL') {
      steps {
        script {
          def dns = sh(script: "terraform -chdir=${TF_DIR} output -raw public_dns", returnStdout: true).trim()
          echo "✅ Your site should be live at: http://${dns}"
        }
      }
    }
  }
  post {
    failure {
      echo "Pipeline failed — check Terraform and Ansible logs above."
    }
  }
}

