pipeline{
    agent any
  
    environment {
      DOCKER_TAG = getVersion()
      DOCKER_CRED= credentials('docker_hub_DSO')
    }

    stages{
        stage('SCM'){
            steps{
                 deleteDir()
                git 'https://github.com/Ameerbatcha/three-tier-architecture-demo.git'
            }
        }

          stage('Bundling') {
            steps {

                sh 'tar czf Bundle.tar.gz web'
            }
        }
        
            stage('Build and push Image') {
                steps {
                    
                    sh "echo ${DOCKER_TAG}"
                    
                    // Add your Docker build and push steps here
                            sshPublisher(publishers: [
            sshPublisherDesc(
                configName: 'worker1',
                transfers: [
                    sshTransfer(
                        cleanRemote: false,
                        excludes: '',
                        execCommand: """
                                        sudo su - ;
                                        cd /opt/docker; 
                                        tar -xf Bundle.tar.gz; 
                                        cd web;
                                        docker build . -t ameerbatcha/kubernetes:${DOCKER_TAG}
                                        docker push ameerbatcha/kubernetes:${DOCKER_TAG}
                                        """,
                        execTimeout: 200000000,
                        flatten: false,
                        makeEmptyDirs: false,
                        noDefaultExcludes: false,
                        patternSeparator: '[, ]+$',
                        remoteDirectory: '//opt//docker',
                        remoteDirectorySDF: false,
                        removePrefix: '',
                        sourceFiles: '**/*.gz'
                    )
                ],
                usePromotionTimestamp: false,
                useWorkspaceInPromotion: false,
                verbose: true
            )
        ])
                 
                //   script {
                   
                //     if (currentBuild.resultIsBetterOrEqualTo('SUCCESS')) {
                //         // Send success email to manager for approval
                //         sendApprovalEmail('SUCCESS')
                //     } else {
                //         // Send failure email to manager for previous build
                //         sendFailureEmail('FAILURE')
                //     }
                // }


            }
            }
          

        // stage('Kubenetes Deployment') {
        //     steps {
        //         script {
        //             def ansiblePlaybookContent = '''
        //             - hosts: worker2
        //               become: True

 

        //               tasks:
        //                 - name: Install python pip
        //                   yum:
        //                     name: python-pip
        //                     state: present

 

        //                 - name: Install docker-py python module
        //                   pip:
        //                     name: docker-py
        //                     state: present

 

        //                 - name: Start the container
        //                   docker_container:
        //                     name: nodecontainer
        //                     image: "thoshinny/angularapp:{{ DOCKER_TAG }}"
        //                     state: started
        //                     published_ports:
        //                       - 0.0.0.0:80:80
        //             '''

 

        //             writeFile(file: 'inline_playbook.yml', text: ansiblePlaybookContent)

 

        //            def ansibleInventoryContent = '''[dev]
        //             172.31.42.16 ansible_user=ec2-user
        //             '''

 

        //             writeFile(file: 'dev.inv', text: ansibleInventoryContent)

 

   
        //             ansiblePlaybook(
        //                 inventory: 'dev.inv',
        //                 playbook: 'inline_playbook.yml',
        //                 extras: "-e DOCKER_TAG=${DOCKER_TAG}",
        //                 credentialsId: 'dev-server',
        //                 installation: 'ansible',
        //                 disableHostKeyChecking: true,
        //             )

        //       }
        //     }
        // }

 

}

}

 

 

def getVersion(){
    def commitHash = sh label: '', returnStdout: true, script: 'git rev-parse --short HEAD'
    return commitHash
}

// def sendApprovalEmail(buildStatus) {
//     def previousCommit = sh(returnStdout: true, script: 'git rev-parse HEAD~1')
//     def currentCommit = sh(returnStdout: true, script: 'git rev-parse HEAD')
//     def changes = sh(script: 'git show --name-status HEAD^', returnStdout: true).trim()
//     def authorEmail = sh(script: 'git log -1 --format="%ae"', returnStdout: true).trim()

//     def mailSubject = "SUCCESS Notification - Approval Required for Docker Deployment - ${currentBuild.displayName}"
//     def gitDiffOutput = sh(script: "git diff HEAD~1 ${currentCommit}", returnStdout: true)
//     if (gitDiffOutput.isEmpty()) {
//         gitDiffOutput ="No changes found between commits."
//     }
//     // Combine 'changes' and 'gitDiffOutput' and write to 'changelog.txt'
//     def combinedContent = changes + "\n\n" + gitDiffOutput
//     writeFile(file: 'changelog.txt', text: combinedContent)



//     def approvalMail = """
//         Hi Team, <br><br>
//         The Build <b> ${env.BUILD_NUMBER} of ${env.JOB_NAME} has completed the docker build and need approval for deployment. </b> <br><br>
//          Commit ID: <b> ${env.GIT_COMMIT} </b> <br><br>
//          Previous Commit ID:  <b> ${previousCommit} </b> <br><br>
//          Docker tag:  <b> ${env.DOCKER_TAG} </b> <br><br>
//          Source Path:  <b> ${env.WORKSPACE} </b> <br><br>
//          Author:  <b> ${authorEmail} </b> <br><br>
//          Date:<b> ${env.BUILD_TIMESTAMP} </b> <br><br>
//          Build Result: <b> ${buildStatus} </b> <br><br>
//         Please review and approve or reject the deployment.
//     """

//     emailext (
//         subject: mailSubject,
//         body: approvalMail,
//         mimeType: 'text/html',
//         to: 'thoshaws04@gmail.com',
//         attachmentsPattern: 'changelog.txt'
//     )
//   timeout(time: 2, unit: 'MINUTES') {
//                   input message: 'Waiting for Manager Approval'                }
// }



