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
                // Get EC2 public IP from Terraform
                def ec2_ip = sh(script: "terraform output -raw public_ip", returnStdout: true).trim()
                echo "✅ EC2 Public IP is: ${ec2_ip}"

                // Build inventory content
                def inventoryContent = """
[ec2]
ec2 ansible_host=${ec2_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${WORKSPACE}/id_rsa
"""

                // Ensure ansible dir exists
                sh "mkdir -p ${ANSIBLE_DIR}"

                // Write (overwrite) ansible/inventory.ini
                writeFile file: "${ANSIBLE_DIR}/inventory.ini", text: inventoryContent

                echo "✅ Updated ansible/inventory.ini with EC2 IP: ${ec2_ip}"
            }
                }
            }
        }

        stage('Check Ansible Ping') {
            steps {
               withCredentials([sshUserPrivateKey(credentialsId: 'abc-ssh', keyFileVariable: 'SSH_KEY', usernameVariable: 'SSH_USER')]) {
            sh '''
                ansible -i ~/ansible/inventory.ini ec2 -m ping \
                --private-key  /home/ubuntu/abc.pem \
                -u ${SSH_USER}
            '''
        }      
            }
        }
         stage('Run Ansible Playbook') {
            steps {
                 withCredentials([sshUserPrivateKey(credentialsId: 'abc-ssh', keyFileVariable: 'SSH_KEY', usernameVariable: 'SSH_USER')]) {
                sh '''
                ansible-playbook -i ~/ansible/inventory.ini ~/ansible/main.yml \
                --private-key  /home/ubuntu/abc.pem \
                -u ${SSH_USER}
                '''
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

