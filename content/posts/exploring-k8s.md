+++
date = '2021-07-21T15:22:01+03:00'
draft = true
title = 'Exploring Kubernetes'
tags = ["devops", "cloud native", "serverless", "programming", "technology"]
+++

With cloud native and microservice architectures gaining traction,
[Kubernetes](https://kubernetes.io/) (k8s) has become the standard tool for managing deployments.
But what is it, do I need it, and how do I most effectively get started with it?
That's what this post aims to clarify.

I'm no k8s expert. I've been picking it up because I'm interested in the devops
space and because I see the problem domain it solves in my daily work. I've
found the best way to learn something is to simply start working with it. 

In this series of posts I'll develop a basic expressjs server and use k8s to develop
locally and deploy it. We'll take it step-by-step.
After the first post we'll have an expressjs server running and be able to
deploy it via k8s to a development environment. In further posts we'll explore
local development, secret management, production clusters and stateful
components, like databases.

This post assumes a basic knowledge of building and working with containerized applications. Maybe you've played with them on a toy project, or maybe you're read a lot about them. Regardless you understand the basic concepts of Docker. 

## What is K8s & What Does it Solve?

k8s is a container orchestrator. It declaratively manages the configuration,     state, and deployments of a cluster of containerized applications. If
you've ever had to tell a client that you need to bring an app down for
maintenance, tried to do rolling updates, do A/B testing, scale your app, or
recover from your app going down then you understand the pain k8s solves.

With k8s you define the state you want (say three instances of your app), then
tell k8s that you want to deploy a new image. k8s handles terminating the
existing containers, starting up the new ones, while always keeping the
desired number of container instances running. k8s maintains this state, not
just when you explicitly update the application, but also when a container
terminates unexpectedly.

## Do You Need It?

If any of the following applies, you may want to explore k8s. Your app:

1. requires close to 100% up-time
1. has many users
1. has users who are very active at certain times, but not others
1. requires A/B testing

Like any framework, k8s adds complexity, and there's a learning curve. If
that's not appealing, then you could still containerize your app, run the image
on a VM, stop it when you need to update it, pull a new image from an image
repository, and restart the service.

Even if you don't need it, it may be worth exploring k8s because it's become
such a ubiquitous and influential tool in devops.

## Let's Go

We're going to take a quick tour of k8s basics by building a toy app. We'll
build an Expressjs server, containerize it and run it in a local k8s cluster.
The completed files from this tutorial are in [github](https://github.com/kahunacohen/hello-k8s/tree/1). A cluster (very simply) is
a group of "pods" running at least one container.

We will need the following tools:

1. Install [Docker Desktop](https://docs.docker.com/desktop/) if it's not already installed. Under
settings/preferences enable Kubernetes.
1. Install [minikube](https://minikube.sigs.k8s.io/docs/start), which allows you to run kubernetes locally.
1. Install [kubectl](https://kubernetes.io/docs/tasks/tools/), the CLI for k8s.
1. If you don't already have a docker hub account, [create one](https://app.docker.com/signup) now.

## The App

The server we'll build is just one route. Create a new directory called `hello-
k8s`. `cd` into it. Ensure you have a recent version of node installed locally, or
use [nvm](https://github.com/nvm-sh/nvm?tab=readme-ov-file#installing-and-updating) to install an isolated version of node. The latest stable version of
node will do. Once that's installed do:

```
$ npm init
...
$ npm install express --save
```
Now copy this JavaScript to a file called server.js in the root of the directory:

```javascript
const process = require("process");
const express = require("express");
const app = express();

app.get("/", (req, res) => {
res.send(`<h1>Kubernetes Expressjs Example</h2>
    <h2>Non-Secret Configuration Example</h2>
    <ul>
    <li>MY_NON_SECRET: "${process.env.MY_NON_SECRET}"</li>
    <li>MY_OTHER_NON_SECRET: "${process.env.MY_OTHER_NON_SECRET}"</li>
    </ul>
    `);
});
app.listen(3000, () => {
    console.log("Listening on http://localhost:3000");
});
```

Run: `$ node ./server.js` and go to http://localhost:3000 to ensure the
app runs. The "non secret" data should render as `undefined` for now.

## Containerize It

Now let's containerize our app. Create a dockerhub account if you don't have
one already. This is where we will pull and push images.

We'll create a Dockerfile at the root of the directory, which as you know, is a
declarative way to define how your app's image should be built:

```dockerfile
from node:14.17.3

RUN useradd -ms /bin/bash appuser && mkdir /code && chown -R appuser /code

COPY package.json /code/
WORKDIR /code
RUN npm install
COPY server.js /code/

USER appuser
CMD ["node", "server.js"]
```

Let's build it: `$ docker build -t {DOCKER_HUB_USERNAME}/hello-k8s`.

And now run it: `$ docker run -d -p 3000:3000
{DOCKER_HUB_USERNAME}/hello-k8s`. Go to http://localhost:3000, and you
should see the app running. Again, the non secrets will print out as null. Don't
worry about that for now.

Now let's stop the running container. Do `docker ps` to get its ID, and stop it: `$ docker stop {CONTAINER_ID}`.

## Pushing the Image
Because we don't want to have to build the image on target machines, once we
build the image we'll want to push the image to dockerhub. Let's now push the
image you created to your account: $ docker push
{DOCKER_HUB_USERNAME}/hello-k8s. You may have to run: `$ docker login` first.
Pushing the image the first time may take a while.

## Move to k8s

We could stop here and simply build/tag our image on something like an [Amazon EC2](https://aws.amazon.com/pm/ec2/?trk=3fc1271f-8d0f-43b5-b177-4fba4b680f8b&sc_channel=ps&ef_id=Cj0KCQjwxo_CBhDbARIsADWpDH6HdxXQhD4ak0eJJAqCVN5eFLT5_7EWFqYI4bspQOmFkVx02Rx6ZzAaAkTzEALw_wcB:G:s&s_kwcid=AL!4422!3!645125292218!e!!g!!amazon%20ec2!19574556935!145779863272&gad_campaignid=19574556935&gbraid=0AAAAADjHtp9rnwJ4i4jv-vPFXc2FdsLHV&gclid=Cj0KCQjwxo_CBhDbARIsADWpDH6HdxXQhD4ak0eJJAqCVN5eFLT5_7EWFqYI4bspQOmFkVx02Rx6ZzAaAkTzEALw_wcB) or [Google Compute Engine](https://cloud.google.com/products/compute?_gl=1*1gb9n3w*_up*MQ..&gclid=Cj0KCQjwxo_CBhDbARIsADWpDH73h2HXq_uswMYE6nBopvStj3Em3itgoHrm-QA-BVKFcFmVEPlrvvQaAmjnEALw_wcB&gclsrc=aw.ds) instance by SSHing in, pulling the latest image down and running docker commands to start up the container. However, there are some major disadvantages to this workflow:

1. A lot of manual steps
2. App downtime while you are bringing it down and spinning it up again
3. This won't work easily if you want to scale your app to multiple machines

So, let's use k8s to spin up a few instances of our container. But first some
quick k8s basics.

## k8s Architecture

Let's discuss a few major k8s concepts, including  objects. k8s  is modular and is composed of units such as a "cluster".

A cluster, for example, is a group of machines (called nodes--which are another kind of object) that work together to run your application. Each node can run multiple pods (again, another object).

Pods are the smallest deployable units in k8s. Each pod can run one or more containers
(like Docker containers). Think of a node as a physical or virtual machine, and pods as
the applications running on that machine. The cluster also includes a control plane,
which manages and coordinates all the pods to ensure they're running as desired.

Other k8s objects include (but aren't limited to):

- deployments
- services
- secrets
- jobs

We can use kubectl to interact with our cluster, which is a CLI for
communicating via the cluster's API. Setting up an on-premise k8s cluster is
complex; it's usually only done when there's a specific requirement to run on
premise, perhaps for security reasons. It's usually much easier to run a local
cluster for development/testing/CI using a tool like Docker Desktop,
minikube, kind etc. The local k8s cluster tool you choose depends on your
requirements. For this post we are using [minikube](https://minikube.sigs.k8s.io/docs/). In production most people
will use a turn-key solution, like [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine?hl=en) (GKE).


We can create objects imperatively using kubectl, or declaratively with yaml
files (manifests). The advantage of a declarative configuration is we can commit these manifests to source
control and thus the cluster is reprodicible/auditable.

## Creating a Deployment

We could create the pods that will run our express app directly, but usually we write a higher level deployment manifest that
describes how to deploy pods. The pods' spec are handled by the
deployment manifest, so we don't have to define the pods separately.
Let's start up minikube, which creates a local cluster:

```
$ minikube start
minikube v1.22.0 on Darwin 11.2.3
Using the docker driver based on existing profile
Starting control plane node minikube in cluster minikube
Pulling base image ...
docker "minikube" container is missing, will recreate.
Creating docker container (CPUs=2, Memory=1987MB) ...
Preparing Kubernetes v1.21.2 on Docker 20.10.7 ...
Verifying Kubernetes components...
Using image kubernetesui/dashboard:v2.1.0
Using image gcr.io/k8s-minikube/storage-provisioner:v5
Using image kubernetesui/metrics-scraper:v1.0.4
Enabled addons: storage-provisioner, default-storageclass, dashboard
Done! kubectl is now configured to use "minikube" cluster and "default" name
```

> An important word about minikube: There are many ways to run local
> k8s clusters. The simplest way is to use docker desktop and enable
> kubernetes. That works for very simple clusters. For this series we are using
> minikube because it allows us to use a LoadBalancer and it is more
> appropriate for things like managing encrypted data.

Minikube runs inside its own VM so we must connect kubectl to minikube so
we can see images we created in minikube's context.

To do this run:

```
$ eval $(minikube docker-env)
```

This works because minikube docker-env prints out the env vars needed to connect kubectl, but
you must evaluate them in the active terminal session for this to work.

Now ensure the k8s context is set to minikube. This ensures we are using our local
cluster created by docker-desktop:

```
$ kubectl config get-contexts
CURRENT NAME CLUSTER AUTHINFO NAMESPACE

docker-desktop docker-desktop docker-desktop
kind-mycluster kind-mycluster kind-mycluster

* minikube minikube minikube default
```

Your terminal output will likely be different than mine. If minikube is not set
as your context, then do:

```
$ kubectl config use-context minikube
Switched to context "minikube".
```

Now create a `manifests` directory (just to keep things organized) and create
the file: `manifests/web-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-pod
  template:
    metadata:
      labels:
        app: web-pod
    spec:
      containers:
        - name: web
          image: kahunacohen/hello-k8s
          ports:
            - containerPort: 3000
              protocol: TCP

```

Now use kubectl to create the deployment using the manifest:

```
$ kubectl create -f manifests/web-deployment.yaml`
deployment.apps/web-deployment created
```

In essence, the deployment object is a wrapper for two lower level objects, pods
and ReplicaSets, which you *could* create separately. In our case the
deployment object we created implicitly creates two pods and a ReplicaSet.
The ReplicaSet's job is to maintain a set of replica pods.

Now that we created our deployment, we can list the pods:

```
$ kubectl get pods
web-deployment-5bb9d846b6-m5nvk 1/1 Running 0 2m23s
web-deployment-5bb9d846b6-rv2kt 1/1 Running 0 2m23s
```

This tells us there are two pods, which are owned by web-deployment. If we
inspect one of them we should see our container (among other details):

```
$ kubectl inspect pods web-deployment-5bb9d846b6-m5nvk
...
Containers:
    web:
        Container ID: docker://c5e24583fa6942f8d4f791281bbf756d06add13d55f52115a
        Image: kahunacohen/hello-k8s
        Image ID: docker-pullable://kahunacohen/hello-kube@sha256:25b2e36992
        Port: 3000/TCP
...
```

We can exec into the pod, just like we would using docker. Here, we are `ls`ing the `/code` directory:

```
$ kubectl exec --stdin --tty web-deployment-5bb9d846b6-m5nvk -- /bin/bash
root@web-deployment-5bb9d846b6-m5nvk:/code# ls code
node_modules package-lock.json package.json server.js
```

## Creating a Service
Great, now how do we view our app? Currently the nodes are exposed inside
the cluster at ephemeral IPs. We need a service object, which is a k8s object
that abstracts exposing a set of pods on the host network. Create `manifests/web-service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  type: NodePort
  selector:
    app: web-pod
  ports:
    - port: 80
      targetPort: 3000
      protocol: TCP
      name: http
```

and then:

```
$ kubectl create -f manifests/web-service.yaml
```

and finally:

```
$ kubectl get services
NAME TYPE CLUSTER-IP EXTERNAL-IP PORT(S) AGE
kubernetes ClusterIP 10.96.0.1 <none> 443/TCP 10d
web-service NodePort 10.107.232.55 <none> 80:30543/TCP 76s
```

You can find a deeper explanation of the service manifest [here](https://kubernetes.io/docs/concepts/services-networking/service/). The `NodePort` type is one of several options including:

1. `ClusterIP`: useful for exposing pods internally within the cluster.
2. `LoadBalancer`: useful in a production environment, such as AWS or GCE.

The `NodePort` type we are using is mostly used in development. It forwards
requests from outside the cluster to inside and is randomly chooses from a range of ports. The important thing to note is this sequence of requests this service allows. In our case a request comes in to our docker desktop cluster at:

1. localhost:30543 ...which forwards requests to:
2. ...our service to an internal IP at port 80. The service selects pods as per the
spec and forwards to:
3. IP:3000, where our container is running.

This tells us that the NodePort 30543 on localhost is forwarding to port 80,
where are service is. So if we go to: http://localhost:30543, we should see
our express app. Except we don't! If we were using docker desktop as our local
cluster, we could, but minikube is a bit more complex in that it more closely
resembles a production cluster (it allows load balancers etc.). With minikube
we have one more bit of redirection to do to see our app because we have to tunnel
into its VM. Do:

```
$ minikube service web-service
```

This should tunnel in and open up a tab where the app renders.

## Bring Down a Pod
Let's test the `ReplicaSet` that the deployment implicitly created by killing a
pod and see what happens:

```
$ kubectl get pods
web-deployment-fdc6dddb7-9vb9s 1/1 Running 0 5h18m
web-deployment-fdc6dddb7-tnhzd 1/1 Running 0 5h18m
```

Indeed, two pods are running. Kill one:

```
$ kubectl delete pods web-deployment-fdc6dddb7-9vb9s
```

We can see the pod we killed is in the process of terminating, and there's a
new pod already running to take its place. That's the `ReplicaSet` in action,
maintaining the desired state of the cluster. Now a bit later we'll see the pod
we killed is gone, replaced entirely by a new one:

```
kubectl get pods
web-deployment-fdc6dddb7-n4pf8 1/1 Running 0 2m27s
web-deployment-fdc6dddb7-tnhzd 1/1 Running 0 5h22m
```

## Non-sensitive Run-time Data

A great place to keep non-sensitive, run-time configuration is in
environment variables. Traditionally we've set them when the OS starts
up, perhaps in a .env file deployed along with the app.
It's important to understand the security implications of environment variables.
While setting sensitive data in environment variables may be more secure
than hard-coding them in source code, it's still bad practice because they are
easily leaked via logs. Third-party dependencies could read them and
"phone home." We'll discuss managing sensitive data later, but just
know that for now we are only going to store non-sensitive data in
environment variables for our run-time configuration.

If you wanted to set env vars for our project, you could explicitly create a pod
manifest file and set them there. A better way is to use the `ConfigMap`
object. This decouples your configuration from your pods/images and allows them to be more easily re-
used.

Create a web-configmap.yaml file and put it in manifests:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: web-configmap
  namespace: default
data:
  MY_NON_SECRET: foo
  MY_OTHER_NON_SECRET: bar
```

Now do:

```
$ kubectl create -f manifests/web-configmap.yaml
configmap/web-configmap created
$ kubectl describe configmap web-configmap
Name: web-configmap
Namespace: default
Labels: <none>
Annotations: <none>

Data
====
MY_NON_SECRET:
----
foo
MY_OTHER_NON_SECRET:
----
bar
Events: <none>
```

Now our config data is created as just another k8s object. There are
several ways to consume this data from our pods, one of which is via env vars.
Let's add the envFrom block to our web-deployment.yaml to map the pod to the
configmap:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-pod
  template:
    metadata:
      labels:
        app: web-pod
    spec:
      containers:
        - name: web
          image: kahunacohen/hello-k8s
          envFrom:
            - configMapRef:
                name: web-configmap
          ports:
            - containerPort: 3000
              protocol: TCP
```

Then do:

```
kubectl replace -f manifests/web-deployment.yaml
deployment.apps/web-deployment replaced
```

Here we use the replace command to update the deployment in-place. There is no service
outage because, even while k8s updates the deployment, it always maintains
the desired state of two pods running. If you check the pods with `kubectl get
pods` you can see how the state of the cluster changes until the new pods are
running and the old ones are terminated.

Now when you go to `localhost:{NodePort}` you should see:

```
MY_NON_SECRET: "foo"
MY_OTHER_NON_SECRET: "bar"
```

## Jobs

A job is another useful k8s object

Jobs are created like any other object in k8s. Every job is run in a new pod,
and they stick around. You can customize how many pods are kept etc. in the
manifest.

Let's try it. Let's create a specific kind of job, `CronJob`: Create `manifests/print-hello.yaml`:


```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: print-hello
spec:
  schedule: "*/5 * * * *"
  successfulJobsHistoryLimit: 2
  failedJobsHistoryLimit: 2
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: print-hello
              image: kahunacohen/hello-kube:latest
              imagePullPolicy: IfNotPresent
              command:
                - /bin/sh
                - -c
                - date; echo Hello from the Kubernetes cluster
          restartPolicy: OnFailure
```

This will create a pod every 5 minutes, printing out the date and the message
as specified in the command block. It will only keep the two most recent pods--
the rest will be destroyed.

Let's activate it:

```
$ kubectl create -f manifests/print-hello.yaml
$
$ kubectl get jobs
NAME COMPLETIONS DURATION AGE
hello-27114520 1/1 9s 80s
```

We can see a pod was created for this job:

```
$ kubectl get pods
NAME READY STATUS RESTA
hello-27114520-4wnmf 0/1 Completed 0
web-deployment-65b8bccdfd-bb54g 1/1 Running 1 18h
web-deployment-65b8bccdfd-mfwx8 1/1 Running 1 18h
```

And we can ask the pod for logs so we can see the output:

```
$ kubectl logs hello-27114520-4wnmf
Wed Jul 21 12:40:09 UTC 2021
Hello from the Kubernetes cluster
```

Very cool!

## Updating App Code
When we updated the deployment with the `ConfigMap` we saw that there was
no down-time. k8s maintained the desired state of the pods. Once the
deployment was replaced, the config variables became defined and were
rendered.

But how do we actually update the app, not just the deployment? A few things
trigger k8s to redeploy your actual app. The main way we trigger this is by
setting a new image via kubectl's `set image` command. The workflow is:

1. Make a change to your app code.
2. Rebuild a new image, tagging it with a new version.
3. Push both the newly tagged image to an image repo.
4. Call `kubectl set image` to set the deployment to the new image.

Let's see this in detail:

1. In `server.js`, change the header "Kubernetes Expressjs Example" to
"Kubernetes Expressjs Example 123". If you go to localhost:
{NODE_PORT}, you won't see your change because the deployment is still
using the last image built.
2. Now, build a new image and tag it:
`$ docker build -t {DOCKER_HUB_USERNAME}}/hello-k8s:0.0.1`
3. Push the tag:
`docker push {DOCKER_HUB_USERNAME}/hello-k8s:0.0.1`
4. Now we need to set the existing deployment's image to the new tag: 0.0.1,
selecting the container labeled "web" to replace:

```
$ kubectl set image deployment/web-deployment web=kahunacohen/hello-k8s:0.0.1
deployment.apps/web-deployment image updated
```

Now if we do kubectl get pods we should see that k8s is resolving the current
state to the desired state, terminating the existing pods, while creating new
ones with the new container. After some time, you should be able to refresh
localhost:{NODE_PORT} and see your change.

The obvious problem in this development workflow is the manual steps and
the time it takes between when you make a change to application code and
when you can see the change. That is the topic of the next post.
