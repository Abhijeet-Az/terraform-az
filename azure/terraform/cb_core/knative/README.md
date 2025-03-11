# RabbitmqSource with Knative Service Sink

This guide explains how to set up `RabbitmqSource` as the source and a Knative service as the sink. This setup requires a secret for CloudAMQP credentials.

## Prerequisites

1. **Knative Serving and Eventing**: Ensure that Knative Serving and Eventing are already installed in your Kubernetes cluster. You can follow the [Knative installation guide](https://knative.dev/docs/install/) for detailed instructions.
2. **cloudamqp-secret**: Create a Kubernetes secret with your CloudAMQP credentials. The secret should include your `username`, `password`, `uri`, and `port`.

### Example Secret

Create a file named `cloudamqp-secret.yaml` with the following content:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: cloudamqp-secret
  namespace: knative-demo
stringData:
  username: kjwchfkn
  password: xxxx
  uri: "clam.rmq.cloudamqp.com"
  port: "5672"
```

```shell
kubectl apply -f cloudamqp-secret.yaml
```

### RabbitmqSource Configuration

```yaml
apiVersion: sources.knative.dev/v1alpha1
kind: RabbitmqSource
metadata:
  name: cloudamqp
  namespace: knative-demo
spec:
  rabbitmqClusterReference:
    connectionSecret:
      name: cloudamqp-secret
  rabbitmqResourcesConfig:
    vhost: kjwchfkn
    parallelism: 10 # Number of consumers
    exchangeName: "amq.default"
    queueName: "knative"
  sink:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: helloworld-go
```

#### Explanation

The RabbitmqSource custom resource is configured to read messages from a RabbitMQ queue and send them to a Knative service.

	•	rabbitmqClusterReference: Points to the secret containing the RabbitMQ connection details.
	•	rabbitmqResourcesConfig:
	•	vhost: The RabbitMQ virtual host to use.
	•	parallelism: The number of consumer instances to create.
	•	exchangeName: The RabbitMQ exchange name.
	•	queueName: The RabbitMQ queue name.
	•	sink: Specifies the Knative service (helloworld-go) that will receive the messages from the RabbitMQ queue.

### Reference

- [RabbitmqSource](https://knative.dev/docs/eventing/samples/rabbitmq-source/)
- [Knative Eventing](https://knative.dev/docs/eventing/)