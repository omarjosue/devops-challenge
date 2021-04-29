# DevOps Engineer Challenge

## **Project Structure**

- api                      > source code
- app                      > static resources
- runtime-evidence         > proof of the local runtime execution
- terraform                > terraform recipes for aws provider (IaaC)
- terraform/modules        > aws resources for each module defined into the main recipe
- terraform/templates/ecs/ > configuration files for ECS task definition
- Dockerfile               > building artifact for Dockerizing the application

## **Architecture**

Through the devops.evacenter.com domain the traffic is redirected to a cloudfront component, which then it resends the traffic to a public load balancer (ALB) in the port 80. The ALB balances the requests to 2 fargate instances (containers) on port 3000, in which our nodeJS app is listening. Only the required ports are allowed through security group rules. The app logs will be stored in CloudWatch.

If I had more time I'd have defined the necessary aws resources with its variables into the modules directory. I'd also have created the pipeline in AWS (CodePipeline) for deploying the service on every change to the main branch at Github.

## **Setting up the infrastructure:**

terraform init && terraform plan && terraform apply -auto-approve

## **Building the image locally:**

docker build -t devops-challenge .

## **Running the container locally:**

docker run -it -p 3000:3000 --rm --name devops-challenge-app devops-challenge

### **Original Requirements**

1. Clone this repo and create a repo of your own (DO NOT FORK THIS REPO).
2. Deploy this Repo
3. Please document the repo and your code
4. On the README, explain your architecture, component design and development choices
5. On the README, A summary of what else you could/would like to have done if you had more time.
6. The infrastructure provider should be AWS.
7. The AWS infrastructure should be built using IaC.
8. It should run using security best practices.
9. Should leverage community roles when it make sense.
10 A clean bare minimum working infrastructure is preferred than a full blown solution pieced together with scissors, rope and duct tape. Do not skip security considerations.
11. Dockerize the application.
12. Create a simple CI/CD (Github Actions) pipeline which deploys the application on every commit to master.

