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
                    sh """
                        echo '[ec2]' > ansible/inventory.ini
                        echo '${EC2_PUBLIC_IP} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa' >> ansible/inventory.ini
                    """
                    echo "Updated ansible/inventory.ini with EC2 IP: ${EC2_PUBLIC_IP}"
                }
                }
            }
        }

        stage('Check Ansible Ping') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'abc-ssh', keyFileVariable: 'SSH_KEY', usernameVariable: 'SSH_USER')]) {
                    sh '''
                        ansible -i ansible/inventory.ini ec2 -m ping \
                        --private-key ${WORKSPACE}/id_rsa \
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

