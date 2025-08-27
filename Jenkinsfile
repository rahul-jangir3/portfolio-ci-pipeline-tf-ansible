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

                        // Minimal inventory (only host + group)
                        def inventoryContent = """[ec2]
${ec2_ip}
"""
                        writeFile file: "${INVENTORY_FILE}", text: inventoryContent
                        echo "✅ Inventory generated:\n${inventoryContent}"
                    }
                }
            }
        }

        stage('Check Ansible Ping') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'abc-ssh', keyFileVariable: 'SSH_KEY')]) {
                sh "ansible -i inventory.ini ec2 -m ping --private-key $SSH_KEY -u ubuntu"
               }
            }
        }
    }  // <-- closes stages

    post {
        always {
            echo "Pipeline finished ✅"
        }
    }
}  // <-- closes pipeline

