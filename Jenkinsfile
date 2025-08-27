pipeline {
  agent any
  environment {
    TF_DIR = 'terraform'
    ANSIBLE_DIR = 'ansible'
    INVENTORY_FILE = "${ANSIBLE_DIR}/inventory.ini"
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

    stage('Generate Inventory') {
            steps {
                dir("${TF_DIR}") {
                    script {
                        // Fetch EC2 public IP from Terraform output
                        def ec2_ip = sh(script: "terraform output -raw public_ip", returnStdout: true).trim()
                        
                        // Generate inventory.ini with expected format
                        def inventoryContent = """[ec2]
ec2 ansible_host=${ec2_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/abc.pem
"""
                        writeFile file: "${INVENTORY_FILE}", text: inventoryContent
                    }
                }
            }
        }

        stage('Check Ansible Ping') {
            steps {
                dir("${ANSIBLE_DIR}") {
                    sshagent(credentials: ['abc-ssh']) {
                        sh "ansible -i inventory.ini ec2 -m ping"
                    }
                }
            }
        }

        stage('Show Website URL') {
            steps {
                dir("${TF_DIR}") {
                    script {
                        def ec2_ip = sh(script: "terraform output -raw public_ip", returnStdout: true).trim()
                        echo "🚀 Your website is running at: http://${ec2_ip}"
                    }
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline finished ✅"
        }
    }
}

