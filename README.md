# DevOps Engineer Challenge

### **Take-Home Assignment**

## **Description**

With this exercise we want to see your ability to create an entire infrastructure from scratch as well as your skills as a system administrator.

Completing the task should take you anywhere from a couple of hours to up to a day depending on your level of expertise, available time to focus, and level of detail you consider sufficient.

That said, if it is taking you more than a day, you are probably spending more effort than necessary in some details. We expect that you submit your final work within one week of receiving the assignment, but please let us know if this is too short notice for you.

Please feel free to reach out and ask questions if you need any clarification.

## **Details**

This repository contains a NodeJS web server which:

- Listens on the port specified by the PORT env variable or 3000 by default.
- Contains a single endpoint: `GET / -> 200`

The repository also contains a static website that should be hosted.

## **Requirements**

As we said before, it can take you a couple of hours or a day.

- In your solution please emphasize on readability, maintainability and DevOps methodologies. We expect a clear way to recreate your setup.
- The infrastructure provider should be AWS.
- The AWS infrastructure should be built using IaC.
- It should run using security best practices.
- Should leverage community roles when it make sense.
- A clean bare minimum working infrastructure is preferred than a full blown solution pieced together with scissors, rope and duct tape. Do not skip security considerations.
- Dockerize the application.
- Create a simple CI/CD (Github Actions) pipeline which deploys the application on every commit to master.
- Make the logs searchable without ssh-ing into the server.

## **How to deliver**

1. Clone this repo and create a repo of your own (DO NOT FORK THIS REPO).
2. Deploy this Repo
3. Please document the repo and your code
4. On the README, explain your architecture, component design and development choices
5. On the README, A summary of what else you could/would like to have done if you had more time.
