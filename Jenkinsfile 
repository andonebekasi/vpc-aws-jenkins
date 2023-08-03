pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                // Clone the Git repository containing Terraform configurations
                git 'https://github.com/andonebekasi/vpc-aws-jenkins.git'
            }
        }

        stage('Validate Terraform') {
            steps {
                // Validate Terraform configurations
                sh 'terraform validate'
            }
        }

        stage('Initialize Terraform') {
            steps {
                // Initialize Terraform
                sh 'terraform init'
            }
        }

        stage('Plan') {
            steps {
                // Create Terraform execution plan
                sh 'terraform plan'
            }
        }

        stage('Approval') {
            // Optionally, add manual approval step
            // Use 'input' or integrate with your team's approval system
            steps {
                // Example using 'input'
                input 'Do you want to proceed with the changes?'
            }
        }

        stage('Apply') {
            steps {
                // Apply the changes and create the AWS VPC
                sh 'terraform apply -auto-approve'
            }
        }

        // Optionally, add a cleanup stage
        stage('Cleanup') {
            steps {
                // Destroy the AWS VPC
                sh 'terraform destroy -auto-approve'
            }
        }
    }

    post {
        // Cleanup workspace after the pipeline finishes
        always {
            cleanWs()
        }
    }
}
